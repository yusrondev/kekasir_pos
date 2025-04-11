import 'dart:async';
import 'dart:convert';

import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/apis/api_service_transaction.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/components/custom_other_component.dart';
import 'package:kekasir/components/custom_text_component.dart';
import 'package:kekasir/helpers/lottie_helper.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/services/printer_service.dart';
import 'package:kekasir/utils/colors.dart';
import 'package:kekasir/utils/ui_helper.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/web.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetailMutationTransactionPage extends StatefulWidget {
  final dynamic id;
  const DetailMutationTransactionPage({super.key, this.id});

  @override
  State<DetailMutationTransactionPage> createState() => _DetailMutationTransactionPageState();
}

class _DetailMutationTransactionPageState extends State<DetailMutationTransactionPage> {
  ApiServiceTransaction apiServiceTransaction = ApiServiceTransaction();
  final PrinterService _printerService = PrinterService();
  dynamic transaction;
  List order = [];
  bool isLoader = true;
  Timer? _debounceHit;

  List<BluetoothDevice> _devices = [];
  List<Map<String, dynamic>> items = [];

  BluetoothDevice? _selectedDevice;
  bool _isConnecting = false;
  bool _isPrinting = false;

  String subTotal = '0';
  String grandTotal = '0';
  String discount = '0';
  String paid = '0';
  String change = '0';
  String transactionDate = '';
  String transactionTime = '';

  dynamic details;

  final Logger _logger = Logger();

  @override
  void initState() {
    super.initState();
    _debounceHit = Timer(Duration(milliseconds: 500), () {
      detailTransaction();
    });
    _loadDevices();
    _loadSelectedDevice();
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
          subTotal = transaction['sub_total']?.toString() ?? '0';
          grandTotal = transaction['grand_total']?.toString() ?? '0';
          discount = transaction['discount']?.toString() ?? '0';
          paid = transaction['paid']?.toString() ?? '0';
          change = transaction['change']?.toString() ?? '0';
          details = transaction['details'];

          transactionDate = transaction['created_date'];
          transactionTime = transaction['created_time'];

        });

        items = convertDetailsToItems(details);

        Logger().d(transaction);
      }
    } catch (e) {
      showErrorBottomSheet(context, e.toString());
    }
  }

  Future<void> _printTest() async {
    setState(() => _isPrinting = true);
    try {
      await _printerService.printReceipt(
        invoiceNumber: '${transaction['code']}',
        items: items,
        total: int.tryParse(grandTotal.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        payment: int.tryParse(paid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        change: int.tryParse(change.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        merchantName: transaction['merchant_name'],
        merchantAddress: transaction['merchant_address'],
        transactionDate: transactionDate,
        transactionTime : transactionTime
      );
    } catch (e) {
      _logger.e('Print error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPrinting = false);
      }
    }
  }

  Future<void> _loadDevices() async {
    final devices = await _printerService.getPairedDevices();
    setState(() => _devices = devices);
  }

  Future<void> _connectDevice() async {
    if (_selectedDevice == null) return;

    setState(() => _isConnecting = true);

    // Putuskan koneksi jika sebelumnya sudah terkoneksi
    await _printerService.disconnect();

    // Coba hubungkan kembali
    final success = await _printerService.connect(_selectedDevice!);
    setState(() => _isConnecting = false);

    if (success) {
      await _saveSelectedDevice(_selectedDevice!);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menghubungkan printer')),
        );
      }
    }
  }

  Future<void> _saveSelectedDevice(BluetoothDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('printer_address', device.address ?? '');
  }
  
  // Fungsi untuk memuat perangkat terakhir yang tersimpan
  Future<void> _loadSelectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('printer_address');

    if (savedAddress != null) {
      for (var device in _devices) {
        if (device.address == savedAddress) {
          setState(() => _selectedDevice = device);
          _connectDevice(); // Auto-connect jika ditemukan
          break;
        }
      }
    }
  }

  List<Map<String, dynamic>> convertDetailsToItems(dynamic details) {
    try {
      // Handle if details is a JSON string
      final decodedDetails = details is String ? json.decode(details) : details;
      
      // Get the actual items list
      final List<dynamic> itemList = decodedDetails is List
          ? decodedDetails
          : (decodedDetails as Map<String, dynamic>)['items'] as List<dynamic>;
      
      return itemList.map((item) {
        // Access the nested product object
        final product = item['product'] as Map<String, dynamic>? ?? {};
        
        return {
          'name': product['name']?.toString() ?? 'Produk',
          'qty': (item['quantity'] as num?)?.toInt() ?? 1,
          'price': int.tryParse(
            (item['price']?.toString() ?? '0').replaceAll(RegExp(r'[^0-9]'), '')
          ) ?? 0,
          'sub_total': int.tryParse(
            (item['sub_total']?.toString() ?? '0').replaceAll(RegExp(r'[^0-9]'), '')
          ) ?? 0,
          if (product['description']?.toString().isNotEmpty ?? false)
            'note': product['description'].toString()
        };
      }).toList();
    } catch (e) {
      _logger.e('Error converting details to items: $e');
      return [];
    }
  }

  Future<void> _removeSelectedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Pastikan printer benar-benar terputus sebelum menghapus dari penyimpanan
    await _printerService.disconnect();
    
    // Hapus data printer dari penyimpanan
    await prefs.remove('printer_address'); 

    // Reset selected device di UI
    setState(() => _selectedDevice = null);
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Gap(15),
              buildListCart(),
              buildPayment(),
              LineXM(),
              LabelSemiBold(text: "Konfigurasi Printer"),
              DropdownButton<BluetoothDevice>(
                value: _selectedDevice,
                hint: const Text('Pilih Printer'),
                items: _devices.map((device) {
                  return DropdownMenuItem(
                    value: device,
                    child: Text(device.name ?? 'Unknown Device'),
                  );
                }).toList(),
                onChanged: (device) => setState(() => _selectedDevice = device),
                isExpanded: true,
              ),
              
              ElevatedButton(
                onPressed: _selectedDevice == null || _isConnecting 
                    ? null 
                    : _connectDevice,
                child: _isConnecting
                    ? const CircularProgressIndicator()
                    : const Text('Hubungkan Printer'),
              ),
              
              if (_isPrinting) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const Text('Sedang mencetak...'),
              ],
            ],
          )
        ],
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
                onTap: _isPrinting ? null : _printTest,
                child: ButtonPrimary(
                  text: "Cetak",
                )
              ),
            ),
            // ElevatedButton(
            //   onPressed: _selectedDevice == null ? null : _removeSelectedDevice,
            //   child: Text('Putuskan Koneksi Printer'),
            // ),
          ],
        ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LabelSemiBoldMD(text: "Daftar Pesanan"),
              if(transaction['label_price'] != null) ... [
                WarningTag(text: '*Menggunakan harga ${transaction['label_price']}'),
              ]
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