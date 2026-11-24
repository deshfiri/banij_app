import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

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
import 'widgets/account_menu.dart';

/// Account tab. Users get a settings-style list (Profile, Security, Package,
/// Invoices, Receipts, Appearance); tapping a row opens that section on its
/// own screen. Suppliers (`initialTab == 'supplier'`) get Profile +
/// Appearance on one page.
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

/// Section id (kept as the original strings), label key, description key,
/// icon and accent colour.
class _AccountTab {
  final String id;
  final String labelKey;
  final String descKey;
  final IconData icon;
  final Color color;

  const _AccountTab(this.id, this.labelKey, this.descKey, this.icon, this.color);

  static const profile = _AccountTab('Profile', 'profile', 'profile_desc', Icons.person_outline_rounded, primaryOrange);
  static const security = _AccountTab('Security', 'security', 'security_desc', Icons.shield_outlined, Color(0xFF3B82F6));
  static const package = _AccountTab('Package', 'package_tab', 'package_desc', Icons.workspace_premium_outlined, Color(0xFF8B5CF6));
  static const invoices = _AccountTab('Invoices', 'invoices_tab', 'invoices_desc', Icons.receipt_long_outlined, Color(0xFF10B981));
  static const receipts = _AccountTab('Receipts', 'receipts_tab', 'receipts_desc', Icons.payments_outlined, Color(0xFF14B8A6));
  static const appearance = _AccountTab('Appearance', 'appearance_tab', 'appearance_desc', Icons.palette_outlined, Color(0xFFF59E0B));

  static const List<_AccountTab> all = [profile, security, package, invoices, receipts, appearance];
}

class _AccountScreenBodyState extends State<AccountScreenBody> {
  /// Notifies open section screens to rebuild after this state changes.
  final ValueNotifier<int> _sectionRefresh = ValueNotifier<int>(0);

  late bool _isBengali;
  SecurityModel? _securityModel;
  LanguageLocaleResponseModel? _languageLocaleModel;
  bool _isLoadingSecurity = false;

  bool get _isSupplier => widget.initialTab == 'supplier';

  @override
  void initState() {
    super.initState();
    // A specific section was requested (e.g. 'Package'): open it on top.
    if (!_isSupplier && widget.initialTab != null) {
      final requested = _AccountTab.all.where((tab) => tab.id == widget.initialTab);
      if (requested.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _openSection(requested.first);
        });
      }
    }
    _isBengali = appData.read('isBengali') ?? false;
    _fetchSecurityData();
    _fetchLanguageLocale();
  }

  @override
  void dispose() {
    _sectionRefresh.dispose();
    super.dispose();
  }

  /// Same as [setState], and also refreshes any open section screen.
  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    _sectionRefresh.value++;
  }

  void _openSection(_AccountTab tab) {
    AccountSectionScreen.open(
      context,
      title: tab.labelKey.tr,
      subtitle: tab.descKey.tr,
      refresh: _sectionRefresh,
      // Provider data is watched from the section's own context.
      builder: (sectionContext) => _buildTabContent(
        tab.id,
        sectionContext.watch<ThemeProvider>(),
        sectionContext.watch<AccountProvider>(),
      ),
    );
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
          Expanded(
            child: AccountPageBody(
              child: _isSupplier ? _buildSupplierContent(themeProvider, accountProvider) : _buildMenu(),
            ),
          ),
        ],
      ),
    );
  }

  /// Settings-style list of sections; each row opens its own screen.
  Widget _buildMenu() {
    AccountMenuItem item(_AccountTab tab) => AccountMenuItem(
          icon: tab.icon,
          color: tab.color,
          title: tab.labelKey.tr,
          subtitle: tab.descKey.tr,
          onTap: () => _openSection(tab),
        );

    return Column(
      children: [
        AccountMenuGroup(
          title: 'profile'.tr,
          items: [item(_AccountTab.profile), item(_AccountTab.security)],
        ),
        UIHelper.verticalSpace(18.h),
        AccountMenuGroup(
          title: 'package_tab'.tr,
          items: [item(_AccountTab.package), item(_AccountTab.invoices), item(_AccountTab.receipts)],
        ),
        UIHelper.verticalSpace(18.h),
        AccountMenuGroup(
          title: 'appearance_tab'.tr,
          items: [item(_AccountTab.appearance)],
        ),
        UIHelper.verticalSpace(18.h),
        AccountMenuGroup(
          items: [
            AccountMenuItem(
              icon: Icons.logout_rounded,
              title: 'logout'.tr,
              subtitle: 'logout_subtitle'.tr,
              isDanger: true,
              onTap: () => LogoutConfirmationDialog.show(context),
            ),
          ],
        ),
      ],
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

  Widget _buildTabContent(String tabId, ThemeProvider themeProvider, AccountProvider accountProvider) {
    switch (tabId) {
      case 'Profile':
        return AccountProfileSection(accountProvider: accountProvider);
      case 'Security':
        return AccountSecuritySection(isLoading: _isLoadingSecurity, securityModel: _securityModel);
      case 'Package':
        return const AccountPackageSection();
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
