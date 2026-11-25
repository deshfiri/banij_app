import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../feature/dashboard/model/payment_status.dart';
import '../helpers/ui_helpers.dart';

/// Coloured payment-status pill built from the backend's status string.
/// Shows the backend's own wording when it is not a known status.
class PaymentStatusBadge extends StatelessWidget {
  final String? rawStatus;
  final bool compact;

  const PaymentStatusBadge({super.key, required this.rawStatus, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final status = PaymentStatus.fromBackend(rawStatus);
    final text = status == PaymentStatus.unknown && (rawStatus?.trim().isNotEmpty ?? false)
        ? _humanize(rawStatus!)
        : status.label.tr;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 6.w : 8.w, vertical: compact ? 2.h : 3.h),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: status.color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: compact ? 10.sp : 12.sp, color: status.color),
          UIHelper.horizontalSpace(compact ? 3.w : 4.w),
          Text(
            text.toUpperCase(),
            style: TextStyle(
              fontSize: compact ? 8.5.sp : 10.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              color: status.color,
            ),
          ),
        ],
      ),
    );
  }

  static String _humanize(String value) {
    final text = value.replaceAll(RegExp(r'[_-]+'), ' ').trim();
    return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
  }
}
