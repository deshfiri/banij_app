import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../dashboard_card_decoration.dart';
import '../dynamic_step_indicator.dart';

/// Account setup top: hero gradient with the page title and a "Step x of 5"
/// pill, plus a floating card holding the step progress.
class AccountSetupHeader extends StatelessWidget {
  final String title;
  final int currentStep;
  final bool isApproved;

  const AccountSetupHeader({
    super.key,
    required this.title,
    required this.currentStep,
    required this.isApproved,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;
    final totalSteps = DynamicStepIndicator.steps.length;
    final shownStep = currentStep.clamp(1, totalSteps);

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: topInset + 150.h,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: AppColorsTheme.heroGradient(context),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withValues(alpha: 0.35) : primaryOrange.withValues(alpha: 0.25),
                  blurRadius: 18.r,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.w, topInset + 22.h, 20.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 21.sp, fontWeight: FontWeight.w900, color: Colors.white),
              ),
              UIHelper.verticalSpace(8.h),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    'Step @current of @total'.trParams({'current': '$shownStep', 'total': '$totalSteps'}),
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              UIHelper.verticalSpace(20.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 16.h),
                decoration: DashboardCardDecoration.of(context, radius: 22),
                child: DynamicStepIndicator(currentStep: currentStep, isApproved: isApproved),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
