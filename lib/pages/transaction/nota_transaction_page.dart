import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/logger.dart';

class NotaTransactionPage extends StatefulWidget {
  const NotaTransactionPage({super.key});

  @override
  State<NotaTransactionPage> createState() => _NotaTransactionPageState();
}

class _NotaTransactionPageState extends State<NotaTransactionPage> {

  String? subTotal;
  String? grandTotal;
  String? discount;
  String? paid;
  String? change;

  List details = [];
  
  @override
  Widget build(BuildContext context) {

    final transaction = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final data = transaction!['data'][0];

    Logger().d(data);

    DateTime parsedDate = DateTime.parse(data['created_at']).toLocal();
    String formattedDate = DateFormat("d MMMM yyyy", "id_ID").format(parsedDate);
    String formattedTime = DateFormat("HH:mm", "id_ID").format(parsedDate);
    
    setState(() {
      subTotal = data['sub_total'];
      grandTotal = data['grand_total'];
      discount = data['discount'];
      paid = data['paid'];
      change = data['change'];
      details = data['details'];
    });
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => AppLayout()),
          (route) => false, // Menghapus semua route yang ada
        );
        return true; // Tambahkan ini untuk menghindari error
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: ListView(
          padding: defaultPadding,
          children: [
            Column(
              children: [
                Image.asset(
                  'assets/images/kekasir-black.png',
                  width: 60,
                ),
                Gap(13),
                Label(text: data['code'],)
              ],
            ),
            LineSM(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LabelSemiBold(text: data['merchant_name']),
                        // ShortDesc(text: "Alamat Toko",)
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        LabelSemiBold(text: formattedDate),
                        ShortDesc(text: formattedTime)
                      ],
                    ),
                  ],
                ),
                LineSM(),
                LabelSemiBold(text: "Daftar Pesanan",),
                buildProductList(),
                LineSM(),
                LabelSemiBold(text: "Detail Pembayaran",),
                buildpaymentSummary()
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProductList() {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: details.length,
      itemBuilder: (context, index){

        final detail = details[index];

        return Container(
          margin: EdgeInsets.symmetric(vertical: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Label(text: '${detail['product']['name']} (${detail['quantity']})'),
                  Label(text: detail['product']['price'],)
                ],
              ),
              LabelSemiBold(text: detail['sub_total'],)
            ],
          ),
        );

      }
    );
  }
  
  Widget buildpaymentSummary() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Sub Total"),
              LabelSemiBold(text: subTotal,)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Diskon"),
              LabelSemiBold(text: discount,)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Grand Total"),
              LabelSemiBold(text: grandTotal,)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Dibayar"),
              LabelSemiBold(text: paid,)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Kembalian"),
              LabelSemiBold(text: change,)
            ],
          ),
        ],
      ),
    );
  }
}