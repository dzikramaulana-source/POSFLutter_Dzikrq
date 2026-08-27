import '../models/report.dart';
import '../models/transaction.dart';
import 'api_service.dart';

class ReportService {
  // Laporan harian (default: hari ini)
  static Future<DailyReport> getDailyReport({DateTime? date}) async {
    final dateStr = (date ?? DateTime.now()).toIso8601String().split('T').first;
    final data = await ApiService.get('/reports/daily?date=$dateStr');
    return DailyReport.fromJson(data);
  }

  // Laporan periode: summary + grafik + top produk + payment + transaksi (pagination)
  static Future<PeriodReport> getPeriodReport({
    required DateTime start,
    required DateTime end,
    int page = 1,
    int limit = 20,
  }) async {
    final startStr = _dateStr(start);
    final endStr = _dateStr(end);
    final data = await ApiService.get(
      '/reports/period?start=$startStr&end=$endStr&page=$page&limit=$limit',
    );
    return PeriodReport.fromJson(data);
  }

  static String _dateStr(DateTime d) =>
      d.toIso8601String().split('T').first;
}
