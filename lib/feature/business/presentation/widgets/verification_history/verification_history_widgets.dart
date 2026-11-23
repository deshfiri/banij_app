import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/verification_history_model.dart';

/// Green used for approved verification states (same value as [successGreen]).
const Color _approvedGreen = Color(0xFF10B981);

/// Card for one KYC submission: id, submitted date, status pill, requirements
/// and deadline.
class VerificationRecordCard extends StatelessWidget {
  final VerificationRecordModel record;

  const VerificationRecordCard({super.key, required this.record});

  /// First 8 characters of the id followed by "..." (whole id if shorter —
  /// avoids a RangeError on short ids).
  static String _shortId(String id) => '${id.length >= 8 ? id.substring(0, 8) : id}...';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusLabel = record.statusLabel ?? record.status ?? 'Approved';
    final isSuccess = (record.status?.toLowerCase() == 'approved' || record.statusTone == 'success');
    final statusColor = isSuccess ? _approvedGreen : primaryOrange;
    final deadline = record.deadlineAt != null ? 'Deadline: ${record.deadlineAt}' : '';
    final daysRem = record.daysRemaining != null ? '${record.daysRemaining} days remaining' : '';
    final requirements = record.requirements;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'KYC Submission',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              if (record.id != null)
                Text(
                  'ID: ${_shortId(record.id!)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                ),
            ],
          ),
          UIHelper.verticalSpace(6.h),
          if (record.submittedAt != null)
            Text(
              'Submitted at: ${record.submittedAt}',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColorsTheme.textMutedColor(context),
                height: 1.4,
              ),
            ),
          UIHelper.verticalSpace(14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSuccess ? Icons.check_circle_outline : Icons.info_outline_rounded,
                  color: statusColor,
                  size: 14.sp,
                ),
                UIHelper.horizontalSpace(6.w),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),
          if (requirements != null && requirements.isNotEmpty) ...[
            Text(
              'Requirements (${requirements.length})',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(6.h),
            ...requirements.map((req) => _RequirementRow(requirement: req)),
            UIHelper.verticalSpace(10.h),
          ],
          if (daysRem.isNotEmpty || deadline.isNotEmpty)
            Text(
              '$deadline ($daysRem)',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final RequirementModel requirement;

  const _RequirementRow({required this.requirement});

  @override
  Widget build(BuildContext context) {
    final isApproved = requirement.status == 'approved';

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(
            isApproved ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
            size: 13.sp,
            color: isApproved ? _approvedGreen : AppColorsTheme.textMutedColor(context),
          ),
          UIHelper.horizontalSpace(6.w),
          Text(
            '${requirement.name}: ${requirement.status}',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColorsTheme.textMutedColor(context),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_edu_outlined,
            size: 54.sp,
            color: AppColorsTheme.textMutedColor(context),
          ),
          UIHelper.verticalSpace(12.h),
          Text(
            'Verification history not found',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder: two shimmering record cards.
class VerificationHistoryShimmer extends StatelessWidget {
  const VerificationHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            margin: EdgeInsets.only(bottom: 16.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: AppColorsTheme.borderColor(context),
                width: 1.w,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 140.w, height: 16.h, color: Colors.white),
                    Container(width: 70.w, height: 12.h, color: Colors.white),
                  ],
                ),
                UIHelper.verticalSpace(10.h),
                Container(width: 180.w, height: 12.h, color: Colors.white),
                UIHelper.verticalSpace(14.h),
                Container(
                  width: 90.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
