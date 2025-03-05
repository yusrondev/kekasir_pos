import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';

class IndexPromoPage extends StatefulWidget {
  const IndexPromoPage({super.key});

  @override
  State<IndexPromoPage> createState() => _IndexPromoPageState();
}

class _IndexPromoPageState extends State<IndexPromoPage> {
  ApiService apiService = ApiService();
  List<Product> products = [];

  TextEditingController keyword = TextEditingController();
  Timer? _debounce;

  bool isLoadProduct = true;

  @override
  void initState(){
    super.initState();
    fetchProducts(keyword.text);

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
    keyword.dispose();
    super.dispose();
  }

  Future<void> fetchProducts(String keyword) async {
    final data = await ApiService().fetchProducts(keyword);
    try {
      if (mounted) {
        setState(() {
          isLoadProduct = false;
          products = data;
        });
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      showErrorBottomSheet(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: defaultPadding,
        children: [
          PageTitle(text: "Manajemen Promo"),
          Gap(15),
          SearchTextField(placeholder: "Cari berdasarkan nama produk...", controller: keyword),
          Gap(15),
          buildListProducts(),
        ],
      ),
    );
  }

  Widget buildListProducts() {
    if (isLoadProduct == true) {
      return Column(
        children: [
          Gap(100),
          CustomLoader.showCustomLoader(),
        ],
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: products.length,
      itemBuilder: (context, index){
        final product = products[index];

        return Container(
          padding: EdgeInsets.symmetric(vertical: 5,horizontal: 10),
          margin: EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Stack(
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
                        'assets/icons/gear.png',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  )
                ],
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
            ],
          ),
        );
      }
    );
  }
}