import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/gradient_button.dart';
import '../../../../common_widget/tone_badge_widget.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../networks/api_access.dart';
import '../../../../providers/account_provider.dart';
import '../../../dashboard/model/current_user_model.dart';
import '../../../dashboard/presentation/widgets/dashboard_card_decoration.dart';
import 'account_ui.dart';

/// Account › Profile: a profile card (cover, initials avatar, name, email,
/// status and roles, "Edit profile"), personal information (name, email,
/// mobile with verified badges, language), account & security details and
/// the delete-account block.
///
/// Opens read-only. "Edit profile" turns the name / email fields on and
/// shows Save / Cancel; a successful save (or Cancel) returns to the
/// read-only view.
class AccountProfileSection extends StatefulWidget {
  final AccountProvider accountProvider;

  const AccountProfileSection({super.key, required this.accountProvider});

  @override
  State<AccountProfileSection> createState() => _AccountProfileSectionState();
}

class _AccountProfileSectionState extends State<AccountProfileSection> {
  bool _isEditing = false;
  bool _isSaving = false;
  String _originalName = '';
  String _originalEmail = '';

  AccountProvider get _provider => widget.accountProvider;

  @override
  void initState() {
    super.initState();
    // Mobile, verification and account details come from /me; load it if no
    // other screen has yet.
    if (!currentUserRxObj.getCurrentUserData.hasValue) currentUserRxObj.fetchCurrentUser();
  }

  void _startEditing() {
    _originalName = _provider.nameController.text;
    _originalEmail = _provider.emailController.text;
    setState(() => _isEditing = true);
  }

  void _cancelEditing() {
    _provider.nameController.text = _originalName;
    _provider.emailController.text = _originalEmail;
    FocusScope.of(context).unfocus();
    setState(() => _isEditing = false);
  }

