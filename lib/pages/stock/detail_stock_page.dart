import 'dart:async';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/apis/api_service_stock.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/currency_helper.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/models/product.dart';
import 'package:kekasir/models/stock.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';

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
  int? previousMonth = 0;

  String today = DateFormat('dd-MM-yyyy').format(DateTime.now());

  DateTime? _selected;

  Timer? _debounceHit;

  @override
  void initState() {
    super.initState();
    // Menjalankan kode setelah widget dibangun sepenuhnya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _debounceHit = Timer(Duration(milliseconds: 500), () {
        fetchMutation(widget.product!.id, today);
      });
    });
  }

  @override
  void dispose() {
    _debounceHit?.cancel(); // Pastikan Timer dibatalkan saat widget dihancurkan
    super.dispose();
  }

  Future<void> fetchMutation(int productId, String date) async {
    final data = await ApiServiceStock().fetchMutation(productId, date);    
    try {
      if (mounted) {
        setState(() {
          stocks = data.stockList;
          totalStockIn = data.totalStockIn;
          totalStockOut = data.totalStockOut;
          previousMonth = data.previousMonth;
          isLoading = false;
          availableStock = (totalStockIn! - totalStockOut! + data.previousMonth) as int?;
        }); 
      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    
    Future<void> showDate({
      required BuildContext context
    }) async {
      final selectedDate = await showMonthPicker(
        context: context,
        initialDate: _selected ?? DateTime.now(),
        firstDate: DateTime(2023),
        lastDate: DateTime(DateTime.now().year, DateTime.now().month),
      );

      if (selectedDate != null && _selected != selectedDate) {
        setState(() {
          isLoading = true;
          _selected = selectedDate;
          fetchMutation(widget.product!.id, selectedDate.toString());
        });
      }
    }

    return Scaffold(
      extendBodyBehindAppBar:true,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(0), // Ukuran AppBar jadi 0
        child: AppBar(
          backgroundColor: primaryColor, // Warna status bar
          elevation: 0, // Hilangkan bayangan
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: primaryColor, // Warna status bar
            statusBarIconBrightness: Brightness.light, // Ikon status bar terang
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: () async {
          fetchMutation(widget.product!.id, today);
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 45, left: 14, right: 14), 
              child: 
                PageTitle(text: "Detail Mutasi  - ${widget.product!.name.length > 16 ? '${widget.product?.name.substring(0, 16)}...' : widget.product?.name } ", back: true)
            ),
            Gap(10),
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(bottom: 45, left: 14, right: 14), 
                children: [
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: bgDanger),
                      color: Color(0xffFFF5E9),
                      borderRadius: BorderRadius.circular(10)
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, size: 20,),
                        Gap(5),
                        Text("Kekasir : menggunakan metode FIFO", style: TextStyle(
                          fontWeight: FontWeight.w600,
                        )),
                      ],
                    ),
                  ),
                  Gap(10),
                  LabelSemiBold(text: "Periode",),
                  ShortDesc(text: "Anda dapat menyesuaikan periode mutasi",),
                  Gap(5),
                  GestureDetector(
                    onTap: () async => showDate(context: context),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: secondaryColor),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.date_range, color: Color(0xffB1B9C3), size: 20,),
                          Gap(5),
                          _selected == null 
                          ? Text(DateFormat('MMMM yyyy', 'id_ID').format(DateTime.now()), style: TextStyle(fontSize: 15))
                          : Text(DateFormat('MMMM yyyy', 'id_ID').format(_selected!), style: TextStyle(fontSize: 15))
                        ],
                      ),
                    ),
                  ),
                  Gap(10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: secondaryColor),
                      color: ligthSky
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelSemiBold(text: "Total Perhitungan"),
                        Gap(8),
                        buildCounting(),
                      ],
                    )
                  ),
                  Gap(10),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ligthSky,
                      border: Border.all(color: secondaryColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelSemiBold(text: "Daftar Mutasi"),
                        Gap(8),
                        buildListDetailMutation(),
                        if(previousMonth != 0 && isLoading != true) ... [
                          LineXM(),
                          Container(
                            margin: EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.white,
                              border: Border.all(color: secondaryColor),
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
                                          padding: EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(5),
                                            color: secondaryColor,
                                          ),
                                          child: Center(
                                            child: Text("Sisa Stok", 
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 12
                                              )
                                            ),
                                          )
                                        ),
                                        Gap(10),
                                        Center(
                                          child: Text('$previousMonth Pcs', 
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                    Label(text: "Dari bulan sebelumnya")
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]
                      ],
                    )
                  ),
                ],
              ),
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
                    Expanded(
                      child: AutoSizeText(
                        "Stok Masuk",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        minFontSize: 10,
                      ),
                    ),
                    Icon(
                      Icons.arrow_downward_rounded,
                      color: Colors.white,
                      size: 15,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        Gap(10),
        Expanded(
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Color(0xffb71540),
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
                    Expanded(
                      child: AutoSizeText(
                        "Stok Keluar",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        minFontSize: 10,
                      ),
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
                    Expanded(
                      child: AutoSizeText(
                        "Tersisa",
                        maxLines: 1,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                        minFontSize: 10,
                      ),
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
              border: Border.all(color: secondaryColor),
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
                          padding: EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: stock.type == "in" ? Color(0xff4A92A9) : Color(0xffb71540),
                          ),
                          child: Center(
                            child: Text(stock.type == "in" ? "Masuk" : "Keluar", 
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12
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