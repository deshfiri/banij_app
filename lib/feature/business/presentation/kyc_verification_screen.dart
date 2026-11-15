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
            // Top Clean App Bar
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
                    UIHelper.verticalSpace(20.h),

                    // Main Group Card: Personal & Business Information Verification
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
                                '${kycProvider.uploadedRequiredCount} of 3 ${'completed'.tr}',
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

                          // Document 1: National ID (national_id)
                          _buildDocumentBox(
                            context: context,
                            title: 'National ID',
                            desc: 'Both sides, in colour, with all four corners visible.',
                            countText: kycProvider.nationalIdFileName != null ? '1 of 1 provided' : '0 of 1 provided',
                            isComplete: kycProvider.nationalIdFileName != null,
                            child: _buildFileSelector(
                              context: context,
                              label: 'National ID Document',
                              desc: 'Upload a clear photo or PDF of your National ID.',
                              fileName: kycProvider.nationalIdFileName,
                              onPick: () => kycProvider.pickFile('national_id'),
                            ),
                          ),
                          UIHelper.verticalSpace(18.h),

                          // Document 2: Proof of Address (proof_of_address)
                          _buildDocumentBox(
                            context: context,
                            title: 'Proof of address',
                            desc: 'A utility bill or bank statement from the last three months.',
                            countText: kycProvider.proofOfAddressFileName != null ? '1 of 1 provided' : '0 of 1 provided',
                            isComplete: kycProvider.proofOfAddressFileName != null,
                            child: _buildFileSelector(
                              context: context,
                              label: 'Utility Bill or Bank Statement',
                              desc: 'Upload a clear copy of your proof of address document.',
                              fileName: kycProvider.proofOfAddressFileName,
                              onPick: () => kycProvider.pickFile('proof_of_address'),
                            ),
                          ),
                          UIHelper.verticalSpace(18.h),

                          // Document 3: Trade Licence (trade_licence)
                          _buildDocumentBox(
                            context: context,
                            title: 'Trade licence',
                            desc: 'Current year, issued by your city corporation.',
                            countText: kycProvider.tradeLicenceFileName != null ? '1 of 1 provided' : '0 of 1 provided',
                            isComplete: kycProvider.tradeLicenceFileName != null,
                            child: _buildFileSelector(
                              context: context,
                              label: 'Trade Licence Document',
                              desc: 'Upload a clear photo or PDF of your Trade Licence.',
                              fileName: kycProvider.tradeLicenceFileName,
                              onPick: () => kycProvider.pickFile('trade_licence'),
                            ),
                          ),
                          UIHelper.verticalSpace(18.h),

                          // Document 4: TIN (tin)
                          _buildDocumentBox(
                            context: context,
                            title: 'Tax identification number',
                            desc: 'The TIN on your certificate, digits only.',
                            countText: 'Optional',
                            isComplete: kycProvider.tinController.text.trim().isNotEmpty,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'TIN Number',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColorsTheme.textMainColor(context),
                                  ),
                                ),
                                UIHelper.verticalSpace(6.h),
                                TextField(
                                  controller: kycProvider.tinController,
                                  keyboardType: TextInputType.number,
                                  style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
                                  decoration: InputDecoration(
                                    hintText: 'Enter TIN digits',
                                    hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                                    contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                                    filled: true,
                                    fillColor: AppColorsTheme.cardBg(context),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                      borderSide: BorderSide(color: primaryOrange, width: 1.5.w),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpace(24.h),

                    // Submit & Confirmation Card
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
                              fontSize: 12.5.sp,
                              color: AppColorsTheme.textMutedColor(context),
                              height: 1.35,
                            ),
                          ),
                          UIHelper.verticalSpace(16.h),

                          // Still Needed Checklist List
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
                            ...kycProvider.stillNeededList.map(
                              (item) => Padding(
                                padding: EdgeInsets.only(bottom: 6.h),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.cancel_outlined,
                                      color: Colors.redAccent,
                                      size: 15.sp,
                                    ),
                                    UIHelper.horizontalSpace(8.w),
                                    Expanded(
                                      child: Text(
                                        item['text'] ?? '',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColorsTheme.textMutedColor(context),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else ...[
                            Container(
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: const Color(0xFF10B981),
                                    size: 20.sp,
                                  ),
                                  UIHelper.horizontalSpace(10.w),
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
                            ),
                          ],
                          UIHelper.verticalSpace(16.h),

                          // Checkbox confirmation
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 22.w,
                                height: 22.h,
                                child: Checkbox(
                                  value: kycProvider.isConfirmed,
                                  activeColor: primaryOrange,
                                  onChanged: kycProvider.toggleConfirmation,
                                ),
                              ),
                              UIHelper.horizontalSpace(10.w),
                              Expanded(
                                child: Text(
                                  'confirm_genuine'.tr,
                                  style: TextStyle(
                                    fontSize: 12.5.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColorsTheme.textMainColor(context),
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          UIHelper.verticalSpace(20.h),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: (kycProvider.isConfirmed && !kycProvider.isSubmitting && !kycProvider.isSubmitted)
                                  ? () => kycProvider.submitVerification(context)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryOrange,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
                                disabledForegroundColor: isDark ? const Color(0xFF636366) : const Color(0xFF9CA3AF),
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                elevation: 0,
                              ),
                              child: kycProvider.isSubmitting
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: const CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      kycProvider.isSubmitted ? 'submitted_successfully'.tr : 'submit_verification'.tr,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpace(30.h),
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
    Color bg;
    Color fg;
    String text;
    IconData icon;

    switch (statusKey) {
      case 'complete':
        bg = const Color(0xFF10B981).withValues(alpha: 0.15);
        fg = const Color(0xFF10B981);
        text = 'complete'.tr;
        icon = Icons.check_circle_outline;
        break;
      case 'in_progress':
        bg = primaryOrange.withValues(alpha: 0.15);
        fg = primaryOrange;
        text = 'in_progress'.tr;
        icon = Icons.hourglass_top_rounded;
        break;
      default:
        bg = AppColorsTheme.textMutedColor(context).withValues(alpha: 0.12);
        fg = AppColorsTheme.textMutedColor(context);
        text = 'not_started'.tr;
        icon = Icons.radio_button_unchecked;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: fg, size: 12.sp),
          UIHelper.horizontalSpace(4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
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
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isComplete ? Colors.green.withValues(alpha: 0.5) : AppColorsTheme.borderColor(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: isComplete
                      ? Colors.green.withValues(alpha: 0.12)
                      : AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  countText,
                  style: TextStyle(
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.bold,
                    color: isComplete ? Colors.green : AppColorsTheme.textMutedColor(context),
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
              height: 1.3,
            ),
          ),
          UIHelper.verticalSpace(14.h),
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
    final isUploaded = fileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
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
        UIHelper.verticalSpace(4.h),
        Text(
          desc,
          style: TextStyle(
            fontSize: 11.5.sp,
            color: AppColorsTheme.textMutedColor(context),
            height: 1.3,
          ),
        ),
        UIHelper.verticalSpace(10.h),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: onPick,
              icon: Icon(
                isUploaded ? Icons.check_circle_outline : Icons.file_present_outlined,
                size: 16.sp,
              ),
              label: Text(
                isUploaded ? 'File selected' : 'choose_file'.tr,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isUploaded ? Colors.green : AppColorsTheme.cardBg(context),
                foregroundColor: isUploaded ? Colors.white : AppColorsTheme.textMainColor(context),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  side: BorderSide(
                    color: isUploaded ? Colors.green : AppColorsTheme.borderColor(context),
                  ),
                ),
                elevation: 0,
              ),
            ),
            if (fileName != null) ...[
              UIHelper.horizontalSpace(10.w),
              Expanded(
                child: Text(
                  fileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        UIHelper.verticalSpace(6.h),
        Text(
          'accepted_file_types'.tr,
          style: TextStyle(
            fontSize: 10.5.sp,
            color: AppColorsTheme.textMutedColor(context),
          ),
        ),
      ],
    );
  }
}
