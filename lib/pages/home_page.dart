import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ApiServiceTransaction apiServiceTransaction = ApiServiceTransaction();

  String thisMonthRevenue = "";
  String lastMonthRevenue = "";

  @override
  void initState() {
    super.initState();
    getRevenue();
  }

  Future<void> getRevenue() async {
    final data = await ApiServiceTransaction().getRevenue();
    if (mounted) {
      setState(() {
        thisMonthRevenue = data!['data']['this_month'];
        lastMonthRevenue = data['data']['last_month'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primaryColor, // Warna status bar untuk halaman ini
      statusBarIconBrightness: Brightness.light, // Ikon terang
    ));

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            getRevenue();
          });
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
                    children: [
                      Gap(44),
                      buildLogo(),
                      Gap(15),
                      buildBalance(),
                    ],
                  )
                )
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
            Color(0xff273A99)
          ]
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20)
        )
      ),
    );
  }

  Widget buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          'assets/images/kekasir.png',
          width: 70,
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/profile');
          },
          child: Image.asset(
            'assets/icons/menu.png',
            width: 23,
          ),
        )
      ],
    );
  }

  Widget buildBalance() {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15)
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pendapatan Bulan Ini", style: TextStyle(
                    fontSize: 13
                  )),
                  thisMonthRevenue == ""
                  ? Container(
                      margin: EdgeInsets.only(top: 10),
                      width: 15,
                      height: 15,
                      child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                    )
                  : Text(
                      thisMonthRevenue,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
                    )
                ],
              ),
              Image.asset('assets/images/money.png',height: 28)
            ],
          ),
          Gap(10),
          Container(
            padding: EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Color(0xFFF3F5FB),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Bulan Kemarin', style: TextStyle(color: primaryColor)),
                lastMonthRevenue == "" ? SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                ) :
                Text(lastMonthRevenue, style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600))
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildSectionFeatures() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround ,
        children: [
          InkWell(
            onTap: () {
              Navigator.pushNamed(context, '/stock');
            },
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.asset(
                    'assets/sections/stock.png',
                    width: 55,
                  ),
                ),
                Gap(5),
                Text(
                  "Mutasi Stok", 
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600
                  )
                )
              ],
            ),
          ),
          InkWell(
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
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600
                  )
                )
              ],
            ),
          ),
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.asset(
                  'assets/sections/report.png',
                  width: 55,
                ),
              ),
              Gap(5),
              Text(
                "Laporan", 
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600
                )
              )
            ],
          ),
        ],
      ),
    );
  }
}