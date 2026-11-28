import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/accent_bar_card.dart';
import '../../../../../common_widget/tone_badge_widget.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/subscription_model.dart';
import 'subscription_format.dart';

/// "Previous terms · N" heading followed by one card per past subscription.
class PreviousTermsSection extends StatelessWidget {
  final List<SubscriptionTermModel> terms;

  const PreviousTermsSection({super.key, required this.terms});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 17.h,
              decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(2.r)),
            ),
            UIHelper.horizontalSpace(8.w),
            Text(
              'sub_previous_terms'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.horizontalSpace(8.w),
            CountPill(label: '${terms.length}'),
          ],
        ),
        UIHelper.verticalSpace(12.h),
        for (final term in terms) PreviousTermTile(term: term),
      ],
    );
  }
}

/// A past term: muted bar and icon (it is no longer active), name, dates /
/// amount paid and its status.
class PreviousTermTile extends StatelessWidget {
  final SubscriptionTermModel term;

  const PreviousTermTile({super.key, required this.term});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final paid = term.paid?.display;
    final details = SubscriptionFormat.termLine(term);

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: AccentBarCard(
        barColor: muted.withValues(alpha: 0.6),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: AppColorsTheme.innerCardBg(context),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(Icons.history_rounded, size: 19.sp, color: muted),
            ),
            UIHelper.horizontalSpace(12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    term.displayName,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  if (details.isNotEmpty) ...[
                    UIHelper.verticalSpace(2.h),
                    Text(details, style: TextStyle(fontSize: 11.sp, color: muted, height: 1.4)),
                  ],
                  if (paid != null && paid != '—') ...[
                    UIHelper.verticalSpace(4.h),
                    Text(
                      '${'sub_paid'.tr} $paid',
                      style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w800, color: primaryOrange),
                    ),
                  ],
                ],
              ),
            ),
            UIHelper.horizontalSpace(8.w),
            ToneBadge(label: term.displayStatus, tone: term.statusTone),
          ],
        ),
      ),
    );
  }
}
