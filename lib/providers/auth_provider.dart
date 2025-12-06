import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  String _userName = "Guest";
  String _userEmail = "";
  String? _phoneNumber;
  bool _isLoggedIn = false;

  // Getters for UI
  String get userName => _userName;
  String get userEmail => _userEmail;
  String? get phoneNumber => _phoneNumber;
  bool get isLoggedIn => _isLoggedIn;

  // 🔥 Login via Phone
  void loginWithPhone(String phone) {
    _phoneNumber = phone;
    _userName = "User"; // You can update after profile completed
    _isLoggedIn = true;
    notifyListeners();
  }

  // 🔥 Login via Email
  void loginWithEmail({
    required String name,
    required String email,
  }) {
    _userName = name;
    _userEmail = email;
    _isLoggedIn = true;
    notifyListeners();
  }

  // 🚪 Logout - reset to guest mode
  void logout() {
    _userName = "Guest";
    _userEmail = "";
    _phoneNumber = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}
