import '../models/user.dart';
import 'api_service.dart';

class UserService {
  // Ambil semua user kasir (opsional search)
  static Future<List<User>> getKasir({String? search}) async {
    final query = search != null && search.isNotEmpty
        ? '?search=${Uri.encodeQueryComponent(search)}'
        : '';
    final data = await ApiService.get('/users$query');
    final list = data['users'] as List? ?? [];
    return list
        .map((e) => User.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Tambah kasir baru
  static Future<User> createKasir({
    required String username,
    required String password,
    required String name,
  }) async {
    final data = await ApiService.post('/users', {
      'username': username,
      'password': password,
      'name': name,
    });
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  // Update kasir
  static Future<User> updateKasir(
    String id, {
    String? username,
    String? password,
    String? name,
  }) async {
    final body = <String, dynamic>{
      'username': ?username,
      if (password != null && password.isNotEmpty) 'password': password,
      'name': ?name,
    };
    final data = await ApiService.put('/users/$id', body);
    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  // Hapus kasir
  static Future<void> deleteKasir(String id) async {
    await ApiService.delete('/users/$id');
  }
}
