import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_cart.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
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
  ApiServiceTransaction apiServiceTransaction = ApiServiceTransaction();

  List<CartItem> cartItems = [];

  TextEditingController nominalCustomer = TextEditingController();

  String grandTotal = "Rp 0";
  int totalItem = 0;
  bool isLoader = true;
  bool transactionProccess = false;

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

  Future<void> saveTransaction() async {
    try {
      final paid = nominalCustomer.text.replaceAll(RegExp(r'[^0-9]'), '');
      final gt = grandTotal.replaceAll(RegExp(r'[^0-9]'), '');

      final paidNominal = int.tryParse(paid) ?? 0; // Konversi ke int, jika gagal jadi 0
      final gtFinal = int.tryParse(gt) ?? 0; // Konversi ke int, jika gagal jadi 0

      if (paidNominal < gtFinal) { 
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Nominal pembayaran harus lebih dari grand total!")),
          );
        }
        return; // Hentikan proses jika paid tidak valid
      }

      transactionProccess = true;
      Navigator.pop(context);
      final transactionData = await ApiServiceTransaction().saveTransaction(paid);

      setState(() {
        transactionProccess = false;
      });

      if (context.mounted) {
        Navigator.pushNamed(context, '/nota', arguments: transactionData);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        // Kembalikan data saat pengguna swipe back
        Navigator.pop(context, true);
        return true; // Izinkan navigasi ke belakang
      },
      child: Scaffold(
        // backgroundColor: ligthSky,
        body: isLoader == true ?
          Center(child: CustomLoader.showCustomLoader()) : cartItems.isEmpty ? Center(
            child: LabelSemiBold(text: "Hemmm, belum ada item nih...",),
          ) : transactionProccess == true ? Center(child: CustomLoader.showCustomLoader()) : ListView(
          padding: defaultPadding,
          children: [
            PageTitle(text: "Checkout", back: true),
            Column(
              children: [
                Gap(15),
                buildListCart(),
                buildPayment(),
                Gap(10),
                buildPaymentMethod(),
              ],
            )
          ],
        ),
        bottomNavigationBar: buildFinishTransaction(screenHeight),
      ),
    );
  }

  Widget buildListCart() {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10, right: 10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ligthSky,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelSemiBoldMD(text: "Daftar Pesanan"),
          Gap(5),
          ListView.builder(
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final cartItem = cartItems[index];
      
              return Container(
                margin: EdgeInsets.only(bottom: 5),
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: secondaryColor.withValues(alpha: 0.4), width: 1),
                  borderRadius: BorderRadius.circular(10)
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
                    SizedBox(
                      width: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabelSemiBold(text: cartItem.productName),
                          ShortDesc(text: cartItem.productShortDescription,),
                          LabelSemiBold(text: cartItem.unitPrice),
                        ],
                      ),
                    ),
                    Gap(5),
                    SizedBox( // Ganti Expanded dengan SizedBox untuk jumlah item
                      child: Align(
                        alignment: Alignment.topRight,
                        child: LabelSemiBoldMD(
                          text: '${cartItem.quantity}x'
                        ),
                      ),
                    ),
                    Gap(25),
                    Expanded( // Pastikan subtotal punya lebar tetap
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
        ],
      ),
    );
  }

  Widget buildPayment() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ligthSky,
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelSemiBoldMD(text: "Ringkasan Pembayaran"),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Sub Total",),
              LabelSemiBoldMD(text: grandTotal),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Diskon",),
              LabelSemiBoldMD(text: "- Rp 0"),
            ],
          ),
          Line(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LabelSemiBold(text: 'Grand Total'),
              LabelSemiBoldMD(text: grandTotal, primary: true,),
            ],
          )
        ],
      ),
    );
  }

  Widget buildFinishTransaction(screenHeight) {
    return isLoader == false && transactionProccess != true ? Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
      child: InkWell(
        onTap: () {
          cartItems.isEmpty ? Navigator.pop(context, true) : 
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Tambahkan ini!
            backgroundColor: secondaryColor,
            builder: (context) {
              return FractionallySizedBox(
                heightFactor: 0.8, // Mengatur tinggi menjadi full screen
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: 5,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Color(0xffced6e0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Gap(30),
                      Align(
                        alignment: Alignment.topLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Grand Total',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              grandTotal,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Gap(5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 200,
                            child: PriceField(
                              label: "Nominal Pelanggan",
                              controller: nominalCustomer,
                              placeholder: "Nominal...",
                            ),
                          ),
                          Gap(10),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(top: 15),
                              padding: EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: primaryColor,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () {
                                  saveTransaction();
                                },
                                child: Text(
                                  "Bayar",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      LabelSemiBold(text: "Nominal Pecahan"),
                      Gap(10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                nominalCustomer.text = grandTotal;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: bgSuccess,
                                borderRadius: BorderRadius.circular(5)
                              ),
                              child: Center(
                                child: Text("Uang Pas", style: TextStyle(
                                  color: successColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                                )),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                nominalCustomer.text = 'Rp 5.000';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: bgSuccess,
                                borderRadius: BorderRadius.circular(5)
                              ),
                              child: Center(
                                child: Text("Rp 5.000", style: TextStyle(
                                  color: successColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                                )),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                nominalCustomer.text = 'Rp 10.000';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: bgSuccess,
                                borderRadius: BorderRadius.circular(5)
                              ),
                              child: Center(
                                child: Text("Rp 10.000", style: TextStyle(
                                  color: successColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                                )),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {
                                nominalCustomer.text = 'Rp 15.000';
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: bgSuccess,
                                borderRadius: BorderRadius.circular(5)
                              ),
                              child: Center(
                                child: Text("Rp 15.000", style: TextStyle(
                                  color: successColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600
                                )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
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
    ) : SizedBox.shrink();
  }

  Widget buildPaymentMethod() {
    return transactionProccess != true ?
       Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ligthSky,
          borderRadius: BorderRadius.circular(10)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LabelSemiBoldMD(text: "Metode Pembayaran"),
            ShortDesc(text: "Pilih salah satu metode"),
            Gap(5),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: secondaryColor.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 35,
                        height: 35,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: lightColor,
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/cash.png',
                            width: 23,
                          )
                        ),
                      ),
                      Gap(10),
                      LabelSemiBold(text: "Tunai",)
                    ],
                  ),
                  Container(
                    width: 25,
                    height: 25,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: bgSuccess,
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Center(
                      child: Icon(Icons.check, size: 15, color: successColor,)
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: secondaryColor,
                border: Border.all(color: secondaryColor.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Row(
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: lightColor,
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/qr-code.png',
                        width: 18,
                      )
                    ),
                  ),
                  Gap(10),
                  LabelSemiBold(text: "QRIS",)
                ],
              ),
            )
          ],
        ),
      ) : SizedBox.shrink();
    }
}