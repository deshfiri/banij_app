import 'package:flutter/material.dart';

import '../../../package/presentation/widgets/packages/package_plans_list.dart';

/// Account › Package: current-plan banner, then the same plan list and
/// "Choose this plan" flow as the Packages screen (`GET /packages`,
/// `POST /packages/{slug}/select`). The section screen's header already
/// shows the "Package" title and description, so none is repeated here.
class AccountPackageSection extends StatelessWidget {
  const AccountPackageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const PackagePlansList(showCurrentPlan: true);
  }
}
