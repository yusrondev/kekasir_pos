import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:logger/logger.dart';

class FormProductPage extends StatefulWidget {
  final Product? product;
  const FormProductPage({super.key, this.product});

  @override
  State<FormProductPage> createState() => _FormProductPageState();
}

class _FormProductPageState extends State<FormProductPage> {
  final _formKey = GlobalKey<FormState>();

  // controllers field
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController shortDescriptionController = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController description = TextEditingController();

  File? _image;
  String? urlImage;
  ApiService apiService = ApiService();
  String labelStock = "Sesuaikan Stok";
  String descStock= "Tentukan jumlah stok pertama untuk produk ini";
  bool isEdit = false;
  String? selectedValue;
  int availableStock = 0;
  bool hasBeenChange = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!.name;
      priceController.text = formatRupiah(widget.product!.price);
      shortDescriptionController.text = widget.product!.shortDescription;
      urlImage = widget.product!.image;
      setState(() {
        isEdit = true;
        availableStock = widget.product!.availableStock;
        labelStock = "Butuh Penyesuaian Stok?";
        descStock = "Tujuan penyesuaian stok Mengetahui selisih persediaan barang yang sebenarnya";
      });
    }
  }
  
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Sesuaikan Ukuran',
            toolbarColor: primaryColor,
            toolbarWidgetColor: Colors.white,
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
          IOSUiSettings(
            title: 'Sesuaikan Ukuran',
            aspectRatioPresets: [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
            ],
          ),
          WebUiSettings(
            // ignore: use_build_context_synchronously
            context: context,
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          urlImage = null;
          _image = File(croppedFile.path);
          hasBeenChange = true;
        });
      }
    }
  }

  String _cleanCurrency(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), ''); // Menghapus Rp, titik, dan karakter non-angka lainnya
  }

  Future<void> saveProduct() async {
    if (_formKey.currentState!.validate()) {
      bool success;

      String priceValue = _cleanCurrency(priceController.text);

      if (nameController.text == "") {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pastikan nama produk sudah terisi!')));
        return;
      }

      // Tampilkan Lottie loading animation
      showDialog(
        context: context,
        barrierDismissible: false,  // Mencegah dialog ditutup tanpa proses selesai
        barrierColor: Colors.white.withValues(alpha: 0.8),
        builder: (BuildContext context) {
          return Center(
            child: CustomLoader.showCustomLoader()
          );
        },
      );

      if (widget.product == null) {
        // Jika produk baru, buat produk
        success = await apiService.createProduct(
          nameController.text,
          priceValue,
          _image,
          shortDescriptionController.text,
          "Masuk",
          quantity.text,
          description.text
        );
      } else {
        int? parsedQuantity = int.tryParse(quantity.text);
        if (selectedValue.toString() == "Keluar" && parsedQuantity != null && parsedQuantity > availableStock) {
          Navigator.pop(context); 
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Jumlah melebihi stok yang tersedia!')));
          return;
        }
        // Jika produk sudah ada, update produk
        success = await apiService.updateProduct(
          widget.product!.id, // ID produk yang akan diupdate
          nameController.text,
          priceValue,
          _image,
          shortDescriptionController.text,
          selectedValue.toString(),
          quantity.text,
          description.text
        );
      }

      Navigator.pop(context); 

      if (success == true) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to create product')));
      }
    }
  }  

  @override
  Widget build(BuildContext context) {
    Logger().d(urlImage);
    return Scaffold(
        body: Form(
          key: _formKey,
          child: ListView(
            padding: defaultPadding,
            children: [
              PageTitle(text: widget.product == null ? "Tambah Produk" : "Edit Produk", back: true),
              Gap(20),
              Column(
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: Row(
                      children: [
                        _image == null ? Gap(0) : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_image!)
                        ),
                        if(urlImage != null) ... [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(urlImage ?? "")
                          ),
                        ],
                        if(hasBeenChange == false && urlImage == null) ... [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset("assets/images/empty.png")
                          ),
                        ]
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        icon: Icon(Icons.camera, color: primaryColor,),
                        label: Text('Kamera', style: TextStyle(color: primaryColor),),
                        onPressed: () => pickImage(ImageSource.camera),
                      ),
                      TextButton.icon(
                        icon: Icon(Icons.image, color: primaryColor,),
                        label: Text('Gallery', style: TextStyle(color: primaryColor),),
                        onPressed: () => pickImage(ImageSource.gallery),
                      ),
                    ],
                  )
                ],
              ),
              CustomTextField(
                controller: nameController,
                label: "Nama",
                placeholder: "Misalnya Snack...",
              ),
              CustomTextField(
                controller: shortDescriptionController,
                label: "Deskripsi Singkat",
                placeholder: "Misalnya Varian Pedas Banget (Opsional)...",
                maxLine: 4,
              ),
              PriceField(
                controller: priceController,
                label: "Harga",
                placeholder: "Misalnya 10.000...",
              ),
              // adjust stock
              Line(),
              LabelSemiBold(text: labelStock),
              ShortDesc(text: descStock, maxline: 2,),
              
              if(isEdit == true) ... [
                Gap(10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: availableStock > 5 ? bgSuccess : bgDanger,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(
                    child: Text(
                      "Tersisa $availableStock untuk produk ini ${availableStock < 5 ? '(Hampir Habis)' : ''}",
                      style: TextStyle(
                        color: availableStock > 5 ? successColor : dangerColor,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                  ),
                ),
                Gap(10),
                CustomDropdownField(
                  shortDescription: "Sesuaikan untuk tipe stok masuk atau keluar",
                  label: "Tipe",
                  hint: "Pilih salah satu",
                  items: ["Masuk", "Keluar"],
                  selectedValue: selectedValue,
                  onChanged: (newValue) {
                    setState(() {
                      selectedValue = newValue;
                    });
                  },
                ),
              ],
              isEdit == false ? Gap(10) : Gap(0),
              CustomTextFieldNumber(
                controller: quantity,
                label: "Jumlah",
                shortDescription: "Jumlah penyesuaian stok",
                placeholder: "Misalnya 20...",
              ),
              CustomTextField(
                maxLine: 3,
                controller: description,
                label: "Deskripsi",
                placeholder: "Misalnya karena barang rusak (Opsional)",
              )
            ],
          ),
        ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: InkWell(
          onTap: () {
            DialogHelper.showCreateConfirmation(context: context, onConfirm: () => saveProduct());
          },
          child: ButtonPrimary(
            text: "Simpan",
          ),
        ),
      ),
    );
  }
}