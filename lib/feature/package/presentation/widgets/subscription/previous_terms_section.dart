import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../common_widget/tone_badge_widget.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/subscription_model.dart';
import 'subscription_format.dart';

/// "Previous terms" heading followed by one tile per past subscription.
class PreviousTermsSection extends StatelessWidget {
  final List<SubscriptionTermModel> terms;

  const PreviousTermsSection({super.key, required this.terms});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'sub_previous_terms'.tr,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        UIHelper.verticalSpace(10.h),
        for (final term in terms) PreviousTermTile(term: term),
      ],
    );
  }
}

class PreviousTermTile extends StatelessWidget {
  final SubscriptionTermModel term;

  const PreviousTermTile({super.key, required this.term});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final paid = term.paid?.display;
    final details = [
      SubscriptionFormat.termLine(term),
      if (paid != null && paid != '—') '${'sub_paid'.tr} $paid',
    ].where((text) => text.isNotEmpty).join(' · ');

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.innerCardBg(context),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.history_rounded, size: 18.sp, color: muted),
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
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                if (details.isNotEmpty) ...[
                  UIHelper.verticalSpace(2.h),
                  Text(details, style: TextStyle(fontSize: 11.sp, color: muted, height: 1.4)),
                ],
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          ToneBadge(label: term.displayStatus, tone: term.statusTone),
        ],
      ),
    );
  }
}
