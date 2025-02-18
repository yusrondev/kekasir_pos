import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/helpers/dialog_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';

class IndexProductPage extends StatefulWidget {
  const IndexProductPage({super.key});

  @override
  State<IndexProductPage> createState() => _IndexProductPageState();
}

class _IndexProductPageState extends State<IndexProductPage> {
  ApiService apiService = ApiService();
  List<Product> products = [];

  TextEditingController searchField = TextEditingController();

  @override
  void initState(){
    super.initState();
    fetchProducts(searchField.text);

    searchField.addListener(() {
      // Jika teks berubah, panggil fetchProducts
      fetchProducts(searchField.text);
    });
  }

  Future<void> fetchProducts(String text) async {
    final data = await ApiService().fetchProducts(searchField.text);
    if (!mounted) return; // Pastikan widget masih ada sebelum setState
    setState(() {
      products = data;
    });
  }

  deleteProduct(id) async {
    await ApiService().deleteProduct(id);
    setState(() {
      fetchProducts(searchField.text);
    });
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
    return products.isEmpty ? Column(
      children: [
        Gap(200),
        Icon(Icons.production_quantity_limits, size: 30,),
        Gap(10),
        LabelSemiBold(text: "Belum ada produk di sini...",)
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
                        child: Image.network(
                          product.image,
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