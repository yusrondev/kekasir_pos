import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kekasir/components/custom_button_component.dart';
import 'package:kekasir/pages/layouts/app_layout.dart';
import 'package:kekasir/services/printer_service.dart';
import 'package:kekasir/utils/variable.dart';
import 'package:logger/logger.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart'; // Added for json.decode

class PrintPage extends StatefulWidget {
  const PrintPage({super.key});

  @override
  State<PrintPage> createState() => _PrintPageState();
}

class _PrintPageState extends State<PrintPage> {
  final PrinterService _printerService = PrinterService();
  final Logger _logger = Logger();
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

  dynamic details; // Changed to dynamic to handle both List and Map
  Map<String, dynamic>? transaction;
  dynamic data;

  @override
  void initState() {
    super.initState();
    _loadDevices();
    _loadSelectedDevice();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (transaction == null) {
      transaction = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (transaction != null) {
        data = transaction!['data'][0];

        DateTime parsedDate = DateTime.parse(data['created_at']).toLocal();
        String formattedDate = DateFormat("d/MM/yyyy", "id_ID").format(parsedDate);
        String formattedTime = DateFormat("HH:mm", "id_ID").format(parsedDate);

        setState(() {
          subTotal = data['sub_total']?.toString() ?? '0';
          grandTotal = data['grand_total']?.toString() ?? '0';
          discount = data['discount']?.toString() ?? '0';
          paid = data['paid']?.toString() ?? '0';
          change = data['change']?.toString() ?? '0';
          details = data['details'];
          transactionDate = formattedDate;
          transactionTime = formattedTime;
          
          // Convert details to items right after setting details
          items = convertDetailsToItems(details);
        });
        
        _logger.d('Details: $details');
        _logger.d('Items: $items');
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
    final success = await _printerService.connect(_selectedDevice!);
    setState(() => _isConnecting = false);
    
    if (success) {
      // Simpan perangkat yang terhubung
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

  Future<void> _printTest() async {
    setState(() => _isPrinting = true);
    try {
      await _printerService.printReceipt(
        invoiceNumber: '${data['code']}',
        items: items,
        total: int.tryParse(grandTotal.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        payment: int.tryParse(paid.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        change: int.tryParse(change.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
        merchantName: data['merchant_name'],
        merchantAddress: data['merchant_address'],
        transactionDate: transactionDate,
        transactionTime : transactionTime,
        createdBy : ""
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
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
        ),
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _printerService.disconnect();
    super.dispose();
  }
}