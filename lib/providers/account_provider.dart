import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../helpers/all_routes.dart';
import '../helpers/di.dart';
import '../helpers/navigation_service.dart';

import '../feature/account/model/account_model.dart';
import '../feature/package/model/package_model.dart';
import '../helpers/loading_helper.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';

class AccountProvider extends ChangeNotifier {
  final TextEditingController nameController =
      TextEditingController(text: 'Mohammad Hira Ashrafi');
  final TextEditingController emailController =
      TextEditingController(text: 'ashrafiashra038@gmail.com');

  PackageResponseModel? packageResponse;
  AccountDeletionInfoModel? deletionInfo;

  late bool _isBengali;

  bool get isBengali => _isBengali;

  AccountProvider() {
    _isBengali = appData.read('isBengali') ?? false;
    fetchUserProfile();
    fetchPackages();
    fetchDeletionInfo();
  }

  Future<void> fetchPackages() async {
    try {
      packageResponse = await packageRxObj.fetchPackages();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchDeletionInfo() async {
    try {
      deletionInfo = await accountRxObj.fetchAccountDeletionInfo();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchUserProfile() async {
    try {
      final accountModel = await accountRxObj.fetchProfile();
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

  Future<void> saveProfile(BuildContext context) async {
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
    } catch (e) {
      String errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.contains('Failure')) {
        errorMsg = 'Failed to update profile. Please check your details and network connection.';
      }
      ToastUtil.showErrorMessage(errorMsg);
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
    } catch (_) {}

    await appData.remove(kKeyAccessToken);
    await appData.write(kKeyIsLoggedIn, false);
    await appData.remove(KkName);
    await appData.remove(KkUserEmail);
    await appData.remove(KkID);

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
