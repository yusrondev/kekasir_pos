import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/apis/api_service_cart.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/helpers/snackbar_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';

class IndexTransactionPage extends StatefulWidget {
  const IndexTransactionPage({super.key});

  @override
  State<IndexTransactionPage> createState() => _IndexTransactionPageState();
}

class _IndexTransactionPageState extends State<IndexTransactionPage> {
  ApiService apiService = ApiService();
  ApiServiceCart apiServiceCart = ApiServiceCart();

  List<Product> products = [];
  List<int> quantities = []; // Menyimpan jumlah produk untuk setiap item
  String grandTotal = "Rp 0";
  int totalItem = 0;
  bool isLoadCart = false;
  bool isLoadProduct = true;
  BuildContext? _dialogContext;

  TextEditingController keyword = TextEditingController();
  Timer? _debounce;
  Timer? _debounceHit;

  @override
  void initState() {
    super.initState();
      if (mounted) {
        _debounceHit = Timer(Duration(milliseconds: 500), () {
          fetchProducts(keyword.text, 'true');
          fetchCart();
      });
    }

    keyword.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 1000), () {
        isLoadProduct = true;
        fetchProducts(keyword.text, 'true');
        fetchCart();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    keyword.dispose();
    _debounceHit?.cancel(); // Pastikan Timer dibatalkan saat widget dihancurkan
    super.dispose();
  }

