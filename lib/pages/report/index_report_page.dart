import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/components/custom_field_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';

class IndexReportPage extends StatefulWidget {
  const IndexReportPage({super.key});

  @override
  State<IndexReportPage> createState() => _IndexReportPageState();
}

class _IndexReportPageState extends State<IndexReportPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Padding(
          padding: defaultPadding,
          child: Column(
            children: [
              PageTitle(text: "Laporan", back: true,),
              Gap(5),
              const TabBar(
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                
                tabs: [
                  Tab(text: "Produk"),
                  Tab(text: "Transaksi"),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.only(top: 10),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 200, // Sesuaikan tinggi agar cukup ruang
                      child: const TabBarView(
                        children: [
                          Column(
                            children: [
                              CustomTextField(label: "Produk")
                            ],
                          ),
                          Center(child: Icon(Icons.directions_transit, size: 100)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
