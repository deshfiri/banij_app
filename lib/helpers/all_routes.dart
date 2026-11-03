import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../feature/auth/presentation/forgot_password_screen/forgot_password_screen.dart';
import '../feature/auth/presentation/login_screen/loginScreen.dart';
import '../feature/auth/presentation/register_screen/registerScreen.dart';
import '../feature/dashboard/presentation/dashboard_screen.dart';

final class Routes {
  static final Routes _routes = Routes._internal();
  Routes._internal();
  static Routes get instance => _routes;

  static const String loginScreen = '/loginScreen';
  static const String signupScreen = '/signupScreen';
  static const String forgotPasswordScreen = '/forgotPasswordScreen';
  static const String dashboardScreen = '/dashboardScreen';
}

final class RouteGenerator {
  static final RouteGenerator _routeGenerator = RouteGenerator._internal();
  RouteGenerator._internal();
  static RouteGenerator get instance => _routeGenerator;

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.loginScreen:
        return Platform.isAndroid
            ? _AdvancedTransitionRoute(widget: const LoginScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const LoginScreen(), settings: settings);
      case Routes.signupScreen:
        return Platform.isAndroid
            ? _AdvancedTransitionRoute(widget: const RegisterScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const RegisterScreen(), settings: settings);
      case Routes.forgotPasswordScreen:
        return Platform.isAndroid
            ? _AdvancedTransitionRoute(widget: const ForgotPasswordScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const ForgotPasswordScreen(), settings: settings);
      case Routes.dashboardScreen:
        return Platform.isAndroid
            ? _AdvancedTransitionRoute(widget: const DashboardScreen(), settings: settings)
            : CupertinoPageRoute(builder: (context) => const DashboardScreen(), settings: settings);
    }

    return null;
  }
}

class _AdvancedTransitionRoute extends PageRouteBuilder {
  final Widget widget;
  @override
  final RouteSettings settings;

  _AdvancedTransitionRoute({required this.widget, required this.settings})
    : super(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, animation, secondaryAnimation) => widget,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;

          var slideTween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var fadeTween = Tween<double>(begin: 0.0, end: 1.0).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(slideTween),
            child: FadeTransition(
              opacity: animation.drive(fadeTween),
              child: child,
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
