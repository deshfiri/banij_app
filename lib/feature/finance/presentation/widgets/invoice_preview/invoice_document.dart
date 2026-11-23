import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../constants/image_const.dart';
import '../../../../../helpers/ui_helpers.dart';
import 'preview_strings.dart';

/// Tabular B2B invoice shown in the preview modal.
class InvoiceDocument extends StatelessWidget {
  final PreviewStrings t;
  final String docNo;
  final String date;
  final String client;
  final String amount;
  final String status;
  final Color statusColor;

  const InvoiceDocument({
    super.key,
    required this.t,
    required this.docNo,
    required this.date,
    required this.client,
    required this.amount,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = AppColorsTheme.textMainColor(context);
    final mutedColor = AppColorsTheme.textMutedColor(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: primaryOrange.withValues(alpha: 0.3), width: 1.5.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
            blurRadius: 16.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner: logo + status
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: primaryOrange.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(isDark ? whiteLogo : logo, width: 80.w, height: 28.h, fit: BoxFit.contain),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: statusColor, letterSpacing: 0.5),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // Issuer + invoice meta
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoCard(
                  heading: t('issuer_heading'),
                  children: [
                    Text(
                      t('company_name'),
                      style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: mainColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      t('company_address'),
                      style: TextStyle(fontSize: 9.5.sp, color: mutedColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              UIHelper.horizontalSpace(10.w),
              Expanded(
                child: _InfoCard(
                  heading: 'INVOICE META',
                  children: [
                    Text(
                      '# $docNo',
                      style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: mainColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text('Date: $date', style: TextStyle(fontSize: 9.5.sp, color: mutedColor)),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(12.h),

          // Billed to
          SizedBox(
            width: double.infinity,
            child: _InfoCard(
              heading: t('customer_heading'),
              children: [
                Text(
                  client,
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: mainColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // Items table
          _TableHeader(t: t),
          UIHelper.verticalSpace(4.h),
          _TableRow(desc: t('item_1'), qty: '1 Unit', rate: amount, amount: amount, isAlternate: false),
          _TableRow(desc: t('item_2'), qty: '5 Hrs', rate: '৳ 1,500.00', amount: '৳ 7,500.00', isAlternate: true),
          UIHelper.verticalSpace(14.h),

          // Summary
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.innerCardBg(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColorsTheme.borderColor(context)),
            ),
            child: Column(
              children: [
                _SummaryRow(label: t('subtotal'), value: amount),
                _SummaryRow(label: t('taxable'), value: '৳ 5,200.00'),
                _SummaryRow(label: t('tax_rate'), value: '6.25%'),
                _SummaryRow(label: t('tax_due'), value: '৳ 325.00'),
                Divider(color: AppColorsTheme.borderColor(context), height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      t('total_due'),
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                    ),
                    Text(
                      amount,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Inner card with an orange 9sp heading followed by [children].
class _InfoCard extends StatelessWidget {
  final String heading;
  final List<Widget> children;

  const _InfoCard({required this.heading, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heading, style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: primaryOrange)),
          UIHelper.verticalSpace(2.h),
          ...children,
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final PreviewStrings t;

  const _TableHeader({required this.t});

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.white);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: primaryOrange,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(t('desc'), style: style)),
          Expanded(flex: 2, child: Text(t('qty'), textAlign: TextAlign.center, style: style)),
          Expanded(flex: 2, child: Text(t('rate'), textAlign: TextAlign.right, style: style)),
          Expanded(flex: 3, child: Text(t('amount_col'), textAlign: TextAlign.right, style: style)),
        ],
      ),
    );
  }
}

class _TableRow extends StatelessWidget {
  final String desc;
  final String qty;
  final String rate;
  final String amount;
  final bool isAlternate;

  const _TableRow({
    required this.desc,
    required this.qty,
    required this.rate,
    required this.amount,
    required this.isAlternate,
  });

  @override
  Widget build(BuildContext context) {
    final main = AppColorsTheme.textMainColor(context);
    final muted = AppColorsTheme.textMutedColor(context);
    Widget cell(int flex, String text, TextAlign align, TextStyle style) => Expanded(
          flex: flex,
          child: Text(text, textAlign: align, style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
        );

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isAlternate ? AppColorsTheme.innerCardBg(context).withValues(alpha: 0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(6.r),
        border: Border(bottom: BorderSide(color: AppColorsTheme.borderColor(context).withValues(alpha: 0.4))),
      ),
      child: Row(
        children: [
          cell(5, desc, TextAlign.start, TextStyle(fontSize: 10.sp, color: main)),
          cell(2, qty, TextAlign.center, TextStyle(fontSize: 10.sp, color: muted)),
          cell(2, rate, TextAlign.right, TextStyle(fontSize: 10.sp, color: muted)),
          cell(3, amount, TextAlign.right, TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: main)),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 10.sp, color: AppColorsTheme.textMutedColor(context)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            value,
            style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: AppColorsTheme.textMainColor(context)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
