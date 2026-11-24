import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/gradient_button.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/account_provider.dart';
import 'account_ui.dart';

/// Profile card (name, email) and the delete-account block.
///
/// Opens read-only. "Edit" turns the fields on and shows Save / Cancel;
/// a successful save (or Cancel) returns to the read-only view.
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
    final accountProvider = _provider;

    return Column(
      children: [
        AccountSectionCard(
          title: 'profile_heading'.tr,
          subtitle: _isEditing ? 'acc_editing_hint'.tr : 'profile_desc'.tr,
          trailing: _isEditing ? null : _EditButton(onPressed: _startEditing),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _isEditing ? _buildEditForm(accountProvider) : _buildReadOnly(accountProvider),
            ),
          ),
        ),
        UIHelper.verticalSpace(16.h),
        AccountSectionCard(
          title: 'delete_account_title'.tr,
          child: AccountSettingTile(
            icon: Icons.delete_outline_rounded,
            title: 'Delete Account'.tr,
            subtitle: accountProvider.deletionInfo?.message ??
                accountProvider.deletionInfo?.deletionRequest?.status ??
                'delete_account_desc'.tr,
            isDanger: true,
            onTap: () => Navigator.pushNamed(context, Routes.deleteAccountScreen),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnly(AccountProvider accountProvider) {
    final name = accountProvider.nameController.text.trim();
    final email = accountProvider.emailController.text.trim();

    return Column(
      key: const ValueKey('read-only'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileInfoRow(icon: Icons.person_outline_rounded, label: 'name'.tr, value: name),
        UIHelper.verticalSpace(10.h),
        _ProfileInfoRow(icon: Icons.mail_outline_rounded, label: 'email_address'.tr, value: email),
      ],
    );
  }

  Widget _buildEditForm(AccountProvider accountProvider) {
    return Column(
      key: const ValueKey('editing'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomFieldLabel(label: 'name'.tr),
        CustomFormField(
          controller: accountProvider.nameController,
          inputType: TextInputType.name,
          prefixIcon: Icon(Icons.person_outline_rounded, size: 18.sp, color: primaryOrange),
        ),
        UIHelper.verticalSpace(16.h),
        CustomFieldLabel(label: 'email_address'.tr),
        CustomFormField(
          controller: accountProvider.emailController,
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
}

/// Small orange "Edit" pill shown in the card header.
class _EditButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _EditButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(Icons.edit_outlined, size: 15.sp),
      label: Text('acc_edit'.tr, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800)),
      style: TextButton.styleFrom(
        foregroundColor: primaryOrange,
        backgroundColor: primaryOrange.withValues(alpha: 0.1),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        minimumSize: Size(0, 32.h),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
    );
  }
}

/// Read-only row: tinted icon, small label, value.
class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProfileInfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEmpty = value.isEmpty;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: isDark ? 0.18 : 0.12),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(icon, size: 18.sp, color: primaryOrange),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context))),
                UIHelper.verticalSpace(2.h),
                Text(
                  isEmpty ? 'acc_not_set'.tr : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: isEmpty ? FontWeight.w400 : FontWeight.w700,
                    fontStyle: isEmpty ? FontStyle.italic : FontStyle.normal,
                    color: isEmpty ? AppColorsTheme.textMutedColor(context) : AppColorsTheme.textMainColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
