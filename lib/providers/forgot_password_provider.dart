import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  String _email = '';

  String get email => _email;

  void updateEmail(String value) {
    _email = value;
    notifyListeners();
  }

  bool get isValidEmail {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(_email);
  }
}
