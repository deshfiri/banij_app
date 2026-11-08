import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../constants/color.dart';
import '../../../../constants/image_const.dart';
import '../../../../helpers/ui_helpers.dart';

class InvoiceReceiptPreviewModal extends StatefulWidget {
  final String title; // 'Invoice' or 'Receipt'
  final String docNo; // e.g. INV-2026-0841 or REC-9942
  final String clientOrGateway; // Client Name or Payment Gateway
  final String date;
  final String dueDateOrTime;
  final String amount;
  final String status; // PAID, PENDING, OVERDUE, VERIFIED
  final bool isInvoice;

  const InvoiceReceiptPreviewModal({
    super.key,
    required this.title,
    required this.docNo,
    required this.clientOrGateway,
    required this.date,
    required this.dueDateOrTime,
    required this.amount,
    required this.status,
    required this.isInvoice,
  });

  static void show(
    BuildContext context, {
    required String title,
    required String docNo,
    required String clientOrGateway,
    required String date,
    required String dueDateOrTime,
    required String amount,
    required String status,
    required bool isInvoice,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoiceReceiptPreviewModal(
        title: title,
        docNo: docNo,
        clientOrGateway: clientOrGateway,
        date: date,
        dueDateOrTime: dueDateOrTime,
        amount: amount,
        status: status,
        isInvoice: isInvoice,
      ),
    );
  }

  @override
  State<InvoiceReceiptPreviewModal> createState() => _InvoiceReceiptPreviewModalState();
}

class _InvoiceReceiptPreviewModalState extends State<InvoiceReceiptPreviewModal> {
  bool _isBengali = false;
  bool _isDownloading = false;

