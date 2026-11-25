import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/app_constants.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/di.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../providers/account_provider.dart';

/// "Log out?" confirmation. Shows which account is signed in, and runs the
/// logout itself with a loading button so the user sees it happening.
/// `AccountProvider.logout` navigates to onboarding, which also closes this
/// dialog.
class LogoutConfirmationDialog extends StatefulWidget {
  final AccountProvider accountProvider;

  const LogoutConfirmationDialog._({required this.accountProvider});

  static Future<void> show(BuildContext context) {
    // Read the provider before the dialog opens: the drawer that opens this
    // dialog may be closed (and its context unmounted) meanwhile.
    final accountProvider = context.read<AccountProvider>();
    return showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close',
      barrierColor: Colors.black.withValues(alpha: 0.55),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, _, _) => LogoutConfirmationDialog._(accountProvider: accountProvider),
      transitionBuilder: (_, animation, _, child) {
        final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutBack, reverseCurve: Curves.easeIn);
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(curved), child: child),
        );
      },
    );
  }

  @override
  State<LogoutConfirmationDialog> createState() => _LogoutConfirmationDialogState();
}

class _LogoutConfirmationDialogState extends State<LogoutConfirmationDialog> {
  bool _isLoggingOut = false;

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    HapticFeedback.mediumImpact();
    setState(() => _isLoggingOut = true);
    await widget.accountProvider.logout(context);
    // Normally unreachable: logout replaces the whole route stack.
    if (mounted) setState(() => _isLoggingOut = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isCompact = screenSize.width < 360;
    final name = appData.read(KkName)?.toString().trim() ?? '';
    final email = appData.read(KkUserEmail)?.toString().trim() ?? '';

    return PopScope(
      canPop: !_isLoggingOut,
      child: Dialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        insetPadding: EdgeInsets.symmetric(horizontal: isCompact ? 16.w : 24.w, vertical: 24.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26.r)),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420, maxHeight: screenSize.height * 0.86),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Soft red header band with the layered icon.
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 22.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [errorRed.withValues(alpha: 0.12), errorRed.withValues(alpha: 0.0)],
                    ),
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          tooltip: 'Cancel'.tr,
                          onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
                          icon: Icon(Icons.close_rounded, size: 20.sp, color: AppColorsTheme.textMutedColor(context)),
                        ),
                      ),
                      const _LogoutIllustration(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(22.w, 0, 22.w, 22.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Log out?'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      UIHelper.verticalSpace(6.h),
                      Text(
                        'You will need to sign in again to access your account and workspace.'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5.sp, height: 1.5, color: AppColorsTheme.textMutedColor(context)),
                      ),
                      if (name.isNotEmpty || email.isNotEmpty) ...[
                        UIHelper.verticalSpace(16.h),
                        _AccountChip(name: name, email: email),
                      ],
                      UIHelper.verticalSpace(22.h),
                      _buildButtons(isCompact),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtons(bool isCompact) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r));
    final minSize = Size(0, 50.h);
    final textStyle = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800);

    final cancel = OutlinedButton(
      onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        minimumSize: minSize,
        shape: shape,
        side: BorderSide(color: AppColorsTheme.borderColor(context)),
        foregroundColor: AppColorsTheme.textMainColor(context),
      ),
      child: Text('Cancel'.tr, style: textStyle),
    );

    final confirm = ElevatedButton.icon(
      onPressed: _isLoggingOut ? null : _logout,
      icon: _isLoggingOut
          ? SizedBox.square(
              dimension: 16.sp,
              child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(Icons.logout_rounded, size: 18.sp),
      label: Text((_isLoggingOut ? 'Logging out…' : 'Log out').tr, style: textStyle),
      style: ElevatedButton.styleFrom(
        backgroundColor: errorRed,
        foregroundColor: Colors.white,
        disabledBackgroundColor: errorRed.withValues(alpha: 0.7),
        disabledForegroundColor: Colors.white,
        minimumSize: minSize,
        shape: shape,
        elevation: 0,
      ),
    );

    if (isCompact) {
      return Column(
        children: [
          SizedBox(width: double.infinity, child: confirm),
          UIHelper.verticalSpace(10.h),
          SizedBox(width: double.infinity, child: cancel),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: cancel),
        UIHelper.horizontalSpace(12.w),
        Expanded(child: confirm),
      ],
    );
  }
}

/// Halo + ring + red gradient disc with the logout icon.
class _LogoutIllustration extends StatelessWidget {
  const _LogoutIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104.w,
      height: 104.w,
      decoration: BoxDecoration(shape: BoxShape.circle, color: errorRed.withValues(alpha: 0.08)),
      child: Center(
        child: Container(
          width: 80.w,
          height: 80.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: errorRed.withValues(alpha: 0.14)),
          child: Center(
            child: Container(
              width: 58.w,
              height: 58.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [errorRed, Color.lerp(errorRed, Colors.black, 0.18)!]),
                boxShadow: [
                  BoxShadow(color: errorRed.withValues(alpha: 0.35), blurRadius: 14.r, offset: const Offset(0, 5)),
                ],
              ),
              child: Icon(Icons.logout_rounded, color: Colors.white, size: 28.sp),
            ),
          ),
        ),
      ),
    );
  }
}

/// The signed-in account: initial avatar, name and email.
class _AccountChip extends StatelessWidget {
  final String name;
  final String email;

  const _AccountChip({required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    final display = name.isNotEmpty ? name : email;
    final initial = display.isEmpty ? '?' : display[0].toUpperCase();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [primaryOrange, secondaryOrange]),
            ),
            child: Text(
              initial,
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.white),
            ),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Signed in as'.tr,
                  style: TextStyle(fontSize: 10.5.sp, color: AppColorsTheme.textMutedColor(context)),
                ),
                Text(
                  display,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                if (name.isNotEmpty && email.isNotEmpty)
                  Text(
                    email,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
