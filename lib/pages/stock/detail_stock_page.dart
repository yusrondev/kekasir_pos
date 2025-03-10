import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_stock.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/models/stock.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';

class DetailStockPage extends StatefulWidget {
  final Product? product;
  const DetailStockPage({super.key, this.product});
  @override
  State<DetailStockPage> createState() => _DetailStockPageState();
}

class _DetailStockPageState extends State<DetailStockPage> {
  ApiServiceStock apiServiceStock = ApiServiceStock();
  List<Stock> stocks = [];
  bool isLoading = true;
  num? totalStockIn = 0;
  num? totalStockOut = 0;
  int? availableStock = 0;

  Timer? _debounceHit;

  @override
  void initState() {
    super.initState();
    // Menjalankan kode setelah widget dibangun sepenuhnya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debounceHit = Timer(Duration(milliseconds: 500), () {
        fetchMutation(widget.product!.id);
      });
    });
  }

  @override
  void dispose() {
    _debounceHit?.cancel(); // Pastikan Timer dibatalkan saat widget dihancurkan
    super.dispose();
  }

  Future<void> fetchMutation(int productId) async {
    final data = await ApiServiceStock().fetchMutation(productId);    
    try {
      if (mounted) {
        setState(() {
          stocks = data.stockList;
          totalStockIn = data.totalStockIn;
          totalStockOut = data.totalStockOut;
          isLoading = false;
          availableStock = (totalStockIn! - totalStockOut!) as int?;
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
          fetchMutation(widget.product!.id);
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: ListView(
          padding: defaultPadding,
          children: [
            PageTitle(text: "Detail Mutasi  - ${widget.product!.name.length > 10 ? '${widget.product?.name.substring(0, 10)}...' : widget.product?.name } ", back: true),
            Gap(15),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ligthSky
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelSemiBold(text: "Total Perhitungan Stok"),
                  Gap(8),
                  buildCounting(),
                ],
              )
            ),
            Gap(15),
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: ligthSky
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LabelSemiBold(text: "Daftar Mutasi"),
                  Gap(8),
                  buildListDetailMutation(),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCounting(){
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xff4A92A9),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$totalStockIn", 
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                    overflow: TextOverflow.ellipsis,
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Stok Masuk", 
                      maxLines: 1,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        overflow: TextOverflow.ellipsis,
                      )
                    ),
                    Icon(Icons.arrow_downward_rounded, color: Colors.white, size: 15,)
                  ],
                ),
              ],
            ),
          ),
        ),
        Gap(10),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xfffc5c65),
              borderRadius: BorderRadius.circular(8)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$totalStockOut", 
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                    overflow: TextOverflow.ellipsis,
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Stok Keluar", style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13
                      )
                    ),
                    Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 15,)
                  ],
                ),
              ],
            ),
          ),
        ),
        Gap(10),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$availableStock", 
                  maxLines: 1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 25,
                    overflow: TextOverflow.ellipsis,
                  )
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Tersisa", style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontSize: 13
                      )
                    ),
                    Icon(Icons.check, color: kekasirColor, size: 15,)
                  ],
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget buildListDetailMutation() {
    return isLoading ? Center(
        child: CustomLoader.showCustomLoader(),
      ) : ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: stocks.length,
      itemBuilder: (context, index){
        final stock = stocks[index];

        return GestureDetector(
          onTap: () {
            if (stock.transactionId != null) {
              Navigator.pushNamed(
                context,
                '/transaction/detail',
                arguments: stock.transactionId
              );
            }
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 10),
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              border: Border.all(color: secondaryColor.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 60,
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: stock.type == "in" ? Color(0xff4A92A9) : Color(0xfffc5c65),
                          ),
                          child: Center(
                            child: Text(stock.type == "in" ? "Masuk" : "Keluar", 
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14
                              )
                            ),
                          )
                        ),
                        Gap(10),
                        Center(
                          child: Text('${stock.quantity.toString()} Pcs', 
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14
                            )
                          ),
                        ),
                      ],
                    ),
                    Label(text: stock.createdAt)
                  ],
                ),
                if(stock.description != '' && stock.costPrice == 0) ... [
                  LineSM(),
                  ShortDescSM(text : stock.description, maxline: 5,),
                ] else if(stock.description != '' && stock.costPrice != 0) ... [
                  LineSM(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShortDescSM(text : stock.description, maxline: 5,),
                      PriceTag(text: 'Harga beli : ${formatRupiah(stock.costPrice)}'),
                    ],
                  ),
                ]else ... [
                  LineSM(),
                  PriceTag(text: 'Harga beli : ${formatRupiah(stock.costPrice)}'),
                ]
              ],
            ),
          ),
        );
      }
    );
  }
}