import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service.dart';
import 'package:kekasir/apis/api_service_cart.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/logger.dart';

class IndexTransactionPage extends StatefulWidget {
  const IndexTransactionPage({super.key});

  @override
  State<IndexTransactionPage> createState() => _IndexTransactionPageState();
}

class _IndexTransactionPageState extends State<IndexTransactionPage> {
  ApiService apiService = ApiService();
  ApiServiceCart apiServiceCart = ApiServiceCart();

  List<Product> products = [];
  List<int> quantities = []; // Menyimpan jumlah produk untuk setiap item
  String grandTotal = "Rp 0";

  TextEditingController keyword = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      fetchProducts(keyword.text);
      totalPrice();
    }

    keyword.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(Duration(milliseconds: 500), () {
        fetchProducts(keyword.text);
        totalPrice();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    keyword.dispose();
    super.dispose();
  }

  Future<void> totalPrice() async {
    await Future.delayed(Duration(milliseconds: 300)); // Tambahkan delay untuk memastikan data siap

    final totalPrice = await ApiServiceCart().totalPrice();

    if (mounted) {
      setState(() {
        grandTotal = totalPrice;
      });
      Logger().d('Total Price: $totalPrice');
    }
  }

  Future<void> fetchProducts(String keyword) async {
    final data = await ApiService().fetchProducts(keyword);
    if (mounted) {  
      setState(() {
        products = data;
        quantities = List.generate(products.length, (index) => products[index].quantity); // Default jumlah 0
      });
    }
  }

  void _updateCart(int index, int quantity) async {
    try {
      await ApiServiceCart().updateCart(products[index].id, quantity);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  void _increment(int index) {
    setState(() {
      if (quantities[index] < products[index].availableStock) {
        quantities[index]++;
      }
    });
    _updateCart(index, quantities[index]);
    totalPrice();
  }

  void _decrement(int index) {
    setState(() {
      if (quantities[index] != 0) {
        quantities[index]--;
      }
    });
    _updateCart(index, quantities[index]);
    totalPrice();
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
            PageTitle(text: "Tambah Transaksi"),
            Gap(10),
            SearchTextField(placeholder: "Cari berdasarkan nama produk...", controller: keyword),
            Gap(10),
            buildProductList(),
          ],
        ),
      ),
      bottomNavigationBar: buildGrandtotal(),
    );
  }

  Widget buildProductList() {
    if (products.isEmpty) {
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
      itemBuilder: (context, index) {
        final product = products[index];

        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(7),
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
                  width: 60,
                  height: 60,
                  fit: BoxFit.fitWidth,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      'assets/images/empty.png', 
                      width: 60,
                      height: 60,
                      fit: BoxFit.fitWidth,
                    );
                  },
                ),
              ),
              Gap(5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelSemiBoldMD(text: product.name),
                    ShortDesc(text: product.shortDescription, maxline: 2),
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
              Gap(5),
              // Bagian Quantity (Plus Minus)
              Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: lightColor,
                        radius: 20,
                        child: IconButton(
                          iconSize: 15,
                          highlightColor: lightColor,
                          icon: Icon(Icons.remove, color: primaryColor),
                          onPressed: () => _decrement(index),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          controller: TextEditingController(text: quantities[index].toString()),
                          decoration: InputDecoration(
                            counterText: "",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                        backgroundColor: lightColor,
                        radius: 20,
                        child: IconButton(
                          iconSize: 15,
                          icon: Icon(Icons.add, color: primaryColor),
                          onPressed: () => _increment(index),
                        ),
                      ),
                    ],
                  ),
                  LabelSemiBold(text: formatRupiah(product.price * quantities[index])),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildGrandtotal() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: primaryColor,
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
                  "Total Harga",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12
                  ),
                ),
                Text(
                  '$grandTotal',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 18
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10)
              ),
              child: Text("Checkout", style: TextStyle(
                fontSize: 12,
                color: primaryColor,
                fontWeight: FontWeight.w600
              ),),
            )
          ],
        ),
      ),
    );
  }
}
