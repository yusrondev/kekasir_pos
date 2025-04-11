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

class NotaTransactionPage extends StatefulWidget {
  final dynamic id;
  const NotaTransactionPage({super.key, this.id});

  @override
  State<NotaTransactionPage> createState() => _NotaTransactionPageState();
}

class _NotaTransactionPageState extends State<NotaTransactionPage> {
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
  bool _isConnected = false;
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
    // Pastikan load devices selesai sebelum load selected device
    _initPrinterSetup();
  }

  Future<void> _initPrinterSetup() async {
    await _loadDevices();
    await _loadSelectedDevice();
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
    try {
      final devices = await _printerService.getPairedDevices();
      if (mounted) {
        setState(() {
          _devices = devices;
          _logger.d('Devices loaded: ${devices.length} devices');
        });
      }
    } catch (e) {
      _logger.e('Error loading devices: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat daftar printer: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _connectDevice() async {
    if (_selectedDevice == null) return;

    setState(() => _isConnecting = true);

    final success = await _printerService.connect(_selectedDevice!);
    setState(() {
      _isConnecting = false;
      _isConnected = success; // Perbarui status koneksi berdasarkan hasil
    });

    Logger().d(_isConnecting);

    if (success) {
      await _saveSelectedDevice(_selectedDevice!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Printer berhasil terhubung')),
        );
      }
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
    await prefs.setString('printer_name', device.name ?? ''); // Store name instead of address
    setState(() {
      _isConnected = true;
    });
  }
  
  Future<void> _loadSelectedDevice() async {
    if (_devices.isEmpty) {
      _logger.w('Devices list is empty');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('printer_name');

    _logger.d('Saved printer name: $savedName');
    _logger.d('Available devices: $_devices');

    if (savedName != null) {
      for (var device in _devices) {
        if (device.name == savedName) {
          _logger.d('Found saved device: ${device.name}');
          setState(() {
            _selectedDevice = device;
            _isConnected = true;
          });
          
          // Auto-connect jika diperlukan
          // final isConnected = await _printerService.isConnected;
          // if (!isConnected) {
          //   await _connectDevice();
          // }
          // break;
        }
      }
    }

    // Update connection status
    // final isConnected = await _printerService.isConnected;
    // if (mounted) {
    //   setState(() {
    //     _isConnected = isConnected;
    //   });
    // }
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
    
    await _printerService.disconnect();
    
    await prefs.remove('printer_name'); 

    setState(() {
      _selectedDevice = null;
      _isConnected = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Printer telah diputus')),
      );
    }
  }

  Future<void> _showPrinterSelectionDialog(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8, // Batasi tinggi maksimal 80% layar
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Pilih Printer',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Divider(height: 1),
                Expanded( // Gunakan Expanded agar ListView bisa scroll
                  child: _devices.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('Tidak ada printer yang terdeteksi'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: _devices.length,
                          itemBuilder: (context, index) {
                            final device = _devices[index];
                            return ListTile(
                              leading: const Icon(Icons.print),
                              title: Text(device.name ?? 'Unknown Device'),
                              subtitle: Text(device.address ?? ''),
                              trailing: _selectedDevice?.address == device.address
                                  ? const Icon(Icons.check, color: Colors.green)
                                  : null,
                              onTap: () {
                                setState(() => _selectedDevice = device);
                                Navigator.pop(context);
                              },
                            );
                          },
                        ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('TUTUP'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
              Row(
                children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => AppLayout()),
                          (route) => false, // Menghapus semua route yang ada
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 15),
                        width: 35,
                        height: 35,
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Color(0xfff5f6fa),
                          borderRadius: BorderRadius.circular(100)
                        ),
                        child: Container(
                          margin: EdgeInsets.only(left: 5),
                          child: Icon(Icons.arrow_back_ios, size: 15)
                        ),
                      )
                    ),
                  Text(
                    "Detail Transaksi",
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600
                    ),
                  ),
                ],
              ),
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
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ligthSky,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: secondaryColor)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LabelSemiBold(text: "Konfigurasi Printer"),
                    ShortDesc(text: "Sesuaikan perangkat printer Anda",),
                    if (_devices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          'Tidak ada printer yang terdeteksi',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              await _loadDevices(); // Refresh devices list
                              // ignore: use_build_context_synchronously
                              _showPrinterSelectionDialog(context);
                            },
                            icon: const Icon(Icons.print, color: primaryColor),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: lightColor, // Warna background
                              foregroundColor: primaryColor, // Warna teks/icon
                              side: BorderSide(color: primaryColor, width: 1), // Warna dan ketebalan border
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Border radius
                              ),
                            ),
                            label: Text(
                              _selectedDevice?.name ?? 'Pilih Printer',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        if (_isConnected)
                          ElevatedButton(
                            onPressed: _removeSelectedDevice,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xffe74c3c), // Ubah warna background
                              foregroundColor: Colors.white, // Warna teks/icon
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Border radius
                                side: BorderSide(color: Color(0xffe74c3c), width: 1), // Warna dan ketebalan border
                              ),
                              elevation: 0
                            ),
                            child: const Text('Putuskan', style: TextStyle(fontWeight: FontWeight.w600)),
                          )
                        else
                          ElevatedButton(
                            onPressed: _selectedDevice == null ? null : _connectDevice,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor, // Ubah warna background
                              foregroundColor: Colors.white, // Warna teks/icon
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Border radius
                                side: BorderSide(color: primaryColor, width: 1), // Warna dan ketebalan border
                              ),
                              elevation: 0
                            ),
                            child: const Text('Hubungkan', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          )
        ],
      ),
      bottomNavigationBar: isLoader != true ? Padding(
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
          ],
        ),
      ) : null,
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