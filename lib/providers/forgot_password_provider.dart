import 'package:flutter/material.dart';

class ForgotPasswordProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();

  String get email => emailController.text;

  void updateEmail(String value) {
    if (emailController.text != value) {
      emailController.text = value;
    }
    notifyListeners();
  }

  bool get isValidEmail {
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(emailController.text.trim());
  }

  void resetForm() {
    emailController.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
