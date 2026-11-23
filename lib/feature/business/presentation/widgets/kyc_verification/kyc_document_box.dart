import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// One required file document in the KYC form. [docKey] is the value passed
/// to `KycVerificationProvider.pickFile`.
class KycFileDocument {
  final String docKey;
  final String title;
  final String description;
  final String selectorLabel;
  final String selectorDescription;

  const KycFileDocument({
    required this.docKey,
    required this.title,
    required this.description,
    required this.selectorLabel,
    required this.selectorDescription,
  });

  static const List<KycFileDocument> all = [
    KycFileDocument(
      docKey: 'national_id',
      title: 'National ID',
      description: 'Both sides, in colour, with all four corners visible.',
      selectorLabel: 'National ID Document',
      selectorDescription: 'Upload a clear photo or PDF of your National ID.',
    ),
    KycFileDocument(
      docKey: 'proof_of_address',
      title: 'Proof of address',
      description: 'A utility bill or bank statement from the last three months.',
      selectorLabel: 'Utility Bill or Bank Statement',
      selectorDescription: 'Upload a clear copy of your proof of address document.',
    ),
    KycFileDocument(
      docKey: 'trade_licence',
      title: 'Trade licence',
      description: 'Current year, issued by your city corporation.',
      selectorLabel: 'Trade Licence Document',
      selectorDescription: 'Upload a clear photo or PDF of your Trade Licence.',
    ),
  ];
}

/// Bordered box for one KYC document: title, count pill, description, [child].
/// The border and pill turn green when [isComplete].
class KycDocumentBox extends StatelessWidget {
  final String title;
  final String description;
  final String countText;
  final bool isComplete;
  final Widget child;

  const KycDocumentBox({
    super.key,
    required this.title,
    required this.description,
    required this.countText,
    required this.isComplete,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
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
                  color: isComplete ? Colors.green.withValues(alpha: 0.12) : AppColorsTheme.cardBg(context),
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
            description,
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
}

/// "Choose file" button with label, description, selected file name and hint.
class KycFileSelector extends StatelessWidget {
  final String label;
  final String description;
  final String? fileName;
  final VoidCallback onPick;

  const KycFileSelector({
    super.key,
    required this.label,
    required this.description,
    required this.fileName,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final fileName = this.fileName;
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
          description,
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
