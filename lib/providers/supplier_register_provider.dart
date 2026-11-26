import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../constants/color.dart';
import '../helpers/all_routes.dart';
import 'auth_provider.dart';

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

  /// The mobile API has no supplier sign-up endpoint (suppliers can only
  /// sign in on `/supplier/auth/login`), so nothing can be registered here.
  /// Instead of pretending — and opening the supplier dashboard without an
  /// account or session — explain it and go back to sign in with the
  /// Supplier switch on and the email filled in.
  Future<void> submitRegistration(BuildContext context) async {
    final email = emailController.text.trim();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        icon: const Icon(Icons.storefront_rounded, color: primaryOrange, size: 36),
        title: Text(
          'Supplier accounts are created by Deshfiri'.tr,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800, color: AppColorsTheme.textMainColor(context)),
        ),
        content: Text(
          'Supplier sign-up is not available in the app yet, so no account was created. '
                  'Please contact Deshfiri to open your supplier account. When you have your supplier login, '
                  'sign in with the Supplier switch on.'
              .tr,
          textAlign: TextAlign.center,
          style: TextStyle(height: 1.45, color: AppColorsTheme.textMutedColor(context)),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Back to sign in'.tr),
            ),
          ),
        ],
      ),
    );
    if (!context.mounted) return;

    resetSupplierForm();
    notifyListeners();
    final auth = context.read<AuthProvider>();
    auth.toggleSupplierRegister(true);
    if (email.isNotEmpty) auth.emailController.text = email;
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacementNamed(context, Routes.loginScreen);
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
