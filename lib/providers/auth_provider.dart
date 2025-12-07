import 'package:flutter/material.dart';
import '../shopify/shopify_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _customerAccessToken;
  String? _customerEmail;
  bool _isLoading = false;
  String? _lastError;
  // add these 2 new fields so old UI keeps working:
  String? _userName;
  String? _phoneNumber;

  String? get customerAccessToken => _customerAccessToken;
  String? get customerEmail => _customerEmail;
  bool get isLoggedIn => _customerAccessToken != null;
  bool get isLoading => _isLoading;
  String? get lastError => _lastError;

   // ✅ old getters expected in Account page:
  String? get userName => _userName;
  String? get userEmail => _customerEmail; // map to Shopify email
  String? get phoneNumber => _phoneNumber;

  final ShopifyService _shopify = ShopifyService();

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _lastError = null;
    notifyListeners();

    try {
      final token = await _shopify.loginCustomer(email, password);

      _customerAccessToken = token;
      _customerEmail = email;

      // TODO (optional): persist the token using SharedPreferences
      // so user stays logged in after app restart.

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _lastError = e.toString();
      notifyListeners();
      rethrow; // let UI show message
    }
  }

  void logout() {
    _customerAccessToken = null;
    _customerEmail = null;
    _lastError = null;
    // TODO: also clear from SharedPreferences if you persist it
    notifyListeners();
  }
}
