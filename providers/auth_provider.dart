import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _userEmail = '';
  bool _isLoading = false;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  String get userEmail => _userEmail;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadAuthStatus();
  }

  void _loadAuthStatus() {
    _isAuthenticated = StorageService.isLoggedIn();
    _userEmail = StorageService.getUserEmail() ?? 'student.passenger@yatra.com';
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Realistic network simulation for student auth
    await Future.delayed(const Duration(milliseconds: 650));

    if (email.trim().isEmpty || !email.contains('@')) {
      _errorMessage = 'Please enter a valid email address';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (password.trim().length < 4) {
      _errorMessage = 'Password must be at least 4 characters';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isAuthenticated = true;
    _userEmail = email.trim();
    await StorageService.setLoggedIn(true, email: _userEmail);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<bool> signup(String name, String email, String password, String phone) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    if (name.trim().isEmpty || email.trim().isEmpty || password.length < 4) {
      _errorMessage = 'Please fill all required signup fields';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _isAuthenticated = true;
    _userEmail = email.trim();
    await StorageService.setLoggedIn(true, email: _userEmail);

    // Save initial profile
    final profile = StorageService.loadProfile().copyWith(
      name: name.trim(),
      email: email.trim(),
      phone: phone.trim(),
    );
    await StorageService.saveProfile(profile);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userEmail = '';
    await StorageService.clearAuth();
    notifyListeners();
  }
}
