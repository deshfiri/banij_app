import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../constants/image_const.dart';
import '../../../../../helpers/ui_helpers.dart';
import 'preview_strings.dart';

/// Classic money-receipt layout shown in the preview modal.
class MoneyReceiptDocument extends StatelessWidget {
  final PreviewStrings t;
  final String docNo;
  final String date;
  final String receivedFrom;
  final String amount;
  final Color statusColor;

  const MoneyReceiptDocument({
    super.key,
    required this.t,
    required this.docNo,
    required this.date,
    required this.receivedFrom,
    required this.amount,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: primaryOrange.withValues(alpha: 0.5), width: 2.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ReceiptBanner(t: t, date: date),
          _NumberDateRow(t: t, docNo: docNo, date: date),
          Divider(color: AppColorsTheme.borderColor(context), height: 1.h),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ReceiptLineField(label: '${t('received_from')}:', value: receivedFrom, valueColor: primaryOrange),
                UIHelper.verticalSpace(10.h),
                ReceiptLineField(label: '${t('amount_label')}:', value: amount, valueColor: statusColor),
                UIHelper.verticalSpace(10.h),
                ReceiptLineField(label: '${t('in_word')}:', value: t('amount_in_words_val')),
                UIHelper.verticalSpace(10.h),
                Row(
                  children: [
                    Expanded(flex: 3, child: ReceiptLineField(label: '${t('for_label')}:', value: t('for_val'))),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(flex: 2, child: ReceiptLineField(label: '${t('branch_label')}:', value: t('branch_val'))),
                  ],
                ),
                UIHelper.verticalSpace(10.h),
                Row(
                  children: [
                    Expanded(child: ReceiptLineField(label: t('acct_label'), value: t('acct_val'))),
                    UIHelper.horizontalSpace(8.w),
                    Expanded(child: ReceiptLineField(label: t('paid_label'), value: amount)),
                    UIHelper.horizontalSpace(8.w),
                    Expanded(child: ReceiptLineField(label: t('due_label'), value: t('due_val'))),
                  ],
                ),
                UIHelper.verticalSpace(16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(flex: 3, child: _AmountBox(label: t('amount_equals'), amount: amount)),
                    UIHelper.horizontalSpace(8.w),
                    Expanded(flex: 4, child: _SignatureLine(label: t('received_by'))),
                    UIHelper.horizontalSpace(8.w),
                    Expanded(flex: 4, child: _SignatureLine(label: t('authorized_sig'))),
                  ],
                ),
              ],
            ),
          ),
          // Bottom footer band
          Container(
            height: 10.h,
            decoration: BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(14.r),
                bottomRight: Radius.circular(14.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Label: ____value____" line with a muted underline.
class ReceiptLineField extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const ReceiptLineField({super.key, required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        UIHelper.horizontalSpace(4.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(bottom: 2.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppColorsTheme.textMutedColor(context).withValues(alpha: 0.4),
                  width: 1.w,
                  style: BorderStyle.solid,
                ),
              ),
            ),
            child: Text(
              ' $value',
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: valueColor ?? AppColorsTheme.textMainColor(context),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

/// Orange-tinted top band: logo + company, "MONEY RECEIPT", company + date.
class _ReceiptBanner extends StatelessWidget {
  final PreviewStrings t;
  final String date;

  const _ReceiptBanner({required this.t, required this.date});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = AppColorsTheme.textMainColor(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(14.r),
          topRight: Radius.circular(14.r),
        ),
        border: Border(bottom: BorderSide(color: primaryOrange, width: 2.w)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Image.asset(isDark ? whiteLogo : logo, width: 36.w, height: 26.h, fit: BoxFit.contain),
                UIHelper.horizontalSpace(4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('company_name'),
                        style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w900, color: mainColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        t('company_tagline'),
                        style: TextStyle(fontSize: 7.5.sp, fontWeight: FontWeight.w600, color: primaryOrange),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                Text(
                  t('money_receipt'),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: mainColor, letterSpacing: 0.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  '${t('phone')} | ${t('email')}',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 7.5.sp, color: AppColorsTheme.textMutedColor(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  t('company_name'),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold, color: mainColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  date,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w700, color: primaryOrange),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "NO. <docNo>" on the left, "Date: <date>" on the right.
class _NumberDateRow extends StatelessWidget {
  final PreviewStrings t;
  final String docNo;
  final String date;

  const _NumberDateRow({required this.t, required this.docNo, required this.date});

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColorsTheme.textMainColor(context);
    final labelStyle = TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: mainColor);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Text(t('no_label'), style: labelStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                UIHelper.horizontalSpace(4.w),
                Expanded(
                  child: Text(
                    docNo,
                    style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('${t('date_label')}: ', style: labelStyle),
                Expanded(
                  child: Text(
                    date,
                    style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: mainColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "Amount=" label above an orange-bordered amount box.
class _AmountBox extends StatelessWidget {
  final String label;
  final String amount;

  const _AmountBox({required this.label, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w900, color: AppColorsTheme.textMainColor(context)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        UIHelper.verticalSpace(4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            border: Border.all(color: primaryOrange, width: 1.5.w),
            borderRadius: BorderRadius.circular(8.r),
            color: AppColorsTheme.innerCardBg(context),
          ),
          child: Text(
            amount,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: primaryOrange),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Dashed signature line above a caption ("Received by", "Authorized Sign").
class _SignatureLine extends StatelessWidget {
  final String label;

  const _SignatureLine({required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '---------------------',
          style: TextStyle(color: AppColorsTheme.textMutedColor(context)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        UIHelper.verticalSpace(2.h),
        Text(
          label,
          style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
