import '../constants/app_constants.dart';
import '../networks/dio/dio.dart';
import 'all_routes.dart';
import 'di.dart';

/// Where a signed-in account lands — one rule for login, 2FA and app start.
abstract final class AuthRouting {
  /// Supplier → supplier dashboard; user → dashboard, or KYC while the
  /// business account is not activated yet.
  static String homeRoute({required bool isSupplier, bool isActivated = true}) {
    if (isSupplier) return Routes.supplierDashboardScreen;
    return isActivated ? Routes.dashboardScreen : Routes.kycVerificationScreen;
  }

  /// Remembers the account type so a restart opens the right dashboard.
  static Future<void> saveAccountType({required bool isSupplier}) => appData.write(kKeyIsSupplier, isSupplier);

  /// Home route for the saved session (used on app start).
  static String get savedHomeRoute => homeRoute(isSupplier: appData.read(kKeyIsSupplier) == true);

  /// A real signed-in session: logged in with a saved bearer token.
  static bool get hasSession {
    final token = appData.read(kKeyAccessToken)?.toString() ?? '';
    return appData.read(kKeyIsLoggedIn) == true && token.isNotEmpty;
  }

  /// A signed-in supplier session.
  static bool get hasSupplierSession => hasSession && appData.read(kKeyIsSupplier) == true;

  /// Ends the session on this device: forgets the token, account type and
  /// user details, and drops the token from the network client so no later
  /// request (e.g. the next login) still carries it.
  static Future<void> clearSession() async {
    await appData.remove(kKeyAccessToken);
    await appData.remove(kKeyIsSupplier);
    await appData.write(kKeyIsLoggedIn, false);
    await appData.remove(KkName);
    await appData.remove(KkUserEmail);
    await appData.remove(KkID);
    DioSingleton.instance.create();
  }
}
