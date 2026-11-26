import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../auth/presentation/widgets/auth_bottom_navigation_bar.dart';
import 'widgets/kyc_verification/kyc_sections.dart';

/// Application & KYC: identity intro, document uploads and submit-for-review.
class KycVerificationScreen extends StatelessWidget {
  const KycVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      bottomNavigationBar: AuthBottomNavigationBar(
        continueLabel: 'submit_kyc'.tr,
        onBack: () => Navigator.pop(context),
        onContinue: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('kyc_submitted_success'.tr),
              backgroundColor: primaryOrange,
              duration: const Duration(seconds: 2),
            ),
          );
        },
      ),
      body: Column(
        children: [
          HeroPageHeader(
            title: 'application_and_kyc_title'.tr,
            subtitle: 'kyc_header_desc'.tr,
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontalPadding = constraints.maxWidth > 792
                      ? (constraints.maxWidth - 760) / 2
                      : 16.w;
                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      20.h,
                      horizontalPadding,
                      28.h,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const KycIntroSection(),
                            SizedBox(height: 18.h),
                            const KycDocumentsCard(),
                            SizedBox(height: 20.h),
                            const KycSubmitCard(),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
