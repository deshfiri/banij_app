import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../helpers/all_routes.dart';
import '../helpers/di.dart';
import '../helpers/navigation_service.dart';

import '../feature/account/data/account_api.dart';
import '../helpers/loading_helper.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';

class AccountProvider extends ChangeNotifier {
  final TextEditingController nameController =
      TextEditingController(text: 'Mohammad Hira Ashrafi');
  final TextEditingController emailController =
      TextEditingController(text: 'ashrafiashra038@gmail.com');

  late bool _isBengali;

  bool get isBengali => _isBengali;

  AccountProvider() {
    _isBengali = appData.read('isBengali') ?? false;
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
