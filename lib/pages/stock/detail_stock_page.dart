import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_stock.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/stock.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/logger.dart';

class DetailStockPage extends StatefulWidget {
  const DetailStockPage({super.key});

  @override
  State<DetailStockPage> createState() => _DetailStockPageState();
}

class _DetailStockPageState extends State<DetailStockPage> {
  ApiServiceStock apiServiceStock = ApiServiceStock();
  List<Stock> stocks = [];
  int? productId;
  bool isLoading = true;
  int? totalStockIn = 0;
  int? totalStockOut = 0;

  @override
  void initState() {
    super.initState();
    // Menjalankan kode setelah widget dibangun sepenuhnya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null && args is int) {
        setState(() {
          productId = args;
        });
        fetchMutation(productId!);
      }
    });
  }

  Future<void> fetchMutation(int productId) async {
    final data = await ApiServiceStock().fetchMutation(productId);
    setState(() {
      stocks = data.stockList;
      totalStockIn = data.totalStockIn;
      totalStockOut = data.totalStockOut;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          fetchMutation(productId!);
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: ListView(
          padding: defaultPadding,
          children: [
            PageTitle(text: "Detail Mutasi", back: true),
            Gap(15),
            buildCounting(),
            Gap(15),
            buildListDetailMutation(),
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
              color: bgSuccess,
              border: Border.all(color: successColor),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                Text("Total Stok Masuk", style: TextStyle(
                    color: successColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13
                  )
                ),
                Text("$totalStockIn", style: TextStyle(
                    color: successColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 25
                  )
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
              color: bgDanger,
              border: Border.all(color: dangerColor),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Column(
              children: [
                Text("Total Stok Keluar", style: TextStyle(
                    color: dangerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 13
                  )
                ),
                Text("$totalStockOut", style: TextStyle(
                    color: dangerColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 25
                  )
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget buildListDetailMutation() {
    return isLoading ? Column(
        children: [
          Gap(100),
          CustomLoader.showCustomLoader(),
        ],
      ) : ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: stocks.length,
      itemBuilder: (context, index){
        final stock = stocks[index];

        return Container(
          margin: EdgeInsets.only(bottom: 10),
          padding: EdgeInsets.all(7),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white
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
                          color: stock.type == "in" ? bgSuccess : bgDanger,
                        ),
                        child: Center(
                          child: Text(stock.type == "in" ? "Masuk" : "Keluar", 
                            style: TextStyle(
                              color: stock.type == "in" ? successColor : dangerColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 14
                            )
                          ),
                        )
                      ),
                      Gap(10),
                      Center(
                        child: Text(stock.quantity.toString(), 
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
              if(stock.description != '') ... [
                LineSM(),
                ShortDesc(text : stock.description, maxline: 5),
              ]
            ],
          ),
        );
      }
    );
  }
}