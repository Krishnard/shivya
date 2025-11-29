import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String? _userName;
  String? _userEmail;
  String? _phoneNumber;
  bool _isLoggedIn = false;

  // Getters for UI
  String? get userName => _userName;
  String? get userEmail => _userEmail;
  String? get phoneNumber => _phoneNumber;
  bool get isLoggedIn => _isLoggedIn;

  // 🔥 Login via Phone
  void loginWithPhone(String phone) {
    _phoneNumber = phone;
    _userName = "User"; // Placeholder until profile completed
    _isLoggedIn = true;
    notifyListeners();
  }

  // Email login (future use)
  void loginWithEmail({required String name, required String email}) {
    _userName = name;
    _userEmail = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  // 🚪 Logout clears everything
  void logout() {
    _userName = null;
    _userEmail = null;
    _phoneNumber = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
