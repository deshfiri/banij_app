import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Centered icon + title + message + optional button (empty / error states).
class SubscriptionMessageView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SubscriptionMessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 36.sp, color: primaryOrange),
          ),
          UIHelper.verticalSpace(14.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
          ),
          if (actionLabel != null && onAction != null) ...[
            UIHelper.verticalSpace(16.h),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize: Size(160.w, 44.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text(actionLabel!, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading placeholder shaped like the current-package card.
class SubscriptionShimmer extends StatelessWidget {
  const SubscriptionShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r)),
        );

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [bar(120.w, 18.h), bar(70.w, 20.h)],
          ),
          UIHelper.verticalSpace(8.h),
          bar(200.w, 12.h),
          UIHelper.verticalSpace(18.h),
          Row(children: [Expanded(child: bar(double.infinity, 34.h)), UIHelper.horizontalSpace(12.w), Expanded(child: bar(double.infinity, 34.h))]),
          UIHelper.verticalSpace(18.h),
          bar(130.w, 14.h),
          UIHelper.verticalSpace(10.h),
          for (var i = 0; i < 6; i++) ...[
            bar(double.infinity, 38.h),
            UIHelper.verticalSpace(6.h),
          ],
        ],
      ),
    );
  }
}

/// Asks the user to confirm cancelling the package. Returns true on confirm.
Future<bool> showCancelSubscriptionDialog(BuildContext context, String packageName) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
      title: Text(
        'sub_cancel_title'.tr,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColorsTheme.textMainColor(context)),
      ),
      content: Text(
        'sub_cancel_message'.trParams({'package': packageName}),
        style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context), height: 1.4),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text('sub_keep_package'.tr, style: TextStyle(color: AppColorsTheme.textMainColor(context))),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
          child: Text('sub_cancel_confirm'.tr, style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
