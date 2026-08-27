import '../models/product.dart';
import 'api_service.dart';

class ProductService {
  // Ambil semua produk (opsional search)
  static Future<List<Product>> getProducts({String? search}) async {
    final query = search != null && search.isNotEmpty
        ? '?search=${Uri.encodeQueryComponent(search)}'
        : '';
    final data = await ApiService.get('/products$query');
    final list = data['products'] as List? ?? [];
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Ambil detail produk
  static Future<Product> getProduct(String id) async {
    final data = await ApiService.get('/products/$id');
    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  // Tambah produk baru
  static Future<Product> createProduct({
    required String name,
    required String sku,
    required double price,
    required double cost,
    required int stock,
    required String category,
  }) async {
    final data = await ApiService.post('/products', {
      'name': name,
      'sku': sku,
      'price': price,
      'cost': cost,
      'stock': stock,
      'category': category,
    });
    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  // Update produk
  static Future<Product> updateProduct(
    String id, {
    required String name,
    required String sku,
    required double price,
    required double cost,
    required int stock,
    required String category,
  }) async {
    final data = await ApiService.put('/products/$id', {
      'name': name,
      'sku': sku,
      'price': price,
      'cost': cost,
      'stock': stock,
      'category': category,
    });
    return Product.fromJson(data['product'] as Map<String, dynamic>);
  }

  // Hapus produk
  static Future<void> deleteProduct(String id) async {
    await ApiService.delete('/products/$id');
  }
}
