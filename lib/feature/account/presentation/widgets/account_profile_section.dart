import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/custom_field_label.dart';
import '../../../../common_widget/custom_form_field.dart';
import '../../../../common_widget/gradient_button.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/account_provider.dart';
import 'account_ui.dart';

/// Profile form (name, email, save) and the delete-account block.
class AccountProfileSection extends StatelessWidget {
  final AccountProvider accountProvider;

  const AccountProfileSection({super.key, required this.accountProvider});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AccountSectionCard(
          title: 'profile_heading'.tr,
          subtitle: 'profile_desc'.tr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomFieldLabel(label: 'name'.tr),
              CustomFormField(controller: accountProvider.nameController),
              UIHelper.verticalSpace(16.h),
              CustomFieldLabel(label: 'email_address'.tr),
              CustomFormField(controller: accountProvider.emailController),
              UIHelper.verticalSpace(22.h),
              GradientButton(
                label: 'save'.tr,
                trailingIcon: Icons.check_rounded,
                onPressed: () async {
                  await accountProvider.saveProfile(context);
                },
              ),
            ],
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
}
