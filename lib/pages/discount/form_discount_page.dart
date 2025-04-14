import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_promo.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';

class FormDiscountPage extends StatefulWidget {
  final Product? product;
  const FormDiscountPage({super.key, this.product});

  @override
  State<FormDiscountPage> createState() => _FormDiscountPageState();
}

class _FormDiscountPageState extends State<FormDiscountPage> {
  ApiServicePromo apiServicePromo = ApiServicePromo();

  TextEditingController nominalController = TextEditingController();
  TextEditingController persentaseController = TextEditingController();
  
  String? selectedValueTipeDiscount = "Nominal";

  @override
  void initState() {
    super.initState();
    persentaseController.addListener(() {
      String value = persentaseController.text;
      if (value.isNotEmpty) {
        int? number = int.tryParse(value);
        if (number != null && number > 100) {
          if (persentaseController.text != "100") {
            persentaseController.text = "100";
            persentaseController.selection = TextSelection.fromPosition(
              TextPosition(offset: persentaseController.text.length),
            );
          }
        }
      }
    });
  }

  Future<void> updatePromo(int productId) async {

    String originPrice = formatRupiah(widget.product!.price);
    String originPriceFinal = _cleanCurrency(originPrice);

    String originNominal = _cleanCurrency(nominalController.text);

    int? parseOriginPriceFinal = int.tryParse(originPriceFinal);
    int? parseIntNominal = int.tryParse(originNominal);
    
    if (parseIntNominal != null && parseOriginPriceFinal != null && parseIntNominal > parseOriginPriceFinal) {
      DialogHelper.customDialog(
        context: context,
        onConfirm: () {},
        content: "Nominal tidak boleh melebihi harga produk!",
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

    final store = await ApiServicePromo().updatePromo(productId, persentaseController.text, originNominal);
    
    if (store == true) {
      if (mounted) {
        Navigator.pop(context, true);
        Navigator.pop(context, true);
      }
      alertLottie(context, "Berhasil menyimpan diskon!");
    }else{
      alertLottie(context, "Opps ada yang salah!", 'error');
    }
  }

  String _cleanCurrency(String value) {
    return value.replaceAll(RegExp(r'[^0-9]'), ''); // Menghapus Rp, titik, dan karakter non-angka lainnya
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
      body: ListView(
        padding: defaultPadding,
        children: [
          PageTitle(text: "Sesuaikan Promo - ${widget.product!.name.length > 10 ? '${widget.product?.name.substring(0, 10)}...' : widget.product?.name } ", back: true),
          Gap(15),
          buildForm()
        ],
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        child: GestureDetector(
          onTap: () {
            DialogHelper.showCreateConfirmation(context: context, onConfirm: () => updatePromo(widget.product!.id));
          },
          child: ButtonPrimary(
            text: "Simpan",
          ),
        ),
      ),
    );
  }

  Widget buildForm(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Harga Produk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatRupiah(widget.product!.price),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: primaryColor
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              decoration: BoxDecoration(
                color: secondaryColor
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Potongan Diskon',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatRupiah(widget.product!.nominalDiscount),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: dangerColor
                  ),
                ),
              ],
            ),
            Container(
              width: 1,
              height: 40,
              decoration: BoxDecoration(
                color: secondaryColor
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Harga Akhir',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatRupiah(widget.product!.price - widget.product!.nominalDiscount),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: successColor
                  ),
                ),
              ],
            )
          ],
        ),
        Gap(5),
        LineSM(),
        Gap(5),
        Container(
          padding: EdgeInsets.all(10),
          width: double.infinity,
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: primaryColor)
          ),
          child: Center(
            child: Text("Promo ini berlaku untuk setiap satuan (per satu item).", style: TextStyle(
                color: primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w600
              )
            ),
          ),
        ),
        Gap(10),
        LabelSemiBold(text: "Pilih satu tipe"),
        ShortDesc(text: "Anda dapat memilih salah satu tipe untuk dijadikan acuan promo",),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Radio<String>(
                    activeColor: primaryColor,
                    value: "Nominal",
                    groupValue: selectedValueTipeDiscount,
                    onChanged: (value) {
                      setState(() {
                        selectedValueTipeDiscount = value;
                        nominalController.text = "";
                        persentaseController.text = "";
                      });
                    },
                  ),
                  Text("Nominal"),
                ],
              ),
            ),
            Expanded(
              child: Row(
                children: [
                  Radio<String>(
                    activeColor: primaryColor,
                    value: "Persentase",
                    groupValue: selectedValueTipeDiscount,
                    onChanged: (value) {
                      setState(() {
                        selectedValueTipeDiscount = value;
                        nominalController.text = "";
                        persentaseController.text = "";
                      });
                    },
                  ),
                  Text("Persentse"),
                ],
              ),
            ),
          ],
        ),

        if(selectedValueTipeDiscount == "Nominal") ... [
          PriceField(
            label: "Nominal Diskon",
            shortDescription: "Dalam Rupiah",
            controller: nominalController,
            border: true,
          ),
        ],

        if(selectedValueTipeDiscount == "Persentase") ... [
          CustomTextFieldNumber(
            label: "Persentase Diskon",
            shortDescription: "Dalam Persen %",
            controller: persentaseController,
            border: true,
          ),
        ],
      ],
    );
  }
}