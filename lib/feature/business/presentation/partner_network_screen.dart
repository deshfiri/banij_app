import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/referrals_model.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final partnerCode = _referralsModel?.code ?? 'CGKRRMKR';
    final partnerLink = _referralsModel?.link ?? 'https://staging.deshfiri.com/register?ref=$partnerCode';
    final summary = _referralsModel?.summary;
    final directList = _referralsModel?.direct?.data ?? [];
    final earningsList = _referralsModel?.earnings?.data ?? [];

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        appBar: AppBar(
          backgroundColor: AppColorsTheme.cardBg(context),
          elevation: 1,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: AppColorsTheme.textMainColor(context)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Partner Network',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
        ),
        body: _buildReferralShimmer(context),
      );
    }

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.cardBg(context),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColorsTheme.textMainColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Partner Network',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ),
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

            // Card 1: Your partner code
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your partner code',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        partnerCode,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: partnerCode));
                          ToastUtil.showSuccessMessage('Partner code copied!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorsTheme.background(context),
                          foregroundColor: AppColorsTheme.textMainColor(context),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            side: BorderSide(color: AppColorsTheme.borderColor(context)),
                          ),
                          elevation: 0,
                        ),
                        child: Text('Copy', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(16.h),
                  Divider(color: AppColorsTheme.borderColor(context)),
                  UIHelper.verticalSpace(12.h),
                  Text(
                    'Your Partner Network link',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(8.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          partnerLink,
                          style: TextStyle(
                            fontSize: 12.5.sp,
                            color: primaryOrange,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      UIHelper.horizontalSpace(12.w),
                      ElevatedButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: partnerLink));
                          ToastUtil.showSuccessMessage('Partner link copied!');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColorsTheme.background(context),
                          foregroundColor: AppColorsTheme.textMainColor(context),
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            side: BorderSide(color: AppColorsTheme.borderColor(context)),
                          ),
                          elevation: 0,
                        ),
                        child: Text('Copy', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(20.h),

            // 5 Stat Cards (Grid)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.6,
              children: [
                _buildStatCard(context, 'Direct Partner Network members', '${summary?.direct ?? 0}'),
                _buildStatCard(context, 'Active', '${summary?.directActive ?? 0}'),
                _buildStatCard(context, 'Earned', summary?.paid?.formatted ?? '৳0.00'),
                _buildStatCard(context, 'Waiting to be paid', summary?.pending?.formatted ?? '৳0.00'),
                _buildStatCard(context, 'Taken back', summary?.reversed?.formatted ?? '৳0.00'),
              ],
            ),
            UIHelper.verticalSpace(24.h),

            // Businesses in your Partner Network Card (Direct Members list or empty state)
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Businesses in your Partner Network',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),
                  directList.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              UIHelper.verticalSpace(20.h),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColorsTheme.background(context),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                                ),
                                child: Icon(Icons.share_outlined, size: 28.sp, color: AppColorsTheme.textMutedColor(context)),
                              ),
                              UIHelper.verticalSpace(16.h),
                              Text(
                                'Nobody is in your Partner Network yet',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              UIHelper.verticalSpace(6.h),
                              Text(
                                'Share your link. Businesses that register with it appear here.',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              UIHelper.verticalSpace(20.h),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: directList.length,
                          itemBuilder: (context, index) {
                            final member = directList[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: AppColorsTheme.background(context),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: AppColorsTheme.borderColor(context)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.name ?? 'Business Member',
                                        style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                                      ),
                                      UIHelper.verticalSpace(2.h),
                                      Text(
                                        'Since: ${member.since ?? 'N/A'}',
                                        style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                                    decoration: BoxDecoration(
                                      color: primaryOrange.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                    child: Text(
                                      member.state ?? 'Active',
                                      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: primaryOrange),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            UIHelper.verticalSpace(20.h),

            // Card 3: Your earnings
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 10.r,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your earnings',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),
                  earningsList.isEmpty
                      ? Center(
                          child: Column(
                            children: [
                              UIHelper.verticalSpace(20.h),
                              Container(
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: AppColorsTheme.background(context),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                                ),
                                child: Icon(Icons.groups_outlined, size: 28.sp, color: AppColorsTheme.textMutedColor(context)),
                              ),
                              UIHelper.verticalSpace(16.h),
                              Text(
                                'No earnings yet',
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              UIHelper.verticalSpace(6.h),
                              Text(
                                'When a business in your chain is activated and the programme pays, each earning appears here with its level.',
                                style: TextStyle(
                                  fontSize: 12.5.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              UIHelper.verticalSpace(20.h),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: earningsList.length,
                          itemBuilder: (context, index) {
                            final earning = earningsList[index];
                            return Container(
                              margin: EdgeInsets.only(bottom: 10.h),
                              padding: EdgeInsets.all(14.w),
                              decoration: BoxDecoration(
                                color: AppColorsTheme.background(context),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: AppColorsTheme.borderColor(context)),
                              ),
                              child: Text(
                                earning.toString(),
                                style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            value,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: AppColorsTheme.textMainColor(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 200.w, height: 16.h, color: Colors.white),
            UIHelper.verticalSpace(12.h),
            Container(width: double.infinity, height: 140.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r))),
            UIHelper.verticalSpace(20.h),
            Container(width: double.infinity, height: 160.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r))),
            UIHelper.verticalSpace(20.h),
            Container(width: double.infinity, height: 200.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r))),
          ],
        ),
      ),
    );
  }
}
