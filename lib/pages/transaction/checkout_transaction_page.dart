import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  String subTotal = "Rp 0";
  String totalDiscount = "Rp 0";
  int totalItem = 0;
  bool isLoader = true;
  bool transactionProccess = false;

  int selectedIndex = -1;
  String selectedName = "";
  String selectedNominal = "";

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
          subTotal = fetchCartSummary.subTotal;
          totalDiscount = fetchCartSummary.totalDiscount;
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
          alertLottie(context, "Nominal pembayaran harus lebih dari grand total!", "error");
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
        Navigator.pushNamed(context, '/nota', arguments: transactionData['data'][0]['id']);
      }
    } catch (e) {
      if (context.mounted) {
        alertLottie(context, e.toString(), 'error');
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(
                            imageUrl : cartItem.productImage,
                            width: 60,
                            height: 60,
                            fit: BoxFit.fitWidth,
                            placeholder: (context, url) => Image.asset(
                              'assets/images/empty.png', 
                              width: 60,
                              height: 60,
                              fit: BoxFit.fitWidth,
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/empty.png', 
                              width: 60,
                              height: 60,
                              fit: BoxFit.fitWidth
                            )
                          ),
                        ),
                        Gap(10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Label(text: cartItem.productName),
                              if (cartItem.productShortDescription != "") ...[
                                ShortDesc(text: cartItem.productShortDescription, maxline: 1),
                              ] else ...[
                                Gap(2),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Label(text: cartItem.unitPrice),
                                  Label(text: '${cartItem.quantity}x'),
                                  Gap(10),
                                  LabelSemiBold(text: cartItem.subtotal)
                                ],
                              ),
                              if(cartItem.discount != "Rp 0") ... [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '- ${cartItem.discount}',
                                      maxLines: 1,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        color: red
                                      ),
                                    ),
                                    Text('- ${cartItem.subTotalDiscount}', 
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis,
                                        color: red
                                      ),
                                    )
                                  ],
                                ),
                              ]
                            ],
                          ),
                        )
                      ],
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
              LabelSemiBoldMD(text: subTotal),
            ],
          ),
          Gap(5),
          if(totalDiscount != "Rp 0") ... [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Label(text: "Diskon"), LabelSemiBoldMDRed(text: '- $totalDiscount')],
            ),
          ],
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
                                        // ignore: deprecated_member_use
                                        TyperAnimatedTextKit(
                                          text: [grandTotal],
                                          textStyle: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.w600,
                                            color: primaryColor
                                          ),
                                          speed: Duration(milliseconds: 90),
                                          pause: Duration(seconds: 0),
                                          repeatForever: false,
                                          isRepeatingAnimation: false,
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
                                      Expanded(
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
                                                9,
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
                                              final paid = value.replaceAll(RegExp(r'[^0-9]'), '');
                                              final paidSelected = selectedNominal.replaceAll(RegExp(r'[^0-9]'), '');
                                              final paidGrandTotal = grandTotal.replaceAll(RegExp(r'[^0-9]'), '');
                                        
                                              if (paid != paidSelected) {
                                                setModalState(() {
                                                  selectedIndex = -1;
                                                });
                                              }
                                              if (paid == "5000") {
                                                setModalState(() {
                                                  selectedIndex = 1;
                                                });
                                              }
                                              if (paid == "10000") {
                                                setModalState(() {
                                                  selectedIndex = 2;
                                                });
                                              }
                                              if (paid == "20000") {
                                                setModalState(() {
                                                  selectedIndex = 3;
                                                });
                                              }
                                              if (paid == paidGrandTotal) {
                                                setModalState(() {
                                                  selectedIndex = 0;
                                                });
                                              }
                                        
                                              final formatted = _formatCurrency(value);
                                              nominalCustomer.value = TextEditingValue(
                                                text: formatted,
                                                selection: TextSelection.collapsed(offset: formatted.length),
                                              );
                                            }
                                        
                                          ),
                                        ),
                                      ),
                                      Gap(10),
                                      GestureDetector(
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
                                                selectedNominal = grandTotal;
                                                nominalCustomer.text = grandTotal;
                                              } else {
                                                selectedNominal = nominalList[index];
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
            border: Border.all(color: secondaryColor)
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
