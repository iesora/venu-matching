import 'package:flutter/foundation.dart';

class LoginState extends ChangeNotifier {
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;

  void login() {
    _isLoggedIn = true;
    notifyListeners(); // リスナーに状態変更を通知
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners(); // リスナーに状態変更を通知
  }
}
