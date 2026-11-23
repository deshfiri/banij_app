import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Building blocks shared by the finance sub-screens (wallet, withdrawals,
/// payout methods) and their bottom sheets.

/// Status → accent colour used by invoice/receipt cards and previews.
Color financeStatusColor(String status) {
  switch (status) {
    case 'PAID':
    case 'VERIFIED':
      return const Color(0xFF10B981);
    case 'PENDING':
      return primaryOrange;
    case 'OVERDUE':
      return const Color(0xFFEF4444);
    default:
      return primaryOrange;
  }
}

/// App bar with a back button, bold title and an optional orange text action.
AppBar financeAppBar(
  BuildContext context, {
  required String title,
  Color? backgroundColor,
  double elevation = 0,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  return AppBar(
    backgroundColor: backgroundColor ?? AppColorsTheme.background(context),
    elevation: elevation,
    leading: IconButton(
      icon: Icon(Icons.arrow_back_rounded, color: AppColorsTheme.textMainColor(context)),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: AppColorsTheme.textMainColor(context),
      ),
    ),
    actions: actionLabel == null
        ? null
        : [
            TextButton.icon(
              onPressed: onAction,
              icon: Icon(Icons.add_circle_outline_rounded, size: 16.sp, color: primaryOrange),
              label: Text(
                actionLabel,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryOrange),
              ),
            ),
            UIHelper.horizontalSpace(8.w),
          ],
  );
}

/// Opens a finance bottom sheet: scroll-controlled, card background, rounded top.
Future<T?> showFinanceSheet<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColorsTheme.cardBg(context),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: builder,
  );
}

/// Muted intro paragraph under a screen's app bar.
class FinanceIntroText extends StatelessWidget {
  final String text;

  const FinanceIntroText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        color: AppColorsTheme.textMutedColor(context),
      ),
    );
  }
}

/// Full-width orange button with a leading icon (e.g. "Add payout method").
class FinancePrimaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const FinancePrimaryButton({super.key, required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18.sp),
        label: Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          elevation: 0,
        ),
      ),
    );
  }
}

/// Bordered card with a large muted icon, title and subtitle.
class FinanceEmptyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final double padding;

  const FinanceEmptyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48.sp, color: AppColorsTheme.textMutedColor(context)),
            UIHelper.verticalSpace(12.h),
            Text(
              title,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
            ),
            UIHelper.verticalSpace(4.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
            ),
          ],
        ),
      ),
    );
  }
}

/// List row card: tinted circle icon, title + subtitle, and a trailing widget.
class FinanceListCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Widget title;
  final String subtitle;
  final double subtitleSize;
  final Widget trailing;
  final Color? borderColor;

  const FinanceListCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.subtitleSize,
    required this.trailing,
    this.borderColor,
  });

  /// Standard bold 13.5sp title text.
  static Widget titleText(BuildContext context, String text) => Text(
        text,
        style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
      );

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: borderColor ?? AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                title,
                UIHelper.verticalSpace(2.h),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: subtitleSize.sp, color: AppColorsTheme.textMutedColor(context)),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

/// Right-aligned amount over a small coloured status label.
class FinanceAmountStatus extends StatelessWidget {
  final String amount;
  final Color amountColor;
  final String status;
  final Color statusColor;

  const FinanceAmountStatus({
    super.key,
    required this.amount,
    required this.amountColor,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          amount,
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: amountColor),
        ),
        UIHelper.verticalSpace(2.h),
        Text(
          status,
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: statusColor),
        ),
      ],
    );
  }
}

/// Bottom-sheet title row with a close button.
class FinanceSheetHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const FinanceSheetHeader({super.key, required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        IconButton(
          icon: Icon(Icons.close_rounded, color: AppColorsTheme.textMainColor(context)),
          onPressed: onClose,
        ),
      ],
    );
  }
}

/// Bold 12.5sp field label used in finance sheets.
class FinanceSheetLabel extends StatelessWidget {
  final String text;

  const FinanceSheetLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
    );
  }
}

/// Numeric amount input ("e.g. 5000") used by top-up and withdrawal sheets.
class FinanceAmountField extends StatelessWidget {
  final TextEditingController controller;

  const FinanceAmountField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 14.sp, color: AppColorsTheme.textMainColor(context)),
      decoration: InputDecoration(
        hintText: 'e.g. 5000',
        hintStyle: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
        ),
      ),
    );
  }
}

/// Full-width submit button that shows a spinner and is disabled while [isLoading].
class FinanceSubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const FinanceSubmitButton({super.key, required this.label, required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryOrange,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 20.w,
                height: 20.h,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(label, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// Small rounded bar at the top of tall custom sheets.
class FinanceDragHandle extends StatelessWidget {
  const FinanceDragHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 42.w,
        height: 4.5.h,
        decoration: BoxDecoration(
          color: AppColorsTheme.textMutedColor(context).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }
}
