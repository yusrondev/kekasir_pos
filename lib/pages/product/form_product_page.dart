import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/apis/api_service_type_price.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/label_price.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:logger/web.dart';

class FormProductPage extends StatefulWidget {
  final Product? product;
  const FormProductPage({super.key, this.product});

  @override
  State<FormProductPage> createState() => _FormProductPageState();
}

class DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    double dashWidth = 3, dashSpace = 3;
    Path path = Path()..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), Radius.circular(10)));

    Path dashPath = Path();
    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        Path extractPath = pathMetric.extractPath(distance, distance + dashWidth);
        dashPath.addPath(extractPath, Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class _FormProductPageState extends State<FormProductPage> {
  final _formKey = GlobalKey<FormState>();

  // controllers field
  TextEditingController nameController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController costController = TextEditingController();
  TextEditingController shortDescriptionController = TextEditingController();
  TextEditingController quantity = TextEditingController();
  TextEditingController description = TextEditingController();
  TextEditingController labelPrice = TextEditingController();
  TextEditingController typePrice = TextEditingController();

  final ScrollController mainListView= ScrollController();

  ApiServiceTypePrice apiServiceTypePrice = ApiServiceTypePrice();

  File? _image;
  String? urlImage;
  ApiService apiService = ApiService();
  String labelStock = "Sesuaikan Stok";
  String wordingPrice = "Harga Jual Produk (Normal)*";
  String descStock= "Tentukan jumlah stok pertama untuk produk ini";
  bool isEdit = false;
  String? selectedValue;
  int availableStock = 0;
  bool hasBeenChange = false;
  bool _listPrice = false;
  bool isEditedPrice = false;
  int productId = 0;
  String? storeQuantity = "Masukkan harga...";
  String? _selectedName = "-";
  String? _oldValueType;

  List<LabelPrice> labelPrices = [];

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

        fetchLabelPrice(widget.product!.id);
      });
    }else{
      fetchLabelPrice(productId);
    }

    quantity.addListener(() {
      String? wording = "";
      if (quantity.text != "") {
        wording = "Total harga beli dari ${quantity.text} pcs...";
      }else{
        wording = "Masukkan harga...";
      }

      setState(() {
        storeQuantity = wording;
      });
    });

    priceController.addListener(() {
      setState(() {
        if (_selectedName != "-") {
          isEditedPrice = true; 
        }
      });
    });
  }

  @override
  void dispose() {
    priceController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    if (mainListView.hasClients) {
      mainListView.animateTo(
        mainListView.position.maxScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
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

  Future<void> showDialogAddPriceType() async {
    labelPrice.text = "";
    showDialog(
      context: context, 
      barrierColor: Colors.black.withValues(alpha: 0.4), // Atur tingkat 
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            clipBehavior: Clip.hardEdge,
            backgroundColor: Colors.white,
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: "Tipe Harga",
                  controller: labelPrice,
                  placeholder: "Misalnya Harga Reseller...",
                  border: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ButtonPrimary(
                        onPressed: () => saveLabel(),
                        text: "+ Tambahkan",
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }

  Future<void> saveLabel() async {
    if (labelPrice.text == "") {
      DialogHelper.customDialog(
        context: context,
        onConfirm: () {},
        content: "Pastikan nama tipe sudah terisi!",
        actionButton: false,
      );
      return;
    }

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
    
    try {
      String? error = await apiServiceTypePrice.updateLabelPrice(labelPrice.text, productId.toString());
      
      if (error == null) {
        if (mounted) { // Pastikan widget masih terpasang
          setState(() {
            labelPrice.text = "";
          });
          Navigator.pop(context);
          Navigator.pop(context);
          fetchLabelPrice(productId);
        }
      } else {
        if (mounted) { // Pastikan widget masih te
          Navigator.pop(context);
          showErrorBottomSheetCustom(context, error);
        }
      }

    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        showErrorBottomSheetCustom(context, e.toString());
      }
    }
  }

  Future<void> updateTypePrice() async {
    if (priceController.text == "") {
      DialogHelper.customDialog(
        context: context,
        onConfirm: () {},
        content: "Pastikan harga jual sudah terisi!",
        actionButton: false,
      );
      return;
    }

    String priceValue = _cleanCurrency(priceController.text);

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
    
    try {
      String? error = await apiServiceTypePrice.updateTypePrice(priceValue, _selectedName.toString(), productId);
      
      if (error == null) {
        if (mounted) { // Pastikan widget masih terpasang
          Navigator.pop(context);
          alertLottie(context, 'Berhasil memperbarui harga!');
          fetchLabelPrice(productId);
          if (productId != 0) {
            priceController.text = formatRupiah(widget.product!.price);
          }
          setState(() {
            isEditedPrice = false;
            _selectedName = "-";
            wordingPrice = "Harga Jual Produk (Normal)*";
          });
        }
      } else {
        if (mounted) { // Pastikan widget masih te
          showErrorBottomSheetCustom(context, error);
        }
      }

    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        showErrorBottomSheetCustom(context, e.toString());
      }
    }
  }

  Future<void> fetchLabelPrice(productId) async {
    final data = await apiServiceTypePrice.fetchLabelPrice(productId);

    if (mounted) { // Cek apakah widget masih ada sebelum setState
      setState(() {
        labelPrices = data;
      });

      Logger().d(labelPrices);
    }
  }

  Future<void> saveProduct() async {
    if (_formKey.currentState!.validate()) {
      bool success;

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

      if (quantity.text.isEmpty && isEdit == false) {
        Navigator.pop(context, true);
        alertLottie(context, 'Pastikan jumlah stok sudah terisi!', 'info');
        return;
      }    

      String priceValue = _cleanCurrency(priceController.text);
      String costValue = _cleanCurrency(costController.text);

      if (nameController.text == "") {
        Navigator.pop(context, true);
        alertLottie(context, 'Pastikan nama produk sudah terisi!', 'info');
        return;
      }

      if (priceController.text == "") {
        Navigator.pop(context, true);
        alertLottie(context, 'Pastikan harga produk sudah terisi!', 'info');
        return;
      }      

      if (costController.text == "" && selectedValue.toString() == "Masuk") {
        Navigator.pop(context, true);
        alertLottie(context, 'Pastikan harga beli sudah terisi!', 'info');
        return;
      }      

      if (costController.text == "" && isEdit == false) {
        Navigator.pop(context, true);
        alertLottie(context, 'Pastikan harga beli sudah terisi!', 'info');
        return;
      }      

      int? parsedQuantity = int.tryParse(quantity.text);
      if (parsedQuantity == 0 && selectedValue.toString().isNotEmpty) {
        Navigator.pop(context, true);
        alertLottie(context, 'Pastikan jumlah stok tidak 0!', 'info');
        return;
      }

      if (quantity.text == "" && selectedValue.toString() != "null") {
        Navigator.pop(context, true);
        alertLottie(context, 'Pastikan jumlah stok sudah terisi!', 'info');
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
          costValue,
          description.text
        );
      } else {
        int? parsedQuantity = int.tryParse(quantity.text);
        if (selectedValue.toString() == "Keluar" && parsedQuantity != null && parsedQuantity > availableStock) {
          Navigator.pop(context, true);
          alertLottie(context, 'Jumlah melebihi stok yang tersedia!', 'info');
          return;
        }

        if (quantity.text.isNotEmpty && selectedValue == null) {
          Navigator.pop(context, true);
          alertLottie(context, 'Pastikan tipe penyesuaian sudah terpilih!', 'info');
          return;
        }

        if (selectedValue.toString() == "Masuk" || selectedValue.toString() == "Keluar") {
          if (quantity.text == "") {
            Navigator.pop(context, true);
            alertLottie(context, 'Pastikan jumlah stok produk sudah terisi!', 'info');
            return;
          }
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
          costValue,
          description.text
        );
      }

      if (success == true) {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
        // ignore: use_build_context_synchronously
        alertLottie(context, 'Berhasil memperbarui produk!');
      } else {
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
        // ignore: use_build_context_synchronously
        alertLottie(context, 'Ada yang salah...', 'error');
        return;
      }
    }
  }  

  deleteTypePrice(String id) async {
    try {
      await apiServiceTypePrice.deleteTypePrice(id);
      if (mounted) {
        setState(() {
          fetchLabelPrice(productId);
          Navigator.pop(context);
          alertLottie(context, "Berhasil menghapus tipe harga!");
        });
      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  Future<void> updateNameType(String id) async {
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
    
    try {
      String? error = await apiServiceTypePrice.updateNameType(id, typePrice.text);
      
      if (error == null) {
        if (mounted) { // Pastikan widget masih terpasang
          Navigator.pop(context);
          alertLottie(context, 'Berhasil memperbarui nama tipe!');
          fetchLabelPrice(productId);
          if (productId != 0) {
            priceController.text = formatRupiah(widget.product!.price);
          }
          setState(() {
            isEditedPrice = false;
            _selectedName = "-";
            wordingPrice = "Harga Jual Produk (Normal)*";
          });
        }
      } else {
        if (mounted) { // Pastikan widget masih te
          showErrorBottomSheetCustom(context, error);
        }
      }

    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        showErrorBottomSheetCustom(context, e.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar:true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(0), // Ukuran AppBar jadi 0
          child: AppBar(
            backgroundColor: primaryColor, // Warna status bar
            elevation: 0, // Hilangkan bayangan
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarColor: primaryColor, // Warna status bar
              statusBarIconBrightness: Brightness.light, // Ikon status bar terang
            ),
          ),
        ),
        backgroundColor: Colors.white,
        body: Form(
          key: _formKey,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 45, left: 14, right: 14), 
                child: PageTitle(text: widget.product == null ? "Tambah Produk" : "Edit Produk - ${widget.product!.name.length > 10 ? '${widget.product?.name.substring(0, 10)}...' : widget.product?.name } ", back: true),
              ),
              Gap(10),
              Expanded(
                child: ListView(
                  controller: mainListView,
                  padding: EdgeInsets.only(bottom: 45, left: 14, right: 14), 
                  children: [
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
                      border: true,
                      controller: nameController,
                      label: "Nama *",
                      placeholder: "Misalnya Snack...",
                      maxLine: 1,
                    ),
                    CustomTextField(
                      border: true,
                      controller: shortDescriptionController,
                      label: "Deskripsi Singkat",
                      placeholder: "Misalnya Varian Pedas Banget (tidak wajib)...",
                      maxLine: 4,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: PriceField(
                            controller: priceController,
                            label: wordingPrice,
                            shortDescription: "Harga per pcs",
                            placeholder: "Misalnya 10.000...",
                            maxLine: 1,
                            border: true,
                          ),
                        ),
                        Gap(10),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (_selectedName != "-" && isEditedPrice == true) {
                                updateTypePrice();
                              }else{
                                if (_listPrice == false) {
                                  _listPrice = true;
                                }else{
                                  _listPrice = false;
                                  _selectedName = "-";
                                  wordingPrice = "Harga Jual Produk (Normal)*";
                                  if (productId != 0) {
                                    priceController.text = formatRupiah(widget.product!.price);
                                    setState(() {
                                      isEditedPrice = false;
                                    });
                                  }else{
                                    priceController.text = "";
                                    setState(() {
                                      isEditedPrice = false;
                                    });
                                  }
                                }
                              }
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(top: 20),
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isEditedPrice == true ? primaryColor :ligthSky,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: isEditedPrice == true ? primaryColor :secondaryColor)
                            ),
                            child: Icon( isEditedPrice == true ? Icons.check : _listPrice == true ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded , color: isEditedPrice == true ? Colors.white : primaryColor,),
                          ),
                        )
                      ],
                    ),
                    if(_listPrice == true) ... [
                      if(labelPrices.isNotEmpty) ... [
                        LabelSemiBold(text: "Daftar Tipe Harga"),
                        ShortDesc(text: 'Harga produk akan otomatis mengikuti sesuai transaksi'),
                        Gap(5),
                      ],
                      ListView.builder(
                        padding: EdgeInsets.all(0),
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: labelPrices.length,
                        itemBuilder: (context, index){
                          final labelPrice = labelPrices[index];
                          bool isSelected = _selectedName == labelPrice.name; 
                
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (_selectedName == labelPrice.name) {
                                  _selectedName = "-";
                                  wordingPrice = "Harga Jual Produk (Normal)*";
                                  if (productId != 0) {
                                    priceController.text = formatRupiah(widget.product!.price);
                                    setState(() {
                                      isEditedPrice = false;
                                    });
                                  }else{
                                    priceController.text = "";
                                    setState(() {
                                      isEditedPrice = false;
                                    });
                                  }
                                }else{
                                  _selectedName = labelPrice.name;
                                  priceController.text = formatRupiah(labelPrice.price);
                                  isEditedPrice = false;
                                  wordingPrice = "Harga Jual Produk (${toBeginningOfSentenceCase(_selectedName)})*";
                                }
                              });
                            },
                            onLongPress: () {
                              setState(() {
                                typePrice.text = labelPrice.name ?? "";
                                _oldValueType = labelPrice.id.toString();
                
                                // default
                                if (_selectedName == labelPrice.name) {
                                  if (productId != 0) {
                                    priceController.text = formatRupiah(widget.product!.price);
                                    setState(() {
                                      isEditedPrice = false;
                                    });
                                  }else{
                                    priceController.text = "";
                                    setState(() {
                                      isEditedPrice = false;
                                    });
                                  }
                                }else{
                                  _selectedName = labelPrice.name;
                                  priceController.text = formatRupiah(labelPrice.price);
                                  isEditedPrice = false;
                                  wordingPrice = "Harga Jual Produk (${toBeginningOfSentenceCase(_selectedName)})*";
                                }
                              });
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    clipBehavior: Clip.hardEdge,
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomTextField(
                                          label: "Sesuaikan tipe : ${labelPrice.name}",
                                          shortDescription: "Anda dapat menghapus / merubah tipe harga ini",
                                          controller: typePrice,
                                          maxLength: 100,
                                          border: true,
                                          placeholder: "Misalnya Reseller...",
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  DialogHelper.customDialog(context: context, onConfirm: () => deleteTypePrice(_oldValueType!), title: "Yakin menghapus tipe ${labelPrice.name}?", content: "Tipe harga ini akan dihapus untuk semua produk.", actionButton: true);
                                                },
                                                child: ButtonDangerOutline(
                                                  text: "Hapus",
                                                ),
                                              )
                                            ),
                                            Gap(5),
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  if (_selectedName != typePrice.text) {
                                                    Navigator.pop(context);
                                                    DialogHelper.customDialog(context: context, onConfirm: () => updateNameType(_oldValueType!), title: "Yakin merubah tipe ${labelPrice.name}?", content: "Anda akan melakukan perubahan nama dari $_selectedName menjadi ${typePrice.text}", actionButton: true);
                                                  }
                                                },
                                                child: ButtonPrimary(
                                                  text: "Simpan",
                                                ),
                                              )
                                            ),
                                          ],
                                        ),
                                        Gap(10),
                                        Center(
                                          child: ShortDesc(text: "Klik bagian luar untuk keluar"),
                                        )
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 5),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isSelected == true ? bgSuccess : ligthSky,
                                border: Border.all(color: isSelected == true ? successColor : secondaryColor),
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(toBeginningOfSentenceCase(labelPrice.name) ?? "", style: TextStyle(fontWeight: FontWeight.w600, color: isSelected == true ? successColor : Colors.black)),
                                  Row(
                                    children: [
                                      labelPrice.productId == 0 ? Text("Belum diatur", style: TextStyle(color: isSelected == true ? successColor : softBlack),) : Text(formatRupiah(labelPrice.price), style: TextStyle(fontWeight: FontWeight.w600, color: isSelected == true ? successColor : Colors.black)),
                                      if (isSelected) ... [
                                        Gap(5),
                                        Icon(Icons.check_circle, size: 15, color: successColor),
                                      ]
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        }
                      ),
                      CustomPaint(
                        painter: DashedBorderPainter(),
                        child: GestureDetector(
                          onTap: () => showDialogAddPriceType(),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 5),
                            padding: EdgeInsets.only(top: 10, bottom: 6),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Center(child: Text("+ Tambah Tipe Harga", style: TextStyle(fontWeight: FontWeight.w600))))),
                      ),
                    ],
                    // adjust stock
                    Gap(5),
                    LineSM(),
                    Gap(5),
                    LabelSemiBold(text: labelStock),
                    ShortDesc(text: descStock, maxline: 2,),
                    
                    if(isEdit == true) ... [
                      Gap(10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/stock-detail', arguments: widget.product);
                        },
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: availableStock > 5 ? bgSuccess : bgDanger,
                            border: Border.all(color: availableStock > 5 ? successColor : dangerColor),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                availableStock == 0 ? "Produk ini telah habis" : "Tersisa $availableStock pcs untuk produk ini",
                                style: TextStyle(
                                  color: availableStock > 5 ? successColor : dangerColor,
                                  fontWeight: FontWeight.w600
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: availableStock > 5 ? successColor : dangerColor,
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: Text("Mutasi" , style: TextStyle(
                                  color: Colors.white
                                )),
                              )
                            ],
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
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              scrollToBottom();
                            });
                          });
                        },
                      ),
                    ],
                    isEdit == false ? Gap(10) : Gap(0),
                    if(isEdit == false || selectedValue != null) ... [
                      CustomTextFieldNumber(
                        controller: quantity,
                        label: "Jumlah Stok *",
                        placeholder: "Misalnya 20...",
                        maxLength: 5,
                        border: true,
                      ),
                      if(selectedValue.toString() == "Masuk" || isEdit == false) ... [
                        PriceField(
                          controller: costController,
                          label: "Total Harga Beli *",
                          placeholder: "$storeQuantity",
                          maxLine: 1,
                          border: true,
                        ),
                      ],
                      CustomTextField(
                        border: true,
                        maxLine: 3,
                        maxLength: 150,
                        controller: description,
                        label: "Deskripsi",
                        placeholder: "Misalnya karena barang rusak / stok awal (tidak wajib)",
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: GestureDetector(
          onTap: () {
            if (nameController.text == "") {
              alertLottie(context, 'Pastikan nama produk sudah terisi!', 'info');
              return;
            }

            if (priceController.text == "") {
              alertLottie(context, 'Pastikan harga produk sudah terisi!', 'info');
              return;
            }

            if (_selectedName != "-") {
              setState(() {
                _selectedName = "-";
                if (productId != 0) {
                  priceController.text = formatRupiah(widget.product!.price);
                }
              });
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