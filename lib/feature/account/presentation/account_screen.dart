import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/custom_button.dart';
import '../../../common_widget/custom_field_label.dart';
import '../../../common_widget/custom_form_field.dart';
import '../../../common_widget/finance_card_widget.dart';
import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/di.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../finance/presentation/widgets/invoice_receipt_preview_modal.dart';

class AccountScreenBody extends StatefulWidget {
  final String? initialTab;
  final VoidCallback? onOpenDrawer;

  const AccountScreenBody({
    super.key,
    this.initialTab,
    this.onOpenDrawer,
  });

  @override
  State<AccountScreenBody> createState() => _AccountScreenBodyState();
}

class _AccountScreenBodyState extends State<AccountScreenBody> {
  late String _selectedTab;
  final List<String> _tabs = [
    'Profile',
    'Security',
    'Package',
    'Invoices',
    'Receipts',
    'Appearance',
  ];

  late bool _isBengali;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab == 'supplier' ? 'Profile' : (widget.initialTab ?? 'Profile');
    _isBengali = appData.read('isBengali') ?? false;
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  Widget _buildTabContent(BuildContext context, ThemeProvider themeProvider, AccountProvider accountProvider) {
    switch (_selectedTab) {
      case 'Profile':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'profile_heading'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'profile_desc'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(20.h),
            CustomFieldLabel(label: 'name'.tr),
            CustomFormField(
              controller: accountProvider.nameController,
            ),
            UIHelper.verticalSpace(16.h),
            CustomFieldLabel(label: 'email_address'.tr),
            CustomFormField(
              controller: accountProvider.emailController,
            ),
            UIHelper.verticalSpace(24.h),
            SizedBox(
              width: 110.w,
              child: CustomButton(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('profile_updated_success'.tr),
                      backgroundColor: primaryOrange,
                    ),
                  );
                },
                btnName: 'save'.tr,
              ),
            ),
            UIHelper.verticalSpace(32.h),
            Text(
              'delete_account_title'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(6.h),
            Text(
              'delete_account_desc'.tr,
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
              'security_heading'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'security_desc'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(20.h),
            FinanceCardWidget(
              title: 'change_password'.tr,
              subtitle: 'change_password_sub'.tr,
              iconData: Icons.lock_outline_rounded,
              onTap: () {
                Navigator.pushNamed(context, Routes.changePasswordScreen);
              },
            ),
          ],
        );

      case 'Package':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'your_package'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'package_desc'.tr,
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
                        'standard_package'.tr,
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
                              'awaiting_payment'.tr,
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
                    'no_package_renew'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),
                  Text(
                    'paid'.tr,
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
                    'renews_at'.tr,
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
                    'how_you_got_it'.tr,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  Text(
                    'purchased'.tr,
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
                    'what_this_includes'.tr,
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
                          'dedicated_website'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        Text(
                          'included'.tr,
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
              'invoices_heading'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'invoices_desc'.tr,
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
              onTap: () {
                InvoiceReceiptPreviewModal.show(
                  context,
                  title: 'Invoice',
                  docNo: 'INV-2026-001',
                  clientOrGateway: 'Considine Supermarket Ltd',
                  date: '05 Nov 2026',
                  dueDateOrTime: '20 Nov 2026',
                  amount: '৳49,500.00',
                  status: 'PENDING',
                  isInvoice: true,
                );
              },
            ),
          ],
        );

      case 'Receipts':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'receipts_heading'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'receipts_desc'.tr,
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
              onTap: () {
                InvoiceReceiptPreviewModal.show(
                  context,
                  title: 'Receipt',
                  docNo: 'REC-2026-089',
                  clientOrGateway: 'bKash Merchant Payment',
                  date: '04 Nov 2026, 04:30 PM',
                  dueDateOrTime: '04 Nov 2026, 04:30 PM',
                  amount: '৳25,500.00',
                  status: 'VERIFIED',
                  isInvoice: false,
                );
              },
            ),
          ],
        );

      case 'Appearance':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'appearance_heading'.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'appearance_desc'.tr,
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
                    content: Text(val ? 'dark_mode_enabled'.tr : 'light_mode_enabled'.tr),
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
                    content: Text(val ? 'lang_switched_bn'.tr : 'lang_switched_en'.tr),
                    backgroundColor: primaryOrange,
                    duration: const Duration(milliseconds: 600),
                  ),
                );
              },
            ),
            UIHelper.verticalSpace(16.h),

            // Logout Action Card
            AccountActionCardWidget(
              title: 'logout'.tr,
              subtitle: 'logout_subtitle'.tr,
              iconData: Icons.logout_rounded,
              onTap: () => _showLogoutConfirmation(context, accountProvider),
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
    final accountProvider = context.watch<AccountProvider>();
    final canPop = Navigator.canPop(context);
    final isSupplier = widget.initialTab == 'supplier';

    final isDark = themeProvider.isDarkMode;

    return Container(
      color: AppColorsTheme.background(context),
      child: Column(
        children: [
          // Account Top Header / AppBar Stack (Fixed Centered Logo)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 100% Dead-Centered Logo
                  Center(
                    child: Image.asset(
                      isDark ? whiteLogo : logo,
                      width: 110.w,
                      height: 36.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Left Back Button or Menu Icon
                  if (canPop)
                    Positioned(
                      left: 0,
                      child: IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(
                          Icons.arrow_back,
                          color: AppColorsTheme.textMainColor(context),
                          size: 22.sp,
                        ),
                      ),
                    )
                  else if (widget.onOpenDrawer != null)
                    Positioned(
                      left: 0,
                      child: IconButton(
                        onPressed: widget.onOpenDrawer,
                        icon: Icon(
                          Icons.menu_rounded,
                          color: AppColorsTheme.textMainColor(context),
                          size: 24.sp,
                        ),
                      ),
                    ),
                  // Right Action Icons: Notifications & Profile
                  Positioned(
                    right: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pushNamed(context, Routes.notificationScreen);
                          },
                          icon: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                Icons.notifications_none_rounded,
                                color: AppColorsTheme.textMainColor(context),
                                size: 22.sp,
                              ),
                              Positioned(
                                top: -2.h,
                                right: -2.w,
                                child: Container(
                                  width: 8.w,
                                  height: 8.h,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: primaryOrange,
                                  ),
                                ),
                              ),
                            ],
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
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 100.h),
              child: isSupplier
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Supplier Account & Profile Settings View
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

                              CustomFieldLabel(label: 'name'.tr),
                              CustomFormField(
                                controller: accountProvider.nameController,
                              ),
                              UIHelper.verticalSpace(16.h),

                              CustomFieldLabel(label: 'email_address'.tr),
                              CustomFormField(
                                controller: accountProvider.emailController,
                              ),
                              UIHelper.verticalSpace(20.h),

                              SizedBox(
                                width: 110.w,
                                child: CustomButton(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('supplier_profile_updated_success'.tr),
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

                        // Appearance & Theme Section for Supplier
                        Text(
                          'appearance_heading'.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColorsTheme.textMainColor(context),
                          ),
                        ),
                        UIHelper.verticalSpace(12.h),

                        AccountSwitchCardWidget(
                          title: 'dark_mode'.tr,
                          subtitle: themeProvider.isDarkMode ? 'dark_mode_on'.tr : 'dark_mode_off'.tr,
                          iconData: Icons.dark_mode_outlined,
                          value: themeProvider.isDarkMode,
                          onChanged: (val) {
                            context.read<ThemeProvider>().toggleDarkMode(val);
                          },
                        ),
                        UIHelper.verticalSpace(14.h),

                        AccountSwitchCardWidget(
                          title: 'change_language'.tr,
                          subtitle: _isBengali ? 'lang_bn'.tr : 'lang_en'.tr,
                          iconData: Icons.language_outlined,
                          value: _isBengali,
                          onChanged: (val) async {
                            await accountProvider.toggleLanguage(val);
                            if (!context.mounted) return;
                            setState(() {
                              _isBengali = val;
                            });
                          },
                        ),
                        UIHelper.verticalSpace(24.h),

                        // Logout Action Card
                        AccountActionCardWidget(
                          title: 'logout'.tr,
                          subtitle: 'logout_subtitle'.tr,
                          iconData: Icons.logout_rounded,
                          onTap: () => _showLogoutConfirmation(context, accountProvider),
                        ),
                        UIHelper.verticalSpace(20.h),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vertical Tabs List for User Account
                        ..._tabs.map((tab) {
                          final isSelected = _selectedTab == tab;

                          String tabLabel = tab;
                          if (tab == 'Profile') tabLabel = 'profile'.tr;
                          if (tab == 'Security') tabLabel = 'security'.tr;
                          if (tab == 'Package') tabLabel = 'package_tab'.tr;
                          if (tab == 'Invoices') tabLabel = 'invoices_tab'.tr;
                          if (tab == 'Receipts') tabLabel = 'receipts_tab'.tr;
                          if (tab == 'Appearance') tabLabel = 'appearance_tab'.tr;

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
                                tabLabel,
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
                        _buildTabContent(context, themeProvider, accountProvider),
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(11.w),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: isDark ? 0.16 : 0.14),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: primaryOrange.withValues(alpha: 0.25),
                width: 1.w,
              ),
            ),
            child: Icon(
              iconData,
              size: 22.sp,
              color: primaryOrange,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                SizedBox(height: 3.h),
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

class AccountActionCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final VoidCallback onTap;

  const AccountActionCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: AppColorsTheme.borderColor(context),
              width: 1.w,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: isDark ? 0.16 : 0.14),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: primaryOrange.withValues(alpha: 0.25),
                    width: 1.w,
                  ),
                ),
                child: Icon(
                  iconData,
                  size: 22.sp,
                  color: primaryOrange,
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    SizedBox(height: 3.h),
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
              Icon(
                Icons.chevron_right,
                size: 20.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
