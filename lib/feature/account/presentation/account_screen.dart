import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/pill_chip.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/di.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../../../providers/account_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../business/presentation/widgets/drawer/logout_confirmation_dialog.dart';
import '../model/language_locale_model.dart';
import '../model/security_model.dart';
import 'widgets/account_appearance_section.dart';
import 'widgets/account_documents_section.dart';
import 'widgets/account_hero_header.dart';
import 'widgets/account_package_section.dart';
import 'widgets/account_profile_section.dart';
import 'widgets/account_security_section.dart';

/// Account tab. Users get tabbed sections (Profile, Security, Package,
/// Invoices, Receipts, Appearance); suppliers (`initialTab == 'supplier'`)
/// get Profile + Appearance on one page.
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

/// Tab id (kept as the original strings), label key and chip icon.
class _AccountTab {
  final String id;
  final String labelKey;
  final IconData icon;

  const _AccountTab(this.id, this.labelKey, this.icon);

  static const List<_AccountTab> all = [
    _AccountTab('Profile', 'profile', Icons.person_outline_rounded),
    _AccountTab('Security', 'security', Icons.shield_outlined),
    _AccountTab('Package', 'package_tab', Icons.workspace_premium_outlined),
    _AccountTab('Invoices', 'invoices_tab', Icons.receipt_long_outlined),
    _AccountTab('Receipts', 'receipts_tab', Icons.payments_outlined),
    _AccountTab('Appearance', 'appearance_tab', Icons.palette_outlined),
  ];
}

class _AccountScreenBodyState extends State<AccountScreenBody> {
  late String _selectedTab;

  late bool _isBengali;
  SecurityModel? _securityModel;
  LanguageLocaleResponseModel? _languageLocaleModel;
  bool _isLoadingSecurity = false;

  bool get _isSupplier => widget.initialTab == 'supplier';

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTab == 'supplier' ? 'Profile' : (widget.initialTab ?? 'Profile');
    _isBengali = appData.read('isBengali') ?? false;
    _fetchSecurityData();
    _fetchLanguageLocale();
  }

  Future<void> _fetchLanguageLocale() async {
    try {
      final res = await languageLocaleRxObj.fetchLanguageLocale();
      if (mounted) {
        setState(() {
          _languageLocaleModel = res;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchSecurityData() async {
    setState(() {
      _isLoadingSecurity = true;
    });
    try {
      final res = await securityRxObj.fetchSecurityRules();
      if (mounted) {
        setState(() {
          _securityModel = res;
          _isLoadingSecurity = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoadingSecurity = false;
        });
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: primaryOrange, duration: const Duration(milliseconds: 600)),
    );
  }

  // ---- User view handlers (with confirmation snackbars) ----

  void _onUserDarkModeChanged(bool val) {
    context.read<ThemeProvider>().toggleDarkMode(val);
    _showSnack(val ? 'dark_mode_enabled'.tr : 'light_mode_enabled'.tr);
  }

  Future<void> _onUserLanguageChanged(bool val) async {
    final targetLocale = val ? 'bn' : 'en';
    try {
      await languageLocaleRxObj.updateLanguageLocale({"locale": targetLocale});
    } catch (_) {}
    await appData.write('isBengali', val);
    if (!mounted) return;
    setState(() {
      _isBengali = val;
    });
    Get.updateLocale(val ? const Locale('bn', 'BD') : const Locale('en', 'US'));
    _showSnack(val ? 'lang_switched_bn'.tr : 'lang_switched_en'.tr);
  }

  String get _userLanguageSubtitle {
    final langLabel = _isBengali ? 'lang_bn'.tr : 'lang_en'.tr;
    final locale = _languageLocaleModel?.data?.locale;
    return locale != null ? 'Locale: ${locale.toUpperCase()} ($langLabel)' : langLabel;
  }

  // ---- Supplier view handlers (no snackbars; language via AccountProvider) ----

  Future<void> _onSupplierLanguageChanged(bool val, AccountProvider accountProvider) async {
    final targetLocale = val ? 'bn' : 'en';
    try {
      await languageLocaleRxObj.updateLanguageLocale({"locale": targetLocale});
    } catch (_) {}
    await accountProvider.toggleLanguage(val);
    if (!mounted) return;
    setState(() {
      _isBengali = val;
    });
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
          AccountHeroHeader(
            onBack: canPop ? () => Navigator.pop(context) : null,
            onOpenDrawer: widget.onOpenDrawer,
            onNotifications: () => Navigator.pushNamed(context, Routes.notificationScreen),
            fallbackName: accountProvider.nameController.text,
            fallbackEmail: accountProvider.emailController.text,
          ),
          if (!_isSupplier) ...[
            UIHelper.verticalSpace(14.h),
            PillChipBar(
              chips: [
                for (final tab in _AccountTab.all)
                  PillChip(
                    label: tab.labelKey.tr,
                    icon: tab.icon,
                    isSelected: _selectedTab == tab.id,
                    onTap: () => setState(() => _selectedTab = tab.id),
                  ),
              ],
            ),
          ],
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 100.h),
              child: _isSupplier
                  ? _buildSupplierContent(themeProvider, accountProvider)
                  : _buildTabContent(themeProvider, accountProvider),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierContent(ThemeProvider themeProvider, AccountProvider accountProvider) {
    return Column(
      children: [
        AccountProfileSection(accountProvider: accountProvider),
        UIHelper.verticalSpace(16.h),
        AccountAppearanceSection(
          showDescription: false,
          isDarkMode: themeProvider.isDarkMode,
          onDarkModeChanged: (val) => context.read<ThemeProvider>().toggleDarkMode(val),
          isBengali: _isBengali,
          languageSubtitle: _isBengali ? 'lang_bn'.tr : 'lang_en'.tr,
          onLanguageChanged: (val) => _onSupplierLanguageChanged(val, accountProvider),
          onLogout: () => LogoutConfirmationDialog.show(context),
        ),
      ],
    );
  }

  Widget _buildTabContent(ThemeProvider themeProvider, AccountProvider accountProvider) {
    switch (_selectedTab) {
      case 'Profile':
        return AccountProfileSection(accountProvider: accountProvider);
      case 'Security':
        return AccountSecuritySection(isLoading: _isLoadingSecurity, securityModel: _securityModel);
      case 'Package':
        return AccountPackageSection(
          packages: accountProvider.packageResponse?.data ?? [],
          selectedSlug: accountProvider.packageResponse?.selectedSlug,
        );
      case 'Invoices':
        return const AccountInvoicesSection();
      case 'Receipts':
        return const AccountReceiptsSection();
      case 'Appearance':
        return AccountAppearanceSection(
          isDarkMode: themeProvider.isDarkMode,
          onDarkModeChanged: _onUserDarkModeChanged,
          isBengali: _isBengali,
          languageSubtitle: _userLanguageSubtitle,
          onLanguageChanged: _onUserLanguageChanged,
          onLogout: () => LogoutConfirmationDialog.show(context),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
