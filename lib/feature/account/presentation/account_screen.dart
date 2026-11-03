import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/custom_button.dart';
import '../../../common_widget/custom_form_field.dart';
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
  String _selectedTab = 'Profile';
  final List<String> _tabs = [
    'Profile',
    'Security',
    'Package',
    'Invoices',
    'Receipts',
    'Appearance',
  ];

  final TextEditingController _nameController =
      TextEditingController(text: 'Mohammad Hira Ashrafi');
  final TextEditingController _emailController =
      TextEditingController(text: 'ashrafiashra038@gmail.com');

  late bool _isBengali;

  @override
  void initState() {
    super.initState();
    _isBengali = appData.read('isBengali') ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
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

  Widget _buildTabContent(BuildContext context, ThemeProvider themeProvider) {
    switch (_selectedTab) {
      case 'Profile':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'Update your name and email address',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(20.h),
            Text(
              'Name',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(8.h),
            CustomFormField(
              controller: _nameController,
            ),
            UIHelper.verticalSpace(16.h),
            Text(
              'Email address',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(8.h),
            CustomFormField(
              controller: _emailController,
            ),
            UIHelper.verticalSpace(24.h),
            SizedBox(
              width: 100.w,
              child: CustomButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: primaryOrange,
                    ),
                  );
                },
                btnName: 'Save',
              ),
            ),
            UIHelper.verticalSpace(32.h),
            Text(
              'Delete your account',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(6.h),
            Text(
              'You cannot delete your account yourself. Ask us, and an authorised member of our team will review the request.',
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.4,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
          ],
        );

      case 'Security':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Security',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'Manage your password, 2FA, and active sessions.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(20.h),
            FinanceCardWidget(
              title: 'Change Password',
              subtitle: 'Update your account password',
              iconData: Icons.lock_outline_rounded,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening Change Password...'),
                    backgroundColor: primaryOrange,
                  ),
                );
              },
            ),
          ],
        );

      case 'Package':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your package',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'What you are on, what it grants, and when it renews.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(20.h),
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Standard',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_shipping_outlined,
                              size: 12.sp,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Awaiting payment',
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(8.h),
                  Text(
                    'You do not have a package to renew yet.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'Paid',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  Text(
                    '৳49,500.00',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(12.h),
                  Text(
                    'Renews at',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  Text(
                    '৳25,500.00 · Yearly',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(12.h),
                  Text(
                    'How you got it',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  Text(
                    'Purchased',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),
                  Divider(color: AppColorsTheme.borderColor(context)),
                  UIHelper.verticalSpace(12.h),
                  Text(
                    'What this includes',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(10.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.background(context),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Dedicated website',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        Text(
                          'Included',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 'Invoices':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Invoices',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'View and download your billing invoices.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(20.h),
            FinanceCardWidget(
              title: 'Invoice #INV-2026-001',
              subtitle: '৳49,500.00 · Unpaid',
              iconData: Icons.receipt_long_outlined,
              onTap: () {},
            ),
          ],
        );

      case 'Receipts':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Receipts',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'Track your payment receipts and transaction records.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(20.h),
            FinanceCardWidget(
              title: 'Receipt #REC-2026-089',
              subtitle: '৳25,500.00 · Completed',
              iconData: Icons.payments_outlined,
              onTap: () {},
            ),
          ],
        );

      case 'Appearance':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance & Settings',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'Manage your dark mode preference, language, and session.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(20.h),

            // Dark Mode Switch Card
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

            // Language Switch Card
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

            // Logout Card
            FinanceCardWidget(
              title: 'logout'.tr,
              subtitle: 'logout_subtitle'.tr,
              iconData: Icons.logout_rounded,
              onTap: () => _showLogoutConfirmation(context),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
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
                bottom: BorderSide(
                  color: AppColorsTheme.borderColor(context),
                  width: 1.w,
                ),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(4.h),
                  Text(
                    'Manage your profile and account settings',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Body Content with Vertical Tabs & Dynamic View
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vertical Tabs List matching screenshot
                  ..._tabs.map((tab) {
                    final isSelected = _selectedTab == tab;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTab = tab;
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? primaryOrange
                              : AppColorsTheme.cardBg(context),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected
                                ? primaryOrange
                                : AppColorsTheme.borderColor(context),
                          ),
                        ),
                        child: Text(
                          tab,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? Colors.white
                                : AppColorsTheme.textMainColor(context),
                          ),
                        ),
                      ),
                    );
                  }),
                  UIHelper.verticalSpace(8.h),
                  Divider(color: AppColorsTheme.borderColor(context)),
                  UIHelper.verticalSpace(16.h),

                  // Dynamic Tab Content Below
                  _buildTabContent(context, themeProvider),
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
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
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
