import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
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
      _debounce = Timer(Duration(milliseconds: 3000), () {
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
          child: Text(product.name),
        );
      }
    );
  }
}