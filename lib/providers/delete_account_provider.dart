import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../feature/account/data/account_api.dart';
import '../helpers/all_routes.dart';
import '../helpers/di.dart';
import '../helpers/loading_helper.dart';
import '../helpers/navigation_service.dart';
import '../helpers/toast.dart';

class DeleteAccountProvider extends ChangeNotifier {
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  bool get obscurePassword => _obscurePassword;
  bool get isLoading => _isLoading;

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  Future<bool> deleteAccount(BuildContext context, GlobalKey<FormState> formKey) async {
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) {
      return false;
    }

    _isLoading = true;
    notifyListeners();

    try {
      await AccountApi.instance.deleteAccount(
        currentPassword: currentPasswordController.text,
        reason: reasonController.text.trim(),
      ).waitingForSucess();

      _isLoading = false;
      notifyListeners();

      await appData.remove(kKeyAccessToken);
      await appData.write(kKeyIsLoggedIn, false);
      await appData.remove(KkName);
      await appData.remove(KkUserEmail);
      await appData.remove(KkID);

      ToastUtil.showSuccessMessage('Account deleted successfully');
      resetForm();
      NavigationService.navigateToReplacementUntil(Routes.onboardingScreen);
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('Failure')) {
        errorMsg = 'Failed to delete account. Please check your password and network connection.';
      }
      ToastUtil.showErrorMessage(errorMsg);
      return false;
    }
  }

  void resetForm() {
    currentPasswordController.clear();
    reasonController.clear();
    _obscurePassword = true;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    currentPasswordController.dispose();
    reasonController.dispose();
    super.dispose();
  }
}
