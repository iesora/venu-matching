import 'package:flutter/material.dart';

class AuthState with ChangeNotifier {
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userInfo;

  bool get isLoggedIn => _isLoggedIn;
  Map<String, dynamic>? get userInfo => _userInfo;

  void login(Map<String, dynamic> userInfo) {
    _isLoggedIn = true;
    _userInfo = userInfo;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    _userInfo = null;
    notifyListeners();
  }

  void updateUserInfo(Map<String, dynamic> newInfo) {
    if (_userInfo != null) {
      _userInfo!.addAll(newInfo);
      notifyListeners();
    }
  }
}
