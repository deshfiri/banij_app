import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../helpers/ui_helpers.dart';
import '../../../package/presentation/widgets/packages/package_plans_list.dart';
import 'account_ui.dart';

/// Account › Package: the same plan list and "Choose this plan" flow as the
/// Packages screen (`GET /packages`, `POST /packages/{slug}/select`).
class AccountPackageSection extends StatelessWidget {
  const AccountPackageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AccountSectionTitle(title: 'your_package'.tr, subtitle: 'package_desc'.tr),
        UIHelper.verticalSpace(16.h),
        const PackagePlansList(showCurrentPlan: true),
      ],
    );
  }
}
