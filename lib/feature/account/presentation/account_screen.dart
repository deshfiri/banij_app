import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../auth/presentation/login_screen/loginScreen.dart';
import '../../finance/presentation/finance_screen.dart';

class AccountScreenBody extends StatefulWidget {
  const AccountScreenBody({super.key});

  @override
  State<AccountScreenBody> createState() => _AccountScreenBodyState();
}

class _AccountScreenBodyState extends State<AccountScreenBody> {
  bool _isDarkMode = false;
  bool _isBengali = false;

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

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: inputFillColor,
          title: Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: textMain,
            ),
          ),
          content: Text(
            'You will need to sign in again to access your account and workspace.',
            style: TextStyle(
              fontSize: 13.sp,
              color: textMuted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
              },
              child: Text(
                'No',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: textMuted,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Yes',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
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

        // Body Content with Cards & Switches
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
                  'Manage your profile, security settings, dark mode and language.',
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

                // Card 3: Dark Mode Switch Card
                AccountSwitchCardWidget(
                  title: 'Dark Mode',
                  subtitle: _isDarkMode ? 'Dark theme enabled' : 'Light theme enabled',
                  iconData: Icons.dark_mode_outlined,
                  value: _isDarkMode,
                  onChanged: (val) {
                    setState(() {
                      _isDarkMode = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isDarkMode ? 'Dark Mode Enabled' : 'Light Mode Enabled'),
                        backgroundColor: primaryOrange,
                        duration: const Duration(milliseconds: 600),
                      ),
                    );
                  },
                ),
                UIHelper.verticalSpace(16.h),

                // Card 4: Language Change Switch Card
                AccountSwitchCardWidget(
                  title: 'Change Language',
                  subtitle: _isBengali ? 'Language: Bengali (বাংলা)' : 'Language: English (EN)',
                  iconData: Icons.language_outlined,
                  value: _isBengali,
                  onChanged: (val) {
                    setState(() {
                      _isBengali = val;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(_isBengali ? 'Language switched to Bengali' : 'Language switched to English'),
                        backgroundColor: primaryOrange,
                        duration: const Duration(milliseconds: 600),
                      ),
                    );
                  },
                ),
                UIHelper.verticalSpace(16.h),

                // Card 5: Logout Card
                FinanceCardWidget(
                  title: 'Logout',
                  subtitle: 'Sign out of your account securely',
                  iconData: Icons.logout_rounded,
                  onTap: () => _showLogoutConfirmation(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class AccountSwitchCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final bool value;
  final ValueChanged<bool> onChanged;

  const AccountSwitchCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: inputFillColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: cardBorderColor, width: 1.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7F2),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: primaryOrange.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              iconData,
              size: 26.sp,
              color: primaryOrange,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: primaryOrange,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
