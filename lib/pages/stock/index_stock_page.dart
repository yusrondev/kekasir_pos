import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';

class IndexStockPage extends StatefulWidget {
  const IndexStockPage({super.key});

  @override
  State<IndexStockPage> createState() => _IndexStockPageState();
}

class _IndexStockPageState extends State<IndexStockPage> {
  ApiService apiService = ApiService();
  List<Product> products = [];
  TextEditingController keyword = TextEditingController();
  bool isLoading = true;

  Timer? _debounce;
  Timer? _debounceHit;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _debounceHit = Timer(Duration(milliseconds: 500), () {
        fetchProducts(keyword.text);
      });
    }

    keyword.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 500), () {
        fetchProducts(keyword.text);
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

  Future<void> fetchProducts(String keyword) async {
    final data = await ApiService().fetchProducts(keyword);
    Logger().d(data);
    try {
      if(mounted){
        setState(() {
          products = data;
          isLoading = false;
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
          await fetchProducts(keyword.text);
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: ListView(
          padding: defaultPadding,
          children: [
            PageTitle(text: "Mutasi Stok", back: true),
            Gap(15),
            SearchTextField(placeholder: "Cari berdasarkan nama produk...", controller: keyword),
            Gap(10),
            buildListProduct(),
          ],
        ),
      ),
    );
  }

  Widget buildListProduct() {
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
      ) : ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index){
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/stock-detail', arguments: product);
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: secondaryColor)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        product.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.fitWidth,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/images/empty.png', 
                            width: 60,
                            height: 60,
                            fit: BoxFit.fitWidth
                          );
                        },
                      )
                    ),
                    Gap(10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(width: 150,child: LabelSemiBoldMD(text: product.name)),
                        Gap(2),
                        SizedBox(width: 150,child: Label(text: formatRupiah(product.price)))
                      ],
                    ),
                  ],
                ),
                StockBadge(availableStock: product.availableStock),
              ],
            ),
          ),
        );
      }
    );
  }
}