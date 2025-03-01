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
import 'package:kekasir/helpers/snackbar_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

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
  int productId = 0;

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
        productId = widget.product!.id;
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
        showErrorSnackbar(context, 'Pastikan nama produk sudah terisi!');
        return;
      }

      if (priceController.text == "") {
        showErrorSnackbar(context, 'Pastikan harga produk sudah terisi!');
        return;
      }      

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
          showErrorSnackbar(context, 'Jumlah melebihi stok yang tersedia!');
          return;
        }

        if (quantity.text.isNotEmpty && selectedValue == null) {
          showErrorSnackbar(context, 'Pastikan tipe penyesuaian sudah terpilih!');
          return;
        }

        if (selectedValue.toString() == "Masuk" || selectedValue.toString() == "Keluar") {
          if (quantity.text == "") {
            showErrorSnackbar(context, 'Pastikan jumlah stok produk sudah terisi!');
            return;
          }
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

      if (success == true) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      } else {
        // ignore: use_build_context_synchronously
        showErrorSnackbar(context, 'Ada yang salah...');
      }
    }
  }  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Form(
          key: _formKey,
          child: ListView(
            padding: defaultPadding,
            children: [
              PageTitle(text: widget.product == null ? "Tambah Produk" : "Edit Produk", back: true),
              Gap(10),
              Column(
                children: [
                  SizedBox(
                    width: 170,
                    height: 170,
                    child: Row(
                      children: [
                        _image == null ? Gap(0) : ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(_image!, 
                            width: 170,
                            height: 155,
                            fit: BoxFit.fitWidth
                          )
                        ),
                        if(urlImage != null) ... [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              urlImage ?? "",
                              width: 170,
                              height: 155,
                              fit: BoxFit.fitWidth,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/empty.png', 
                                  width: 170,
                                  height: 155,
                                  fit: BoxFit.fitWidth
                                );
                              },
                            )
                          ),
                        ],
                        if(hasBeenChange == false && urlImage == null) ... [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset("assets/images/empty.png",
                              width: 170,
                              height: 155,
                              fit: BoxFit.fitWidth
                            )
                          ),
                        ]
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 125,
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: ligthSky,
                        border: Border.all(color: secondaryColor),
                        borderRadius: BorderRadius.circular(20)
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              border: Border.all(color: secondaryColor)
                            ),
                            child: IconButton(
                              icon: Icon(Icons.camera_alt_rounded, color: Color(0xff747d8c), size: 20,),
                              onPressed: () => pickImage(ImageSource.camera),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              border: Border.all(color: secondaryColor)
                            ),
                            child: IconButton(
                              icon: Icon(Icons.image_rounded, color: Color(0xff747d8c), size: 20,),
                              onPressed: () => pickImage(ImageSource.gallery),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              CustomTextField(
                controller: nameController,
                label: "Nama *",
                placeholder: "Misalnya Snack...",
                maxLine: 1,
              ),
              CustomTextField(
                controller: shortDescriptionController,
                label: "Deskripsi Singkat",
                placeholder: "Misalnya Varian Pedas Banget (Tidak Wajib)...",
                maxLine: 4,
              ),
              PriceField(
                controller: priceController,
                label: "Harga *",
                placeholder: "Misalnya 10.000...",
                maxLine: 1,
              ),
              // adjust stock
              LineSM(),
              Gap(5),
              LabelSemiBold(text: labelStock),
              ShortDesc(text: descStock, maxline: 2,),
              
              if(isEdit == true) ... [
                Gap(10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: availableStock > 5 ? bgSuccess : bgDanger,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: availableStock > 5 ?successColor : dangerColor, width: 0.7)
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Tersisa $availableStock untuk produk ini",
                        style: TextStyle(
                          color: availableStock > 5 ? successColor : dangerColor,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/stock-detail', arguments: productId);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: availableStock > 5 ? successColor : dangerColor,
                            borderRadius: BorderRadius.circular(5)
                          ),
                          child: Text("Mutasi" , style: TextStyle(
                            color: Colors.white
                          )),
                        ),
                      )
                    ],
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
                maxLength: 5,
              ),
              CustomTextField(
                maxLine: 3,
                maxLength: 150,
                controller: description,
                label: "Deskripsi",
                placeholder: "Misalnya karena barang rusak / stok awal (Tidak Wajib)",
              )
            ],
          ),
        ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: GestureDetector(
          onTap: () {
            if (nameController.text == "") {
              showErrorSnackbar(context, 'Pastikan nama produk sudah terisi!');
              return;
            }

            if (priceController.text == "") {
              showErrorSnackbar(context, 'Pastikan harga produk sudah terisi!');
              return;
            }
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