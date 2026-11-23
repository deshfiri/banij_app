import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Confirm dialog for cancelling a store order, with an optional reason.
class OrderCancellationDialog extends StatefulWidget {
  final String orderId;
  final Function(String reason) onConfirm;

  const OrderCancellationDialog({
    super.key,
    required this.orderId,
    required this.onConfirm,
  });

  static void show(BuildContext context, String orderId, Function(String reason) onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => OrderCancellationDialog(
        orderId: orderId,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<OrderCancellationDialog> createState() => _OrderCancellationDialogState();
}

class _OrderCancellationDialogState extends State<OrderCancellationDialog> {
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _confirm() {
    Navigator.pop(context);
    widget.onConfirm(_reasonController.text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: color, width: width),
        );

    return AlertDialog(
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      icon: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(color: errorRed.withValues(alpha: isDark ? 0.18 : 0.1), shape: BoxShape.circle),
        child: Icon(Icons.warning_amber_rounded, color: errorRed, size: 28.sp),
      ),
      title: Text(
        'Cancel Order'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColorsTheme.textMainColor(context)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Are you sure you want to cancel order #@id?'.trParams({'id': widget.orderId}),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
          ),
          UIHelper.verticalSpace(14.h),
          TextField(
            controller: _reasonController,
            maxLines: 2,
            style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
            decoration: InputDecoration(
              hintText: 'Cancellation reason (optional)...'.tr,
              hintStyle: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
              filled: true,
              fillColor: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
              border: border(AppColorsTheme.borderColor(context)),
              enabledBorder: border(isDark ? darkCardBorderColor : errorRed.withValues(alpha: 0.2)),
              focusedBorder: border(errorRed, 1.5),
            ),
          ),
        ],
      ),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  side: BorderSide(color: AppColorsTheme.borderColor(context)),
                  foregroundColor: AppColorsTheme.textMainColor(context),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text('Keep Order'.tr, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            UIHelper.horizontalSpace(10.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: errorRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'Confirm Cancellation'.tr,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
