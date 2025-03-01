import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';

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

  @override
  void initState() {
    super.initState();
    detailTransaction();
  }

  Future<void> detailTransaction() async {
    final data = await ApiServiceTransaction().detailTransaction(widget.id);
    if (mounted) {
      setState(() {
        transaction = data;
        isLoader = false;
      });
    }
    Logger().d(transaction['details']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoader == true ?
        Center(child: CustomLoader.showCustomLoader()) : ListView(
        padding: defaultPadding,
        children: [
          PageTitle(text: "Detail Transaksi", back: true),
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
        borderRadius: BorderRadius.circular(10)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LabelSemiBoldMD(text: "Daftar Pesanan"),
              Label(text: transaction['created_at'],)
            ],
          ),
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
                        cartItem['product']['image'],
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
                          LabelSemiBold(text: cartItem['price'].toString()),
                        ],
                      ),
                    ),
                    Gap(5),
                    SizedBox( // Ganti Expanded dengan SizedBox untuk jumlah item
                      child: Align(
                        alignment: Alignment.topRight,
                        child: LabelSemiBoldMD(
                          text: '${cartItem['quantity']}x'
                        ),
                      ),
                    ),
                    Gap(25),
                    Expanded( // Pastikan subtotal punya lebar tetap
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: LabelSemiBoldMD(text: cartItem['sub_total']),
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
        borderRadius: BorderRadius.circular(10)
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