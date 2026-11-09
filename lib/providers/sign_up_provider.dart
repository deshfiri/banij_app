import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../feature/auth/model/response_model.dart';
import '../helpers/di.dart';
import '../helpers/loading_helper.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';
import '../networks/dio/dio.dart';

class SignUpProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController partnerCodeController = TextEditingController();

  DateTime? _selectedDob;
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
  DateTime? get selectedDob => _selectedDob;

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
    _selectedDob = picked;
    dobController.text =
        "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
    notifyListeners();
  }

  String _getCountryCode(String country) {
    switch (country) {
      case 'Bangladesh':
        return 'BD';
      case 'India':
        return 'IN';
      case 'United States':
        return 'US';
      case 'United Kingdom':
        return 'GB';
      default:
        return 'BD';
    }
  }

  String _getFormattedGender(String gender) {
    switch (gender.toLowerCase()) {
      case 'male':
        return 'male';
      case 'female':
        return 'female';
      case 'other':
        return 'other';
      default:
        return 'male';
    }
  }

  Future<bool> handleCreateAccount(BuildContext context, GlobalKey<FormState> formKey) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      return false;
    }

    if (!_acceptTerms || !_acceptPrivacy) {
      ToastUtil.showErrorMessage('Please accept both Terms & Conditions and Privacy Policy to proceed.');
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final dobIso = _selectedDob != null
          ? _selectedDob!.toIso8601String()
          : DateTime(2000, 1, 1).toIso8601String();

      final Map<String, dynamic> registrationData = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "mobile": phoneController.text.trim(),
        "password": passwordController.text,
        "password_confirmation": confirmPasswordController.text,
        "date_of_birth": dobIso,
        "gender": _getFormattedGender(_selectedGender),
        "country": _getCountryCode(_selectedCountry),
        "nationality": nationalityController.text.trim().isEmpty
            ? "bangladesi"
            : nationalityController.text.trim(),
        "referral_code": partnerCodeController.text.trim().isEmpty
            ? "string"
            : partnerCodeController.text.trim(),
        "invitation": "string",
        "terms_accepted": _acceptTerms ? "yes" : "no",
        "privacy_accepted": _acceptPrivacy ? "yes" : "no",
        "device_name": "mobile",
      };

      RegisterResponse response = await registerRxObj.userRegister(
        registrationData: registrationData,
      ).waitingForSucess();

      _isLoading = false;
      notifyListeners();

      if (response.token != null || response.user != null) {
        if (response.token != null) {
          await appData.write(kKeyAccessToken, response.token);
          DioSingleton.instance.update(response.token!);
        }
        await appData.write(kKeyIsLoggedIn, true);

        if (response.user != null) {
          if (response.user!.name != null) {
            await appData.write(KkName, response.user!.name);
          }
          if (response.user!.email != null) {
            await appData.write(KkUserEmail, response.user!.email);
          }
          if (response.user!.id != null) {
            await appData.write(KkID, response.user!.id);
          }
        }

        ToastUtil.showSuccessMessage('Registration successful!');
        resetSignUpForm();
        return true;
      } else {
        final errorMsg = response.message ?? 'Registration failed. Please try again.';
        ToastUtil.showErrorMessage(errorMsg);
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('Failure')) {
        errorMsg = 'Failed to register. Please check your credentials and network connection.';
      }
      ToastUtil.showErrorMessage(errorMsg);
      return false;
    }
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
    _selectedDob = null;
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
