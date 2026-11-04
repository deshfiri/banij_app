import 'package:flutter/material.dart';
import '../helpers/all_routes.dart';

class SupplierRegisterProvider extends ChangeNotifier {
  int _currentStep = 1;

  // Step 1 Controllers (Business)
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController contactPersonController = TextEditingController();
  final TextEditingController businessAddressController = TextEditingController();

  // Step 2 Controllers (Contact & documents)
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController tradeLicenceController = TextEditingController();
  final TextEditingController tinController = TextEditingController();

  // Step 3 Controllers (Account security)
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  int get currentStep => _currentStep;
  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void handleContinue(BuildContext context, GlobalKey<FormState> formKey) {
    FocusScope.of(context).unfocus();
    if (formKey.currentState!.validate()) {
      if (_currentStep < 3) {
        _currentStep++;
        notifyListeners();
      } else {
        submitRegistration(context);
      }
    }
  }

  void handleBack(BuildContext context) {
    if (_currentStep > 1) {
      _currentStep--;
      notifyListeners();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> submitRegistration(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    _isLoading = false;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushReplacementNamed(context, Routes.supplierDashboardScreen);
    }
  }

  void resetSupplierForm() {
    _currentStep = 1;
    businessNameController.clear();
    contactPersonController.clear();
    businessAddressController.clear();
    emailController.clear();
    phoneController.clear();
    tradeLicenceController.clear();
    tinController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    _isLoading = false;
  }

  @override
  void dispose() {
    businessNameController.dispose();
    contactPersonController.dispose();
    businessAddressController.dispose();
    emailController.dispose();
    phoneController.dispose();
    tradeLicenceController.dispose();
    tinController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
