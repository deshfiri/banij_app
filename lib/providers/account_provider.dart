import '../helpers/auth_routing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../helpers/error_message.dart';
import '../constants/app_constants.dart';
import '../helpers/all_routes.dart';
import '../helpers/di.dart';
import '../helpers/navigation_service.dart';

import '../feature/account/model/account_model.dart';
import '../helpers/loading_helper.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';

class AccountProvider extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  AccountDeletionInfoModel? deletionInfo;

  late bool _isBengali;

  bool get isBengali => _isBengali;

  AccountProvider() {
    _isBengali = appData.read('isBengali') ?? false;
    fetchUserProfile();
    fetchDeletionInfo();
  }

  Future<void> fetchDeletionInfo() async {
    try {
      deletionInfo = await accountRxObj.fetchAccountDeletionInfo();

      final status = deletionInfo?.deletionRequest?.status?.toLowerCase() ?? '';
      final msg = deletionInfo?.message?.toLowerCase() ?? '';

      if (status == 'accepted' || msg.contains('accepted')) {
        await AuthRouting.clearSession();

        ToastUtil.showSuccessMessage('Your account deletion request has been accepted.');
        NavigationService.navigateToReplacementUntil(Routes.onboardingScreen);
        return;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('AccountProvider.fetchDeletionInfo failed: $e');
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final accountModel = await accountRxObj.fetchProfile();
      if (accountModel.deletionRequest != null) {
        final status = accountModel.deletionRequest!.status?.toLowerCase() ?? '';
        if (status == 'accepted') {
          await AuthRouting.clearSession();

          ToastUtil.showSuccessMessage('Your account deletion request has been accepted.');
          NavigationService.navigateToReplacementUntil(Routes.onboardingScreen);
          return;
        }
      }

      if (accountModel.data != null) {
        if (accountModel.data!.name != null) {
          nameController.text = accountModel.data!.name!;
        }
        if (accountModel.data!.email != null) {
          emailController.text = accountModel.data!.email!;
        }
        notifyListeners();
      }
    } catch (e) {
      final cachedName = appData.read(KkName);
      final cachedEmail = appData.read(KkUserEmail);
      if (cachedName != null) nameController.text = cachedName;
      if (cachedEmail != null) emailController.text = cachedEmail;
    }
  }

  /// Saves name + email. Returns true when the API accepted the change.
  Future<bool> saveProfile(BuildContext context) async {
    try {
      final Map<String, dynamic> updateData = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
      };

      final accountModel = await accountRxObj.saveProfile(updateData).waitingForSucess();

      if (accountModel.data != null) {
        if (accountModel.data!.name != null) {
          nameController.text = accountModel.data!.name!;
          appData.write(KkName, accountModel.data!.name!);
        }
        if (accountModel.data!.email != null) {
          emailController.text = accountModel.data!.email!;
          appData.write(KkUserEmail, accountModel.data!.email!);
        }
      }

      ToastUtil.showSuccessMessage('profile_updated_success'.tr);
      return true;
    } catch (e) {
      String errorMsg = e.apiErrorMessage;
      if (errorMsg.contains('Failure')) {
        errorMsg = 'Failed to update profile. Please check your details and network connection.';
      }
      ToastUtil.showErrorMessage(errorMsg);
      return false;
    }
  }

  Future<void> toggleLanguage(bool val) async {
    await appData.write('isBengali', val);
    _isBengali = val;
    Get.updateLocale(val ? const Locale('bn', 'BD') : const Locale('en', 'US'));
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    try {
      await logoutRxObj.userLogout().waitingForSucess();
    } catch (e) {
      debugPrint('AccountProvider.logout failed: $e');
    }

    await AuthRouting.clearSession();

    ToastUtil.showSuccessMessage('Logged out successfully');
    NavigationService.navigateToReplacementUntil(Routes.onboardingScreen);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
