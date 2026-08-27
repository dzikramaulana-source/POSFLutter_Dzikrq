import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/user_service.dart';

class UserProvider extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadKasir({String? search}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _users = await UserService.getKasir(search: search);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addKasir({
    required String username,
    required String password,
    required String name,
  }) async {
    try {
      await UserService.createKasir(
        username: username,
        password: password,
        name: name,
      );
      await loadKasir();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateKasir(
    User user, {
    String? username,
    String? password,
    String? name,
  }) async {
    try {
      await UserService.updateKasir(
        user.id,
        username: username,
        password: password,
        name: name,
      );
      await loadKasir();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteKasir(User user) async {
    try {
      await UserService.deleteKasir(user.id);
      await loadKasir();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
