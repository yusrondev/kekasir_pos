import 'package:intl/intl.dart';

String formatRupiah(double price) {
  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  return currencyFormat.format(price / 100); // Bagi 100 jika nilainya disimpan dalam sen
}