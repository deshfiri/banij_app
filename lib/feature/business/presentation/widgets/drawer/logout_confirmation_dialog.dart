import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/app_constants.dart';
import '../../../../../constants/color.dart';
import '../../../../../constants/image_const.dart';
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
                _Header(onClose: _isLoggingOut ? null : () => Navigator.pop(context)),
                Padding(
                  padding: EdgeInsets.fromLTRB(22.w, 18.h, 22.w, 22.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'logout_title'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21.sp,
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
                        UIHelper.verticalSpace(18.h),
                        _AccountChip(name: name, email: email),
                      ],
                      UIHelper.verticalSpace(12.h),
                      const _SafeNote(),
                      UIHelper.verticalSpace(20.h),
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
    final radius = BorderRadius.circular(28.r);
    final height = 50.h;
    final textStyle = TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800);

    final cancel = SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: _isLoggingOut ? null : () => Navigator.pop(context),
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: radius),
          side: BorderSide(color: AppColorsTheme.borderColor(context), width: 1.2),
          foregroundColor: AppColorsTheme.textMainColor(context),
        ),
        child: Text('logout_cancel'.tr, style: textStyle),
      ),
    );

    final confirm = Opacity(
      opacity: _isLoggingOut ? 0.85 : 1,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: primaryOrange.withValues(alpha: 0.35), blurRadius: 14.r, offset: const Offset(0, 5)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _isLoggingOut ? null : _logout,
            borderRadius: radius,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isLoggingOut)
                      SizedBox.square(
                        dimension: 16.sp,
                        child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    else
                      Icon(Icons.logout_rounded, size: 18.sp, color: Colors.white),
                    UIHelper.horizontalSpace(8.w),
                    Text(
                      (_isLoggingOut ? 'logout_logging_out' : 'logout_confirm').tr,
                      style: textStyle.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (isCompact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [confirm, UIHelper.verticalSpace(10.h), cancel],
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

/// Orange gradient band: white logo, close button and the logout emblem.
class _Header extends StatelessWidget {
  final VoidCallback? onClose;

  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(top: -40.h, right: -30.w, child: _circle(130.w, 0.1)),
          Positioned(bottom: -30.h, left: -20.w, child: _circle(90.w, 0.07)),
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 10.h, 8.w, 22.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.asset(whiteLogo, width: 70.w, height: 22.h, fit: BoxFit.contain),
                    const Spacer(),
                    IconButton(
                      tooltip: 'logout_cancel'.tr,
                      onPressed: onClose,
                      style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.18)),
                      icon: Icon(Icons.close_rounded, size: 18.sp, color: Colors.white),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(6.h),
                const _LogoutEmblem(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _circle(double size, double alpha) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
        ),
      );
}

/// Glass rings around a white disc with the orange logout icon.
class _LogoutEmblem extends StatelessWidget {
  const _LogoutEmblem();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100.w,
      height: 100.w,
      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.12)),
      child: Center(
        child: Container(
          width: 78.w,
          height: 78.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          ),
          child: Center(
            child: Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 12.r, offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(Icons.logout_rounded, color: primaryOrange, size: 27.sp),
            ),
          ),
        ),
      ),
    );
  }
}

/// The signed-in account: orange left bar, initials avatar, name and email.
class _AccountChip extends StatelessWidget {
  final String name;
  final String email;

  const _AccountChip({required this.name, required this.email});

  String get _initials {
    final source = name.isNotEmpty ? name : email;
    final parts = source.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.characters.first;
    final last = parts.length > 1 ? parts.last.characters.first : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final display = name.isNotEmpty ? name : email;
    final radius = BorderRadius.circular(16.r);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color.alphaBlend(primaryOrange.withValues(alpha: isDark ? 0.08 : 0.05), AppColorsTheme.cardBg(context)),
        borderRadius: radius,
        border: Border.all(color: primaryOrange.withValues(alpha: isDark ? 0.35 : 0.25)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 10.h, 12.w, 10.h),
              child: Row(
                children: [
                  Container(
                    width: 42.w,
                    height: 42.w,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(colors: [secondaryOrange, primaryOrange]),
                    ),
                    child: Text(
                      _initials,
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  UIHelper.horizontalSpace(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'logout_signed_in_as'.tr.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                            color: primaryOrange,
                          ),
                        ),
                        UIHelper.verticalSpace(2.h),
                        Text(
                          display,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5.sp,
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
                  Icon(Icons.verified_user_rounded, size: 18.sp, color: primaryOrange.withValues(alpha: 0.8)),
                ],
              ),
            ),
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4.w,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [primaryOrange, secondaryOrange],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Small reassurance line under the account.
class _SafeNote extends StatelessWidget {
  const _SafeNote();

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline_rounded, size: 13.sp, color: muted),
        UIHelper.horizontalSpace(5.w),
        Flexible(
          child: Text(
            'logout_safe_note'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.sp, color: muted),
          ),
        ),
      ],
    );
  }
}
