import 'dart:async';

import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:logger/logger.dart';

class IndexProductPage extends StatefulWidget {
  const IndexProductPage({super.key});

  @override
  State<IndexProductPage> createState() => _IndexProductPageState();
}

class _IndexProductPageState extends State<IndexProductPage> {
  ApiService apiService = ApiService();
  List<Product> products = [];
  bool isLoading = true;

  var logger = Logger();

  TextEditingController searchField = TextEditingController();

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      fetchProducts(searchField.text);
    }

    searchField.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 500), () {
        fetchProducts(searchField.text);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchField.dispose();
    super.dispose();
  }

  Future<void> fetchProducts(String text) async {
    final data = await ApiService().fetchProducts(searchField.text);
    logger.d(data);
    if (!mounted) return; // Pastikan widget masih ada sebelum setState
    setState(() {
      products = data;
      isLoading = false;
    });
  }

  deleteProduct(id) async {
    final delete = await ApiService().deleteProduct(id);
    logger.i(delete);
    if (mounted) {
      setState(() {
        fetchProducts(searchField.text);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: defaultPadding,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PageTitle(text: "Data Produk"),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/create-product').then((value){
                    if (value == true) {
                      fetchProducts(searchField.text);
                    }
                  });
                },
                child: Icon(Icons.add_box_rounded, color: primaryColor,size: 30),
              )
            ],
          ),
          Gap(10),
          SearchTextField(controller: searchField, placeholder: "Cari berdasarkan nama produk...",),
          Gap(14),
          buildProductList()
        ],
      )
    );
  }

  Widget buildProductList(){
    return isLoading ? Column(
      children: [
        Gap(100),
        CustomLoader.showCustomLoader(),
      ],
    ) : GridView.builder(
      padding: EdgeInsets.all(0),
      itemCount: products.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        mainAxisExtent: 248
      ), 
      itemBuilder: (context, index){
        final product = products[index];
        return InkWell(
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
            padding: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(10),
                Stack(
                  children: [
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: isLoading ? 
                          Image.asset(
                            'assets/images/empty.png', 
                            width: 155,
                            height: 155,
                            fit: BoxFit.fitWidth
                          )
                          : Image.network(
                            product.image,
                            width: 155,
                            height: 155,
                            fit: BoxFit.fitWidth,
                          )
                      ),
                    ),
                    StockBadge(availableStock: product.availableStock)
                  ],
                ),
                Gap(8),
                ProductName(text: product.name),
                ShortDesc(text: product.shortDescription),
                Gap(5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LabelSemiBold(text: formatRupiah(product.price),),
                    InkWell(
                      onTap: () {
                        DialogHelper.showDeleteConfirmation(context: context, onConfirm: () => deleteProduct(product.id), content: product.name);
                      },
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: dangerColor,
                          borderRadius: BorderRadius.circular(5)
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      }
    );
  }
}