  Future<void> fetchProducts(String keyword, String sort) async {
    final data = await ApiService().fetchProducts(keyword, sort);
    Logger().d(data);
    try {
      if (mounted) {  
        setState(() {
          isLoadProduct = false;
          products = data;
          quantities = List.generate(products.length, (index) => products[index].quantity); // Default jumlah 0
        });
        fetchCart();
      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  Future<void> fetchCart() async {

    final fetchCartSummary = await ApiServiceCart().fetchCartSummary();

    if (mounted) {
      setState(() {
        grandTotal = fetchCartSummary.totalPrice;
        totalItem = fetchCartSummary.totalQuantity;
        isLoadCart = false;
        closeLoadingDialog();
      });
    }
  }

  void _updateCart(int index, int quantity) async {
    // Tampilkan Lottie loading animation
    try {
      await ApiServiceCart().updateCart(products[index].id, quantity);
      fetchCart();
    } catch (e) {
      if (mounted) {
        showErrorSnackbar(context, e.toString());
      }
    }
  }
  
  void _increment(int index) {
    showLoadingDialog(context);
    setState(() {
      if (quantities[index] < products[index].availableStock) {
        isLoadCart = true;
        quantities[index]++;
      }
    });
    _debounceUpdateCart(index);
  }

  void _decrement(int index) {
    showLoadingDialog(context);
    setState(() {
      if (quantities[index] != 0) {
        isLoadCart = true;
        quantities[index]--;
      }
    });
    _debounceUpdateCart(index);
  }

  void _debounceUpdateCart(int index) {
    // Batalkan debounce sebelumnya jika ada
    _debounce?.cancel();

    // Buat debounce baru dengan delay 300ms
    _debounce = Timer(Duration(milliseconds: 300), () {
      _updateCart(index, quantities[index]); // Update ke backend setelah delay
    });
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

  void clearCart() async {
    showLoadingDialog(context);
    try {
      await ApiServiceCart().clearCart();
      fetchCart();
      fetchProducts(keyword.text, 'true');
      closeLoadingDialog();
    } catch (e) {
      showErrorSnackbar(context, e.toString());
    }
  }

  void showInputDialog(int index, int availableStock) {
    TextEditingController controller = TextEditingController(
      text: quantities[index] == 0 ? "" : quantities[index].toString(),
    );

    controller.addListener(() {
      int? val = int.tryParse(controller.text);
      if (val != null && val > availableStock) {
        controller.text = availableStock.toString(); // Batasi ke stok maksimum
        controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length), // Geser kursor ke akhir teks
        );
      }
    });

    showDialog(
      context: context,
      barrierColor: Colors.black54, // Agar tetap fokus ke dialog
      useSafeArea: false, // Menghindari batas layar
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LabelSemiBold(
                    text: "Jumlah Pembelian",
                  ),
                  StockTag(text: 'Tersedia : ${availableStock.toString()}')
                ],
              ),
              Gap(10),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: secondaryColor),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // Hanya angka
                    FilteringTextInputFormatter.deny(RegExp(r'\s')), // Mencegah spasi
                  ],
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Masukkan jumlah...",
                  ),
                  onSubmitted: (value) {
                    int? val = int.tryParse(value);
                    if (val != null) {
                      setState(() {
                        quantities[index] = val.clamp(0, availableStock);
                      });
                      Navigator.pop(context);
                    }
                  },
                ),
              ),
              Gap(10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: ButtonPrimaryOutline(
                        text: "Batal",
                      ),
                    )
                  ),
                  Gap(5),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        int? val = int.tryParse(controller.text);
                        if (val != null) {
                          Navigator.pop(context);
                          if (val != quantities[index]) {  
                            showLoadingDialog(context);
                            setState(() {
                              quantities[index] = val.clamp(0, availableStock);
                              _updateCart(index, quantities[index]);
                            });
                          }
                        }
                      },
                      child: ButtonPrimary(
                        text: "Simpan",
                      ),
                    )
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await fetchProducts(keyword.text, 'true');
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: ListView(
          padding: defaultPadding,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitle(text: "Tambah Transaksi"),
                GestureDetector(
                  onTap: () {
                    if (grandTotal != "Rp 0") {
                      DialogHelper.showDeleteAllCartConfirmation(context: context, onConfirm: (){
                        clearCart();
                      });
                    }
                  },
                  child: Image.asset(
                    grandTotal != "Rp 0" ? 'assets/icons/empty-cart-active.png' : 'assets/icons/empty-cart.png',
                    width: 30,
                  ),
                )
              ],
            ),
            Gap(10),
            SearchTextField(placeholder: "Cari berdasarkan nama produk...", controller: keyword),
            Gap(10),
            // isLoadCart == true ? CustomLoader.showCustomLoader() : buildProductList(),
            buildProductList(),
          ],
        ),
      ),
      bottomNavigationBar: buildGrandtotal(),
    );
  }

  Widget buildProductList() {
    if (isLoadProduct == true) {
      return Column(
        children: [
          Gap(100),
          CustomLoader.showCustomLoader(),
        ],
      );
    }

    if (isLoadProduct == false && products.isEmpty) {
      return Center(
        child: Label(text: "Data produk tidak ditemukan",),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return Container(
          padding: EdgeInsets.symmetric(vertical: 7,horizontal: 7),
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/edit-product', arguments: product).then((value){
                    if (value == true) {
                      setState(() {
                        fetchProducts(keyword.text, 'true');
                      });
                    }
                  });
                },
                child: Align(
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () {
                      showInputDialog(index, product.availableStock);
                    },
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            product.image,
                            width: 65,
                            height: 65,
                            fit: BoxFit.fitWidth,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/empty.png', 
                                width: 65,
                                height: 65,
                                fit: BoxFit.fitWidth,
                              );
                            },
                          ),
                        ),
                        Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          height: 65,
                          child: Center(
                            child: Image.asset(
                              'assets/icons/pen.png',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Gap(10),
              Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelSemiBoldMD(text: product.name),
                      if(product.shortDescription != "") ... [
                        ShortDesc(text: product.shortDescription, maxline: 2)
                      ]else ... [
                        Gap(2)
                      ],
                      Row(
                        children: [
                          PriceTag(text: formatRupiah(product.price)),
                          Gap(5),
                          StockTag(text: 'Stok : ${product.availableStock.toString()}'),
                        ],
                      ),
                      Gap(5),
                    ],
                  ),
                ),
              ),
              Gap(5),
              // Bagian Quantity (Plus Minus)
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color(0xffF2F4F8),
                      borderRadius: BorderRadius.circular(100)
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: IconButton(
                            iconSize: 15,
                            highlightColor: Colors.white,
                            icon: Icon(Icons.remove, color: Colors.black),
                            onPressed: () => quantities[index] > 0 ? _decrement(index) : null,
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          height: 20,
                          child: TextField(
                            readOnly: true,
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            controller: TextEditingController(text: quantities[index].toString()),
                            decoration: InputDecoration(
                              counterText: "",
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 11),
                              hintStyle: TextStyle(
                              color: Color(0xffB1B9C3), 
                              fontSize: 16,
                              )
                            ),
                            onChanged: (value) {
                              setState(() {
                                int? val = int.tryParse(value);
                                if (val == null || val < 0) {
                                  quantities[index] = 0; // Minimal 0
                                } else {
                                  quantities[index] = val;
                                }
                              });
                            },
                          ),
                        ),
                        CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 15,
                          child: IconButton(
                            iconSize: 15,
                            icon: Icon(Icons.add, color: Colors.black),
                            onPressed: () => product.availableStock != 0 && quantities[index] != product.availableStock ? _increment(index) : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(5),
                  LabelSemiBold(text: formatRupiah(product.price * quantities[index]), primary: true,),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildGrandtotal() {
    if (grandTotal != "Rp 0") {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xff344BBC),
                Color(0xff344BBC),
                Color(0xff273A99)
              ]
            ),
            borderRadius: BorderRadius.circular(10)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Total : $totalItem barang",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14
                    ),
                  ),
                  Text(
                    grandTotal,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 18
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/checkout').then((value){
                    if (value == true) {
                      setState(() {
                        fetchProducts(keyword.text, 'true');
                      });
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Text("Checkout", style: TextStyle(
                    fontSize: 14,
                    color: primaryColor,
                    fontWeight: FontWeight.w600
                  ),),
                ),
              )
            ],
          ),
        ),
      ); 
    }else{
      return SizedBox.shrink();
    }
  }
}
