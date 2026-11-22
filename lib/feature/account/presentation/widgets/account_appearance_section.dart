import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../helpers/ui_helpers.dart';
import 'account_ui.dart';

/// Dark mode + language switches and logout. The caller supplies the
/// handlers, so the user and supplier views keep their own behaviour.
class AccountAppearanceSection extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onDarkModeChanged;
  final bool isBengali;
  final String languageSubtitle;
  final ValueChanged<bool> onLanguageChanged;
  final VoidCallback onLogout;

  /// The user view shows the description under the heading; the supplier view does not.
  final bool showDescription;

  const AccountAppearanceSection({
    super.key,
    required this.isDarkMode,
    required this.onDarkModeChanged,
    required this.isBengali,
    required this.languageSubtitle,
    required this.onLanguageChanged,
    required this.onLogout,
    this.showDescription = true,
  });

  @override
  Widget build(BuildContext context) {
    return AccountSectionCard(
      title: 'appearance_heading'.tr,
      subtitle: showDescription ? 'appearance_desc'.tr : null,
      child: Column(
        children: [
          AccountSettingTile(
            icon: Icons.dark_mode_outlined,
            title: 'dark_mode'.tr,
            subtitle: isDarkMode ? 'dark_mode_on'.tr : 'dark_mode_off'.tr,
            switchValue: isDarkMode,
            onChanged: onDarkModeChanged,
          ),
          UIHelper.verticalSpace(10.h),
          AccountSettingTile(
            icon: Icons.language_outlined,
            title: 'change_language'.tr,
            subtitle: languageSubtitle,
            switchValue: isBengali,
            onChanged: onLanguageChanged,
          ),
          UIHelper.verticalSpace(10.h),
          AccountSettingTile(
            icon: Icons.logout_rounded,
            title: 'logout'.tr,
            subtitle: 'logout_subtitle'.tr,
            isDanger: true,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
