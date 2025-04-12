import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class PrinterService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  bool _isConnected = false;

  Future<List<BluetoothDevice>> getPairedDevices() async {
    return await _printer.getBondedDevices();
  }

  Future<bool> connect(BluetoothDevice device) async {
    try {
      _isConnected = await _printer.connect(device);
      await Future.delayed(Duration(seconds: 1)); // beri waktu
      return _isConnected;
    } catch (e) {
      Logger().e('Connection error: $e');
      _isConnected = false;
      return false;
    }
  }

  String _formatCurrency(num value) {
    return value.toStringAsFixed(0);
  }

  String _sanitizeText(String input) {
    return input.replaceAll(RegExp(r'[^\x00-\x7F]'), ''); // hanya ASCII
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
    if (!_isConnected) {
      Logger().w("Printer tidak terkoneksi");
      return;
    }

    try {
      // Header Toko
      _printer.printCustom(_sanitizeText(merchantName ?? "Toko"), 1, 1);
      if (merchantAddress != null) {
        _printer.printCustom(_sanitizeText(merchantAddress), 1, 1);
      }

      await Future.delayed(Duration(milliseconds: 200));
      _printer.printCustom("-------------------------------", 1, 1);
      await Future.delayed(Duration(milliseconds: 200));

      // Info Nota
      _printer.printLeftRight("Nota    :", invoiceNumber, 1);
      _printer.printLeftRight("Tanggal :", transactionDate.toString(), 1);
      _printer.printLeftRight("Jam     :", transactionTime.toString(), 1);
      _printer.printCustom("-------------------------------", 1, 1);

      // Daftar Item
      for (var item in items) {
        String name = _sanitizeText(item['name']);
        _printer.printCustom(name, 1, 0);
        _printer.printLeftRight(
          "${_formatCurrency(item['price'])} (${item['qty']}x)",
          _formatCurrency(item['sub_total']),
          1,
        );
        await Future.delayed(Duration(milliseconds: 100));
      }

      _printer.printCustom("-------------------------------", 1, 1);
      _printer.printLeftRight("Grand Total :", _formatCurrency(total), 1);
      _printer.printLeftRight("Tunai       :", _formatCurrency(payment), 1);
      _printer.printLeftRight("Kembalian   :", _formatCurrency(change), 1);
      _printer.printCustom("-------------------------------", 1, 1);

      _printer.printNewLine();
      _printer.printCustom("Terima kasih telah berbelanja", 1, 1);
      _printer.printCustom("Sistem ini didukung oleh", 1, 1);

      // Print Gambar Aman
      try {
        ByteData bytesAsset = await rootBundle.load("assets/images/black-white-kekasir.png");
        Uint8List imageBytesFromAsset = bytesAsset.buffer.asUint8List();
        _printer.printImageBytes(imageBytesFromAsset);
      } catch (e) {
        Logger().w("Gagal load gambar: $e");
      }

      _printer.printNewLine();
      _printer.printNewLine();
      _printer.printNewLine();
    } catch (e) {
      Logger().e("Print error: $e");
    }
  }

  Future<void> disconnect() async {
    try {
      await _printer.disconnect();
      _isConnected = false;
    } catch (e) {
      Logger().d('Disconnection error: $e');
    }
  }

  bool get isConnected => _isConnected;
}
