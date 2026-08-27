import 'package:flutter/foundation.dart';
import '../models/report.dart';
import '../services/report_service.dart';

class ReportProvider extends ChangeNotifier {
  PeriodReport? _report;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _error;
  DateTime? _start;
  DateTime? _end;
  int _page = 1;

  PeriodReport? get report => _report;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get error => _error;
  DateTime? get start => _start;
  DateTime? get end => _end;
  bool get hasMore {
    final report = _report;
    if (report == null) return false;
    return report.transactions.page < report.transactions.totalPages;
  }

  // Muat laporan untuk periode baru (reset pagination)
  Future<void> load({required DateTime start, required DateTime end}) async {
    _isLoading = true;
    _error = null;
    _start = start;
    _end = end;
    _page = 1;
    notifyListeners();
    try {
      _report = await ReportService.getPeriodReport(start: start, end: end);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  // Muat halaman transaksi berikutnya (append)
  Future<void> loadMore() async {
    final start = _start;
    final end = _end;
    if (start == null || end == null || _isLoading || _isLoadingMore) return;
    if (!hasMore) return;

    _isLoadingMore = true;
    notifyListeners();
    try {
      final nextPage = _page + 1;
      final result = await ReportService.getPeriodReport(
        start: start,
        end: end,
        page: nextPage,
      );
      _page = nextPage;
      final current = _report;
      if (current != null) {
        final combined = TransactionPage(
          items: [...current.transactions.items, ...result.transactions.items],
          page: result.transactions.page,
          limit: result.transactions.limit,
          total: result.transactions.total,
          totalPages: result.transactions.totalPages,
        );
        _report = PeriodReport(
          start: current.start,
          end: current.end,
          summary: current.summary,
          previousSummary: current.previousSummary,
          chartData: current.chartData,
          topProducts: current.topProducts,
          paymentSummary: current.paymentSummary,
          transactions: combined,
        );
      }
    } catch (e) {
      _error = e.toString();
    }
    _isLoadingMore = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
  }
}
