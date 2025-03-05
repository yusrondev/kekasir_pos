import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
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
    });
  }

  /// Simpan data revenue ke SharedPreferences
  Future<void> saveRevenueToStorage(String thisMonth, String lastMonth) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('this_month_revenue', thisMonth);
    await prefs.setString('last_month_revenue', lastMonth);
  }

  /// Ambil data revenue dari API
  Future<void> getRevenue() async {
    try {
      final data = await ApiServiceTransaction().getRevenue();
      if (mounted) {
        setState(() {
          thisMonthRevenue = data!['data']['this_month'];
          lastMonthRevenue = data['data']['last_month'];
        });

        // Simpan data revenue ke storage setelah diambil dari API
        saveRevenueToStorage(thisMonthRevenue, lastMonthRevenue);
      }
    } catch (e) {
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
                  Text("Pendapatan Bulan Ini", style: TextStyle(fontSize: 13)),
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
        padding: EdgeInsets.only(top: 15, bottom: 15),
        decoration: BoxDecoration(
          color: ligthSky,
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
}
