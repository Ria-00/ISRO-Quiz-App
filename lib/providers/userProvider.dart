import 'package:flutter/material.dart';

class userProvider extends ChangeNotifier {
  String? _email;
  String? _password;

  String? get email => _email;
  String? get password => _password;

  void setValue(String uemail) {
    _email = uemail;
    notifyListeners();
  }

  void setPass(String password) {
    _password = password;
    notifyListeners();
  }

  void removeValue() {
    _email = null;
    notifyListeners();
  }
}
