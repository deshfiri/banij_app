import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../networks/api_access.dart';
import '../../../helpers/ui_helpers.dart';
import '../model/verification_history_model.dart';

class VerificationHistoryScreen extends StatefulWidget {
  const VerificationHistoryScreen({super.key});

  @override
  State<VerificationHistoryScreen> createState() => _VerificationHistoryScreenState();
}

class _VerificationHistoryScreenState extends State<VerificationHistoryScreen> {
  bool _isLoading = true;
  VerificationHistoryResponseModel? _responseModel;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _responseModel = await verificationHistoryRxObj.fetchVerificationHistory();
    } catch (_) {
      _responseModel = VerificationHistoryResponseModel(data: []);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final records = _responseModel?.data ?? [];

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header / AppBar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                border: Border(
                  bottom: BorderSide(
                    color: AppColorsTheme.borderColor(context),
                    width: 1.w,
                  ),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: AppColorsTheme.textMainColor(context),
                      size: 22.sp,
                    ),
                  ),
                  UIHelper.horizontalSpace(8.w),
                  Text(
                    'verification_history'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ],
              ),
            ),

            // Content Body
            Expanded(
              child: _isLoading
                  ? _buildVerificationShimmer(context)
                  : records.isEmpty
                      ? Center(
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
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                          itemCount: records.length,
                          itemBuilder: (context, index) {
                            final record = records[index];
                            final statusLabel = record.statusLabel ?? record.status ?? 'Approved';
                            final isSuccess = (record.status?.toLowerCase() == 'approved' || record.statusTone == 'success');
                            final deadline = record.deadlineAt != null ? 'Deadline: ${record.deadlineAt}' : '';
                            final daysRem = record.daysRemaining != null ? '${record.daysRemaining} days remaining' : '';

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
                                  // Title / ID
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
                                          'ID: ${record.id!.substring(0, 8)}...',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: AppColorsTheme.textMutedColor(context),
                                          ),
                                        ),
                                    ],
                                  ),
                                  UIHelper.verticalSpace(6.h),

                                  // Meta Dates
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

                                  // Status Badge
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (isSuccess ? const Color(0xFF10B981) : primaryOrange).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(20.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          isSuccess ? Icons.check_circle_outline : Icons.info_outline_rounded,
                                          color: isSuccess ? const Color(0xFF10B981) : primaryOrange,
                                          size: 14.sp,
                                        ),
                                        UIHelper.horizontalSpace(6.w),
                                        Text(
                                          statusLabel,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w600,
                                            color: isSuccess ? const Color(0xFF10B981) : primaryOrange,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  UIHelper.verticalSpace(14.h),

                                  // Requirements summary if any
                                  if (record.requirements != null && record.requirements!.isNotEmpty) ...[
                                    Text(
                                      'Requirements (${record.requirements!.length})',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColorsTheme.textMainColor(context),
                                      ),
                                    ),
                                    UIHelper.verticalSpace(6.h),
                                    ...record.requirements!.map((req) => Padding(
                                          padding: EdgeInsets.only(bottom: 4.h),
                                          child: Row(
                                            children: [
                                              Icon(
                                                req.status == 'approved' ? Icons.check_rounded : Icons.radio_button_unchecked_rounded,
                                                size: 13.sp,
                                                color: req.status == 'approved' ? const Color(0xFF10B981) : AppColorsTheme.textMutedColor(context),
                                              ),
                                              UIHelper.horizontalSpace(6.w),
                                              Text(
                                                '${req.name}: ${req.status}',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: AppColorsTheme.textMutedColor(context),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),
                                    UIHelper.verticalSpace(10.h),
                                  ],

                                  // Deadline & Days Remaining
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
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationShimmer(BuildContext context) {
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
