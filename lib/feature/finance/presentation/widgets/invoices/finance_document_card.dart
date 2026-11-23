import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Invoice / receipt card: coloured left edge, number + status badge, a
/// detail box (title + meta row), amount and a preview/details button.
///
/// The small differences between the original invoice and receipt cards
/// (badge padding/radius, shadow offset, label size, spacing, colours) are
/// parameters so both render exactly as before.
class FinanceDocumentCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String number;
  final String status;
  final Color statusColor;
  final double badgeHorizontalPadding;
  final double badgeRadius;
  final double shadowOffsetY;
  final String detailTitle;
  final double detailGap;
  final Widget detailMeta;
  final String amountLabel;
  final double amountLabelSize;
  final String amount;
  final Color amountColor;
  final Color buttonColor;
  final VoidCallback? onCardTap;
  final VoidCallback onPreview;

  const FinanceDocumentCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.number,
    required this.status,
    required this.statusColor,
    required this.badgeHorizontalPadding,
    required this.badgeRadius,
    required this.shadowOffsetY,
    required this.detailTitle,
    required this.detailGap,
    required this.detailMeta,
    required this.amountLabel,
    required this.amountLabelSize,
    required this.amount,
    required this.amountColor,
    required this.buttonColor,
    this.onCardTap,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 0.8.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 8.r,
            offset: Offset(0, shadowOffsetY),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onCardTap,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: statusColor, width: 4.w),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  UIHelper.verticalSpace(8.h),
                  _buildDetailBox(context),
                  UIHelper.verticalSpace(8.h),
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(5.w),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(icon, color: iconColor, size: 16.sp),
            ),
            UIHelper.horizontalSpace(6.w),
            Text(
              number,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: badgeHorizontalPadding.w,
            vertical: 2.5.h,
          ),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(badgeRadius.r),
            border: Border.all(color: statusColor.withValues(alpha: 0.35)),
          ),
          child: Text(
            status,
            style: TextStyle(
              fontSize: 8.5.sp,
              fontWeight: FontWeight.w900,
              color: statusColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detailTitle,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          UIHelper.verticalSpace(detailGap.h),
          detailMeta,
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              amountLabel,
              style: TextStyle(
                fontSize: amountLabelSize.sp,
                color: AppColorsTheme.textMutedColor(context),
                fontWeight: FontWeight.w600,
              ),
            ),
            UIHelper.verticalSpace(1.h),
            Text(
              amount,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w900,
                color: amountColor,
              ),
            ),
          ],
        ),
        SizedBox(
          height: 32.h,
          child: ElevatedButton.icon(
            onPressed: onPreview,
            icon: Icon(
              onCardTap == null
                  ? Icons.preview_rounded
                  : Icons.arrow_forward_rounded,
              size: 12.sp,
            ),
            label: Text(
              onCardTap == null ? 'Design Preview' : 'View Details',
              style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}

/// Small icon + text pair used in a card's meta row (e.g. "Issued: …").
class FinanceMetaItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String text;
  final FontWeight weight;
  final Color textColor;

  const FinanceMetaItem({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.weight,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 10.sp, color: iconColor),
        UIHelper.horizontalSpace(4.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: weight,
            color: textColor,
          ),
        ),
      ],
    );
  }
}
