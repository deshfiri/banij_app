import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';

class FinanceScreenBody extends StatelessWidget {
  const FinanceScreenBody({super.key});

  void _handleInvoiceTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Invoices...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  void _handleReceiptsTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening Receipts...'),
        backgroundColor: primaryOrange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Finance Header / AppBar
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
                'Finance',
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
                  'Financial Management',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: textMain,
                  ),
                ),
                UIHelper.verticalSpace(6.h),
                Text(
                  'Manage your invoices and track payment receipts in one place.',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: textMuted,
                  ),
                ),
                UIHelper.verticalSpace(20.h),

                // Card 1: Invoice
                FinanceCardWidget(
                  title: 'Invoice',
                  subtitle: 'Manage, create & view invoices',
                  iconData: Icons.receipt_long_outlined,
                  onTap: () => _handleInvoiceTap(context),
                ),
                UIHelper.verticalSpace(16.h),

                // Card 2: Receipts
                FinanceCardWidget(
                  title: 'Receipts',
                  subtitle: 'Track payment receipts & transactions',
                  iconData: Icons.payments_outlined,
                  onTap: () => _handleReceiptsTap(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FinanceCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData iconData;
  final VoidCallback onTap;

  const FinanceCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // Icon in soft orange container
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

            // Title & Subtitle
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

            // Trailing arrow icon
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: textMuted,
            ),
          ],
        ),
      ),
    );
  }
}
