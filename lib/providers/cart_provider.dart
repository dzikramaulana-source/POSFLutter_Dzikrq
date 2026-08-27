import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/transaction.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  double get total {
    return _items.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get itemCount {
    return _items.fold(0, (sum, item) => sum + item.qty);
  }

  // Tambah produk ke keranjang (atau naikkan qty jika sudah ada)
  void addItem(Product product) {
    final index = _items.indexWhere((e) => e.productId == product.id);
    if (index >= 0) {
      final existing = _items[index];
      if (existing.qty < existing.maxStock) {
        existing.qty++;
      }
    } else {
      if (product.stock > 0) {
        _items.add(CartItem(
          productId: product.id,
          name: product.name,
          price: product.price,
          qty: 1,
          maxStock: product.stock,
        ));
      }
    }
    notifyListeners();
  }

  // Naikkan qty item
  void increment(String productId) {
    final index = _items.indexWhere((e) => e.productId == productId);
    if (index >= 0) {
      final item = _items[index];
      if (item.qty < item.maxStock) {
        item.qty++;
        notifyListeners();
      }
    }
  }

  // Turunkan qty item (hapus jika 0)
  void decrement(String productId) {
    final index = _items.indexWhere((e) => e.productId == productId);
    if (index >= 0) {
      final item = _items[index];
      item.qty--;
      if (item.qty <= 0) {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Hapus item dari keranjang
  void removeItem(String productId) {
    _items.removeWhere((e) => e.productId == productId);
    notifyListeners();
  }

  // Kosongkan keranjang setelah transaksi sukses
  void clear() {
    _items.clear();
    notifyListeners();
  }
}
