import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_cart.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/cart_summary.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';

class CheckoutTransactionPage extends StatefulWidget {
  const CheckoutTransactionPage({super.key});

  @override
  State<CheckoutTransactionPage> createState() => _CheckoutTransactionPageState();
}

class _CheckoutTransactionPageState extends State<CheckoutTransactionPage> {
  ApiServiceCart apiServiceCart = ApiServiceCart();
  List<CartItem> cartItems = [];

  TextEditingController nominalCustomer = TextEditingController();

  String grandTotal = "Rp 0";
  int totalItem = 0;
  bool isLoader = true;

  @override
  void initState() {
    super.initState();
    fetchCart();
  }

  Future<void> fetchCart() async {
    await Future.delayed(Duration(milliseconds: 300)); // Tambahkan delay untuk memastikan data siap

    final fetchCartSummary = await ApiServiceCart().fetchCartSummary();

    if (mounted) {
      setState(() {
        grandTotal = fetchCartSummary.totalPrice;
        totalItem = fetchCartSummary.totalQuantity;
        cartItems = fetchCartSummary.items;
        isLoader = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoader == true ?
        Center(child: CustomLoader.showCustomLoader()) : cartItems.isEmpty ? Center(
          child: LabelSemiBold(text: "Hemmm, belum ada item nih...",),
        ) : ListView(
        padding: defaultPadding,
        children: [
          PageTitle(text: "Checkout", back: true),
          Gap(15),
          buildListCart(),
          Gap(15),
          buildPayment()
        ],
      ),
      bottomNavigationBar: buildFinishTransaction(),
    );
  }

  Widget buildListCart() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];

              return Container(
                margin: EdgeInsets.only(bottom: 5),
                padding: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: darkColor)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        cartItem.productImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/empty.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.fitWidth,
                          );
                        },
                      ),
                    ),
                    Gap(10),
                    Expanded( // Expanded membungkus Column untuk mengisi sisa ruang
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabelSemiBoldMD(text: cartItem.productName),
                          ShortDesc(text: cartItem.productShortDescription, maxline: 2),
                          LabelSemiBoldMD(text: cartItem.unitPrice),
                        ],
                      ),
                    ),
                    SizedBox(width: 50, // Ganti Expanded dengan SizedBox untuk jumlah item
                      child: Align(
                        alignment: Alignment.topRight,
                        child: LabelSemiBoldMD(
                          text: '${cartItem.quantity}x',
                        ),
                      ),
                    ),
                    SizedBox(width: 100, // Pastikan subtotal punya lebar tetap
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: LabelSemiBoldMD(text: cartItem.subtotal),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LabelSemiBoldMD(text: "Total Bayar"),
              LabelSemiBoldMD(text: grandTotal),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildPayment() {
    return Column(
      children: [
        PriceField(
          controller: nominalCustomer,
          label: "Nominal Bayar",
          placeholder: "Masukkan Nominal...",
        )
      ],
    );
  }

  Widget buildFinishTransaction() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: InkWell(
        onTap: () {
          cartItems.isEmpty ? Navigator.pop(context) : DialogHelper.showCreateConfirmation(context: context, onConfirm: () => {});
        },
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Text(
            cartItems.isEmpty ? "Kembali" : "Selesaikan Pembayaran",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600
            ),
          )
        ),
      ),
    ); 
  }
}