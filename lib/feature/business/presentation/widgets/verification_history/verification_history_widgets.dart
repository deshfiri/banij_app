import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/verification_history_model.dart';

const Color _green = Color(0xFF10B981);
const Color _red = Color(0xFFEF4444);
const Color _blue = Color(0xFF3B82F6);

/// "Nov 9, 2026" from an API date string, or null when it can't be parsed.
String? _formatDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final date = DateTime.tryParse(raw.trim());
  if (date == null) return raw;
  return DateFormat('MMM d, yyyy').format(date.toLocal());
}

/// Colour + icon for a verification's overall status.
(Color, IconData) _recordStatusStyle(VerificationRecordModel record) {
  final tone = record.statusTone?.toLowerCase();
  final status = record.status?.toLowerCase() ?? '';
  if (tone == 'success' || status == 'approved' || status == 'verified') {
    return (_green, Icons.check_circle_outline_rounded);
  }
  if (tone == 'danger' || tone == 'error' || status == 'rejected' || status == 'declined') {
    return (_red, Icons.cancel_outlined);
  }
  if (tone == 'info' || status == 'submitted' || status == 'in_review' || status == 'under_review') {
    return (_blue, Icons.hourglass_top_rounded);
  }
  return (primaryOrange, Icons.schedule_rounded);
}

String _humanize(String value) {
  final text = value.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  return text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}

/// One verification: title + status, timeline dates, due date and the
/// documents that were asked for.
class VerificationRecordCard extends StatelessWidget {
  final VerificationRecordModel record;

  const VerificationRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = AppColorsTheme.textMutedColor(context);
    final (statusColor, statusIcon) = _recordStatusStyle(record);
    final statusLabel = record.statusLabel ?? _humanize(record.status ?? 'Pending');

    final timeline = <String>[
      if (_formatDate(record.openedAt) case final d?) '${'vh_opened'.tr} $d',
      if (_formatDate(record.submittedAt) case final d?) '${'vh_submitted'.tr} $d',
      if (_formatDate(record.reviewedAt) case final d?) '${'vh_reviewed'.tr} $d',
    ];
    final due = _dueText();
    final requirements = record.requirements ?? const <RequirementModel>[];

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'vh_verification'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
              ),
              UIHelper.horizontalSpace(8.w),
              _StatusBadge(label: statusLabel, color: statusColor, icon: statusIcon),
            ],
          ),
          if (timeline.isNotEmpty) ...[
            UIHelper.verticalSpace(4.h),
            Text(
              timeline.join('  ·  '),
              style: TextStyle(fontSize: 12.sp, color: muted, height: 1.45),
            ),
          ],
          if (due != null) ...[
            UIHelper.verticalSpace(12.h),
            Text(
              due,
              style: TextStyle(
                fontSize: 12.sp,
                height: 1.4,
                color: record.isOverdue == true ? _red : muted,
                fontWeight: record.isOverdue == true ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
          if (requirements.isNotEmpty) ...[
            UIHelper.verticalSpace(14.h),
            Text(
              'vh_what_we_asked_for'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(8.h),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Column(
                  children: [
                    for (var i = 0; i < requirements.length; i++) ...[
                      if (i > 0) Divider(height: 1, thickness: 1, color: AppColorsTheme.borderColor(context)),
                      _RequirementRow(requirement: requirements[i]),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// "Due Dec 9, 2026 — 16 days left" (or "overdue by N days").
  String? _dueText() {
    final date = _formatDate(record.deadlineAt);
    if (date == null) return null;
    final days = record.daysRemaining;
    final base = '${'vh_due'.tr} $date';
    if (days == null) return base;
    if (record.isOverdue == true || days < 0) {
      return '$base — ${'vh_overdue_by'.tr} ${days.abs()} ${'vh_days'.tr}';
    }
    if (days == 0) return '$base — ${'vh_due_today'.tr}';
    return '$base — $days ${days == 1 ? 'vh_day_left'.tr : 'vh_days_left'.tr}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusBadge({required this.label, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          UIHelper.horizontalSpace(4.w),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final RequirementModel requirement;

  const _RequirementRow({required this.requirement});

  /// Label + colour (null colour = muted text) for a requirement's status.
  (String, Color?) _status() {
    final status = requirement.status?.toLowerCase().trim() ?? '';
    switch (status) {
      case 'approved' || 'verified' || 'accepted':
        return ('vh_approved'.tr, _green);
      case 'submitted' || 'pending' || 'uploaded' || 'in_review' || 'under_review':
        return ('vh_under_review'.tr, primaryOrange);
      case 'rejected' || 'declined':
        return ('vh_rejected'.tr, _red);
      default:
        return (requirement.isRequired == false ? 'vh_not_provided'.tr : 'vh_still_needed'.tr, null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final (label, color) = _status();
    final name = requirement.name?.trim().isNotEmpty == true
        ? requirement.name!.trim()
        : _humanize(requirement.key ?? 'Document');
    final instructions = requirement.instructions?.trim();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: name,
                    children: [
                      if (requirement.isRequired == false)
                        TextSpan(
                          text: ' ${'vh_optional'.tr}',
                          style: TextStyle(color: muted, fontWeight: FontWeight.w400),
                        ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                if (instructions != null && instructions.isNotEmpty) ...[
                  UIHelper.verticalSpace(2.h),
                  Text(
                    instructions,
                    style: TextStyle(fontSize: 11.sp, color: muted, height: 1.35),
                  ),
                ],
              ],
            ),
          ),
          UIHelper.horizontalSpace(10.w),
          Padding(
            padding: EdgeInsets.only(top: 1.h),
            child: color == null
                ? Text(label, style: TextStyle(fontSize: 11.sp, color: muted))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      UIHelper.horizontalSpace(5.w),
                      Text(
                        label,
                        style: TextStyle(fontSize: 11.sp, color: color, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Shown when there are no verification records.
class VerificationHistoryEmpty extends StatelessWidget {
  const VerificationHistoryEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.verified_user_outlined, size: 38.sp, color: primaryOrange),
          ),
          UIHelper.verticalSpace(14.h),
          Text(
            'vh_empty_title'.tr,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            'vh_empty_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder shaped like a verification card.
class VerificationHistoryShimmer extends StatelessWidget {
  const VerificationHistoryShimmer({super.key});

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
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [bar(110.w, 16.h), bar(76.w, 20.h)],
            ),
            UIHelper.verticalSpace(10.h),
            bar(240.w, 12.h),
            UIHelper.verticalSpace(14.h),
            bar(170.w, 12.h),
            UIHelper.verticalSpace(18.h),
            bar(120.w, 14.h),
            UIHelper.verticalSpace(10.h),
            for (var i = 0; i < 3; i++) ...[
              bar(double.infinity, 46.h),
              UIHelper.verticalSpace(8.h),
            ],
          ],
        ),
      ),
    );
  }
}