  String _t(String key) {
    const translations = {
      'en': {
        'preview_title': 'Design Preview',
        'invoice_type': 'Official B2B Invoice & Quote',
        'receipt_type': 'Official Money Receipt',
        'company_name': 'Banij B2B Ecosystem Ltd',
        'company_address': 'House 42, Road 11, Banani, Dhaka',
        'money_receipt': 'MONEY RECEIPT',
        'phone': '01700-000000',
        'email': 'support@banij.com.bd',
        'no_label': 'NO.',
        'date_label': 'Date',
        'received_from': 'Received with thanks from',
        'amount_label': 'Amount',
        'in_word': 'In word',
        'amount_in_words_val': 'Forty-Five Thousand Taka Only',
        'for_label': 'For',
        'for_val': 'B2B Wholesale Settlement',
        'branch_label': 'Branch',
        'branch_val': 'Dhaka Main Hub',
        'acct_label': 'ACCT.',
        'acct_val': 'ACC-99',
        'paid_label': 'PAID',
        'due_label': 'DUE',
        'due_val': '৳ 0.00',
        'amount_equals': 'Amount=',
        'received_by': 'Received by',
        'authorized_sig': 'Authorized Sign',
        'company_tagline': 'LOGO HERE TAGLINE',
        'customer_heading': 'BILLED TO / CUSTOMER',
        'issuer_heading': 'ISSUED BY',
        'desc': 'DESCRIPTION',
        'qty': 'QTY',
        'rate': 'RATE',
        'amount_col': 'AMOUNT',
        'item_1': 'Wholesale Supply & Inventory (Batch #1)',
        'item_2': 'Express Dispatch & Logistics Handling',
        'subtotal': 'Subtotal',
        'taxable': 'Taxable Amount',
        'tax_rate': 'Tax Rate (VAT)',
        'tax_due': 'Tax Due',
        'other': 'Other Charges',
        'total_due': 'TOTAL Due',
        'terms_title': 'TERMS AND CONDITIONS',
        'term_1': '1. Customer will be billed after invoice acceptance.',
        'term_2': '2. Payment is due prior to delivery of service and goods.',
        'acceptance': 'Customer Acceptance (sign below):',
        'download': 'Download to Internal Storage',
        'downloading': 'Saving to internal storage...',
        'success_msg': ' successfully saved to internal storage!',
      },
      'bn': {
        'preview_title': 'ডিজাইন প্রিভিউ',
        'invoice_type': 'অফিসিয়াল বিটুবি ইনভয়েস ও কোট',
        'receipt_type': 'অফিসিয়াল মানি রসিদ',
        'company_name': 'বাণিজ বিটুবি ইকোসিস্টেম লিমিটেড',
        'company_address': 'হাউস ৪২, রোড ১১, বনানী, ঢাকা',
        'money_receipt': 'মানি রসিদ',
        'phone': '০১৭১০-০০০০০০',
        'email': 'support@banij.com.bd',
        'no_label': 'নম্বর',
        'date_label': 'তারিখ',
        'received_from': 'ধন্যবাদসহ প্রাপ্তিস্থান',
        'amount_label': 'পরিমাণ',
        'in_word': 'কথায়',
        'amount_in_words_val': 'পঁয়তাল্লিশ হাজার টাকা মাত্র',
        'for_label': 'বাবদ',
        'for_val': 'পাইকারি সরবরাহ সেটেলমেন্ট',
        'branch_label': 'শাখা',
        'branch_val': 'ঢাকা হাব',
        'acct_label': 'অ্যাকাউন্ট',
        'acct_val': 'ACC-99',
        'paid_label': 'পরিশোধিত',
        'due_label': 'বকেয়া',
        'due_val': '৳ ০.০০',
        'amount_equals': 'টাকা=',
        'received_by': 'গ্রহীতা',
        'authorized_sig': 'অনুমোদিত স্বাক্ষর',
        'company_tagline': 'লোগো এখানে ট্যাগলাইন',
        'customer_heading': 'গ্রাহক / বিল প্রাপক',
        'issuer_heading': 'ইস্যুকারী প্রতিষ্ঠান',
        'desc': 'বিবরণ',
        'qty': 'পরিমাণ',
        'rate': 'দর',
        'amount_col': 'টাকা',
        'item_1': 'পাইকারি পণ্য সরবরাহ ও ইনভেন্টরি (ব্যাচ #১)',
        'item_2': 'এক্সপ্রেস ডিসপ্যাচ ও লজিস্টিকস হ্যান্ডলিং',
        'subtotal': 'সাবটোটাল',
        'taxable': 'ট্যাক্সযোগ্য পরিমাণ',
        'tax_rate': 'ট্যাক্স হার (ভ্যাট)',
        'tax_due': 'প্রদেয় ট্যাক্স',
        'other': 'অন্যান্য চার্জ',
        'total_due': 'সর্বমোট প্রদেয়',
        'terms_title': 'শর্তাবলী',
        'term_1': '১. ইনভয়েস গ্রহণের পর গ্রাহককে বিল করা হবে।',
        'term_2': '২. সেবা ও পণ্য সরবরাহের পূর্বে পেমেন্ট পরিশোধ করতে হবে।',
        'acceptance': 'গ্রাহকের স্বীকৃতি (নিচে স্বাক্ষর করুন):',
        'download': 'অভ্যন্তরীণ স্টোরেজে ডাউনলোড করুন',
        'downloading': 'সংরক্ষণ করা হচ্ছে...',
        'success_msg': ' সফলভাবে অভ্যন্তরীণ স্টোরেজে সংরক্ষিত হয়েছে!',
      },
    };

    return translations[_isBengali ? 'bn' : 'en']?[key] ?? key;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PAID':
      case 'VERIFIED':
        return const Color(0xFF10B981);
      case 'PENDING':
        return primaryOrange;
      case 'OVERDUE':
        return const Color(0xFFEF4444);
      default:
        return primaryOrange;
    }
  }

  Future<void> _downloadToInternalStorage(BuildContext context) async {
    setState(() {
      _isDownloading = true;
    });

    try {
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getDownloadsDirectory();
        directory ??= Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          try {
            await directory.create(recursive: true);
          } catch (_) {
            directory = await getExternalStorageDirectory();
          }
        }
      } else {
        directory = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      directory ??= await getApplicationDocumentsDirectory();

      final fileName = '${widget.docNo}.txt';
      final file = File('${directory.path}/$fileName');

      final content = '''
=============================================
${widget.isInvoice ? _t('invoice_type') : _t('money_receipt')}
=============================================
Document No: ${widget.docNo}
Date: ${widget.date}
Client/Gateway: ${widget.clientOrGateway}
Amount: ${widget.amount}
Status: ${widget.status}
---------------------------------------------
Saved to Phone Storage: ${file.path}
=============================================
''';

      await file.writeAsString(content);
      await Future.delayed(const Duration(milliseconds: 1000));

      if (context.mounted) {
        setState(() {
          _isDownloading = false;
        });
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'Saved to Phone Storage!\nPath: ${file.path}',
                    style: TextStyle(fontSize: 11.sp),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        setState(() {
          _isDownloading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor(widget.status);

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 25.r,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          UIHelper.verticalSpace(10.h),
          Center(
            child: Container(
              width: 42.w,
              height: 4.5.h,
              decoration: BoxDecoration(
                color: AppColorsTheme.textMutedColor(context).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          UIHelper.verticalSpace(8.h),

          // Header Bar: Title, Language Switcher, Download Icon & Close Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(
                          widget.isInvoice ? Icons.receipt_long_rounded : Icons.payments_rounded,
                          color: primaryOrange,
                          size: 18.sp,
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('preview_title'),
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w900,
                                color: AppColorsTheme.textMainColor(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              widget.isInvoice ? _t('invoice_type') : _t('receipt_type'),
                              style: TextStyle(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Language Toggle Button (EN / বাংলা)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isBengali = !_isBengali;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: primaryOrange.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: primaryOrange.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          _isBengali ? 'EN' : 'বাংলা',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w900,
                            color: primaryOrange,
                          ),
                        ),
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    // Download Icon Button
                    IconButton(
                      onPressed: _isDownloading ? null : () => _downloadToInternalStorage(context),
                      icon: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: primaryOrange,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.download_rounded,
                          size: 18.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Close Button
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: AppColorsTheme.cardBg(context),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColorsTheme.borderColor(context)),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 18.sp,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(8.h),
          Divider(color: AppColorsTheme.borderColor(context)),

          // Body: Conditionally renders Professional Tabular Invoice or Authentic Money Receipt Layout
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: widget.isInvoice
                  ? _buildInvoiceLayout(context, isDark, statusColor)
                  : _buildMoneyReceiptLayout(context, isDark, statusColor),
            ),
          ),

          // Bottom Action Button: Download to Internal Storage
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 20.h),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              border: Border(top: BorderSide(color: AppColorsTheme.borderColor(context))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton.icon(
                onPressed: _isDownloading ? null : () => _downloadToInternalStorage(context),
                icon: _isDownloading
                    ? SizedBox(
                        width: 18.w,
                        height: 18.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.download_rounded, size: 18.sp),
                label: Text(
                  _isDownloading ? _t('downloading') : _t('download'),
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Authentic Money Receipt Layout (Fully Responsive, Overflow-Free)
  Widget _buildMoneyReceiptLayout(BuildContext context, bool isDark, Color statusColor) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: primaryOrange.withValues(alpha: 0.5),
          width: 2.w,
        ),
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
          // Top Header Banner
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14.r),
                topRight: Radius.circular(14.r),
              ),
              border: Border(
                bottom: BorderSide(color: primaryOrange, width: 2.w),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Image.asset(
                        isDark ? whiteLogo : logo,
                        width: 36.w,
                        height: 26.h,
                        fit: BoxFit.contain,
                      ),
                      UIHelper.horizontalSpace(4.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('company_name'),
                              style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w900, color: AppColorsTheme.textMainColor(context)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              _t('company_tagline'),
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
                        _t('money_receipt'),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: AppColorsTheme.textMainColor(context), letterSpacing: 0.5),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      UIHelper.verticalSpace(2.h),
                      Text(
                        '${_t('phone')} | ${_t('email')}',
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
                        _t('company_name'),
                        textAlign: TextAlign.right,
                        style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        widget.date,
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
          ),

          // Receipt Number & Date Row
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        _t('no_label'),
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      UIHelper.horizontalSpace(4.w),
                      Expanded(
                        child: Text(
                          widget.docNo,
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
                      Text(
                        '${_t('date_label')}: ',
                        style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                      ),
                      Expanded(
                        child: Text(
                          widget.date,
                          style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w700, color: AppColorsTheme.textMainColor(context)),
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
          ),
          Divider(color: AppColorsTheme.borderColor(context), height: 1.h),

          // Receipt Body Fields
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReceiptLineField(context, label: '${_t('received_from')}:', value: widget.clientOrGateway, valueColor: primaryOrange),
                UIHelper.verticalSpace(10.h),
                _buildReceiptLineField(context, label: '${_t('amount_label')}:', value: widget.amount, valueColor: statusColor),
                UIHelper.verticalSpace(10.h),
                _buildReceiptLineField(context, label: '${_t('in_word')}:', value: _t('amount_in_words_val')),
                UIHelper.verticalSpace(10.h),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildReceiptLineField(context, label: '${_t('for_label')}:', value: _t('for_val')),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      flex: 2,
                      child: _buildReceiptLineField(context, label: '${_t('branch_label')}:', value: _t('branch_val')),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(10.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildReceiptLineField(context, label: _t('acct_label'), value: _t('acct_val')),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    Expanded(
                      child: _buildReceiptLineField(context, label: _t('paid_label'), value: widget.amount),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    Expanded(
                      child: _buildReceiptLineField(context, label: _t('due_label'), value: _t('due_val')),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(16.h),

                // Bottom Row: Amount Box, Received By, Authorized Signature
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t('amount_equals'),
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
                              widget.amount,
                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    Expanded(
                      flex: 4,
                      child: Column(
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
                            _t('received_by'),
                            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    Expanded(
                      flex: 4,
                      child: Column(
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
                            _t('authorized_sig'),
                            style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Bottom Footer Banner
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

  Widget _buildReceiptLineField(BuildContext context, {required String label, required String value, Color? valueColor}) {
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

  // Highly Perfect, Attractive, and User-Friendly Tabular Invoice Layout
  Widget _buildInvoiceLayout(BuildContext context, bool isDark, Color statusColor) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: primaryOrange.withValues(alpha: 0.3),
          width: 1.5.w,
        ),
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
          // Top Invoice Header Banner (Orange Accent Card)
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
                    Image.asset(
                      isDark ? whiteLogo : logo,
                      width: 80.w,
                      height: 28.h,
                      fit: BoxFit.contain,
                    ),
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
                    widget.status,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w900,
                      color: statusColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // Issuer & Invoice Meta Info Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Issuer Card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.innerCardBg(context),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _t('issuer_heading'),
                        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                      ),
                      UIHelper.verticalSpace(2.h),
                      Text(
                        _t('company_name'),
                        style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _t('company_address'),
                        style: TextStyle(fontSize: 9.5.sp, color: AppColorsTheme.textMutedColor(context)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              UIHelper.horizontalSpace(10.w),
              // Meta Card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.innerCardBg(context),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INVOICE META',
                        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                      ),
                      UIHelper.verticalSpace(2.h),
                      Text(
                        '# ${widget.docNo}',
                        style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Date: ${widget.date}',
                        style: TextStyle(fontSize: 9.5.sp, color: AppColorsTheme.textMutedColor(context)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(12.h),

          // Client / Billed To Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.innerCardBg(context),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('customer_heading'),
                  style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  widget.clientOrGateway,
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // Itemized Table Header
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: primaryOrange,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                Expanded(flex: 5, child: Text(_t('desc'), style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text(_t('qty'), textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 2, child: Text(_t('rate'), textAlign: TextAlign.right, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.white))),
                Expanded(flex: 3, child: Text(_t('amount_col'), textAlign: TextAlign.right, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.bold, color: Colors.white))),
              ],
            ),
          ),
          UIHelper.verticalSpace(4.h),
          _buildInvoiceTableRow(context, _t('item_1'), '1 Unit', widget.amount, widget.amount, isAlternate: false),
          _buildInvoiceTableRow(context, _t('item_2'), '5 Hrs', '৳ 1,500.00', '৳ 7,500.00', isAlternate: true),
          UIHelper.verticalSpace(14.h),

          // Summary Card
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.innerCardBg(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColorsTheme.borderColor(context)),
            ),
            child: Column(
              children: [
                _buildSummaryRow(context, _t('subtotal'), widget.amount),
                _buildSummaryRow(context, _t('taxable'), '৳ 5,200.00'),
                _buildSummaryRow(context, _t('tax_rate'), '6.25%'),
                _buildSummaryRow(context, _t('tax_due'), '৳ 325.00'),
                Divider(color: AppColorsTheme.borderColor(context), height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _t('total_due'),
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                    ),
                    Text(
                      widget.amount,
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

  Widget _buildInvoiceTableRow(BuildContext context, String desc, String qty, String rate, String amount, {required bool isAlternate}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isAlternate ? AppColorsTheme.innerCardBg(context).withValues(alpha: 0.5) : Colors.transparent,
        borderRadius: BorderRadius.circular(6.r),
        border: Border(bottom: BorderSide(color: AppColorsTheme.borderColor(context).withValues(alpha: 0.4))),
      ),
      child: Row(
        children: [
          Expanded(flex: 5, child: Text(desc, style: TextStyle(fontSize: 10.sp, color: AppColorsTheme.textMainColor(context)), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(qty, textAlign: TextAlign.center, style: TextStyle(fontSize: 10.sp, color: AppColorsTheme.textMutedColor(context)), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 2, child: Text(rate, textAlign: TextAlign.right, style: TextStyle(fontSize: 10.sp, color: AppColorsTheme.textMutedColor(context)), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Expanded(flex: 3, child: Text(amount, textAlign: TextAlign.right, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)), maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 10.sp, color: AppColorsTheme.textMutedColor(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(value, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: AppColorsTheme.textMainColor(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
