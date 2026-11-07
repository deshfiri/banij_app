import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

class InvoiceItemModel {
  final String invoiceNo;
  final String clientName;
  final String date;
  final String dueDate;
  final String amount;
  final String status; // PAID, PENDING, OVERDUE

  const InvoiceItemModel({
    required this.invoiceNo,
    required this.clientName,
    required this.date,
    required this.dueDate,
    required this.amount,
    required this.status,
  });
}

class ReceiptItemModel {
  final String receiptNo;
  final String gateway;
  final String date;
  final String amount;
  final String status; // VERIFIED

  const ReceiptItemModel({
    required this.receiptNo,
    required this.gateway,
    required this.date,
    required this.amount,
    required this.status,
  });
}

class InvoicesReceiptsSheet extends StatefulWidget {
  final String initialTab; // 'Invoices' or 'Receipts'

  const InvoicesReceiptsSheet({
    super.key,
    this.initialTab = 'Invoices',
  });

  static void show(BuildContext context, {String initialTab = 'Invoices'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => InvoicesReceiptsSheet(initialTab: initialTab),
    );
  }

  @override
  State<InvoicesReceiptsSheet> createState() => _InvoicesReceiptsSheetState();
}

class _InvoicesReceiptsSheetState extends State<InvoicesReceiptsSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const List<InvoiceItemModel> _invoices = [
    InvoiceItemModel(
      invoiceNo: 'INV-2026-0841',
      clientName: 'Considine Supermarket Ltd',
      date: '05 Nov 2026',
      dueDate: '20 Nov 2026',
      amount: '৳ 45,800.00',
      status: 'PENDING',
    ),
    InvoiceItemModel(
      invoiceNo: 'INV-2026-0792',
      clientName: 'Banij Wholesale Mart Dhaka',
      date: '28 Oct 2026',
      dueDate: '12 Nov 2026',
      amount: '৳ 18,200.00',
      status: 'PAID',
    ),
    InvoiceItemModel(
      invoiceNo: 'INV-2026-0650',
      clientName: 'Chittagong Supply Hub',
      date: '15 Oct 2026',
      dueDate: '30 Oct 2026',
      amount: '৳ 32,400.00',
      status: 'OVERDUE',
    ),
  ];

  static const List<ReceiptItemModel> _receipts = [
    ReceiptItemModel(
      receiptNo: 'REC-9942',
      gateway: 'bKash Merchant Payment',
      date: '04 Nov 2026, 04:30 PM',
      amount: '৳ 12,500.00',
      status: 'VERIFIED',
    ),
    ReceiptItemModel(
      receiptNo: 'REC-8831',
      gateway: 'City Bank B2B Transfer',
      date: '29 Oct 2026, 11:15 AM',
      amount: '৳ 35,000.00',
      status: 'VERIFIED',
    ),
    ReceiptItemModel(
      receiptNo: 'REC-7712',
      gateway: 'Nagad Express Merchant',
      date: '20 Oct 2026, 02:45 PM',
      amount: '৳ 8,400.00',
      status: 'VERIFIED',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab == 'Receipts' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
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

  void _handleDownload(BuildContext context, String title, String filename) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 1400), () {
          if (context.mounted) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text('$filename downloaded & saved successfully!'),
                    ),
                  ],
                ),
                backgroundColor: const Color(0xFF10B981),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        });

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          backgroundColor: AppColorsTheme.cardBg(context),
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
            child: Row(
              children: [
                SizedBox(
                  width: 28.w,
                  height: 28.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(primaryOrange),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Downloading $title',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Saving PDF to device storage...',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInvoiceCard(BuildContext context, InvoiceItemModel invoice, bool isDark) {
    final statusColor = _getStatusColor(invoice.status);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Invoice No & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: primaryOrange.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      color: primaryOrange,
                      size: 18.sp,
                    ),
                  ),
                  UIHelper.horizontalSpace(10.w),
                  Text(
                    invoice.invoiceNo,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  invoice.status,
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
          UIHelper.verticalSpace(12.h),

          // Client Business Name
          Text(
            invoice.clientName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(4.h),

          // Dates
          Row(
            children: [
              Text(
                'Issued: ${invoice.date}',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColorsTheme.textMutedColor(context),
                ),
              ),
              UIHelper.horizontalSpace(12.w),
              Text(
                'Due: ${invoice.dueDate}',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(12.h),
          Divider(color: AppColorsTheme.borderColor(context)),
          UIHelper.verticalSpace(10.h),

          // Amount & Download PDF Action Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                invoice.amount,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: primaryOrange,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _handleDownload(context, 'Invoice PDF', '${invoice.invoiceNo}.pdf'),
                icon: Icon(Icons.picture_as_pdf_rounded, size: 14.sp),
                label: Text(
                  'Download PDF',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(BuildContext context, ReceiptItemModel receipt, bool isDark) {
    const statusColor = Color(0xFF10B981);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: AppColorsTheme.borderColor(context),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Receipt No & Verified Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.payments_rounded,
                      color: statusColor,
                      size: 18.sp,
                    ),
                  ),
                  UIHelper.horizontalSpace(10.w),
                  Text(
                    receipt.receiptNo,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  receipt.status,
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
          UIHelper.verticalSpace(12.h),

          // Payment Method Gateway
          Text(
            receipt.gateway,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(4.h),
          Text(
            receipt.date,
            style: TextStyle(
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w500,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
          UIHelper.verticalSpace(12.h),
          Divider(color: AppColorsTheme.borderColor(context)),
          UIHelper.verticalSpace(10.h),

          // Amount & Download Receipt Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                receipt.amount,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: statusColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _handleDownload(context, 'Payment Receipt', '${receipt.receiptNo}.pdf'),
                icon: Icon(Icons.download_rounded, size: 14.sp),
                label: Text(
                  'Download Receipt',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: statusColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredInvoices = _invoices.where((inv) {
      return inv.invoiceNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          inv.clientName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final filteredReceipts = _receipts.where((rec) {
      return rec.receiptNo.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          rec.gateway.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle bar
          UIHelper.verticalSpace(12.h),
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
          UIHelper.verticalSpace(12.h),

          // Sheet Header: Title & Close Button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoices & Receipts',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      'B2B Wholesale Transactions & Billing',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 20.sp,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // Tab Bar Switcher (Invoices & Receipts)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              height: 44.h,
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primaryOrange,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                labelColor: Colors.white,
                unselectedLabelColor: AppColorsTheme.textMutedColor(context),
                labelStyle: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'Invoices'),
                  Tab(text: 'Payment Receipts'),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // Search Input Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: primaryOrange,
                    size: 20.sp,
                  ),
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: TextStyle(
                        fontSize: 13.5.sp,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search invoices or receipts...',
                        hintStyle: TextStyle(
                          fontSize: 13.sp,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Icon(
                        Icons.clear_rounded,
                        size: 18.sp,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // Tab Bar View Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Invoices List Tab
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                  itemCount: filteredInvoices.length,
                  itemBuilder: (context, index) {
                    return _buildInvoiceCard(context, filteredInvoices[index], isDark);
                  },
                ),

                // Receipts List Tab
                ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 6.h),
                  itemCount: filteredReceipts.length,
                  itemBuilder: (context, index) {
                    return _buildReceiptCard(context, filteredReceipts[index], isDark);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
