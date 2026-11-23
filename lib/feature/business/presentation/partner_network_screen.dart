import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        appBar: partnerNetworkAppBar(context, isLoading: true),
        body: const PartnerNetworkShimmer(),
      );
    }

    final partnerCode = _referralsModel?.code ?? 'CGKRRMKR';
    final partnerLink = _referralsModel?.link ?? 'https://staging.deshfiri.com/register?ref=$partnerCode';

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: partnerNetworkAppBar(context, isLoading: false),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Partner Network',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w900,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              'Your partner code, the businesses in your Partner Network, and what you have earned from the Partner Network programme.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
                height: 1.4,
              ),
            ),
            UIHelper.verticalSpace(20.h),
            PartnerCodeCard(code: partnerCode, link: partnerLink),
            UIHelper.verticalSpace(20.h),
            PartnerStatsGrid(summary: _referralsModel?.summary),
            UIHelper.verticalSpace(24.h),
            PartnerMembersCard(members: _referralsModel?.direct?.data ?? []),
            UIHelper.verticalSpace(20.h),
            PartnerEarningsCard(earnings: _referralsModel?.earnings?.data ?? []),
          ],
        ),
      ),
    );
  }
}
