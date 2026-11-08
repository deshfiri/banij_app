import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Usage:
/// CustomFinanceAppBar(
///   title: 'Finance', // Dynamic title
///   onBackTap: () => Navigator.pop(context),
///   onNotificationTap: () {},
///   onActionTap: () {},
/// )
class CustomFinanceAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onActionTap;

  const CustomFinanceAppBar({
    super.key,
    required this.title,
    this.onBackTap,
    this.onNotificationTap,
    this.onActionTap,
  });

  @override
  Size get preferredSize => Size.fromHeight(170.h);

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: preferredSize,
      child: ClipPath(
        clipper: _BottomWaveClipper(),
        child: Container(
          height: 170.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3B39F3), Color(0xFF7A3EF4), Color(0xFFE85BCF)],
            ),
          ),
          child: Stack(
            children: [
              // Left decorative transparent shape
              Positioned(
                left: -20.w,
                bottom: 15.h,
                child: Container(
                  width: 85.w,
                  height: 85.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
              ),

              // Right decorative transparent shape
              Positioned(
                right: 15.w,
                top: -15.h,
                child: Transform.rotate(
                  angle: 0.35,
                  child: Container(
                    width: 95.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                ),
              ),

              // Content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  child: Column(
                    children: [
                      // Top Row
                      Row(
                        children: [
                          // Cargoaim logo + text
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance,
                                color: Colors.white,
                                size: 22.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'Cargoaim',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),

                          const Spacer(),

                          // Notification Button
                          _GlassIconButton(
                            icon: Icons.notifications_none_rounded,
                            size: 18.sp,
                            onTap: onNotificationTap,
                          ),
                        ],
                      ),

                      SizedBox(height: 14.h),

                      // Bottom Row
                      Row(
                        children: [
                          // Back Button
                          _CircleButton(
                            icon: Icons.chevron_left_rounded,
                            onTap: onBackTap,
                          ),

                          Expanded(
                            child: Center(
                              child: Text(
                                title, // Dynamic title
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),

                          // Right Action Button
                          _CircleButton(
                            icon: Icons.content_paste_outlined,
                            iconSize: 20.sp,
                            onTap: onActionTap,
                          ),
                        ],
                      ),
                    ],
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

/// Glass square button for notification
class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;

  const _GlassIconButton({required this.icon, required this.size, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }
}

/// Circular white button
class _CircleButton extends StatelessWidget {
  final IconData icon;
  final double? iconSize;
  final VoidCallback? onTap;

  const _CircleButton({required this.icon, this.iconSize, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42.w,
          height: 42.w,
          child: Icon(
            icon,
            color: const Color(0xFF5A5A5A),
            size: iconSize ?? 24.sp,
          ),
        ),
      ),
    );
  }
}

/// Bottom wave clipper
class _BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    path.lineTo(0, size.height - 18);

    // Left curve
    path.quadraticBezierTo(
      size.width * 0.20,
      size.height - 8,
      size.width * 0.42,
      size.height - 12,
    );

    // Center dip
    path.quadraticBezierTo(
      size.width * 0.50,
      size.height,
      size.width * 0.58,
      size.height - 12,
    );

    // Right curve
    path.quadraticBezierTo(
      size.width * 0.80,
      size.height - 8,
      size.width,
      size.height - 18,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
