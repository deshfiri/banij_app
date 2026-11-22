import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

/// Round translucent icon badge shown on the hero above a screen title.
class AuthHeroIcon extends StatelessWidget {
  final IconData icon;

  const AuthHeroIcon({super.key, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
        ),
        child: Icon(icon, color: Colors.white, size: 30.sp),
      ),
    );
  }
}

/// Small translucent tag on the hero, e.g. "SUPPLIER REGISTRATION".
class AuthHeroTag extends StatelessWidget {
  final String label;

  const AuthHeroTag({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.w,
              height: 6.w,
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            ),
            UIHelper.horizontalSpace(6.w),
            Text(
              label,
              style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w800, letterSpacing: 1, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Already have an account? Sign in" style prompt with an orange action.
class AuthLinkPrompt extends StatelessWidget {
  final String prompt;
  final String actionLabel;
  final VoidCallback onTap;

  const AuthLinkPrompt({super.key, required this.prompt, required this.actionLabel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          prompt,
          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColorsTheme.textMutedColor(context)),
        ),
        UIHelper.horizontalSpace(4.w),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionLabel,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: primaryOrange),
          ),
        ),
      ],
    );
  }
}

/// Orange link with a leading icon, e.g. "‹ Back to sign in".
class AuthTextLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  const AuthTextLink({super.key, required this.label, required this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onTap,
        style: TextButton.styleFrom(foregroundColor: primaryOrange),
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 16.sp),
        label: Text(label, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

/// Secondary (outlined) button that pairs with [GradientButton].
class AuthOutlinedButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  const AuthOutlinedButton({super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(28.r);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: radius,
        child: Ink(
          height: 54.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
            borderRadius: radius,
            border: Border.all(color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.25)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16.sp, color: AppColorsTheme.textMainColor(context)),
                UIHelper.horizontalSpace(6.w),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Icon tile + title + subtitle heading for a form section/step.
class AuthSectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AuthSectionHeader({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: primaryOrange.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: primaryOrange, size: 22.sp),
        ),
        UIHelper.horizontalSpace(12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColorsTheme.textMainColor(context),
                ),
              ),
              UIHelper.verticalSpace(2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColorsTheme.textMutedColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Numbered step progress (1 — 2 — 3). Completed steps turn green with a
/// check, the active one is an orange gradient circle.
class AuthStepIndicator extends StatelessWidget {
  final List<String> titles;
  final int currentStep;

  const AuthStepIndicator({super.key, required this.titles, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final border = AppColorsTheme.borderColor(context);

    return Row(
      children: List.generate(titles.length, (index) {
        final stepNum = index + 1;
        final isCompleted = stepNum < currentStep;
        final isActive = stepNum == currentStep;
        final isLast = index == titles.length - 1;

        Widget connector(bool visible, bool done) => Expanded(
              child: Container(height: 2.h, color: visible ? (done ? successGreen : border) : Colors.transparent),
            );

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  connector(index != 0, stepNum <= currentStep),
                  Container(
                    width: 32.w,
                    height: 32.w,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: isActive ? const LinearGradient(colors: [primaryOrange, secondaryOrange]) : null,
                      color: isActive ? null : (isCompleted ? successGreen : AppColorsTheme.cardBg(context)),
                      border: Border.all(
                        color: isActive ? Colors.transparent : (isCompleted ? successGreen : border),
                        width: 1.5.w,
                      ),
                      boxShadow: isActive
                          ? [BoxShadow(color: primaryOrange.withValues(alpha: 0.35), blurRadius: 8.r, offset: const Offset(0, 3))]
                          : null,
                    ),
                    child: isCompleted
                        ? Icon(Icons.check_rounded, color: Colors.white, size: 16.sp)
                        : Text(
                            '$stepNum',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w900,
                              color: isActive ? Colors.white : AppColorsTheme.textMutedColor(context),
                            ),
                          ),
                  ),
                  connector(!isLast, stepNum < currentStep),
                ],
              ),
              SizedBox(height: 6.h),
              Text(
                titles[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: isActive || isCompleted ? FontWeight.w800 : FontWeight.w500,
                  color: isActive || isCompleted
                      ? AppColorsTheme.textMainColor(context)
                      : AppColorsTheme.textMutedColor(context),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
