import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiServiceTransaction apiServiceTransaction = ApiServiceTransaction();

  String thisMonthRevenue = "";
  String lastMonthRevenue = "";
  String totalPurchases = "";
  String grossProfit = "";
  String netProfit = "";
  String hpp = "";

  Timer? _debounceHit;

  @override
  void initState() {
    super.initState();
    loadRevenueFromStorage(); // Ambil data dari storage dulu
    _debounceHit = Timer(Duration(milliseconds: 500), () {
      getRevenue(); // Update data dari API setelah 1 detik
    });
  }

  @override
  void dispose() {
    _debounceHit?.cancel(); // Pastikan Timer dibatalkan saat widget dihancurkan
    super.dispose();
  }

  /// Ambil data revenue dari SharedPreferences
  Future<void> loadRevenueFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      thisMonthRevenue = prefs.getString('this_month_revenue') ?? "";
      lastMonthRevenue = prefs.getString('last_month_revenue') ?? "";
      totalPurchases = prefs.getString('total_purchases') ?? "";
      grossProfit = prefs.getString('gross_profit') ?? "";
      netProfit = prefs.getString('net_profit') ?? "";
      hpp = prefs.getString('hpp') ?? "";
    });
  }

  /// Simpan data revenue ke SharedPreferences
  Future<void> saveRevenueToStorage(String thisMonth, String lastMonth, String totalPurchases, String grossProfit, String netProfit, String hpp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('this_month_revenue', thisMonth);
    await prefs.setString('last_month_revenue', lastMonth);
    await prefs.setString('total_purchases', totalPurchases);
    await prefs.setString('gross_profit', grossProfit);
    await prefs.setString('net_profit', netProfit);
    await prefs.setString('hpp', hpp);
  }

  /// Ambil data revenue dari API
  Future<void> getRevenue() async {
    try {
      final data = await ApiServiceTransaction().getRevenue();
      if (mounted) {
        setState(() {
          thisMonthRevenue = data!['data']['this_month'];
          lastMonthRevenue = data['data']['last_month'];
          totalPurchases = data!['data']['total_purchases'];
          grossProfit = data!['data']['gross_profit'];
          netProfit = data!['data']['net_profit'];
          hpp = data!['data']['hpp'];
        });

        Logger().d(data);

        // Simpan data revenue ke storage setelah diambil dari API
        saveRevenueToStorage(thisMonthRevenue, lastMonthRevenue, totalPurchases, grossProfit, netProfit, hpp);
      }
    } catch (e) {
      Logger().d(e.toString());
      // ignore: use_build_context_synchronously
      showErrorBottomSheet(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await getRevenue(); // Update data saat refresh
        },
        color: primaryColor,
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.all(0),
          children: [
            Stack(
              children: [
                buildBackground(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: [Gap(44), buildLogo(), Gap(15), buildBalance()],
                  ),
                ),
              ],
            ),
            Gap(15),
            buildOtherIncome(),
            Gap(15),
            buildSectionFeatures(),
          ],
        ),
      ),
    );
  }

  Widget buildBackground() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xff344BBC),
            Color(0xff344BBC),
            Color(0xff273A99),
            Color(0xff273A99),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
    );
  }

  Widget buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset('assets/images/kekasir.png', width: 70),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Image.asset('assets/icons/menu.png', width: 23),
        ),
      ],
    );
  }

  Widget buildBalance() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pendapatan bulan ini", style: TextStyle(fontSize: 13)),
                  thisMonthRevenue.isEmpty
                      ? Container(
                        margin: EdgeInsets.only(top: 10),
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: primaryColor,
                        ),
                      )
                      : Text(
                        thisMonthRevenue,
                        key: ValueKey(thisMonthRevenue), // Perubahan revenue akan memicu animasi
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 20,
                        ),
                      ),
                ],
              ),
              GestureDetector(
                onTap:
                    () => Navigator.pushNamed(context, '/transaction/mutation'),
                child: Image.asset('assets/images/money.png', height: 28),
              ),
            ],
          ),
          Gap(10),
          Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Color(0xFFF3F5FB),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bulan Kemarin',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                lastMonthRevenue.isEmpty
                    ? SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    )
                    : Text(
                      lastMonthRevenue,
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSectionFeatures() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: Container(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/stock');
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/sections/stock.png', width: 55),
                  ),
                  Gap(5),
                  Text(
                    "Mutasi Stok",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/transaction/mutation');
              },
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/sections/transaction.png',
                      width: 55,
                    ),
                  ),
                  Gap(5),
                  Text(
                    "Mutasi Transaksi",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset('assets/sections/report.png', width: 55),
                ),
                Gap(5),
                Text(
                  "Laporan",
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildOtherIncome() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) {
              return StatefulBuilder(
                builder: (context, setModalState) {
                  return FractionallySizedBox(
                    heightFactor: 0.8,
                    child: Container(
                      padding: EdgeInsets.all(14),
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Align(
                            alignment: Alignment.topCenter,
                            child: Container(
                              height: 5,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Color(0xffced6e0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          Gap(15),
                          LabelSemiBold(text: "📌 Pendapatan bulan ini"),
                          Text(
                            thisMonthRevenue,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "📌 Pendapatan bulan lalu"),
                          Text(
                            lastMonthRevenue,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "💰 Total biaya modal barang yang sudah terjual (HPP)"),
                          Text(
                            hpp,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "💰 Total biaya pembelian barang (semua stok masuk)"),
                          Text(
                            totalPurchases,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "📈 Laba kotor (pendapatan - HPP)"),
                          Text(
                            grossProfit,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          LineXM(),
                          LabelSemiBold(text: "📊 Laba bersih (pendapatan - total modal pembelian)"),
                          Text(
                            netProfit,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: primaryColor
                            ),
                          ),
                          Gap(20),
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Color(0xfff6e58d)),
                              color: Color(0xfff6e58d).withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(10)
                            ),
                            child: Text("Jika laba bersih minus berarti jumlah pembelian barang lebih besar dari pendapatan yang diperoleh. Namun, ini bisa disebabkan oleh stok barang yang belum terjual. Jika barang yang sudah dibeli laku terjual, keuntungan akan meningkat.", style: TextStyle(
                              fontWeight: FontWeight.w600
                            )),
                          )
                        ],
                      ),
                    ),
                  );
                }
              );
            },
          );
        },
        child: Container(
          padding: EdgeInsets.only(top: 10, bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xff34495e),
                      borderRadius: BorderRadius.circular(100)
                    ),
                  ),
                  Gap(5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelSM(text: "Laba Kotor"),
                      LabelSemiBold(text: grossProfit,)
                    ],
                  ),
                ]
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      borderRadius: BorderRadius.circular(100)
                    ),
                  ),
                  Gap(5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelSM(text: "Laba Bersih"),
                      LabelSemiBold(text: netProfit,)
                    ],
                  ),
                ]
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Color(0xffe74c3c),
                      borderRadius: BorderRadius.circular(100)
                    ),
                  ),
                  Gap(5),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabelSM(text: "Total Belanja"),
                      LabelSemiBold(text: totalPurchases,)
                    ],
                  )
                ]
              )
            ],
          ),
        ),
      ),
    );
  }
}
