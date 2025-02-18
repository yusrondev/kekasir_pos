import 'package:intl/intl.dart';

String formatRupiah(double price) {
  return NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(price);
}