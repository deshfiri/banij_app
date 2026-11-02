import 'package:flutter/material.dart';

class SignUpProvider extends ChangeNotifier {
    bool _changePass = true;
  bool get changePass => _changePass;
  void toggleChangePassword() {
    _changePass = !_changePass;
    notifyListeners();
  }
}