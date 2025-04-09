import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_printer/flutter_bluetooth_printer_library.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
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

  ReceiptController? controller;

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
        body: Expanded(
          child: Receipt(
            backgroundColor: Colors.white,
            builder: (context) => Column(
            children: [
              Column(
                children: [
                  Image.asset(
                    'assets/images/kekasir-black.png',
                    width: 100,
                  ),
                  Gap(13),
                  Text(data['code'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 23),)
                ],
              ),
              Container(
                margin: EdgeInsets.symmetric(vertical: 7),
                width: double.infinity,
                height: 2,
                decoration: BoxDecoration(
                  color: Colors.black
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 160,child: Text(data['merchant_name'], style: TextStyle(fontWeight: FontWeight.w600))),
                          SizedBox(width: 200,child: Text(data['merchant_address'] ?? "", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)))
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(formattedDate, style: TextStyle(fontWeight: FontWeight.w600)),
                          Text(formattedTime, style: TextStyle(fontWeight: FontWeight.w600))
                        ],
                      ),
                    ],
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 7),
                    width: double.infinity,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.black
                    ),
                  ),
                  buildProductList(),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 7),
                    width: double.infinity,
                    height: 2,
                    decoration: BoxDecoration(
                      color: Colors.black
                    ),
                  ),
                  buildpaymentSummary(),
                  Gap(100)
                ],
              ),
            ],
          ), onInitialized: (ctrl) {
            setState(() {
              controller = ctrl;
            });
          }),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 30),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () { 
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => AppLayout()),
                      (route) => false, // Menghapus semua route yang ada
                    );
                  },
                  child: ButtonPrimaryOutline(
                    text: "Selesai",
                  )
                ),
              ),
              Gap(10),
              Expanded(
                child: GestureDetector(
                  onTap: () { 
                    printReceipt();
                  },
                  child: ButtonPrimary(
                    text: "Cetak",
                  )
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> printReceipt() async {
    final device = await FlutterBluetoothPrinter.selectDevice(context);
    if (device != null) {
      await controller!.print(address: device.address);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Struk dicetak!")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memilih printer")));
    }
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
                  SizedBox(width: 150,child: Text('${detail['product']['name']}', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 23))),
                  Text(detail['product']['price'],style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22))
                ],
              ),
              Center(
                child: Text('(${detail['quantity']})', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
              ),
              Center(child: Text(detail['sub_total'], style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22)))
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
              Text("Sub Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 23)),
              Text(subTotal.toString(),style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22))
            ],
          ),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Diskon", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 23)),
              Text(discount.toString(),style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22))
            ],
          ),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Grand Total", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 23)),
              Text(grandTotal.toString(),style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22))
            ],
          ),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Dibayar", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 23)),
              Text(paid.toString(),style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22))
            ],
          ),
          Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Kembalian", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 23)),
              Text(change.toString(),style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22))
            ],
          ),
          Gap(5),
        ],
      ),
    );
  }
}