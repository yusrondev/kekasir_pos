import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PrinterService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: ' ',
    decimalDigits: 0,
  );

  bool _isConnected = false;

  Future<List<BluetoothDevice>> getPairedDevices() async {
    return await _printer.getBondedDevices();
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _isConnected = await _printer.connect(device);
      return _isConnected;
    } catch (e) {
      _isConnected = false;
      Logger().d('Connection error: $e');
      return false;
    }
  }

  String truncate(String text, int length) {
    return text.length > length ? text.substring(0, length - 3) + "..." : text;
  }

  Future<void> printReceipt({
    required String invoiceNumber,
    required List<Map<String, dynamic>> items,
    required num total,
    required num payment,
    required num change,
    required String? merchantName,
    required String? merchantAddress,
    required String? transactionDate,
    required String? transactionTime,
  }) async {
    ByteData bytesAsset = await rootBundle.load("assets/images/black-white-kekasir.png");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    // Header Toko
    _printer.printCustom(merchantName.toString(), 1, 1);
    if (merchantAddress != null) {
      _printer.printCustom(merchantAddress.toString(), 1, 1);
    }

    // Garis pemisah
    _printer.printCustom('#$invoiceNumber', 1, 1);
    _printer.printCustom("-------------------------------", 1, 1);
    
    // Info Nota
    _printer.printLeftRight(transactionDate.toString(), transactionTime.toString(), 1);
    _printer.printCustom("-------------------------------", 1, 1);
    // Daftar Item
    for (var item in items) {
      _printer.printCustom(item['name'], 1, 0); // Cetak nama barang di satu baris
      _printer.printLeftRight(
        "${_currencyFormat.format(item['price'])} (${item['qty']}x)", 
        _currencyFormat.format(item['sub_total']), 
        1
      );
    }


    // Total Pembayaran
    _printer.printCustom("-------------------------------", 1, 1);
    _printer.printLeftRight("GRAND TOTAL:", _currencyFormat.format(total), 1);
    _printer.printLeftRight("TUNAI:", _currencyFormat.format(payment), 1);
    _printer.printLeftRight("KEMBALI:", _currencyFormat.format(change), 1);
    _printer.printCustom("-------------------------------", 1, 1);
    _printer.printNewLine();

    // Footer
    _printer.printCustom("Terima kasih telah berbelanja", 1, 1);
    // _printer.printCustom("Barang yang sudah dibeli", 1, 1);
    // _printer.printCustom("tidak dapat ditukar/dikembalikan", 1, 1);
    _printer.printCustom("Sistem ini didukung oleh", 1, 1);
    _printer.printImageBytes(imageBytesFromAsset); //image from Asset
    // _printer.printNewLine();
    // _printer.printNewLine();

    // Cut paper (jika printer support)
    _printer.paperCut();
  }

  Future<void> disconnect() async {
    if (!_isConnected) return;
    
    try {
      await _printer.disconnect();
      _isConnected = false;
    } catch (e) {
      Logger().d('Disconnection error: $e');
      _isConnected = false;
      // Optional: lempar exception jika diperlukan di level UI
      throw Exception('Gagal memutuskan koneksi: ${e.toString()}');
    }
  }

  // Tambahkan getter untuk status koneksi
  bool get isConnected => _isConnected;
}