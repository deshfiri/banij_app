import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/di.dart';
import '../../../../providers/theme_provider.dart';
import 'auth_hero_backdrop.dart';
import 'auth_top_bar.dart';

/// Shared frame for auth screens: hero gradient, top bar (optional back,
/// white logo, theme + language toggles) and the screen body below.
///
/// Owns the language/theme toggle behaviour every auth screen used to
/// duplicate: saves `isBengali`, calls `Get.updateLocale`, toggles
/// [ThemeProvider]. Set [showToggleSnackBars] for the onboarding-style
/// confirmation snackbars.
class AuthScaffold extends StatefulWidget {
  final Widget body;
  final Widget? bottomNavigationBar;
  final double heroHeight;
  final VoidCallback? onBack;
  final bool showToggles;
  final bool showToggleSnackBars;

  const AuthScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.heroHeight = 250,
    this.onBack,
    this.showToggles = true,
    this.showToggleSnackBars = false,
  });

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold> {
  late bool _isBengali;

  @override
  void initState() {
    super.initState();
    _isBengali = appData.read('isBengali') ?? false;
  }

  void _showSnack(String message, Duration duration) {
    if (!widget.showToggleSnackBars) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message), backgroundColor: primaryOrange, duration: duration));
  }

  void _toggleTheme(bool isDark) {
    final newMode = !isDark;
    context.read<ThemeProvider>().toggleDarkMode(newMode);
    _showSnack(newMode ? 'dark_mode_enabled'.tr : 'light_mode_enabled'.tr, const Duration(milliseconds: 600));
  }

  Future<void> _toggleLanguage() async {
    final newIsBengali = !_isBengali;
    await appData.write('isBengali', newIsBengali);
    if (!mounted) return;
    setState(() => _isBengali = newIsBengali);
    Get.updateLocale(newIsBengali ? const Locale('bn', 'BD') : const Locale('en', 'US'));
    _showSnack(newIsBengali ? 'lang_switched_bn'.tr : 'lang_switched_en'.tr, const Duration(milliseconds: 700));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        bottomNavigationBar: widget.bottomNavigationBar,
        body: Stack(
          children: [
            AuthHeroBackdrop(height: widget.heroHeight.h),
            SafeArea(
              child: Column(
                children: [
                  AuthTopBar(
                    isDark: isDark,
                    isBengali: _isBengali,
                    showToggles: widget.showToggles,
                    onBack: widget.onBack,
                    onToggleTheme: () => _toggleTheme(isDark),
                    onToggleLanguage: _toggleLanguage,
                  ),
                  Expanded(child: widget.body),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Standard scrolling body for [AuthScaffold] content.
class AuthScrollBody extends StatelessWidget {
  final List<Widget> children;

  const AuthScrollBody({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20.w, 6.h, 20.w, 28.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}
