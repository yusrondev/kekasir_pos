import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/qr_scanner_button.dart';
import 'package:kekasir/helpers/dialog_expired.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class IndexProductPage extends StatefulWidget {
  const IndexProductPage({super.key});

  @override
  State<IndexProductPage> createState() => _IndexProductPageState();
}

class _IndexProductPageState extends State<IndexProductPage> {
  ApiService apiService = ApiService();
  List<Product> products = [];
  bool isLoading = true;
  List<bool> tapped = [];

  GlobalKey one = GlobalKey();

  var logger = Logger();

  TextEditingController searchField = TextEditingController();

  Timer? _debounce;
  Timer? _debounceHit;

  int offset = 0;
  final int limit = 20;
  bool isLoadMore = false;
  bool hasMore = true;

  String? _selectedName = "";

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _debounceHit = Timer(Duration(milliseconds: 500), () {
        fetchProducts(searchField.text);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkShowcaseStatus();
    });

    searchField.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 500), () {
        fetchProducts(searchField.text);
      });
    });
  }

  void _checkShowcaseStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShownShowcase = prefs.getBool('hasShownProductShowcase') ?? false;

    if (!hasShownShowcase && mounted) {
      final showcase = ShowCaseWidget.of(context);
      showcase.startShowCase([one]);
      prefs.setBool('hasShownProductShowcase', true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchField.dispose();
    _debounceHit?.cancel(); // Pastikan Timer dibatalkan saat widget dihancurkan
    super.dispose();
  }

  Future<void> fetchProducts(String text, {bool append = false}) async {
    // if (isLoadMore || !hasMore) return;
    try {
      if (!append) {
        offset = 0;
        setState(() {
          isLoading = true;
        });
      } else {
        setState(() {
          isLoadMore = true;
        });
      }

      final data = await ApiService().fetchProducts(text, null, null, offset, limit, _selectedName);

      Logger().d(data);

      setState(() {
        if (append) {
          products.addAll(data);
        } else {
          products = data;
        }

        tapped = List.generate(products.length, (index) => false);
        offset += limit;
        hasMore = data.length == limit;
        isLoading = false;
        isLoadMore = false;
      });

      logger.d(data);
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isLoadMore = false;
        });
      }

      if (mounted) {
        if (e.toString().contains('expired')) {
          showNoExpiredDialog(context);
        } else {
          showErrorBottomSheet(context, e.toString());
        }
      }
    }
  }

  void showDialogSort() {
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
                  maxHeight: 300
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    LabelSemiBold(text: "Urutkan Berdasarkan"),
                    Gap(10),
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _selectedName = "Tanpa Filter";
                        });
                        setState(() {
                          _selectedName = "Tanpa Filter";
                          fetchProducts(searchField.text);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedName == "Tanpa Filter" || _selectedName == "" ? bgSuccess : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedName == "Tanpa Filter" || _selectedName == "" ? successColor : secondaryColor)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Tanpa Filter", style: TextStyle(
                              color: _selectedName == "Tanpa Filter" || _selectedName == "" ? successColor : Colors.black,
                              fontWeight: FontWeight.w600
                            )),
                            if(_selectedName == "Tanpa Filter" || _selectedName == "") ... [
                              Icon(Icons.check_circle, size: 15, color: successColor,)
                            ] else ... [
                              Icon(Icons.keyboard_arrow_right_rounded, size: 15, color: primaryColor,)
                            ]
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _selectedName = "Stok Menipis";
                        });
                        setState(() {
                          _selectedName = "Stok Menipis";
                          fetchProducts(searchField.text);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedName == "Stok Menipis" ? bgSuccess : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedName == "Stok Menipis" ? successColor : secondaryColor)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Stok Menipis", style: TextStyle(
                              color: _selectedName == "Stok Menipis" ? successColor : Colors.black,
                              fontWeight: FontWeight.w600
                            )),
                            if(_selectedName == "Stok Menipis") ... [
                              Icon(Icons.check_circle, size: 15, color: successColor,)
                            ] else ... [
                              Icon(Icons.keyboard_arrow_right_rounded, size: 15, color: primaryColor,)
                            ]
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _selectedName = "Stok Terbanyak";
                        });
                        setState(() {
                          _selectedName = "Stok Terbanyak";
                          fetchProducts(searchField.text);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedName == "Stok Terbanyak" ? bgSuccess : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedName == "Stok Terbanyak" ? successColor : secondaryColor)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Stok Terbanyak", style: TextStyle(
                              color: _selectedName == "Stok Terbanyak" ? successColor : Colors.black,
                              fontWeight: FontWeight.w600
                            )),
                            if(_selectedName == "Stok Terbanyak") ... [
                              Icon(Icons.check_circle, size: 15, color: successColor,)
                            ] else ... [
                              Icon(Icons.keyboard_arrow_right_rounded, size: 15, color: primaryColor,)
                            ]
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _selectedName = "Harga Termurah";
                        });
                        setState(() {
                          _selectedName = "Harga Termurah";
                          fetchProducts(searchField.text);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedName == "Harga Termurah" ? bgSuccess : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedName == "Harga Termurah" ? successColor : secondaryColor)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Harga Termurah", style: TextStyle(
                              color: _selectedName == "Harga Termurah" ? successColor : Colors.black,
                              fontWeight: FontWeight.w600
                            )),
                            if(_selectedName == "Harga Termurah") ... [
                              Icon(Icons.check_circle, size: 15, color: successColor,)
                            ] else ... [
                              Icon(Icons.keyboard_arrow_right_rounded, size: 15, color: primaryColor,)
                            ]
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setModalState(() {
                          _selectedName = "Harga Termahal";
                        });
                        setState(() {
                          _selectedName = "Harga Termahal";
                          fetchProducts(searchField.text);
                          Navigator.pop(context);
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 5),
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _selectedName == "Harga Termahal" ? bgSuccess : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _selectedName == "Harga Termahal" ? successColor : secondaryColor)
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Harga Termahal", style: TextStyle(
                              color: _selectedName == "Harga Termahal" ? successColor : Colors.black,
                              fontWeight: FontWeight.w600
                            )),
                            if(_selectedName == "Harga Termahal") ... [
                              Icon(Icons.check_circle, size: 15, color: successColor,)
                            ] else ... [
                              Icon(Icons.keyboard_arrow_right_rounded, size: 15, color: primaryColor,)
                            ]
                          ],
                        ),
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
  }

  deleteProduct(id) async {
    final delete = await ApiService().deleteProduct(id);
    logger.i(delete);
    try {
      if (mounted) {
        setState(() {
          fetchProducts(searchField.text);
          alertLottie(context, "Berhasil menghapus produk!");
        });
      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          fetchProducts(searchField.text);
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 45, left: 14, right: 14), 
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PageTitle(text: "Data Produk"),
                      GestureDetector(
                        onTap: () => showDialogSort(),
                        child: Container(
                          padding: EdgeInsets.only(top: 5, bottom: 5, left: 5, right: 2),
                          decoration: BoxDecoration(
                            color: ligthSky,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: secondaryColor)
                          ),
                          child: Row(
                            children: [
                              Text(_selectedName.toString().isNotEmpty ? toBeginningOfSentenceCase(_selectedName.toString()) : "Urut Berdasarkan", style: TextStyle(fontSize: 14),),
                              Icon(Icons.arrow_drop_down_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gap(10),
                  Row(
                    children: [
                      Expanded(child: SearchTextField(controller: searchField, placeholder: "Cari berdasarkan nama produk...",)),
                      Gap(5),
                      QrScannerButton(controller: searchField)
                    ],
                  )
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 45, left: 14, right: 14), 
                children: [
                  Gap(10),
                  buildProductList()
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Showcase(
        key: one, 
        description: "Klik tombol ini untuk menambahkan produk baru", 
        tooltipPosition: TooltipPosition.top,
        overlayOpacity: 0.5,
        targetBorderRadius: BorderRadius.circular(15),
        child: FloatingActionButton(
          onPressed: (){
            Navigator.pushNamed(context, '/create-product').then((value){
              if (value == true) {
                fetchProducts(searchField.text);
              }
            });
          },
          mini: true,
          backgroundColor: primaryColor,
          child: const Icon(Icons.add, color: Colors.white),
        )
      ),
    );
  }

  Widget buildProductList(){
    if (isLoading == false && products.isEmpty) {
      return Column(
        children: [
          Gap(100),
          EmptyProduct.showEmptyProduct(),
          LabelSemiBold(text: "Data produk tidak ditemukan ..."),
        ],
      );
    }

    return isLoading ? Column(
      children: [
        Gap(100),
        CustomLoader.showCustomLoader(),
      ],
    ) : LayoutBuilder(
      builder: (context, constraints) {

         // Maksimum lebar item (misalnya 200 px)
        double maxItemWidth = 200;

        // Hitung berapa kolom yang bisa muat berdasarkan lebar layar
        int columnCount = (constraints.maxWidth / maxItemWidth).floor();

        // Hitung lebar aktual per item
        double itemWidth = constraints.maxWidth / columnCount;

        // Tentukan tinggi item sesuai rasio yang kamu inginkan (misal 3:3.2)
        double itemHeight = itemWidth / (3 / 2.9);

        // Hitung aspek rasio aktual
        double aspectRatio = itemWidth / itemHeight;

        return Column(
          children: [
            GridView.builder(
                padding: EdgeInsets.all(0),
                itemCount: products.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200, // Maksimal lebar tiap item
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: aspectRatio, // Sesuaikan rasio aspek
                ), 
                itemBuilder: (context, index){
                  final product = products[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        tapped[index] = !tapped[index];
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: secondaryColor),
                        borderRadius: BorderRadius.circular(10)
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(10),
                          Center(
                            child: SizedBox(
                              width: 160,
                              height: 100,
                              child: Stack(
                                children: [
                                  Stack(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            tapped[index] = !tapped[index];
                                          });
                                        },
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(5),
                                          child: CachedNetworkImage(
                                            imageUrl: product.image,
                                            width: 160,
                                            height: 160,
                                            fit: BoxFit.fitWidth,
                                            placeholder: (context, url) => Image.asset(
                                              'assets/images/empty.png',
                                              width: 160,
                                              height: 160,
                                              fit: BoxFit.fitWidth,
                                            ),
                                            errorWidget: (context, url, error) => Image.asset(
                                              'assets/images/empty.png',
                                              width: 160,
                                              height: 160,
                                              fit: BoxFit.fitWidth,
                                            ),
                                          ),
                                        ),
                                      ),
                                      if(product.shortDescription.isNotEmpty) ... [
                                        Container(
                                          width: 160,
                                          height: 160,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            gradient: LinearGradient(
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                              colors: [
                                                Colors.black.withValues(alpha: 0.5),
                                                Colors.black.withValues(alpha: 0.3),
                                                Colors.black.withValues(alpha: 0.2),
                                                Colors.transparent,
                                              ]
                                            )
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Align(
                                            alignment: Alignment.bottomCenter,
                                            child: Text(
                                              product.shortDescription,
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 12,
                                                overflow: TextOverflow.ellipsis,
                                                color: Colors.white
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                      StockBadge(availableStock: product.availableStock),
                                      if( tapped[index] == true) ... [
                                        Container(
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pushNamed(context, '/edit-product', arguments: product).then((value){
                                                    if (value == true) {
                                                      setState(() {
                                                        fetchProducts(searchField.text);
                                                      });
                                                    }
                                                  });
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.all(12),
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.white),
                                                    color: primaryColor,
                                                    borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: Image.asset(
                                                    'assets/icons/pen.png',
                                                    width: 20,
                                                    height: 20,
                                                  ),
                                                ),
                                              ),
                                              Gap(20),
                                              GestureDetector(
                                                onTap: () {
                                                  DialogHelper.showDeleteConfirmation(context: context, onConfirm: () => deleteProduct(product.id), content: product.name);
                                                },
                                                child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(color: Colors.white),
                                                    color: Color(0xffe74c3c),
                                                    borderRadius: BorderRadius.circular(10)
                                                  ),
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.close_rounded,
                                                      color: Colors.white,
                                                      size: 20,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ]
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Gap(10),
                          Flexible(child: Text(product.name, style: TextStyle(fontSize: 14, overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w600))),
                          // LineSM(),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: AutoSizeText(
                                    formatRupiah(product.realPrice),
                                    style: TextStyle(
                                      fontSize: 14, // Ukuran maksimal
                                      color: product.isDiscount == true ? softBlack : primaryColor,
                                      fontWeight: FontWeight.w600,
                                      decoration: product.isDiscount == true ? TextDecoration.lineThrough : TextDecoration.none,
                                      decorationColor: dangerColor
                                    ),
                                    maxLines: 2, // Batasi menjadi 1 baris
                                    minFontSize: 8, // Ukuran minimal agar tetap terbaca
                                    overflow: TextOverflow.ellipsis, // Tambahkan "..." jika masih kepanjangan
                                  )
                                ),
                                if(product.isDiscount == true)
                                  Expanded(
                                    child: AutoSizeText(
                                      formatRupiah(product.price),
                                      style: TextStyle(
                                        fontSize: 14, // Ukuran maksimal
                                        color: primaryColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 2, // Batasi menjadi 1 baris
                                      minFontSize: 8, // Ukuran minimal agar tetap terbaca
                                      overflow: TextOverflow.ellipsis, // Tambahkan "..." jika masih kepanjangan
                                    )
                                  ),
                                Icon(Icons.arrow_forward_rounded, size: 14, color: primaryColor),
                              ],
                            ),
                          ),
                          Gap(7)
                        ],
                      ),
                    ),
                  );
                }
              ),
            if (hasMore)
            isLoadMore
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CustomLoader.showCustomLoader(),
                  )
                : Column(
                  children: [
                    Gap(20),
                    GestureDetector(
                      onTap: () {
                        fetchProducts(searchField.text, append: true);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: primaryColor,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("Muat Lebih", style: TextStyle(color: Colors.white)),
                            Gap(5),
                            Icon(Icons.arrow_downward_outlined, color: Colors.white, size: 14,)
                          ],
                        ),
                      ),
                    ),
                    Gap(20),
                  ],
                )
          ],
        );
      }
    );
  }
}