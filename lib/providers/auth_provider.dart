import 'package:flutter/material.dart';
import '../helpers/all_routes.dart';

class AuthProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSupplierMode = false;
  bool _isSupplierRegister = false;
  bool _isLoading = false;

  bool get rememberMe => _rememberMe;
  bool get obscurePassword => _obscurePassword;
  bool get isSupplierMode => _isSupplierMode;
  bool get isSupplierRegister => _isSupplierRegister;
  bool get isLoading => _isLoading;

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleSupplierMode(bool value) {
    _isSupplierMode = value;
    notifyListeners();
  }

  void toggleSupplierRegister(bool value) {
    _isSupplierRegister = value;
    notifyListeners();
  }

  Future<bool> handleSignIn(BuildContext context, GlobalKey<FormState> formKey) async {
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      _isLoading = true;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

      _isLoading = false;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, Routes.dashboardScreen);
      }
      return true;
    }
    return false;
  }

  void resetLoginForm() {
    emailController.clear();
    passwordController.clear();
    _rememberMe = false;
    _obscurePassword = true;
    _isSupplierMode = false;
    _isSupplierRegister = false;
    _isLoading = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
