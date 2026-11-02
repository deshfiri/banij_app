import 'package:flutter/material.dart';

class ResetPassProvider extends ChangeNotifier{
    bool _resetPass = true;
  bool get resetPass => _resetPass;
  void toggleResetPassword() {
    _resetPass = !_resetPass;
    notifyListeners();
  }
    bool _oldResetPass = true;
  bool get oldResetPass => _oldResetPass;
  void toggleOldResetPassword() {
    _oldResetPass = !_oldResetPass;
    notifyListeners();
  }
}