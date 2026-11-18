import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 24.sp),
          UIHelper.horizontalSpace(8.w),
          Text(
            'Cancel Order',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Are you sure you want to cancel order #${widget.orderId}?',
            style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
          ),
          UIHelper.verticalSpace(14.h),
          TextField(
            controller: _reasonController,
            style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
            decoration: InputDecoration(
              hintText: 'Cancellation reason (optional)...',
              hintStyle: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
              filled: true,
              fillColor: AppColorsTheme.background(context),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColorsTheme.borderColor(context))),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Keep Order', style: TextStyle(color: AppColorsTheme.textMutedColor(context))),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            widget.onConfirm(_reasonController.text);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          ),
          child: const Text('Confirm Cancellation'),
        ),
      ],
    );
  }
}