  Future<void> _save() async {
    if (_isSaving) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final saved = await _provider.saveProfile(context);
    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (saved) _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: currentUserRxObj.getCurrentUserData,
      builder: (context, snapshot) {
        final user = snapshot.data is CurrentUserModel ? (snapshot.data as CurrentUserModel).data : null;
        // The editable fields win: they hold the latest saved values.
        final name = _firstNonEmpty([_provider.nameController.text, user?.name]);
        final email = _firstNonEmpty([_provider.emailController.text, user?.email]);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProfileHeaderCard(
              name: name,
              email: email,
              status: user?.businessAccount?.status,
              roles: _roleNames(user?.platformRoles),
              onEdit: _isEditing ? null : _startEditing,
            ),
            UIHelper.verticalSpace(16.h),
            AccountSectionCard(
              title: 'prof_personal_info'.tr,
              subtitle: _isEditing ? 'acc_editing_hint'.tr : null,
              child: AnimatedSize(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isEditing ? _buildEditForm() : _buildPersonalInfo(name, email, user),
                ),
              ),
            ),
            UIHelper.verticalSpace(16.h),
            AccountSectionCard(
              title: 'prof_account_security'.tr,
              child: _buildAccountDetails(user),
            ),
            UIHelper.verticalSpace(16.h),
            AccountSectionCard(
              title: 'prof_danger_zone'.tr,
              child: AccountSettingTile(
                icon: Icons.delete_outline_rounded,
                title: 'Delete Account'.tr,
                subtitle: _provider.deletionInfo?.message ??
                    _provider.deletionInfo?.deletionRequest?.status ??
                    'delete_account_desc'.tr,
                isDanger: true,
                onTap: () => Navigator.pushNamed(context, Routes.deleteAccountScreen),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPersonalInfo(String? name, String? email, CurrentUserData? user) {
    return Column(
      key: const ValueKey('read-only'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _withDividers([
        _InfoTile(icon: Icons.person_outline_rounded, label: 'name'.tr, value: name),
        _InfoTile(
          icon: Icons.mail_outline_rounded,
          label: 'email_address'.tr,
          value: email,
          badge: _verifiedBadge(user?.emailVerified, hasValue: email != null),
        ),
        _InfoTile(
          icon: Icons.phone_iphone_rounded,
          label: 'mobile_number'.tr,
          value: user?.mobile,
          badge: _verifiedBadge(user?.mobileVerified, hasValue: user?.mobile?.isNotEmpty == true),
        ),
        _InfoTile(icon: Icons.translate_rounded, label: 'prof_language'.tr, value: _languageName(user?.locale)),
      ]),
    );
  }

  Widget _buildAccountDetails(CurrentUserData? user) {
    final business = user?.businessAccount;
    final identity = user?.identityStatus;
    final twoFactor = user?.twoFactorEnabled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _withDividers([
        _InfoTile(icon: Icons.storefront_outlined, label: 'business_name'.tr, value: business?.name),
        _InfoTile(
          icon: Icons.badge_outlined,
          label: 'prof_account_status'.tr,
          value: null,
          badge: business?.status?.isNotEmpty == true
              ? ToneBadge(label: _humanize(business!.status!.toLowerCase().tr), tone: _tone(business.status))
              : null,
        ),
        _InfoTile(
          icon: Icons.verified_user_outlined,
          label: 'identity_verification'.tr,
          value: null,
          badge: identity?.isNotEmpty == true ? ToneBadge(label: _humanize(identity!), tone: _tone(identity)) : null,
        ),
        _InfoTile(
          icon: Icons.lock_outline_rounded,
          label: 'prof_two_factor'.tr,
          value: null,
          badge: twoFactor == null
              ? null
              : ToneBadge(
                  label: twoFactor ? 'prof_on'.tr : 'prof_off'.tr,
                  tone: twoFactor ? 'success' : 'neutral',
                ),
        ),
      ]),
    );
  }

  Widget _buildEditForm() {
    return Column(
      key: const ValueKey('editing'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomFieldLabel(label: 'name'.tr),
        CustomFormField(
          controller: _provider.nameController,
          inputType: TextInputType.name,
          prefixIcon: Icon(Icons.person_outline_rounded, size: 18.sp, color: primaryOrange),
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'email_address'.tr),
        CustomFormField(
          controller: _provider.emailController,
          inputType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          prefixIcon: Icon(Icons.mail_outline_rounded, size: 18.sp, color: primaryOrange),
          onFieldSubmitted: (_) => _save(),
        ),
        UIHelper.verticalSpace(22.h),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54.h,
                child: OutlinedButton(
                  onPressed: _isSaving ? null : _cancelEditing,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColorsTheme.textMainColor(context),
                    side: BorderSide(color: AppColorsTheme.borderColor(context)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                  ),
                  child: Text('acc_cancel'.tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              flex: 3,
              child: GradientButton(
                label: 'save'.tr,
                trailingIcon: Icons.check_rounded,
                isLoading: _isSaving,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Rows separated by hairlines that start after the icon column.
  List<Widget> _withDividers(List<Widget> rows) => [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            Divider(
              height: 1,
              thickness: 1,
              indent: 50.w,
              color: AppColorsTheme.borderColor(context).withValues(alpha: 0.7),
            ),
          rows[i],
        ],
      ];

  static Widget? _verifiedBadge(bool? verified, {required bool hasValue}) {
    if (!hasValue || verified == null) return null;
    return ToneBadge(
      label: verified ? 'prof_verified'.tr : 'prof_not_verified'.tr,
      tone: verified ? 'success' : 'warning',
    );
  }

  static String? _languageName(String? locale) => switch (locale?.toLowerCase()) {
        null || '' => null,
        final l when l.startsWith('bn') => 'বাংলা (Bangla)',
        final l when l.startsWith('en') => 'English',
        final l => l.toUpperCase(),
      };

  /// API tone for a status word ("active", "pending_review", "rejected"…).
  static String _tone(String? raw) {
    final s = (raw ?? '').toLowerCase();
    if (RegExp('reject|suspend|block|fail|denied|expire|inactive|unverified').hasMatch(s)) return 'danger';
    if (RegExp('pending|review|submit|progress|incomplete|draft').hasMatch(s)) return 'warning';
    if (RegExp('active|approved|verified|complete|success').hasMatch(s)) return 'success';
    return 'neutral';
  }

  /// "pending_review" → "Pending review".
  static String _humanize(String raw) {
    final text = raw.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    return text.isEmpty ? raw : text[0].toUpperCase() + text.substring(1);
  }

  static List<String> _roleNames(List<dynamic>? raw) => [
        for (final role in raw ?? const [])
          if (role is Map)
            (role['label'] ?? role['name'] ?? role['slug'] ?? '').toString()
          else
            role.toString(),
      ].where((r) => r.trim().isNotEmpty).map(_humanize).toList();

  static String? _firstNonEmpty(List<String?> values) {
    for (final v in values) {
      if (v != null && v.trim().isNotEmpty) return v.trim();
    }
    return null;
  }
}

/// Top card: orange cover band, initials avatar overlapping it, name, email,
/// status / role chips and the "Edit profile" button.
class _ProfileHeaderCard extends StatelessWidget {
  final String? name;
  final String? email;
  final String? status;
  final List<String> roles;

  /// Null while editing (button hidden).
  final VoidCallback? onEdit;

  const _ProfileHeaderCard({
    required this.name,
    required this.email,
    required this.status,
    required this.roles,
    required this.onEdit,
  });

  String get _initials {
    final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = AppColorsTheme.cardBg(context);
    final coverHeight = 64.h;
    final avatarSize = 84.w;
    final hasStatus = status != null && status!.isNotEmpty;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: DashboardCardDecoration.of(context, radius: 22),
      child: Stack(
        // Centres the avatar column (the Stack's loose width otherwise
        // shrinks it to its content and pins it to the left).
        alignment: Alignment.topCenter,
        children: [
          // Cover band with soft circles.
          Container(
            height: coverHeight,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColorsTheme.heroGradient(context),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(top: -30.h, right: -20.w, child: _circle(100.w, 0.12)),
                Positioned(bottom: -24.h, left: 30.w, child: _circle(60.w, 0.08)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, coverHeight - avatarSize / 2, 16.w, 18.h),
            child: Column(
              children: [
                // Avatar: orange gradient with initials, ringed in the card colour.
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: cardBg,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryOrange.withValues(alpha: 0.25),
                        blurRadius: 14.r,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [secondaryOrange, primaryOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: _initials.isEmpty
                        ? Icon(Icons.person_rounded, size: 34.sp, color: Colors.white)
                        : Text(
                            _initials,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                UIHelper.verticalSpace(10.h),
                Text(
                  name ?? 'acc_not_set'.tr,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                if (email != null) ...[
                  UIHelper.verticalSpace(3.h),
                  Text(
                    email!,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                  ),
                ],
                if (hasStatus || roles.isNotEmpty) ...[
                  UIHelper.verticalSpace(12.h),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: [
                      if (hasStatus)
                        ToneBadge(
                          label: _AccountProfileSectionState._humanize(status!.toLowerCase().tr),
                          tone: _AccountProfileSectionState._tone(status),
                        ),
                      for (final role in roles) _RoleChip(label: role),
                    ],
                  ),
                ],
                if (onEdit != null) ...[
                  UIHelper.verticalSpace(16.h),
                  SizedBox(
                    height: 40.h,
                    child: OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: Icon(Icons.edit_outlined, size: 16.sp),
                      label: Text(
                        'prof_edit_profile'.tr,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryOrange,
                        backgroundColor: primaryOrange.withValues(alpha: 0.06),
                        side: BorderSide(color: primaryOrange.withValues(alpha: 0.5)),
                        padding: EdgeInsets.symmetric(horizontal: 22.w),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
      );
}

/// Neutral pill for a platform role ("Retailer", "Supplier"…).
class _RoleChip extends StatelessWidget {
  final String label;

  const _RoleChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.work_outline_rounded, size: 12.sp, color: AppColorsTheme.textMutedColor(context)),
          UIHelper.horizontalSpace(4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// One detail row: tinted icon, label, value (or "Not set") and an optional
/// badge on the right. A row with only a badge shows the badge as its value.
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? badge;

  const _InfoTile({required this.icon, required this.label, required this.value, this.badge});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = AppColorsTheme.textMutedColor(context);
    final hasValue = value != null && value!.trim().isNotEmpty;
    final badgeOnly = value == null && badge != null;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: isDark ? 0.16 : 0.1),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(icon, size: 18.sp, color: primaryOrange),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: badgeOnly
                ? Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 11.sp, color: muted)),
                      UIHelper.verticalSpace(2.h),
                      Text(
                        hasValue ? value!.trim() : 'acc_not_set'.tr,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: hasValue ? FontWeight.w700 : FontWeight.w400,
                          fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
                          color: hasValue ? AppColorsTheme.textMainColor(context) : muted,
                        ),
                      ),
                    ],
                  ),
          ),
          if (badge != null) ...[
            UIHelper.horizontalSpace(8.w),
            badge!,
          ],
        ],
      ),
    );
  }
}
