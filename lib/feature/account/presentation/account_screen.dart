import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../helpers/di.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/theme_provider.dart';
import '../../auth/presentation/login_screen/loginScreen.dart';
import '../../finance/presentation/finance_screen.dart';

class AccountScreenBody extends StatefulWidget {
  const AccountScreenBody({super.key});

  @override
  State<AccountScreenBody> createState() => _AccountScreenBodyState();
}

class _AccountScreenBodyState extends State<AccountScreenBody> {
  late bool _isBengali;

  @override
  void initState() {
    super.initState();
    _isBengali = appData.read('isBengali') ?? false;
  }

  void _handleProfileTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Profile Settings...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  void _handleSecurityTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Security Settings...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: AppColorsTheme.cardBg(context),
          title: Text(
            'Are you sure you want to logout?'.tr,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          content: Text(
            'You will need to sign in again to access your account and workspace.'.tr,
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                'No'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColorsTheme.textMutedColor(context),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Yes'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      color: AppColorsTheme.background(context),
      child: Column(
        children: [
          // Account Header / AppBar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              border: Border(
                bottom: BorderSide(color: AppColorsTheme.borderColor(context), width: 1.w),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Text(
                  'account_setting'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
              ),
            ),
          ),

          // Body Content with Cards & Switches
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'account_management'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(6.h),
                  Text(
                    'account_subtitle'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),

                  // Card 1: Profile
                  FinanceCardWidget(
                    title: 'profile'.tr,
                    subtitle: 'profile_subtitle'.tr,
                    iconData: Icons.person_outline_rounded,
                    onTap: () => _handleProfileTap(context),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // Card 2: Security
                  FinanceCardWidget(
                    title: 'security'.tr,
                    subtitle: 'security_subtitle'.tr,
                    iconData: Icons.security_outlined,
                    onTap: () => _handleSecurityTap(context),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // Card 3: Dark Mode Switch Card
                  AccountSwitchCardWidget(
                    title: 'dark_mode'.tr,
                    subtitle: themeProvider.isDarkMode ? 'dark_mode_on'.tr : 'dark_mode_off'.tr,
                    iconData: Icons.dark_mode_outlined,
                    value: themeProvider.isDarkMode,
                    onChanged: (val) {
                      context.read<ThemeProvider>().toggleDarkMode(val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
                          backgroundColor: primaryOrange,
                          duration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                  ),
                  UIHelper.verticalSpace(16.h),

                  // Card 4: Language Change Switch Card
                  AccountSwitchCardWidget(
                    title: 'change_language'.tr,
                    subtitle: _isBengali ? 'lang_bn'.tr : 'lang_en'.tr,
                    iconData: Icons.language_outlined,
                    value: _isBengali,
                    onChanged: (val) async {
                      await appData.write('isBengali', val);
                      if (!context.mounted) return;
                      setState(() {
                        _isBengali = val;
                      });
                      Get.updateLocale(
                        val ? const Locale('bn', 'BD') : const Locale('en', 'US'),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Language switched to Bengali' : 'Language switched to English'),
                          backgroundColor: primaryOrange,
                          duration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                  ),
                  UIHelper.verticalSpace(16.h),

                  // Card 5: Logout Card
                  FinanceCardWidget(
                    title: 'logout'.tr,
                    subtitle: 'logout_subtitle'.tr,
                    iconData: Icons.logout_rounded,
                    onTap: () => _showLogoutConfirmation(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AccountSwitchCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AccountSwitchCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context), width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF221A15) : const Color(0xFFFFF7F2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: primaryOrange.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              iconData,
              size: 26.sp,
              color: primaryOrange,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: primaryOrange,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
