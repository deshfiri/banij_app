import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../feature/account/presentation/account_screen_wrapper.dart';
import '../feature/account/presentation/change_password_screen.dart';
import '../feature/account/presentation/delete_account_screen.dart';
import '../feature/auth/presentation/forgot_password_screen/forgot_password_screen.dart';
import '../feature/auth/presentation/login_screen/loginScreen.dart';
import '../feature/auth/presentation/onboarding_screen/onboarding_screen.dart';
import '../feature/auth/presentation/register_screen/registerScreen.dart';
import '../feature/auth/presentation/supplier_register_screen/supplier_register_screen.dart';
import '../feature/business/presentation/kyc_verification_screen.dart';
import '../feature/business/presentation/notification_screen.dart';
import '../feature/business/presentation/supplier_dashboard_screen.dart';
import '../feature/business/presentation/verification_history_screen.dart';
import '../feature/dashboard/presentation/dashboard_screen.dart';

final class Routes {
  static final Routes _routes = Routes._internal();
  Routes._internal();
  static Routes get instance => _routes;

  static const String onboardingScreen = '/onboardingScreen';
  static const String loginScreen = '/loginScreen';
  static const String signupScreen = '/signupScreen';
  static const String forgotPasswordScreen = '/forgotPasswordScreen';
  static const String supplierRegisterScreen = '/supplierRegisterScreen';
  static const String supplierDashboardScreen = '/supplierDashboardScreen';
  static const String kycVerificationScreen = '/kycVerificationScreen';
  static const String notificationScreen = '/notificationScreen';
  static const String verificationHistoryScreen = '/verificationHistoryScreen';
  static const String accountScreen = '/accountScreen';
  static const String changePasswordScreen = '/changePasswordScreen';
  static const String deleteAccountScreen = '/deleteAccountScreen';
  static const String dashboardScreen = '/dashboardScreen';
}

final class RouteGenerator {
  static final RouteGenerator _routeGenerator = RouteGenerator._internal();
  RouteGenerator._internal();
  static RouteGenerator get instance => _routeGenerator;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.onboardingScreen:
        return Platform.isAndroid
            ? _AdvancedTransitionRoute(widget: const OnboardingScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const OnboardingScreen(), settings: settings);
      case Routes.loginScreen:
        return Platform.isAndroid
            ? _AdvancedTransitionRoute(widget: const LoginScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const LoginScreen(), settings: settings);
      case Routes.signupScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const RegisterScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const RegisterScreen(), settings: settings);
      case Routes.forgotPasswordScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const ForgotPasswordScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const ForgotPasswordScreen(), settings: settings);
      case Routes.supplierRegisterScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const SupplierRegisterScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const SupplierRegisterScreen(), settings: settings);
      case Routes.supplierDashboardScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const SupplierDashboardScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const SupplierDashboardScreen(), settings: settings);
      case Routes.kycVerificationScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const KycVerificationScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const KycVerificationScreen(), settings: settings);
      case Routes.notificationScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const NotificationScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const NotificationScreen(), settings: settings);
      case Routes.verificationHistoryScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const VerificationHistoryScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const VerificationHistoryScreen(), settings: settings);
      case Routes.accountScreen:
        final initialTab = settings.arguments as String?;
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: AccountScreen(initialTab: initialTab), settings: settings)
            : CupertinoPageRoute(builder: (context) => AccountScreen(initialTab: initialTab), settings: settings);
      case Routes.changePasswordScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const ChangePasswordScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const ChangePasswordScreen(), settings: settings);
      case Routes.deleteAccountScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const DeleteAccountScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const DeleteAccountScreen(), settings: settings);
      case Routes.dashboardScreen:
        return Platform.isAndroid
            ? _LightningFastTransitionRoute(widget: const DashboardScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const DashboardScreen(), settings: settings);
    }

    return null;
  }
}

class _LightningFastTransitionRoute extends PageRouteBuilder {
  final Widget widget;
  @override
  final RouteSettings settings;

  _LightningFastTransitionRoute({required this.widget, required this.settings})
    : super(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 120),
        reverseTransitionDuration: const Duration(milliseconds: 100),
        pageBuilder: (context, animation, secondaryAnimation) => widget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      );
}

class _AdvancedTransitionRoute extends PageRouteBuilder {
  final Widget widget;
  @override
  final RouteSettings settings;

  _AdvancedTransitionRoute({required this.widget, required this.settings})
    : super(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (context, animation, secondaryAnimation) => widget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const curve = Curves.easeInOutCubic;

          var slideTween = Tween(
            begin: const Offset(0.0, 0.08),
            end: Offset.zero,
          ).chain(CurveTween(curve: curve));

          var fadeTween = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).chain(CurveTween(curve: curve));

          var scaleTween = Tween<double>(
            begin: 0.95,
            end: 1.0,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: ScaleTransition(
              scale: animation.drive(scaleTween),
              child: FadeTransition(
                opacity: animation.drive(fadeTween),
                child: child,
              ),
            ),
          );
        },
      );
}

class ScreenTitle extends StatelessWidget {
  final Widget widget;

  const ScreenTitle({super.key, required this.widget});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: .5, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.bounceIn,
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child: widget,
    );
  }
}
