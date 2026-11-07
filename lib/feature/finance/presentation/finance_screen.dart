import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common_widget/finance_card_widget.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import 'widgets/invoices_receipts_sheet.dart';

class FinanceScreenBody extends StatelessWidget {
  const FinanceScreenBody({super.key});

  void _handleInvoiceTap(BuildContext context) {
    InvoicesReceiptsSheet.show(context, initialTab: 'Invoices');
  }

  void _handleReceiptsTap(BuildContext context) {
    InvoicesReceiptsSheet.show(context, initialTab: 'Receipts');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColorsTheme.background(context),
      child: Column(
        children: [
          // Finance Header / AppBar
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              border: Border(
                bottom: BorderSide(color: AppColorsTheme.borderColor(context), width: 1.w),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: Text(
                  'finance'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
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
                    'financial_management'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(6.h),
                  Text(
                    'financial_subtitle'.tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),

                  // Card 1: Invoice
                  FinanceCardWidget(
                    title: 'invoice'.tr,
                    subtitle: 'invoice_subtitle'.tr,
                    iconData: Icons.receipt_long_outlined,
                    onTap: () => _handleInvoiceTap(context),
                  ),
                  UIHelper.verticalSpace(16.h),

                  // Card 2: Receipts
                  FinanceCardWidget(
                    title: 'receipts'.tr,
                    subtitle: 'receipts_subtitle'.tr,
                    iconData: Icons.payments_outlined,
                    onTap: () => _handleReceiptsTap(context),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
