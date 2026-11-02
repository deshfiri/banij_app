import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../finance/presentation/finance_screen.dart';

class BusinessScreenBody extends StatelessWidget {
  const BusinessScreenBody({super.key});

  void _handleVerificationTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Verification...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  void _handleSubscriptionTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Subscription...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Business Header / AppBar
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
                'Business',
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
                  'Business Management',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
                UIHelper.verticalSpace(6.h),
                Text(
                  'Manage your company verification and active subscriptions.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
                UIHelper.verticalSpace(20.h),

                // Card 1: Verification
                FinanceCardWidget(
                  title: 'Verification',
                  subtitle: 'KYC & business identity verification',
                  iconData: Icons.verified_user_outlined,
                  onTap: () => _handleVerificationTap(context),
                ),
                UIHelper.verticalSpace(16.h),

                // Card 2: Subscription
                FinanceCardWidget(
                  title: 'Subscription',
                  subtitle: 'Manage your plans & billing',
                  iconData: Icons.card_membership_outlined,
                  onTap: () => _handleSubscriptionTap(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
