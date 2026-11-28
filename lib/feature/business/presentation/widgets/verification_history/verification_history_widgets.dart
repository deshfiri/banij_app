import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common_widget/accent_bar_card.dart';
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
    return (_green, Icons.check_circle_rounded);
  }
  if (tone == 'danger' || tone == 'error' || status == 'rejected' || status == 'declined') {
    return (_red, Icons.cancel_rounded);
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

String _statusLabel(VerificationRecordModel record) => record.statusLabel ?? _humanize(record.status ?? 'Pending');

/// "Due Dec 9, 2026" plus "16 days left" / "overdue by 3 days" / "due today".
(String, String?)? _dueParts(VerificationRecordModel record) {
  final date = _formatDate(record.deadlineAt);
  if (date == null) return null;
  final days = record.daysRemaining;
  final base = '${'vh_due'.tr} $date';
  if (days == null) return (base, null);
  if (record.isOverdue == true || days < 0) return (base, '${'vh_overdue_by'.tr} ${days.abs()} ${'vh_days'.tr}');
  if (days == 0) return (base, 'vh_due_today'.tr);
  return (base, '$days ${days == 1 ? 'vh_day_left'.tr : 'vh_days_left'.tr}');
}

/// Approved / total requested documents.
(int, int) _documentProgress(VerificationRecordModel record) {
  final requirements = record.requirements ?? const <RequirementModel>[];
  final approved = requirements.where((r) {
    final s = r.status?.toLowerCase().trim() ?? '';
    return s == 'approved' || s == 'verified' || s == 'accepted';
  }).length;
  return (approved, requirements.length);
}

// -----------------------------------------------------------------------------
// Summary banner
// -----------------------------------------------------------------------------

/// Orange banner for the latest verification: status, due countdown and how
/// many requested documents are approved.
class VerificationSummaryBanner extends StatelessWidget {
  final VerificationRecordModel record;

  const VerificationSummaryBanner({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusIcon) = _recordStatusStyle(record);
    final due = _dueParts(record);
    final (approved, total) = _documentProgress(record);

    return BrandHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Icon(Icons.verified_user_rounded, size: 24.sp, color: Colors.white),
              ),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'vh_current_status'.tr,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      _statusLabel(record),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Icon(statusIcon, size: 18.sp, color: statusColor),
              ),
            ],
          ),
          if (due != null) ...[
            UIHelper.verticalSpace(14.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                _GlassChip(icon: Icons.event_rounded, text: due.$1),
                if (due.$2 != null)
                  _GlassChip(
                    icon: record.isOverdue == true ? Icons.error_rounded : Icons.timer_outlined,
                    text: due.$2!,
                    solid: record.isOverdue == true,
                  ),
              ],
            ),
          ],
          if (total > 0) ...[
            UIHelper.verticalSpace(16.h),
            Row(
              children: [
                Text(
                  'vh_documents_approved'.trParams({'done': '$approved', 'total': '$total'}),
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  '${(approved / total * 100).round()}%',
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ],
            ),
            UIHelper.verticalSpace(6.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: approved / total,
                minHeight: 6.h,
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  final IconData icon;
  final String text;

  /// White chip with red text (overdue) instead of translucent.
  final bool solid;

  const _GlassChip({required this.icon, required this.text, this.solid = false});

  @override
  Widget build(BuildContext context) {
    final foreground = solid ? _red : Colors.white;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: solid ? Colors.white : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: foreground),
          UIHelper.horizontalSpace(5.w),
          Text(text, style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700, color: foreground)),
        ],
      ),
    );
  }
}

/// "All verifications · 2" heading above the record cards.
class VerificationSectionHeading extends StatelessWidget {
  final int count;

