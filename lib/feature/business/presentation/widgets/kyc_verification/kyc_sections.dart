import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/kyc_verification_provider.dart';
import 'kyc_common_widgets.dart';
import 'kyc_document_box.dart';

/// Intro text, "verification batch" + draft pill, and the identity heading.
class KycIntroSection extends StatelessWidget {
  const KycIntroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
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
                color: isDark ? primaryOrange.withValues(alpha: 0.15) : const Color(0xFFFFECE0),
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
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
        KycTitleBlock(
          title: 'identity_verification'.tr,
          description: 'identity_verification_desc'.tr,
          titleSize: 20.sp,
          descriptionSize: 13.sp,
          descriptionHeight: 1.4,
        ),
      ],
    );
  }
}

/// Main card: personal/business info heading, required + status badges,
/// progress bar, the three file documents and the optional TIN field.
class KycDocumentsCard extends StatelessWidget {
  const KycDocumentsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kycProvider = context.watch<KycVerificationProvider>();

    return KycSectionCard(
      withShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KycTitleBlock(
            title: 'personal_info_verification'.tr,
            description: 'personal_info_verification_desc'.tr,
            titleSize: 16.sp,
            descriptionSize: 12.sp,
            descriptionHeight: 1.3,
          ),
          UIHelper.verticalSpace(14.h),
          Row(
            children: [
              const _RequiredBadge(),
              UIHelper.horizontalSpace(8.w),
              KycStatusBadge(statusKey: kycProvider.overallStatusKey),
            ],
          ),
          UIHelper.verticalSpace(18.h),
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
              backgroundColor: isDark ? const Color(0xFF2A2A2D) : const Color(0xFFE5E7EB),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryOrange),
            ),
          ),
          UIHelper.verticalSpace(24.h),
          for (final doc in KycFileDocument.all) ...[
            _FileDocumentBox(doc: doc, fileName: _fileNameFor(kycProvider, doc.docKey)),
            UIHelper.verticalSpace(18.h),
          ],
          KycDocumentBox(
            title: 'Tax identification number',
            description: 'The TIN on your certificate, digits only.',
            countText: 'Optional',
            isComplete: kycProvider.tinController.text.trim().isNotEmpty,
            child: _TinField(controller: kycProvider.tinController),
          ),
        ],
      ),
    );
  }

  static String? _fileNameFor(KycVerificationProvider provider, String docKey) {
    switch (docKey) {
      case 'national_id':
        return provider.nationalIdFileName;
      case 'proof_of_address':
        return provider.proofOfAddressFileName;
      case 'trade_licence':
        return provider.tradeLicenceFileName;
    }
    return null;
  }
}

class _FileDocumentBox extends StatelessWidget {
  final KycFileDocument doc;
  final String? fileName;

  const _FileDocumentBox({required this.doc, required this.fileName});

  @override
  Widget build(BuildContext context) {
    final isComplete = fileName != null;

    return KycDocumentBox(
      title: doc.title,
      description: doc.description,
      countText: isComplete ? '1 of 1 provided' : '0 of 1 provided',
      isComplete: isComplete,
      child: KycFileSelector(
        label: doc.selectorLabel,
        description: doc.selectorDescription,
        fileName: fileName,
        onPick: () => context.read<KycVerificationProvider>().pickFile(doc.docKey),
      ),
    );
  }
}

class _RequiredBadge extends StatelessWidget {
  const _RequiredBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, color: primaryOrange, size: 12.sp),
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
    );
  }
}

class _TinField extends StatelessWidget {
  final TextEditingController controller;

  const _TinField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
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
          controller: controller,
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
    );
  }
}

/// Submit card: still-needed checklist (or all-provided banner), confirmation
/// checkbox and the submit button.
class KycSubmitCard extends StatelessWidget {
  const KycSubmitCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final kycProvider = context.watch<KycVerificationProvider>();

    return KycSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KycTitleBlock(
            title: 'submit_for_review'.tr,
            description: 'submit_for_review_desc'.tr,
            titleSize: 16.sp,
            descriptionSize: 12.5.sp,
            descriptionHeight: 1.35,
          ),
          UIHelper.verticalSpace(16.h),
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
            ...kycProvider.stillNeededList.map((item) => _StillNeededRow(text: item['text'] ?? '')),
          ] else
            const _AllProvidedBanner(),
          UIHelper.verticalSpace(16.h),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                elevation: 0,
              ),
              child: kycProvider.isSubmitting
                  ? SizedBox(
                      width: 20.w,
                      height: 20.h,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      kycProvider.isSubmitted ? 'submitted_successfully'.tr : 'submit_verification'.tr,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StillNeededRow extends StatelessWidget {
  final String text;

  const _StillNeededRow({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Row(
        children: [
          Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 15.sp),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllProvidedBanner extends StatelessWidget {
  const _AllProvidedBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: kycSuccessGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: kycSuccessGreen, size: 20.sp),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Text(
              'all_documents_provided'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: kycSuccessGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
