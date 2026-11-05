import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../constants/app_constants.dart';
import '../helpers/all_routes.dart';
import '../helpers/di.dart';
import '../helpers/navigation_service.dart';

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

  void logout(BuildContext context) {
    appData.write(kKeyIsLoggedIn, false);
    NavigationService.navigateToReplacementUntil(Routes.onboardingScreen);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
}
