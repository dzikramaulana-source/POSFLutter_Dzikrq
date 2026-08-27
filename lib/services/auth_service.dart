import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  // Login: kirim username + password, simpan token
  static Future<User> login(String username, String password) async {
    final data = await ApiService.post(
      '/auth/login',
      {'username': username, 'password': password},
      withAuth: false,
    );

    final token = data['token']?.toString();
    if (token != null) {
      await ApiService.saveToken(token);
    }

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  // Registrasi user baru
  static Future<User> register({
    required String username,
    required String password,
    required String name,
    String role = 'kasir',
  }) async {
    final data = await ApiService.post(
      '/auth/register',
      {'username': username, 'password': password, 'name': name, 'role': role},
      withAuth: false,
    );

    final token = data['token']?.toString();
    if (token != null) {
      await ApiService.saveToken(token);
    }

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  // Ambil data user dari token
  static Future<User?> getCurrentUser() async {
    try {
      final data = await ApiService.get('/auth/me');
      if (data == null || data['user'] == null) return null;
      return User.fromJson(data['user'] as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // Logout: hapus token
  static Future<void> logout() async {
    await ApiService.clearToken();
  }
}
