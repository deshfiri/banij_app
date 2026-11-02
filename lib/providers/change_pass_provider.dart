import 'package:flutter/material.dart';

class ChangePassProvider extends ChangeNotifier{

  bool _changePass = true;
  bool get changePass => _changePass;
  void toggleChangePassword() {
    _changePass = !_changePass;
    notifyListeners();
  }
  bool _oldPass = true;
  bool get oldPass => _oldPass;
  void toggleOldPassword() {
    _oldPass = !_oldPass;
    notifyListeners();
  }

  bool _isCurrenPass = true;
  bool get isCurrenPass => _isCurrenPass;
  void toggleCurrentPassword() {
    _isCurrenPass = !_isCurrenPass;
    notifyListeners();
  }

}