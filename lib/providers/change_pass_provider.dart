import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/color.dart';

class ChangePassProvider extends ChangeNotifier {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isCurrentPassVisible = true;
  bool _isNewPassVisible = true;
  bool _isConfirmPassVisible = true;
  bool _isLoading = false;

  bool get isCurrentPassVisible => _isCurrentPassVisible;
  bool get isNewPassVisible => _isNewPassVisible;
  bool get isConfirmPassVisible => _isConfirmPassVisible;
  bool get isLoading => _isLoading;

  void toggleCurrentPassword() {
    _isCurrentPassVisible = !_isCurrentPassVisible;
    notifyListeners();
  }

  void toggleNewPassword() {
    _isNewPassVisible = !_isNewPassVisible;
    notifyListeners();
  }

  void toggleConfirmPassword() {
    _isConfirmPassVisible = !_isConfirmPassVisible;
    notifyListeners();
  }

  Future<bool> updatePassword(BuildContext context, GlobalKey<FormState> formKey) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('password_updated_success'.tr),
          backgroundColor: primaryOrange,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    }
    return true;
  }

  void resetForm() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _isCurrentPassVisible = true;
    _isNewPassVisible = true;
    _isConfirmPassVisible = true;
    _isLoading = false;
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
