import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';

class DetailMutationTransactionPage extends StatefulWidget {
  final dynamic id;
  const DetailMutationTransactionPage({super.key, this.id});

  @override
  State<DetailMutationTransactionPage> createState() => _DetailMutationTransactionPageState();
}

class _DetailMutationTransactionPageState extends State<DetailMutationTransactionPage> {
  ApiServiceTransaction apiServiceTransaction = ApiServiceTransaction();
  dynamic transaction;
  List order = [];
  bool isLoader = true;
  Timer? _debounceHit;

  @override
  void initState() {
    super.initState();
    _debounceHit = Timer(Duration(milliseconds: 500), () {
      detailTransaction();
    });
  }
  
  @override
  void dispose() {
    _debounceHit?.cancel(); // Pastikan Timer dibatalkan saat widget dihancurkan
    super.dispose();
  }

  Future<void> detailTransaction() async {
    final data = await ApiServiceTransaction().detailTransaction(widget.id);
    try {
      if (mounted) {
        setState(() {
          transaction = data;
          isLoader = false;
        });
      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoader == true ?
        Center(child: CustomLoader.showCustomLoader()) : ListView(
        padding: defaultPadding,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PageTitle(text: "Detail Transaksi", back: true),
              Label(text: transaction['created_at'],)
            ],
          ),
          Column(
            children: [
              Gap(15),
              buildListCart(),
              buildPayment(),
            ],
          )
        ],
      ),
    );
  }

  Widget buildListCart() {
    return Container(
      padding: EdgeInsets.only(left: 10, top: 10, right: 10),
      margin: EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: ligthSky,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: secondaryColor)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelSemiBoldMD(text: "Daftar Pesanan"),
          Gap(5),
          ListView.builder(
            padding: EdgeInsets.all(0),
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: transaction['details'].length,
            itemBuilder: (context, index) {
              final cartItem = transaction['details'][index];
      
              return Container(
                margin: EdgeInsets.only(bottom: 5),
                padding: EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: secondaryColor.withValues(alpha: 0.4), width: 1),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        cartItem['product']['image'] ?? "",
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
                    Gap(10),
                    SizedBox(
                      width: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabelSemiBold(text: cartItem['product']['name']),
                          ShortDesc(text: cartItem['product']['short_description'],),
                          Label(text: cartItem['price'].toString()),
                        ],
                      ),
                    ),
                    Gap(5),
                    SizedBox( // Ganti Expanded dengan SizedBox untuk jumlah item
                      child: Align(
                        alignment: Alignment.topRight,
                        child: LabelSemiBold(
                          text: '${cartItem['quantity']}x'
                        ),
                      ),
                    ),
                    Gap(25),
                    Expanded( // Pastikan subtotal punya lebar tetap
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: LabelSemiBold(text: cartItem['sub_total']),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Gap(5),
        ],
      ),
    );
  }

    Widget buildPayment() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ligthSky,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: secondaryColor)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LabelSemiBoldMD(text: "Ringkasan Pembayaran"),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Sub Total",),
              LabelSemiBoldMD(text: transaction['sub_total']),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Diskon",),
              LabelSemiBoldMD(text: "Rp 0"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Grand Total",),
              LabelSemiBoldMD(text: transaction['grand_total']),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Dibayar",),
              LabelSemiBoldMD(text: transaction['paid']),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Kembalian",),
              LabelSemiBoldMD(text: transaction['change']),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Label(text: "Metode Pembayaran",),
              LabelSemiBoldMD(text: transaction['payment_method']),
            ],
          ),
        ],
      ),
    );
  }
}