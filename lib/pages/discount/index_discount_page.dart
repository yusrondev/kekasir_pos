import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';

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
          PageTitle(text: "Diskon Produk"),
          Gap(15),
          SearchTextField(placeholder: "Cari berdasarkan nama produk...", controller: keyword),
          Gap(10),
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
            ),
            child: Row(
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
                                  formatRupiah(product.price),
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
                            PriceTag(text: formatRupiah(product.price - product.nominalDiscount)),
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
    );
  }
}