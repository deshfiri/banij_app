import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/referrals_model.dart';

/// App bar for the Partner Network screen. While [isLoading] it blends into
/// the background (no elevation); once loaded it sits on the card surface.
PreferredSizeWidget partnerNetworkAppBar(BuildContext context, {required bool isLoading}) {
  return AppBar(
    backgroundColor: isLoading ? AppColorsTheme.background(context) : AppColorsTheme.cardBg(context),
    elevation: isLoading ? 0 : 1,
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
  );
}

/// Rounded card with a soft shadow, used for each Partner Network section.
class PartnerSectionCard extends StatelessWidget {
  final Widget child;

  const PartnerSectionCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
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
      child: child,
    );
  }
}

/// Bold 15sp heading used at the top of each [PartnerSectionCard].
class PartnerCardTitle extends StatelessWidget {
  final String text;

  const PartnerCardTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 15.sp,
        fontWeight: FontWeight.bold,
        color: AppColorsTheme.textMainColor(context),
      ),
    );
  }
}

/// Small outlined "Copy" button that copies [text] and shows [toastMessage].
class PartnerCopyButton extends StatelessWidget {
  final String text;
  final String toastMessage;

  const PartnerCopyButton({super.key, required this.text, required this.toastMessage});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Clipboard.setData(ClipboardData(text: text));
        ToastUtil.showSuccessMessage(toastMessage);
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
    );
  }
}

/// "Your partner code" card: the code and the registration link, each copyable.
class PartnerCodeCard extends StatelessWidget {
  final String code;
  final String link;

  const PartnerCodeCard({super.key, required this.code, required this.link});

  @override
  Widget build(BuildContext context) {
    return PartnerSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PartnerCardTitle('Your partner code'),
          UIHelper.verticalSpace(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                code,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              PartnerCopyButton(text: code, toastMessage: 'Partner code copied!'),
            ],
          ),
          UIHelper.verticalSpace(16.h),
          Divider(color: AppColorsTheme.borderColor(context)),
          UIHelper.verticalSpace(12.h),
          Text(
            'Your Partner Network link',
            style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
          ),
          UIHelper.verticalSpace(8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  link,
                  style: TextStyle(fontSize: 12.5.sp, color: primaryOrange, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              UIHelper.horizontalSpace(12.w),
              PartnerCopyButton(text: link, toastMessage: 'Partner link copied!'),
            ],
          ),
        ],
      ),
    );
  }
}

/// Grid of the five summary stats (members, active, earned, pending, reversed).
class PartnerStatsGrid extends StatelessWidget {
  final ReferralSummaryModel? summary;

  const PartnerStatsGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.6,
      children: [
        _PartnerStatCard(title: 'Direct Partner Network members', value: '${summary?.direct ?? 0}'),
        _PartnerStatCard(title: 'Active', value: '${summary?.directActive ?? 0}'),
        _PartnerStatCard(title: 'Earned', value: summary?.paid?.formatted ?? '৳0.00'),
        _PartnerStatCard(title: 'Waiting to be paid', value: summary?.pending?.formatted ?? '৳0.00'),
        _PartnerStatCard(title: 'Taken back', value: summary?.reversed?.formatted ?? '৳0.00'),
      ],
    );
  }
}

class _PartnerStatCard extends StatelessWidget {
  final String title;
  final String value;

  const _PartnerStatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
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
}

/// Circle icon + title + description shown when a list is empty.
class PartnerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final double? messageHeight;

  const PartnerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.messageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
            child: Icon(icon, size: 28.sp, color: AppColorsTheme.textMutedColor(context)),
          ),
          UIHelper.verticalSpace(16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
            textAlign: TextAlign.center,
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 12.5.sp,
              color: AppColorsTheme.textMutedColor(context),
              height: messageHeight,
            ),
            textAlign: TextAlign.center,
          ),
          UIHelper.verticalSpace(20.h),
        ],
      ),
    );
  }
}

/// Bordered row container used for list items inside the section cards.
class PartnerListTile extends StatelessWidget {
  final Widget child;

  const PartnerListTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: child,
    );
  }
}

/// "Businesses in your Partner Network" card: direct members or an empty state.
class PartnerMembersCard extends StatelessWidget {
  final List<ReferralDirectItemModel> members;

  const PartnerMembersCard({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return PartnerSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PartnerCardTitle('Businesses in your Partner Network'),
          UIHelper.verticalSpace(20.h),
          members.isEmpty
              ? const PartnerEmptyState(
                  icon: Icons.share_outlined,
                  title: 'Nobody is in your Partner Network yet',
                  message: 'Share your link. Businesses that register with it appear here.',
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) => _PartnerMemberTile(member: members[index]),
                ),
        ],
      ),
    );
  }
}

class _PartnerMemberTile extends StatelessWidget {
  final ReferralDirectItemModel member;

  const _PartnerMemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return PartnerListTile(
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
  }
}

/// "Your earnings" card: earnings rows or an empty state.
class PartnerEarningsCard extends StatelessWidget {
  final List<dynamic> earnings;

  const PartnerEarningsCard({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return PartnerSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PartnerCardTitle('Your earnings'),
          UIHelper.verticalSpace(20.h),
          earnings.isEmpty
              ? const PartnerEmptyState(
                  icon: Icons.groups_outlined,
                  title: 'No earnings yet',
                  message:
                      'When a business in your chain is activated and the programme pays, each earning appears here with its level.',
                  messageHeight: 1.4,
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: earnings.length,
                  itemBuilder: (context, index) => PartnerListTile(
                    child: Text(
                      earnings[index].toString(),
                      style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

/// Loading placeholder for the Partner Network screen.
class PartnerNetworkShimmer extends StatelessWidget {
  const PartnerNetworkShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    Widget block(double height) => Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r)),
        );

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
            block(140.h),
            UIHelper.verticalSpace(20.h),
            block(160.h),
            UIHelper.verticalSpace(20.h),
            block(200.h),
          ],
        ),
      ),
    );
  }
}