  const VerificationSectionHeading({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 17.h,
          decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(2.r)),
        ),
        UIHelper.horizontalSpace(8.w),
        Text(
          'vh_all_verifications'.tr,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        UIHelper.horizontalSpace(8.w),
        CountPill(label: '$count'),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Record card
// -----------------------------------------------------------------------------

/// One verification: status, an Opened → Submitted → Reviewed tracker, the
/// due date and the documents that were asked for. [highlighted] marks the
/// latest one.
class VerificationRecordCard extends StatelessWidget {
  final VerificationRecordModel record;
  final bool highlighted;

  const VerificationRecordCard({super.key, required this.record, this.highlighted = false});

  @override
  Widget build(BuildContext context) {
    final (statusColor, statusIcon) = _recordStatusStyle(record);
    final due = _dueParts(record);
    final requirements = record.requirements ?? const <RequirementModel>[];
    final (approved, total) = _documentProgress(record);

    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: AccentBarCard(
        highlighted: highlighted,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AccentCardTitle(
              icon: Icons.verified_user_outlined,
              title: 'vh_verification'.tr,
              subtitle: _formatDate(record.openedAt) == null ? null : '${'vh_opened'.tr} ${_formatDate(record.openedAt)}',
              trailing: _StatusBadge(label: _statusLabel(record), color: statusColor, icon: statusIcon),
            ),
            UIHelper.verticalSpace(16.h),
            _ProgressTracker(record: record),
            if (due != null) ...[
              UIHelper.verticalSpace(14.h),
              _DueBox(text: due.$1, countdown: due.$2, isOverdue: record.isOverdue == true),
            ],
            if (requirements.isNotEmpty) ...[
              UIHelper.verticalSpace(16.h),
              Row(
                children: [
                  Text(
                    'vh_what_we_asked_for'.tr.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1,
                      color: primaryOrange,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$approved/$total',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(8.h),
              Container(
                decoration: BoxDecoration(
                  color: AppColorsTheme.innerCardBg(context).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < requirements.length; i++) ...[
                      if (i > 0) Divider(height: 1, thickness: 1, color: AppColorsTheme.borderColor(context)),
                      _RequirementRow(requirement: requirements[i]),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Three-step horizontal tracker. A step is done when its date is known.
class _ProgressTracker extends StatelessWidget {
  final VerificationRecordModel record;

  const _ProgressTracker({required this.record});

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('vh_opened'.tr, _formatDate(record.openedAt)),
      ('vh_submitted'.tr, _formatDate(record.submittedAt)),
      ('vh_reviewed'.tr, _formatDate(record.reviewedAt)),
    ];
    final border = AppColorsTheme.borderColor(context);
    final muted = AppColorsTheme.textMutedColor(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < steps.length; i++)
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    // Connector into this step (hidden on the first).
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == 0 ? Colors.transparent : (steps[i].$2 != null ? primaryOrange : border),
                      ),
                    ),
                    _StepDot(done: steps[i].$2 != null),
                    // Connector out of this step (hidden on the last).
                    Expanded(
                      child: Container(
                        height: 2,
                        color: i == steps.length - 1
                            ? Colors.transparent
                            : (steps[i + 1].$2 != null ? primaryOrange : border),
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(6.h),
                Text(
                  steps[i].$1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: steps[i].$2 != null ? AppColorsTheme.textMainColor(context) : muted,
                  ),
                ),
                UIHelper.verticalSpace(1.h),
                Text(
                  steps[i].$2 ?? '—',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10.sp, color: muted),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool done;

  const _StepDot({required this.done});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: done ? const LinearGradient(colors: [secondaryOrange, primaryOrange]) : null,
        color: done ? null : AppColorsTheme.cardBg(context),
        border: done ? null : Border.all(color: AppColorsTheme.borderColor(context), width: 2),
        boxShadow: done
            ? [BoxShadow(color: primaryOrange.withValues(alpha: 0.3), blurRadius: 6.r, offset: const Offset(0, 2))]
            : null,
      ),
      child: done ? Icon(Icons.check_rounded, size: 13.sp, color: Colors.white) : null,
    );
  }
}

/// Due date with its countdown; red when overdue.
class _DueBox extends StatelessWidget {
  final String text;
  final String? countdown;
  final bool isOverdue;

  const _DueBox({required this.text, required this.countdown, required this.isOverdue});

  @override
  Widget build(BuildContext context) {
    final color = isOverdue ? _red : primaryOrange;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(isOverdue ? Icons.error_outline_rounded : Icons.event_rounded, size: 17.sp, color: color),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5.sp,
                fontWeight: FontWeight.w700,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
          if (countdown != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20.r)),
              child: Text(
                countdown!,
                style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
        ],
      ),
    );
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
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final RequirementModel requirement;

  const _RequirementRow({required this.requirement});

  /// Label, colour (null = muted) and icon for a requirement's status.
  (String, Color?, IconData) _status() {
    final status = requirement.status?.toLowerCase().trim() ?? '';
    switch (status) {
      case 'approved' || 'verified' || 'accepted':
        return ('vh_approved'.tr, _green, Icons.check_rounded);
      case 'submitted' || 'pending' || 'uploaded' || 'in_review' || 'under_review':
        return ('vh_under_review'.tr, primaryOrange, Icons.hourglass_top_rounded);
      case 'rejected' || 'declined':
        return ('vh_rejected'.tr, _red, Icons.close_rounded);
      default:
        return (
          requirement.isRequired == false ? 'vh_not_provided'.tr : 'vh_still_needed'.tr,
          null,
          Icons.upload_file_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final (label, color, icon) = _status();
    final tint = color ?? muted;
    final name = requirement.name?.trim().isNotEmpty == true
        ? requirement.name!.trim()
        : _humanize(requirement.key ?? 'Document');
    final instructions = requirement.instructions?.trim();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(color: tint.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 15.sp, color: tint),
          ),
          UIHelper.horizontalSpace(10.w),
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
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: color == null ? FontWeight.w500 : FontWeight.w700,
                    color: tint,
                  ),
                ),
                if (instructions != null && instructions.isNotEmpty) ...[
                  UIHelper.verticalSpace(3.h),
                  Text(
                    instructions,
                    style: TextStyle(fontSize: 11.sp, color: muted, height: 1.35),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty / loading
// -----------------------------------------------------------------------------

/// Shown when there are no verification records.
class VerificationHistoryEmpty extends StatelessWidget {
  const VerificationHistoryEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return AccentBarCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 32.h),
      child: Column(
        children: [
          const GradientIconTile(icon: Icons.verified_user_outlined, size: 64),
          UIHelper.verticalSpace(16.h),
          Text(
            'vh_empty_title'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            'vh_empty_subtitle'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder shaped like the banner and a verification card.
class VerificationHistoryShimmer extends StatelessWidget {
  const VerificationHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget block(double height, {double radius = 18}) => Container(
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius.r)),
        );

    return Shimmer.fromColors(
      baseColor: AppColorsTheme.shimmerBase(context),
      highlightColor: AppColorsTheme.shimmerHighlight(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          block(150.h, radius: 20),
          UIHelper.verticalSpace(22.h),
          block(18.h, radius: 6),
          UIHelper.verticalSpace(12.h),
          block(320.h),
        ],
      ),
    );
  }
}
