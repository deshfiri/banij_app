import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';

class StepData {
  final int stepNumber;
  final String title;
  final String? badgeText;

  const StepData({
    required this.stepNumber,
    required this.title,
    this.badgeText,
  });
}

/// Five-step account setup progress (Register → Approval). Done steps are
/// green with a check, the active step is an orange gradient circle.
class DynamicStepIndicator extends StatelessWidget {
  final int currentStep;
  final bool isApproved;

  const DynamicStepIndicator({
    super.key,
    this.currentStep = 3,
    this.isApproved = false,
  });

  /// [StepData.title] / [StepData.badgeText] are translation keys.
  static const List<StepData> steps = [
    StepData(stepNumber: 1, title: 'Register'),
    StepData(stepNumber: 2, title: 'Verify'),
    StepData(stepNumber: 3, title: 'KYC', badgeText: 'KYC'),
    StepData(stepNumber: 4, title: 'Package'),
    StepData(stepNumber: 5, title: 'Approval'),
  ];

  @override
  Widget build(BuildContext context) {
    final border = AppColorsTheme.borderColor(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final stepNum = step.stepNumber;
        final isCompleted = stepNum < currentStep || (stepNum == 5 && (currentStep >= 6 || isApproved));
        final isActive = stepNum == currentStep && !isCompleted;
        final isLast = index == steps.length - 1;

        Widget connector({required bool visible, required bool done}) => Expanded(
              child: Container(
                height: 2.h,
                decoration: BoxDecoration(
                  color: visible ? (done ? successGreen : border) : Colors.transparent,
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            );

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  connector(visible: index != 0, done: isCompleted || stepNum <= currentStep),
                  _StepNode(stepNum: stepNum, isCompleted: isCompleted, isActive: isActive),
                  connector(visible: !isLast, done: isCompleted),
                ],
              ),
              SizedBox(height: 6.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    step.title.tr,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: isActive || isCompleted ? FontWeight.w800 : FontWeight.w500,
                      color: isCompleted || isActive
                          ? AppColorsTheme.textMainColor(context)
                          : AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                ),
              ),
              if (isActive && step.badgeText != null) ...[
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    step.badgeText!.tr,
                    style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: primaryOrange),
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _StepNode extends StatelessWidget {
  final int stepNum;
  final bool isCompleted;
  final bool isActive;

  const _StepNode({required this.stepNum, required this.isCompleted, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.w,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: isActive ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
        color: isActive ? null : (isCompleted ? successGreen : AppColorsTheme.cardBg(context)),
        border: Border.all(
          color: isActive
              ? Colors.transparent
              : (isCompleted ? successGreen : AppColorsTheme.borderColor(context)),
          width: 1.5.w,
        ),
        boxShadow: isActive
            ? [BoxShadow(color: primaryOrange.withValues(alpha: 0.35), blurRadius: 8.r, offset: const Offset(0, 3))]
            : null,
      ),
      child: isCompleted
          ? Icon(Icons.check_rounded, color: Colors.white, size: 15.sp)
          : Text(
              '$stepNum',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w900,
                color: isActive ? Colors.white : AppColorsTheme.textMutedColor(context),
              ),
            ),
    );
  }
}
