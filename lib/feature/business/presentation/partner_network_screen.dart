import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/referrals_model.dart';
import 'widgets/partner_network/partner_network_widgets.dart';

/// Partner Network: partner code/link, summary stats, direct members, earnings.
class PartnerNetworkScreen extends StatefulWidget {
  const PartnerNetworkScreen({super.key});

  @override
  State<PartnerNetworkScreen> createState() => _PartnerNetworkScreenState();
}

class _PartnerNetworkScreenState extends State<PartnerNetworkScreen> {
  ReferralsModel? _referralsModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchReferrals();
  }

  /// [showLoader] is false for pull-to-refresh, which keeps the content.
  Future<void> _fetchReferrals({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);
    try {
      final res = await referralsRxObj.fetchReferrals();
      if (mounted) {
        setState(() {
          _referralsModel = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            const HeroPageHeader(
              title: 'Partner Network',
              subtitle:
                  'Your partner code, the businesses in your Partner Network, and what you have earned from the Partner Network programme.',
            ),
            Expanded(child: _isLoading ? const PartnerNetworkShimmer() : _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      color: primaryOrange,
      onRefresh: () => _fetchReferrals(showLoader: false),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Keep content readable on tablets.
          final side = constraints.maxWidth > 760 ? (constraints.maxWidth - 720) / 2 : 16.w;
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(side, 18.h, side, 28.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // No fallback code: a made-up code would be copied and shared.
                PartnerCodeCard(
                  code: _referralsModel?.code,
                  link: _referralsModel?.link,
                  onRetry: _fetchReferrals,
                ),
                UIHelper.verticalSpace(16.h),
                PartnerStatsGrid(summary: _referralsModel?.summary),
                UIHelper.verticalSpace(22.h),
                PartnerMembersCard(members: _referralsModel?.direct?.data ?? []),
                UIHelper.verticalSpace(14.h),
                PartnerEarningsCard(earnings: _referralsModel?.earnings?.data ?? []),
              ],
            ),
          );
        },
      ),
    );
  }
}
