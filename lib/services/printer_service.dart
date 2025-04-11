import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PrinterService {
  final BlueThermalPrinter _printer = BlueThermalPrinter.instance;
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp ',
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

  Future<void> printReceipt({
    required String invoiceNumber,
    required List<Map<String, dynamic>> items,
    required num total,  // changed from double to num
    required num payment, // changed from double to num
    required num change,  // changed from double to num
  }) async {
    // Header Toko
    _printer.printCustom("TOKO MAJU JAYA", 2, 1);
    _printer.printCustom("Jl. Contoh No. 123", 1, 1);
    _printer.printCustom("Telp: 0812-3456-7890", 1, 1);
    _printer.printNewLine();

    // Garis pemisah
    _printer.printCustom("------------------------------", 1, 1);
    
    // Info Nota
    _printer.printLeftRight("NOTA:", invoiceNumber, 1);
    _printer.printLeftRight(
      "TANGGAL:", 
      DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()), 
      1
    );
    _printer.printNewLine();

    // Header Item
    _printer.printCustom("------------------------------", 1, 1);
    _printer.printLeftRight("ITEM", "HARGA", 1);
    _printer.printCustom("------------------------------", 1, 1);

    // Daftar Item
    for (var item in items) {
      _printer.printLeftRight(
        "${item['name']} (${item['qty']}x)", 
        _currencyFormat.format(item['price']), 
        0
      );
      if (item['note'] != null) {
        _printer.printCustom("  Catatan: ${item['note']}", 0, 0);
      }
    }

    // Total Pembayaran
    _printer.printCustom("------------------------------", 1, 1);
    _printer.printLeftRight("SUBTOTAL:", _currencyFormat.format(total), 1);
    _printer.printLeftRight("TUNAI:", _currencyFormat.format(payment), 1);
    _printer.printLeftRight("KEMBALI:", _currencyFormat.format(change), 1);
    _printer.printCustom("------------------------------", 1, 1);
    _printer.printNewLine();

    // Footer
    _printer.printCustom("Terima kasih telah berbelanja", 1, 1);
    _printer.printCustom("Barang yang sudah dibeli", 1, 1);
    _printer.printCustom("tidak dapat ditukar/dikembalikan", 1, 1);
    _printer.printNewLine();
    _printer.printNewLine();

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