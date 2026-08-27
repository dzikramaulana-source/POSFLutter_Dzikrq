import '../models/transaction.dart';
import 'api_service.dart';

class TransactionService {
  // Buat transaksi baru
  static Future<Transaction> createTransaction({
    required List<CartItem> items,
    required String paymentMethod,
    required double cashReceived,
  }) async {
    final data = await ApiService.post('/transactions', {
      'items': items.map((e) => e.toJson()).toList(),
      'paymentMethod': paymentMethod,
      'cashReceived': cashReceived,
    });
    return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
  }

  // Ambil daftar transaksi (opsional filter tanggal YYYY-MM-DD)
  static Future<List<Transaction>> getTransactions({String? date}) async {
    final query = date != null ? '?date=$date' : '';
    final data = await ApiService.get('/transactions$query');
    final list = data['transactions'] as List? ?? [];
    return list
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Ambil detail transaksi
  static Future<Transaction> getTransaction(String id) async {
    final data = await ApiService.get('/transactions/$id');
    return Transaction.fromJson(data['transaction'] as Map<String, dynamic>);
  }
}
