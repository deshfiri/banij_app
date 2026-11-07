import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

class DynamicStepIndicator extends StatelessWidget {
  final int currentStep;

  const DynamicStepIndicator({
    super.key,
    this.currentStep = 3,
  });

  static const List<StepData> steps = [
    StepData(stepNumber: 1, title: 'Register'),
    StepData(stepNumber: 2, title: 'Verify'),
    StepData(stepNumber: 3, title: 'KYC', badgeText: 'KYC'),
    StepData(stepNumber: 4, title: 'Package'),
    StepData(stepNumber: 5, title: 'Approval'),
  ];

  static const Color successGreen = Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(steps.length, (index) {
          final step = steps[index];
          final stepNum = step.stepNumber;
          final isCompleted = stepNum < currentStep;
          final isActive = stepNum == currentStep;
          final isLast = index == steps.length - 1;

          return Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Circle Node & Connector Line
                Row(
                  children: [
                    // Left Connector (invisible for first item)
                    Expanded(
                      child: Container(
                        height: 2.h,
                        color: index == 0
                            ? Colors.transparent
                            : (stepNum <= currentStep
                                ? successGreen
                                : (isActive
                                    ? primaryOrange
                                    : AppColorsTheme.borderColor(context))),
                      ),
                    ),
                    // Circle Node
                    Container(
                      width: 30.w,
                      height: 30.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? successGreen
                            : AppColorsTheme.cardBg(context),
                        border: Border.all(
                          color: isCompleted
                              ? successGreen
                              : (isActive
                                  ? primaryOrange
                                  : AppColorsTheme.borderColor(context)),
                          width: isActive ? 2.w : 1.5.w,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: isCompleted
                          ? Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16.sp,
                            )
                          : Text(
                              '$stepNum',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: isActive
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isActive
                                    ? primaryOrange
                                    : AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                    ),
                    // Right Connector (invisible for last item)
                    Expanded(
                      child: Container(
                        height: 2.h,
                        color: isLast
                            ? Colors.transparent
                            : (isCompleted
                                ? successGreen
                                : AppColorsTheme.borderColor(context)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),

                // Title Label
                Text(
                  step.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight:
                        isActive || isCompleted ? FontWeight.bold : FontWeight.w500,
                    color: isCompleted || isActive
                        ? AppColorsTheme.textMainColor(context)
                        : AppColorsTheme.textMutedColor(context),
                  ),
                ),

                // Active Badge (e.g. 'KYC' highlight under active step)
                if (isActive && step.badgeText != null) ...[
                  SizedBox(height: 4.h),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECE0),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      step.badgeText!,
                      style: TextStyle(
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.bold,
                        color: primaryOrange,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }
}
