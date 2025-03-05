import 'dart:async';

import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
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
  Timer? _debounceHit;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _debounceHit = Timer(Duration(milliseconds: 500), () {
        fetchProducts(searchField.text);
      });
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
    _debounceHit?.cancel(); // Pastikan Timer dibatalkan saat widget dihancurkan
    super.dispose();
  }

  Future<void> fetchProducts(String text) async {
    final data = await ApiService().fetchProducts(searchField.text);
    logger.d(data);
    if (!mounted) return; // Pastikan widget masih ada sebelum setState
    try {
      setState(() {
        products = data;
        isLoading = false;
      });
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  deleteProduct(id) async {
    final delete = await ApiService().deleteProduct(id);
    logger.i(delete);
    try {
      if (mounted) {
        setState(() {
          fetchProducts(searchField.text);
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
        child: ListView(
          padding: defaultPadding,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                PageTitle(text: "Data Produk"),
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/create-product').then((value){
                      if (value == true) {
                        fetchProducts(searchField.text);
                      }
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:BorderRadius.circular(100) 
                    ),
                    child: Icon(Icons.add, color: Colors.black,size: 24)
                  ),
                )
              ],
            ),
            Gap(10),
            SearchTextField(controller: searchField, placeholder: "Cari berdasarkan nama produk...",),
            Gap(14),
            buildProductList()
          ],
        ),
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
        mainAxisExtent: 190
      ), 
      itemBuilder: (context, index){
        final product = products[index];
        return GestureDetector(
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
                Center(
                  child: SizedBox(
                    width: 160,
                    height: 100,
                    child: Stack(
                      children: [
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              product.image,
                              width: 160,
                              height: 160,
                              fit: BoxFit.fitWidth,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/empty.png', 
                                  width: 155,
                                  height: 155,
                                  fit: BoxFit.fitWidth
                                );
                              },
                            )
                          ),
                        ),
                        StockBadge(availableStock: product.availableStock)
                      ],
                    ),
                  ),
                ),
                Gap(product.shortDescription == "" ? 20 : 3),
                ProductName(text: product.name),
                if(product.shortDescription != "") ... [
                  ShortDesc(text: product.shortDescription),
                  Gap(5),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LabelSemiBold(text: formatRupiah(product.price), primary: true,),
                    GestureDetector(
                      onTap: () {
                        DialogHelper.showDeleteConfirmation(context: context, onConfirm: () => deleteProduct(product.id), content: product.name);
                      },
                      child: Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Color(0xffF2F4F8),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.black,
                          size: 17,
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