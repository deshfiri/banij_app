import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/kyc_verification_provider.dart';

class KycVerificationScreen extends StatelessWidget {
  const KycVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kycProvider = context.watch<KycVerificationProvider>();

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top Clean App Bar: Only Back Button & Title
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
                  Expanded(
                    child: Text(
                      'application_and_kyc_title'.tr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Main Body Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Subtitle & Header Desc
                    Text(
                      'kyc_header_desc'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColorsTheme.textMutedColor(context),
                        height: 1.4,
                      ),
                    ),
                    UIHelper.verticalSpace(20.h),

                    // Verification Batch Section Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'verification_batch'.tr,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: primaryOrange,
                            letterSpacing: 1.0,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: isDark
                                ? primaryOrange.withValues(alpha: 0.15)
                                : const Color(0xFFFFECE0),
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: primaryOrange.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Text(
                            'draft'.tr,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryOrange,
                            ),
                          ),
                        ),
                      ],
                    ),
                    UIHelper.verticalSpace(6.h),
                    Text(
                      'identity_verification'.tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(4.h),
                    Text(
                      'identity_verification_desc'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColorsTheme.textMutedColor(context),
                        height: 1.4,
                      ),
                    ),
                    UIHelper.verticalSpace(6.h),
                    Text(
                      '${kycProvider.completedGroupsCount} of 1 ${'required_groups_complete'.tr}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(20.h),

                    // Main Group Card: Personal Information Verification
                    Container(
                      padding: EdgeInsets.all(18.w),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.cardBg(context),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColorsTheme.borderColor(context),
                          width: 1.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDark ? 0.0 : 0.03),
                            blurRadius: 10.r,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Card Title & Subtitle
                          Text(
                            'personal_info_verification'.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          UIHelper.verticalSpace(4.h),
                          Text(
                            'personal_info_verification_desc'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColorsTheme.textMutedColor(context),
                              height: 1.3,
                            ),
                          ),
                          UIHelper.verticalSpace(14.h),

                          // Badges Row
                          Row(
                            children: [
                              // Required Badge
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                decoration: BoxDecoration(
                                  color: primaryOrange.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(
                                    color: primaryOrange.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: primaryOrange,
                                      size: 12.sp,
                                    ),
                                    UIHelper.horizontalSpace(4.w),
                                    Text(
                                      'required'.tr,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: primaryOrange,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              UIHelper.horizontalSpace(8.w),

                              // Overall Status Badge
                              _buildStatusBadge(context, kycProvider.overallStatusKey),
                            ],
                          ),
                          UIHelper.verticalSpace(18.h),

                          // Progress Counter & Progress Bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'complete_every_option'.tr,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColorsTheme.textMainColor(context),
                                  ),
                                ),
                              ),
                              Text(
                                '${kycProvider.completedGroupsCount} of 2 ${'completed'.tr}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpace(8.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6.r),
                            child: LinearProgressIndicator(
                              value: kycProvider.progressRatio,
                              minHeight: 8.h,
                              backgroundColor: isDark
                                  ? const Color(0xFF2A2A2D)
                                  : const Color(0xFFE5E7EB),
                              valueColor: const AlwaysStoppedAnimation<Color>(primaryOrange),
                            ),
                          ),
                          UIHelper.verticalSpace(24.h),

                          // Document Box 1: NID Verification
                          _buildDocumentBox(
                            context: context,
                            title: 'nid_verification'.tr,
                            desc: 'nid_verification_desc'.tr,
                            countText: '${kycProvider.nidCount} of 2 ${'provided'.tr}',
                            isComplete: kycProvider.nidCount == 2,
                            child: Column(
                              children: [
                                _buildFileSelector(
                                  context: context,
                                  label: 'front_side_verification'.tr,
                                  desc: 'front_side_desc'.tr,
                                  fileName: kycProvider.nidFrontFileName,
                                  onPick: () => kycProvider.pickFile('nidFront'),
                                ),
                                Divider(
                                  height: 28.h,
                                  color: AppColorsTheme.borderColor(context),
                                ),
                                _buildFileSelector(
                                  context: context,
                                  label: 'back_side_verification'.tr,
                                  desc: 'back_side_desc'.tr,
                                  fileName: kycProvider.nidBackFileName,
                                  onPick: () => kycProvider.pickFile('nidBack'),
                                ),
                              ],
                            ),
                          ),
                          UIHelper.verticalSpace(18.h),

                          // Document Box 2: Passport Verification
                          _buildDocumentBox(
                            context: context,
                            title: 'passport_verification'.tr,
                            desc: 'passport_verification_desc'.tr,
                            countText: '${kycProvider.passportCount} of 1 ${'provided'.tr}',
                            isComplete: kycProvider.passportCount == 1,
                            child: _buildFileSelector(
                              context: context,
                              label: 'passport_biodata_page'.tr,
                              desc: 'passport_biodata_desc'.tr,
                              fileName: kycProvider.passportBioFileName,
                              onPick: () => kycProvider.pickFile('passportBio'),
                            ),
                          ),
                          UIHelper.verticalSpace(18.h),

                          // Document Box 3: Driving License Verification
                          _buildDocumentBox(
                            context: context,
                            title: 'driving_license_verification'.tr,
                            desc: 'driving_license_verification_desc'.tr,
                            countText: '${kycProvider.licenseCount} of 2 ${'provided'.tr}',
                            isComplete: kycProvider.licenseCount == 2,
                            child: Column(
                              children: [
                                _buildFileSelector(
                                  context: context,
                                  label: 'license_front_side'.tr,
                                  desc: 'license_front_desc'.tr,
                                  fileName: kycProvider.dlFrontFileName,
                                  onPick: () => kycProvider.pickFile('dlFront'),
                                ),
                                Divider(
                                  height: 28.h,
                                  color: AppColorsTheme.borderColor(context),
                                ),
                                _buildFileSelector(
                                  context: context,
                                  label: 'license_back_side'.tr,
                                  desc: 'license_back_desc'.tr,
                                  fileName: kycProvider.dlBackFileName,
                                  onPick: () => kycProvider.pickFile('dlBack'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpace(24.h),

                    // Bottom Submit Card Container
                    Container(
                      padding: EdgeInsets.all(18.w),
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
                          Text(
                            'submit_for_review'.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          UIHelper.verticalSpace(4.h),
                          Text(
                            'submit_for_review_desc'.tr,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColorsTheme.textMutedColor(context),
                              height: 1.3,
                            ),
                          ),
                          UIHelper.verticalSpace(16.h),

                          // Still Needed Dynamic List
                          if (kycProvider.stillNeededList.isNotEmpty) ...[
                            Text(
                              'still_needed'.tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                            ),
                            UIHelper.verticalSpace(8.h),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: kycProvider.stillNeededList.map((item) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 6.h),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '• ',
                                        style: TextStyle(
                                          color: AppColorsTheme.textMutedColor(context),
                                          fontSize: 12.sp,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          item['text'] ?? '',
                                          style: TextStyle(
                                            color: AppColorsTheme.textMutedColor(context),
                                            fontSize: 12.sp,
                                            height: 1.3,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: const Color(0xFF10B981),
                                  size: 18.sp,
                                ),
                                UIHelper.horizontalSpace(8.w),
                                Expanded(
                                  child: Text(
                                    'all_documents_provided'.tr,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                          UIHelper.verticalSpace(18.h),

                          // Confirmation Checkbox
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 20.w,
                                height: 20.h,
                                child: Checkbox(
                                  value: kycProvider.isConfirmed,
                                  activeColor: primaryOrange,
                                  side: BorderSide(
                                    color: AppColorsTheme.borderColor(context),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4.r),
                                  ),
                                  onChanged: kycProvider.toggleConfirmation,
                                ),
                              ),
                              UIHelper.horizontalSpace(10.w),
                              Expanded(
                                child: Text(
                                  'confirm_genuine'.tr,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColorsTheme.textMainColor(context),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpace(22.h),

                          // Submit Verification Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: kycProvider.isConfirmed && !kycProvider.isSubmitting
                                  ? () => kycProvider.submitVerification(context)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: kycProvider.isSubmitted
                                    ? const Color(0xFF047857)
                                    : primaryOrange,
                                disabledBackgroundColor: isDark
                                    ? const Color(0xFF2A2A2D)
                                    : const Color(0xFFE5E7EB),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: AppColorsTheme.textMutedColor(context),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                elevation: 0,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (kycProvider.isSubmitting) ...[
                                    SizedBox(
                                      width: 16.w,
                                      height: 16.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    UIHelper.horizontalSpace(8.w),
                                    Text(
                                      'submitting'.tr,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ] else if (kycProvider.isSubmitted) ...[
                                    Icon(Icons.check_circle_outline, size: 18.sp, color: Colors.white),
                                    UIHelper.horizontalSpace(8.w),
                                    Text(
                                      'submitted_successfully'.tr,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ] else ...[
                                    Text(
                                      'submit_verification'.tr,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String statusKey) {
    if (statusKey == 'complete') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFF065F46).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFF047857)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, color: const Color(0xFF10B981), size: 12.sp),
            UIHelper.horizontalSpace(4.w),
            Text(
              'complete'.tr,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
      );
    } else if (statusKey == 'in_progress') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFF78350F).withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFB45309)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.access_time, color: const Color(0xFFFCD34D), size: 12.sp),
            UIHelper.horizontalSpace(4.w),
            Text(
              'in_progress'.tr,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFCD34D),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColorsTheme.innerCardBg(context),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColorsTheme.borderColor(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.circle_outlined, color: AppColorsTheme.textMutedColor(context), size: 12.sp),
            UIHelper.horizontalSpace(4.w),
            Text(
              'not_started'.tr,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildDocumentBox({
    required BuildContext context,
    required String title,
    required String desc,
    required String countText,
    required bool isComplete,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
              ),
              UIHelper.horizontalSpace(8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isComplete
                      ? const Color(0xFF065F46).withValues(alpha: 0.2)
                      : AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: isComplete ? const Color(0xFF047857) : AppColorsTheme.borderColor(context),
                  ),
                ),
                child: Text(
                  countText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isComplete ? const Color(0xFF10B981) : AppColorsTheme.textMutedColor(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(4.h),
          Text(
            desc,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColorsTheme.textMutedColor(context),
              height: 1.35,
            ),
          ),
          UIHelper.verticalSpace(16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildFileSelector({
    required BuildContext context,
    required String label,
    required String desc,
    required String? fileName,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
            ),
            UIHelper.horizontalSpace(8.w),
            Text(
              'required'.tr,
              style: TextStyle(
                fontSize: 11.sp,
                color: primaryOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        UIHelper.verticalSpace(4.h),
        Text(
          desc,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppColorsTheme.textMutedColor(context),
            height: 1.35,
          ),
        ),
        UIHelper.verticalSpace(12.h),

        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onPick,
              icon: Icon(
                Icons.upload_file,
                size: 16.sp,
                color: primaryOrange,
              ),
              label: Text(
                'choose_file'.tr,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppColorsTheme.cardBg(context),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                side: BorderSide(color: AppColorsTheme.borderColor(context)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
            if (fileName != null) ...[
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: const Color(0xFF10B981),
                      size: 16.sp,
                    ),
                    UIHelper.horizontalSpace(6.w),
                    Expanded(
                      child: Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        UIHelper.verticalSpace(6.h),
        Text(
          'accepted_file_types'.tr,
          style: TextStyle(
            fontSize: 11.sp,
            color: AppColorsTheme.textMutedColor(context),
          ),
        ),
      ],
    );
  }
}
