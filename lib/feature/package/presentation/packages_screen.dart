import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../providers/packages_provider.dart';
import 'widgets/packages/package_plans_list.dart';

/// Packages: every plan from `GET /packages`, what switching would cost and
/// any limits the account is over. Opened from Subscription › Change package.
class PackagesScreen extends StatelessWidget {
  const PackagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackagesProvider>();
    final currentName = currentPackageName(context, provider.packages);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'pkg_title'.tr,
              subtitle: currentName == null ? 'pkg_subtitle'.tr : '${'pkg_your_current_plan'.tr}: $currentName',
            ),
            Expanded(
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: () => context.read<PackagesProvider>().fetchPackages(force: true),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final side = constraints.maxWidth > 760 ? (constraints.maxWidth - 720) / 2 : 16.w;
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(side, 18.h, side, 28.h),
                      children: const [PackagePlansList()],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
