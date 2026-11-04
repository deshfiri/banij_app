import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/custom_button.dart';
import '../../../common_widget/custom_field_label.dart';
import '../../../common_widget/custom_form_field.dart';
import '../../../common_widget/finance_card_widget.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/theme_provider.dart';

class AccountScreenBody extends StatelessWidget {
  final String? initialTab;
  const AccountScreenBody({super.key, this.initialTab});

  void _showLogoutConfirmation(BuildContext context, AccountProvider accountProvider) {
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
          actionsPadding: EdgeInsets.zero,
          actions: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        side: BorderSide(
                          color: AppColorsTheme.borderColor(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'No'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        accountProvider.logout(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Yes'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
    final accountProvider = context.watch<AccountProvider>();
    final canPop = Navigator.canPop(context);

    return Container(
      color: AppColorsTheme.background(context),
      child: Column(
        children: [
          // Account Header / AppBar with Back Icon if navigable
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
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
              child: Row(
                children: [
                  if (canPop) ...[
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.arrow_back,
                        color: AppColorsTheme.textMainColor(context),
                        size: 22.sp,
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'settings'.tr,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        UIHelper.verticalSpace(2.h),
                        Text(
                          'account_subtitle'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColorsTheme.textMutedColor(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Main Body Settings Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section 1: Profile Update Form
                  Container(
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: AppColorsTheme.borderColor(context),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'profile_heading'.tr,
                          style: TextStyle(
                            fontSize: 17.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        UIHelper.verticalSpace(4.h),
                        Text(
                          'profile_desc'.tr,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColorsTheme.textMutedColor(context),
                          ),
                        ),
                        UIHelper.verticalSpace(18.h),

                        // Name Field
                        CustomFieldLabel(label: 'name'.tr),
                        CustomFormField(
                          controller: accountProvider.nameController,
                        ),
                        UIHelper.verticalSpace(16.h),

                        // Email Field
                        CustomFieldLabel(label: 'email_address'.tr),
                        CustomFormField(
                          controller: accountProvider.emailController,
                        ),
                        UIHelper.verticalSpace(20.h),

                        // Save Button
                        SizedBox(
                          width: 110.w,
                          child: CustomButton(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated successfully!'),
                                  backgroundColor: primaryOrange,
                                ),
                              );
                            },
                            btnName: 'save'.tr,
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(24.h),

                  // Section 2: Appearance & Theme
                  Text(
                    'appearance_heading'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(12.h),

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
                  UIHelper.verticalSpace(14.h),

                  // Language Switch Card
                  AccountSwitchCardWidget(
                    title: 'change_language'.tr,
                    subtitle: accountProvider.isBengali ? 'lang_bn'.tr : 'lang_en'.tr,
                    iconData: Icons.language_outlined,
                    value: accountProvider.isBengali,
                    onChanged: (val) async {
                      await accountProvider.toggleLanguage(val);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(val ? 'Language switched to Bengali' : 'Language switched to English'),
                          backgroundColor: primaryOrange,
                          duration: const Duration(milliseconds: 600),
                        ),
                      );
                    },
                  ),
                  UIHelper.verticalSpace(24.h),

                  // Section 3: Logout Card
                  FinanceCardWidget(
                    title: 'logout'.tr,
                    subtitle: 'logout_subtitle'.tr,
                    iconData: Icons.logout_rounded,
                    onTap: () => _showLogoutConfirmation(context, accountProvider),
                  ),
                  UIHelper.verticalSpace(20.h),
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
              size: 24.sp,
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
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
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
