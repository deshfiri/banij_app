import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../feature/account/data/account_api.dart';
import '../helpers/toast.dart';

class ChangePassProvider extends ChangeNotifier {
  final TextEditingController currentPasswordController=TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _isNewPassVisible = true;
  bool _isConfirmPassVisible = true;
  bool _isLoading = false;

  bool get isNewPassVisible => _isNewPassVisible;
  bool get isConfirmPassVisible => _isConfirmPassVisible;
  bool get isLoading => _isLoading;

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

    try {
      await AccountApi.instance.changePasswordApi(
        currentPassword: currentPasswordController.text.trim(),
        password: newPasswordController.text,
        passwordConfirmation: confirmPasswordController.text,
      );

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        ToastUtil.showSuccessMessage('password_updated_success'.tr);
        Navigator.pop(context);
      }
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to reset password');
      return false;
    }
  }

  void resetForm() {
    currentPasswordController.clear();
    emailController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
    _isNewPassVisible = true;
    _isConfirmPassVisible = true;
    _isLoading = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
