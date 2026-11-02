import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../finance/presentation/finance_screen.dart';

class AccountScreenBody extends StatelessWidget {
  const AccountScreenBody({super.key});

  void _handleProfileTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Profile Settings...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  void _handleSecurityTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Security Settings...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  void _handleAppearanceTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Appearance Settings...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Account Header / AppBar
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
          decoration: BoxDecoration(
            color: inputFillColor,
            border: Border(
              bottom: BorderSide(color: cardBorderColor, width: 1.w),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: Text(
                'Account Setting',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: textMain,
                ),
              ),
            ),
          ),
        ),

        // Body Content with Cards
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Account Management',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
                UIHelper.verticalSpace(6.h),
                Text(
                  'Manage your profile, security settings, and app appearance.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
                UIHelper.verticalSpace(20.h),

                // Card 1: Profile
                FinanceCardWidget(
                  title: 'Profile',
                  subtitle: 'Personal details & information',
                  iconData: Icons.person_outline_rounded,
                  onTap: () => _handleProfileTap(context),
                ),
                UIHelper.verticalSpace(16.h),

                // Card 2: Security
                FinanceCardWidget(
                  title: 'Security',
                  subtitle: 'Password, 2FA & active sessions',
                  iconData: Icons.security_outlined,
                  onTap: () => _handleSecurityTap(context),
                ),
                UIHelper.verticalSpace(16.h),

                // Card 3: Appearance
                FinanceCardWidget(
                  title: 'Appearance',
                  subtitle: 'Theme, notifications & display',
                  iconData: Icons.palette_outlined,
                  onTap: () => _handleAppearanceTap(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
