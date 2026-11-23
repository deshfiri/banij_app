import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import 'widgets/common/sub_screen_top_bar.dart';
import 'widgets/kyc_verification/kyc_sections.dart';

/// Application & KYC: identity intro, document uploads and submit-for-review.
class KycVerificationScreen extends StatelessWidget {
  const KycVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            SubScreenTopBar(title: 'application_and_kyc_title'.tr, horizontalPadding: 12),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const KycIntroSection(),
                    UIHelper.verticalSpace(20.h),
                    const KycDocumentsCard(),
                    UIHelper.verticalSpace(24.h),
                    const KycSubmitCard(),
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
}
