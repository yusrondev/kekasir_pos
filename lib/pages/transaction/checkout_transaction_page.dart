import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/apis/api_service_cart.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/helpers/snackbar_helper.dart';
import 'package:kekasir/models/cart_summary.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';

class CheckoutTransactionPage extends StatefulWidget {
  const CheckoutTransactionPage({super.key});

  @override
  State<CheckoutTransactionPage> createState() =>
      _CheckoutTransactionPageState();
}

class _CheckoutTransactionPageState extends State<CheckoutTransactionPage> {
  ApiServiceCart apiServiceCart = ApiServiceCart();
  ApiServiceTransaction apiServiceTransaction = ApiServiceTransaction();

  List<CartItem> cartItems = [];
  BuildContext? _dialogContext;

  TextEditingController nominalCustomer = TextEditingController();

  String grandTotal = "Rp 0";
  int totalItem = 0;
  bool isLoader = true;
  bool transactionProccess = false;

  int selectedIndex = -1;
  String selectedName = "";

  final List<String> nominalList = [
    "Uang Pas",
    "Rp 5.000",
    "Rp 10.000",
    "Rp 20.000",
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments as String;
      setState(() {
        selectedName = args; // Simpan ke dalam state
      });
      fetchCart(); // Panggil fetchCart setelah mendapatkan selectedName
    });
  }

  Future<void> fetchCart() async {
    await Future.delayed(
      Duration(milliseconds: 300),
    ); // Tambahkan delay untuk memastikan data siap
    final fetchCartSummary = await ApiServiceCart().fetchCartSummary(selectedName);
    try {
      if (mounted) {
        setState(() {
          grandTotal = fetchCartSummary.totalPrice;
          totalItem = fetchCartSummary.totalQuantity;
          cartItems = fetchCartSummary.items;
          isLoader = false;
        });
      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.white.withOpacity(0.8),
      builder: (BuildContext dialogContext) {
        _dialogContext = dialogContext; // Simpan context dari dialog yang aktif
        return Align(
          alignment: Alignment.center,
          child: Material( // Tambahkan Material agar terlihat jelas
            color: Colors.transparent,
            child: SizedBox(
              width: 150,
              height: 150,
              child: CustomLoader.showCustomLoader(),
            ),
          ),
        );
      },
    );
  }

  void closeLoadingDialog() {
    if (mounted) {
      if (_dialogContext != null) {
        Navigator.pop(_dialogContext!);
        _dialogContext = null; // Reset setelah ditutup
      } 
    }
  }

  Future<void> saveTransaction() async {
    try {
      final paid = nominalCustomer.text.replaceAll(RegExp(r'[^0-9]'), '');
      final gt = grandTotal.replaceAll(RegExp(r'[^0-9]'), '');

      final paidNominal =
          int.tryParse(paid) ?? 0; // Konversi ke int, jika gagal jadi 0
      final gtFinal =
          int.tryParse(gt) ?? 0; // Konversi ke int, jika gagal jadi 0

      if (paidNominal < gtFinal) {
        if (context.mounted) {
          closeLoadingDialog();
          DialogHelper.customDialog(
            context: context,
            onConfirm: () {},
            content: "Nominal pembayaran harus lebih dari grand total!",
            actionButton: false,
          );
        }
        return;
      }

      transactionProccess = true;
      Navigator.pop(context);
      final transactionData = await ApiServiceTransaction().saveTransaction(
        paid, selectedName
      );

      setState(() {
        transactionProccess = false;
      });

      if (context.mounted) {
        closeLoadingDialog();
        Navigator.pushNamed(context, '/nota', arguments: transactionData);
      }
    } catch (e) {
      if (context.mounted) {
        showErrorSnackbar(context, e.toString());
      }
    }
  }

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  String _formatCurrency(String value) {
    if (value.isEmpty) return '';
    final number = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return _currencyFormat.format(number);
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async {
        // Kembalikan data saat pengguna swipe back
        Navigator.pop(context, true);
        return true; // Izinkan navigasi ke belakang
      },
      child: Scaffold(
        // backgroundColor: ligthSky,
        body:
            isLoader == true
                ? Center(child: CustomLoader.showCustomLoader())
                : cartItems.isEmpty
                ? Center(
                  child: LabelSemiBold(text: "Hemmm, belum ada item nih..."),
                )
                : transactionProccess == true
                ? Center(child: CustomLoader.showCustomLoader())
                : ListView(
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
                    ),
                  ],
                ),
        bottomNavigationBar: buildFinishTransaction(screenHeight, screenWidth),
      ),
    );
  }

  Widget buildListCart() {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10, right: 10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ligthSky,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: secondaryColor)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LabelSemiBoldMD(text: "Daftar Pesanan"),
              if(selectedName != "") ... [
                WarningTag(text: "*Menggunakan harga : ${toBeginningOfSentenceCase(selectedName)}",)
              ]
            ],
          ),
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
                  border: Border.all(
                    color: secondaryColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
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
                          Label(text: cartItem.productName),
                          if (cartItem.productShortDescription != "") ...[
                            ShortDesc(text: cartItem.productShortDescription),
                          ] else ...[
                            Gap(2),
                          ],
                          Label(text: cartItem.unitPrice),
                        ],
                      ),
                    ),
                    Gap(5),
                    SizedBox(
                      // Ganti Expanded dengan SizedBox untuk jumlah item
                      child: Align(
                        alignment: Alignment.topRight,
                        child: LabelSemiBold(text: '${cartItem.quantity}x'),
                      ),
                    ),
                    Gap(25),
                    Expanded(
                      // Pastikan subtotal punya lebar tetap
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: LabelSemiBold(text: cartItem.subtotal),
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
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: secondaryColor)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelSemiBoldMD(text: "Ringkasan Pembayaran"),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Sub Total"),
              LabelSemiBoldMD(text: grandTotal),
            ],
          ),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Label(text: "Diskon"), LabelSemiBoldMD(text: "Rp 0")],
          ),
          Line(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LabelSemiBold(text: 'Grand Total'),
              LabelSemiBoldMD(text: grandTotal, primary: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFinishTransaction(screenHeight, screenWidth) {
    return isLoader == false && transactionProccess != true
        ? Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
          child: GestureDetector(
            onTap: () {
              cartItems.isEmpty
                  ? Navigator.pop(context, true)
                  : showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.white,
                    builder: (context) {
                      return StatefulBuilder(
                        builder: (context, setModalState) {
                          return FractionallySizedBox(
                            heightFactor: 0.7,
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
                                  Gap(15),
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  LineXM(),
                                  Text(
                                    "Nominal Pelanggan",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Gap(5),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(
                                        width: screenWidth * 0.65,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            color: Colors.white,
                                            border: Border.all(
                                              color: secondaryColor,
                                            ),
                                          ),
                                          child: TextField(
                                            cursorColor: primaryColor,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter
                                                  .digitsOnly,
                                              LengthLimitingTextInputFormatter(
                                                8,
                                              ),
                                            ],
                                            maxLines: 1,
                                            controller: nominalCustomer,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              counterText: "",
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(10), // Radius sudut
                                                borderSide: BorderSide.none, // Hilangkan border default
                                              ),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 5,
                                                  ),
                                              hintText: "Masukkan nominal",
                                              hintStyle: TextStyle(
                                                color: Color(0xffB1B9C3),
                                                fontSize: 14,
                                              ),
                                            ),
                                            onChanged: (value) {
                                              final formatted = _formatCurrency(
                                                value,
                                              );
                                              nominalCustomer.value = TextEditingValue(
                                                text: formatted,
                                                selection:
                                                    TextSelection.collapsed(
                                                      offset: formatted.length,
                                                    ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Gap(10),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            DialogHelper.showFinishPayment(context: context, onConfirm: () => saveTransaction());
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(13),
                                            decoration: BoxDecoration(
                                              color: primaryColor,
                                              borderRadius: BorderRadius.circular(
                                                10,
                                              ),
                                            ),
                                            child: Text(
                                              "Selesai",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Gap(5),
                                  LineXM(),
                                  LabelSemiBold(text: "Nominal Pecahan"),
                                  Gap(5),
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: List.generate(
                                      nominalList.length,
                                      (index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setModalState(() {
                                              selectedIndex = index;

                                              if (index == 0) {
                                                nominalCustomer.text = grandTotal;
                                              } else {
                                                nominalCustomer.text = nominalList[index];
                                              }
                                            });

                                            setState(() {
                                              selectedIndex = index;
                                            });
                                          },
                                          child: ConstrainedBox( // Memberikan batasan lebar
                                            constraints: BoxConstraints(
                                              minWidth: 90, // Lebar minimal
                                              maxWidth: 100, // Lebar maksimal
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: selectedIndex == index ? bgSuccess : lightColor,
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  nominalList[index],
                                                  style: TextStyle(
                                                    color: selectedIndex == index ? successColor : Colors.black,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
            },

            child: ButtonPrimary(
              text: cartItems.isEmpty ? "Kembali" : "Selesaikan Pembayaran",
            )
          ),
        )
        : SizedBox.shrink();
  }

  Widget buildPaymentMethod() {
    return transactionProccess != true
        ? Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: ligthSky,
            borderRadius: BorderRadius.circular(10),
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
                  border: Border.all(
                    color: secondaryColor.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
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
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/cash.png',
                              width: 23,
                            ),
                          ),
                        ),
                        Gap(10),
                        LabelSemiBold(text: "Tunai"),
                      ],
                    ),
                    Container(
                      width: 25,
                      height: 25,
                      padding: EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: bgSuccess,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Center(
                        child: Icon(Icons.check, size: 15, color: successColor),
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
                  border: Border.all(
                    color: secondaryColor.withValues(alpha: 0.5),
                  ),
                  borderRadius: BorderRadius.circular(10),
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
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/qr-code.png',
                              width: 18,
                            ),
                          ),
                        ),
                        Gap(10),
                        LabelSemiBold(text: "QRIS"),
                      ],
                    ),
                    Text("Segera Hadir", style: TextStyle(fontSize: 12),)
                  ],
                ),
              ),
            ],
          ),
        )
        : SizedBox.shrink();
  }
}
