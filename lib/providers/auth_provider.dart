import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../helpers/all_routes.dart';

class AuthProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSupplierMode = false;
  bool _isSupplierRegister = false;
  bool _isLoading = false;

  AuthProvider() {
    _loadSavedCredentials();
    emailController.addListener(_autoSaveCredentials);
    passwordController.addListener(_autoSaveCredentials);
  }

  void _loadSavedCredentials() {
    try {
      final box = Hive.box('auth_box');
      final remember = box.get('rememberMe', defaultValue: false) as bool;
      if (remember) {
        _rememberMe = true;
        emailController.text = box.get('email', defaultValue: '') as String;
        passwordController.text = box.get('password', defaultValue: '') as String;
      }
    } catch (_) {}
  }

  void _autoSaveCredentials() {
    if (_rememberMe) {
      try {
        final box = Hive.box('auth_box');
        box.put('email', emailController.text.trim());
        box.put('password', passwordController.text);
      } catch (_) {}
    }
  }

  bool get rememberMe => _rememberMe;
  bool get obscurePassword => _obscurePassword;
  bool get isSupplierMode => _isSupplierMode;
  bool get isSupplierRegister => _isSupplierRegister;
  bool get isLoading => _isLoading;

  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    try {
      final box = Hive.box('auth_box');
      box.put('rememberMe', _rememberMe);
      if (!_rememberMe) {
        box.delete('email');
        box.delete('password');
      } else {
        box.put('email', emailController.text.trim());
        box.put('password', passwordController.text);
      }
    } catch (_) {}
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

      try {
        final box = Hive.box('auth_box');
        box.put('rememberMe', _rememberMe);
        if (_rememberMe) {
          box.put('email', emailController.text.trim());
          box.put('password', passwordController.text);
        } else {
          emailController.clear();
          passwordController.clear();
          box.delete('email');
          box.delete('password');
        }
      } catch (_) {}

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
    try {
      final box = Hive.box('auth_box');
      final remember = box.get('rememberMe', defaultValue: false) as bool;
      if (remember) {
        _rememberMe = true;
        emailController.text = box.get('email', defaultValue: '') as String;
        passwordController.text = box.get('password', defaultValue: '') as String;
      } else {
        emailController.clear();
        passwordController.clear();
        _rememberMe = false;
      }
    } catch (_) {
      emailController.clear();
      passwordController.clear();
      _rememberMe = false;
    }
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
