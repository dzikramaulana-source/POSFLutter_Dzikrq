import 'package:flutter/foundation.dart';

/// Konfigurasi API
///
/// - Android emulator: otomatis pakai http://10.0.2.2:3000
///   (localhost pada emulator mengarah ke emulator itu sendiri)
/// - Web / Windows / desktop: pakai http://localhost:3000
/// - Device fisik: ganti [baseUrl] dengan IP komputer Anda,
///   mis. http://192.168.1.10:3000
class ApiConfig {
  static const String baseUrl = 'http://localhost:3000';

  static String get apiUrl {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return '$baseUrl/api';
  }
}
