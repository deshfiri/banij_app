import 'package:flutter/material.dart';

import '../feature/auth/model/response_model.dart';
import '../helpers/loading_helper.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  bool _isLoading = false;

  String get email => emailController.text;
  bool get isLoading => _isLoading;

  void updateEmail(String value) {
    if (emailController.text != value) {
      emailController.text = value;
    }
    notifyListeners();
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim());
  }

  Future<bool> sendResetLink(BuildContext context, GlobalKey<FormState> formKey) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      ForgotPasswordResponse response = await forgotPasswordRxObj.sendForgotPassword(
        email: emailController.text.trim(),
      ).waitingForSucess();

      _isLoading = false;
      notifyListeners();

      final msg = response.message ?? 'We have emailed your password reset link.';
      ToastUtil.showSuccessMessage(msg);
      resetForm();
      if (context.mounted) {
        Navigator.pop(context);
      }
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('Failure')) {
        errorMsg = 'Failed to send reset link. Please check your email and network connection.';
      }
      ToastUtil.showErrorMessage(errorMsg);
      return false;
    }
  }

  void resetForm() {
    emailController.clear();
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
