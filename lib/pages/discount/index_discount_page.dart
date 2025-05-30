import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/components/qr_scanner_button.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/dialog_expired.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';

class IndexDiscountPage extends StatefulWidget {
  const IndexDiscountPage({super.key});

  @override
  State<IndexDiscountPage> createState() => _IndexDiscountPageState();
}

class _IndexDiscountPageState extends State<IndexDiscountPage> {
  ApiService apiService = ApiService();
  List<Product> products = [];

  TextEditingController keyword = TextEditingController();
  Timer? _debounce;
  Timer? _debounceHit;

  bool isLoadProduct = true;
  int offset = 0;
  final int limit = 20;
  bool isLoadMore = false;
  bool hasMore = true;

  @override
  void initState(){
    super.initState();
    if (mounted) {
      _debounceHit = Timer(Duration(milliseconds: 500), () {
        fetchProducts(keyword.text);
      });
    }

    keyword.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 1000), () {
        isLoadProduct = true;
        fetchProducts(keyword.text);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _debounceHit?.cancel();
    keyword.dispose();
    super.dispose();
  }

  Future<void> fetchProducts(String text, {bool append = false}) async {
    // if (isLoadMore || !hasMore) return;
    try {
      if (!append) {
        offset = 0;
        setState(() {
          isLoadProduct = true;
        });
      } else {
        setState(() {
          isLoadMore = true;
        });
      }

      final data = await ApiService().fetchProducts(text, null, null, offset, limit);

      setState(() {
        if (append) {
          products.addAll(data);
        } else {
          products = data;
        }

        offset += limit;
        hasMore = data.length == limit;
        isLoadProduct = false;
        isLoadMore = false;
      });

    } catch (e) {
      if (mounted) {
        setState(() {
          isLoadProduct = false;
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

  Future<void> resetDiscount(int id) async {
    try {
      await ApiService().resetDiscount(id);
      if (mounted) {
        alertLottie(context, "Diskon berhasil direset!");
        fetchProducts(keyword.text);
      }
    } catch (e) {
      if (mounted) {
        showErrorBottomSheet(context, e.toString());
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
      body: RefreshIndicator(
        onRefresh: () async {
          fetchProducts(keyword.text);
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 45, left: 14, right: 14), 
              child: Column(
                children: [
                  PageTitle(text: "Diskon Produk"),
                  Gap(10),
                  Row(
                    children: [
                      Expanded(child: SearchTextField(controller: keyword, placeholder: "Cari berdasarkan nama produk...",)),
                      Gap(5),
                      QrScannerButton(controller: keyword)
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
                  buildListProducts(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildListProducts() {
    if (isLoadProduct == false && products.isEmpty) {
      return Column(
        children: [
          Gap(100),
          EmptyProduct.showEmptyProduct(),
          LabelSemiBold(text: "Data produk tidak ditemukan ..."),
        ],
      );
    }

    if (isLoadProduct == true) {
      return Column(
        children: [
          Gap(100),
          CustomLoader.showCustomLoader(),
        ],
      );
    }

    return Column(
      children: [
        ListView.builder(
          padding: EdgeInsets.all(0),
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: products.length,
          itemBuilder: (context, index){
            final product = products[index];
        
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/form-discount', arguments: product).then((value){
                  fetchProducts(keyword.text);
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 7,horizontal: 7),
                margin: EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: secondaryColor)
                ),
                child: Row(
                  children: [
                    Stack(
                      children : [ 
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
                        if(product.isDiscount && product.nominalDiscount != 0) ... [
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
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(
                                '${product.percentageDiscount}%',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontSize: 15
                                ),
                              ),
                            ),
                          )
                        ]
                      ]
                    ),
                    Gap(10),
                    Expanded(
                      child: Align(
                        alignment: Alignment.center,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            LabelSemiBoldMD(text: product.name),
                            Row(
                              children: [
                                if(product.nominalDiscount != 0) ... [
                                  Container(
                                    margin: EdgeInsets.symmetric(vertical: 3),
                                    padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: lightColor,
                                      borderRadius: BorderRadius.circular(5)
                                    ),
                                    child: Text(
                                      formatRupiah(product.realPrice),
                                      style: TextStyle(
                                        fontSize: 13,
                                        decoration: TextDecoration.lineThrough,
                                        decorationColor: dangerColor,
                                        decorationThickness: 2.1,
                                      ),
                                    ),
                                  ),
                                  Gap(5),
                                ],
                                PriceTag(text: formatRupiah(product.calculatedPrice)),
                              ],
                            ),
                            if(product.nominalDiscount != 0) ... [
                              DangerTag(text: 'Diskon : ${formatRupiah(product.nominalDiscount)}'),
                              Gap(5),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Gap(20),
                    if(product.isDiscount && product.nominalDiscount != 0)
                    GestureDetector(
                      onTap: () {
                        DialogHelper.customDialog(context: context, onConfirm: (){resetDiscount(product.id);}, title : "Reset Diskon", content: "Apakah Anda yakin ingin mereset diskon produk ${product.name}?", actionButton: true);
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 7),
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: red,
                          border: Border.all(color: red, width: 1),
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Icon(Icons.refresh, size: 15,color: Colors.white,)
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: 7),
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: secondaryColor, width: 1),
                        borderRadius: BorderRadius.circular(100)
                      ),
                      child: Icon(Icons.arrow_forward_rounded, size: 15,)
                    ),
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
                        fetchProducts(keyword.text, append: true);
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
}