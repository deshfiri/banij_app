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

  Future<void> _fetchReferrals() async {
    setState(() => _isLoading = true);
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
    final partnerCode = _referralsModel?.code ?? 'CGKRRMKR';
    final partnerLink = _referralsModel?.link ?? 'https://staging.deshfiri.com/register?ref=$partnerCode';

    return LayoutBuilder(
      builder: (context, constraints) {
        // Keep content readable on tablets.
        final side = constraints.maxWidth > 760 ? (constraints.maxWidth - 720) / 2 : 16.w;
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(side, 18.h, side, 28.h),
          child: Column(
            children: [
              PartnerCodeCard(code: partnerCode, link: partnerLink),
              UIHelper.verticalSpace(16.h),
              PartnerStatsGrid(summary: _referralsModel?.summary),
              UIHelper.verticalSpace(16.h),
              PartnerMembersCard(members: _referralsModel?.direct?.data ?? []),
              UIHelper.verticalSpace(16.h),
              PartnerEarningsCard(earnings: _referralsModel?.earnings?.data ?? []),
            ],
          ),
        );
      },
    );
  }
}
