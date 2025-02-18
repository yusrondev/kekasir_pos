import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/utils/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
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
    );
  }

  Widget buildBackground() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xff344BBC),
            Color(0xff344BBC),
            Color(0xff273A99)
          ]
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30)
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
            'assets/images/sample-profile.png',
            width: 25,
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
                  Text("Rp 549.000", style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20
                  ))
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
                Text('Rp 450.000', style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600))
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
          Column(
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