import 'package:flutter/material.dart';

class SignUpProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController partnerCodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  bool _acceptPrivacy = false;
  bool _isLoading = false;

  String _selectedGender = 'Not specified';
  final List<String> genderOptions = [
    'Not specified',
    'Male',
    'Female',
    'Other',
  ];

  String _selectedCountry = 'Bangladesh';
  final List<String> countryOptions = [
    'Bangladesh',
    'India',
    'United States',
    'United Kingdom',
    'Other',
  ];

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get acceptTerms => _acceptTerms;
  bool get acceptPrivacy => _acceptPrivacy;
  bool get isLoading => _isLoading;
  String get selectedGender => _selectedGender;
  String get selectedCountry => _selectedCountry;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleObscureConfirmPassword() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  void setAcceptTerms(bool? value) {
    _acceptTerms = value ?? false;
    notifyListeners();
  }

  void setAcceptPrivacy(bool? value) {
    _acceptPrivacy = value ?? false;
    notifyListeners();
  }

  void setSelectedGender(String? gender) {
    if (gender != null) {
      _selectedGender = gender;
      notifyListeners();
    }
  }

  void setSelectedCountry(String? country) {
    if (country != null) {
      _selectedCountry = country;
      notifyListeners();
    }
  }

  void setDateOfBirth(DateTime picked) {
    dobController.text =
        "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
    notifyListeners();
  }

  Future<bool> handleCreateAccount(BuildContext context, GlobalKey<FormState> formKey) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (!_acceptTerms || !_acceptPrivacy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept both Terms & Conditions and Privacy Policy to proceed.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return false;
    }

    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1, milliseconds: 500));

    _isLoading = false;
    notifyListeners();
    return true;
  }

  void resetSignUpForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    dobController.clear();
    nationalityController.clear();
    partnerCodeController.clear();
    _obscurePassword = true;
    _obscureConfirmPassword = true;
    _acceptTerms = false;
    _acceptPrivacy = false;
    _isLoading = false;
    _selectedGender = 'Not specified';
    _selectedCountry = 'Bangladesh';
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    dobController.dispose();
    nationalityController.dispose();
    partnerCodeController.dispose();
    super.dispose();
  }
}
