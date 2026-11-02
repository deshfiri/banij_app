import 'package:flutter/material.dart';

class AuthProvider extends ChangeNotifier {
  // bool _isPassVisible = true;
  // bool get isPassVisible => _isPassVisible;
  // void togglePassword() {
  //   _isPassVisible = !_isPassVisible;
  //   notifyListeners();
  // }

  bool _isOldConfirm = true;
  bool get isOldConfirm => _isOldConfirm;
  void toggleOldPassword() {
    _isOldConfirm = !_isOldConfirm;
    notifyListeners();
  }

  bool _isPassConfirm = true;
  bool get isPassConfirm => _isPassConfirm;
  void toggleConfirmPassword() {
    _isPassConfirm = !_isPassConfirm;
    notifyListeners();
  }

  bool _isCurrenPass = true;
  bool get isCurrenPass => _isCurrenPass;
  void toggleCurrentPassword() {
    _isCurrenPass = !_isCurrenPass;
    notifyListeners();
  }

  String _oldPassword = '';
  String _password = '';
  String _confirmPassword = '';

  String get oldPassword => _oldPassword;
  String get password => _password;
  String get confirmPassword => _confirmPassword;

  bool _isOldPasswordValid = false;
  bool _isPasswordValid = false;
  bool _isConfirmPasswordValid = false;

 
  bool get isFormValid =>
      _isPasswordValid &&
      _isConfirmPasswordValid &&
      _password == _confirmPassword;

  bool get isChangePasswordFormValid =>
      _isOldPasswordValid &&
      _isPasswordValid &&
      _isConfirmPasswordValid &&
      _password == _confirmPassword;

  void updateOldPassword(String value) {
    _oldPassword = value;
    _isOldPasswordValid = value.length >= 8;
    _checkFormValidity();
  }

  void updatePassword(String value) {
    _password = value;
    _isPasswordValid = value.length >= 8;
    _checkFormValidity();
  }

  void updateConfirmPassword(String value) {
    _confirmPassword = value;
    _isConfirmPasswordValid = value.length >= 8;
    _checkFormValidity();
  }

  void _checkFormValidity() {
    notifyListeners(); // Triggers UI updates
  }

  // bool _isRegisterPassVisible = true;
  // bool get isRegisterPassVisible => _isRegisterPassVisible;
  // void toggleRegisterPassVisiable() {
  //   _isRegisterPassVisible = !_isRegisterPassVisible;
  //   notifyListeners();
  // }

  // bool _isChecked = true;
  // bool get isChecked => _isChecked;
  // void toggleCheckBox() {
  //   _isChecked = !_isChecked;
  //   notifyListeners();
  // }

 
  // bool _isResetpass = true;
  // bool get isResetpass => _isResetpass;
  // void toggleResetPass() {
  //   _isResetpass = !_isResetpass;
  //   notifyListeners();
  // }

  // bool _restaurantcondition = true;
  // bool get isOrderCheckBox => _restaurantcondition;
  // void toggleRestaurantcondition() {
  //   _restaurantcondition = !_restaurantcondition;
  //   notifyListeners();
  // }

  // bool _isMyTableCondition = true;
  // bool get isMyTableCondition => _isMyTableCondition;
  // void toggleMytableCondition() {
  //   _isMyTableCondition = !_isMyTableCondition;
  //   notifyListeners();
  // }





  bool _newPassword = true;
  bool get newPassword => _newPassword;
  void toggleNewPassword() {
    _newPassword = !_newPassword;
    notifyListeners();
  }

}
