import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/apis/api_service_cart.dart';
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
import 'package:logger/web.dart';

class IndexTransactionPage extends StatefulWidget {
  const IndexTransactionPage({super.key});

  @override
  State<IndexTransactionPage> createState() => _IndexTransactionPageState();
}

class _IndexTransactionPageState extends State<IndexTransactionPage> {
  ApiService apiService = ApiService();
  ApiServiceCart apiServiceCart = ApiServiceCart();
  ApiServiceTypePrice apiServiceTypePrice = ApiServiceTypePrice();

  List<Product> products = [];
  List<LabelPrice> labelPrices = [];
  List<int> quantities = []; // Menyimpan jumlah produk untuk setiap item
  String grandTotal = "Rp 0";
  int totalItem = 0;
  bool isLoadCart = false;
  bool isLoadProduct = true;
  BuildContext? _dialogContext;

  TextEditingController keyword = TextEditingController();
  Timer? _debounce;
  Timer? _debounceHit;
  String? _selectedName = "";

  @override
  void initState() {
    super.initState();
      if (mounted) {
        _debounceHit = Timer(Duration(milliseconds: 500), () {
          fetchProducts(keyword.text, 'true', _selectedName.toString());
          fetchLabelPrice(0);
          fetchCart(_selectedName.toString());
      });
    }

    keyword.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 1000), () {
        isLoadProduct = true;
        fetchProducts(keyword.text, 'true', _selectedName.toString());
        fetchCart(_selectedName.toString());
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

  Future<void> fetchLabelPrice(productId) async {
    final data = await apiServiceTypePrice.fetchLabelPrice(productId);

    if (mounted) { // Cek apakah widget masih ada sebelum setState
      setState(() {
        labelPrices = data;
      });

      Logger().d(labelPrices);
    }
  }

  Future<void> fetchProducts(String keyword, String sort, String typePrice) async {
    final data = await ApiService().fetchProducts(keyword, sort, typePrice);
    Logger().d(data);
    try {
      if (mounted) {  
        setState(() {
          isLoadProduct = false;
          products = data;
          quantities = List.generate(products.length, (index) => products[index].quantity); // Default jumlah 0
        });
        fetchCart(_selectedName.toString());
      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  Future<void> fetchCart(String? typePrice) async {

    final fetchCartSummary = await ApiServiceCart().fetchCartSummary(typePrice);

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
      fetchCart(_selectedName.toString());
    } catch (e) {
      if (mounted) {
        alertLottie(context, e.toString(), 'error');
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
              width: 50,
              height: 50,
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
      fetchCart(_selectedName.toString());
      fetchProducts(keyword.text, 'true', _selectedName.toString());
      closeLoadingDialog();
    } catch (e) {
      alertLottie(context, e.toString(), 'error');
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return "";
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  void showDialogListPriceType() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4), // Atur tingkat 
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              clipBehavior: Clip.hardEdge,
              backgroundColor: Colors.white,
              content: Container(
                width: 100,
                constraints: BoxConstraints(
                  minHeight: 100, // Tinggi minimum
                  maxHeight: 350
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabelSemiBold(text: "Pilih Tipe Harga"),
                    Gap(2),
                    ShortDesc(text: "Otomatis menggunakan harga normal"),
                    ShortDesc(text: "jika produk tidak memiliki tipe harga terkait"),
                    LineXM(),
                    Container(
                      constraints: BoxConstraints(
                        minHeight: 40, // Tinggi minimum
                        maxHeight: 190
                      ),
                      child: Scrollbar(
                        thumbVisibility: true, // Agar scrollbar selalu terlihat
                        thickness: 3, // Ketebalan scrollbar
                        radius: Radius.circular(10), // Membuat scrollbar lebih halus
                        child: ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(0),
                          itemCount: labelPrices.length,
                          itemBuilder: (context, index){
                            final labelPrice = labelPrices[index];
                            bool isSelected = _selectedName == labelPrice.name; 
                                    
                            return GestureDetector(
                              onTap: () {
                                setModalState(() {
                                  if (_selectedName == labelPrice.name) {
                                    _selectedName = "";
                                  }else{
                                    _selectedName = labelPrice.name;
                                  }
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.only(bottom: 5),
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected == true ? bgSuccess : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSelected == true ? successColor : secondaryColor)
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(_capitalize(labelPrice.name.toString()), style: TextStyle(
                                      color: isSelected == true ? successColor : Colors.black,
                                      fontWeight: FontWeight.w600
                                    )),
                                    if(isSelected)
                                    Icon(Icons.check_circle, size: 15, color: successColor,)
                                  ],
                                ),
                              ),
                            );
                          }
                        ),
                      ),
                    ),
                    Gap(10),
                    Row(
                      children: [
                        Expanded(
                          child: ButtonPrimary(text: _selectedName.toString() == "" ? "Simpan" : "Ubah ke ${_selectedName.toString()}", onPressed: () {
                            fetchProducts(keyword.text, "true", _selectedName.toString());
                            Navigator.pop(context);
                            alertLottie(context, _selectedName.toString() == "" ? "Beralih ke harga normal" : "Beralih ke harga ${_selectedName.toString()}");
                          })
                        )
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
          clipBehavior: Clip.hardEdge,
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
                    contentPadding: EdgeInsets.all(10),
                    border: InputBorder.none,
                    filled: true,
                    fillColor: Colors.white,
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
          await fetchProducts(keyword.text, 'true', _selectedName.toString());
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 45, left: 14, right: 14), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
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
                  Row(
                    children: [
                      Expanded(child: SearchTextField(placeholder: "Cari berdasarkan nama produk...", controller: keyword)),
                      if(labelPrices.isNotEmpty) ... [
                        Gap(5),
                        GestureDetector(
                          onTap: () => showDialogListPriceType(),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ligthSky,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: secondaryColor)
                            ),
                            child: Icon(Icons.settings, size: 20),
                          ),
                        )
                      ]
                    ],
                  ),
                  // isLoadCart == true ? CustomLoader.showCustomLoader() : buildProductList(),
                  if(_selectedName.toString() != "") ... [
                    Gap(5),
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.symmetric(vertical: 3),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: Color(0xfff9ca24),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Menggunakan harga : ${toBeginningOfSentenceCase(_selectedName)}",
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              color: Color(0xff130f40)
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedName = "";
                                fetchProducts(keyword.text, "true", _selectedName.toString());
                                alertLottie(context, _selectedName.toString() == "" ? "Beralih ke harga normal" : "Beralih ke harga ${_selectedName.toString()}"); 
                              });
                            },
                            child: Icon(Icons.close, size: 20, color: Colors.black),
                          )
                        ],
                      ),
                    ),
                    Gap(5),
                  ] else ... [
                    Gap(10),
                  ],
                ],
              ),
            ),
            Expanded(
              child: ListView(
                  padding: EdgeInsets.only(bottom: 45, left: 14, right: 14), 
                  children: [
                    buildProductList(),
                  ],
                ),
            ),
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
      return Column(
        children: [
          Gap(100),
          EmptyProduct.showEmptyProduct(),
          LabelSemiBold(text: "Data produk tidak ditemukan ..."),
        ],
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
            border: Border.all(color: product.haveType == true ?  Color(0xfff9ca24): secondaryColor, width: 1)
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/edit-product', arguments: product).then((value){
                    if (value == true) {
                      setState(() {
                        fetchProducts(keyword.text, 'true', _selectedName.toString());
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
                            color: Colors.black.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        SizedBox(
                          width: 65,
                          height: 65,
                          child: Center(
                            child: Image.asset(
                              'assets/icons/plus-minus.png',
                              width: 25,
                              height: 25,
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
                          PriceTag(text: formatRupiah(product.price), haveType : product.haveType),
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
                  Navigator.pushNamed(
                    context,
                    '/checkout',
                    arguments: _selectedName.toString(),
                  ).then((value) {
                    if (value == true) {
                      setState(() {
                        fetchProducts(keyword.text, 'true', _selectedName.toString());
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
