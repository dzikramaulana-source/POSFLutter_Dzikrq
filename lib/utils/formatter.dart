import 'package:intl/intl.dart';

final NumberFormat _rupiahFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

final NumberFormat _plainNumber = NumberFormat.decimalPattern('id_ID');

/// Format angka menjadi Rupiah, mis. Rp10.000
String formatRupiah(num value) => _rupiahFormat.format(value);

/// Format angka biasa dengan pemisah ribuan, mis. 10.000
String formatNumber(num value) => _plainNumber.format(value);
