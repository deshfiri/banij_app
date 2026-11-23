import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/invoice_provider.dart';
import '../data/invoice_pdf_service.dart';
import '../model/invoice_detail_model.dart';
import '../model/invoice_list_model.dart';
import 'widgets/finance_shared/finance_widgets.dart';
import 'invoice_pdf_preview_screen.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final InvoiceItemModel invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  static Future<void> open(
    BuildContext context, {
    required InvoiceItemModel invoice,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => InvoiceDetailsScreen(invoice: invoice)),
    );
  }

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  bool _isDownloading = false;
  bool _isPrinting = false;

  String get _invoiceId => widget.invoice.id?.trim() ?? '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<InvoiceProvider>().fetchInvoiceDetail(_invoiceId);
      }
    });
  }

  Future<void> _downloadPdf(InvoiceDetailModel invoice) async {
    if (_isDownloading || _isPrinting) return;
    setState(() => _isDownloading = true);
    try {
      final file = await InvoicePdfService.saveToDevice(invoice);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invoice PDF saved to ${file.path}')),
      );
    } catch (error, stackTrace) {
      debugPrint('Invoice PDF download failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save invoice PDF: $error')),
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _printPdf(InvoiceDetailModel invoice) async {
    if (_isDownloading || _isPrinting) return;
    setState(() => _isPrinting = true);
    try {
      await Printing.layoutPdf(
        name: InvoicePdfService.fileName(invoice),
        onLayout: (format) =>
            InvoicePdfService.generate(invoice, format: format),
      );
    } catch (error, stackTrace) {
      debugPrint('Invoice PDF printing failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not print invoice PDF: $error')),
      );
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final detail = provider.invoiceDetailFor(_invoiceId);
    final error = provider.invoiceDetailErrorFor(_invoiceId);
    final isLoading = provider.isLoadingInvoiceDetail(_invoiceId);
    final invoice = detail?.withListSummary(widget.invoice);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Invoice Details',
              subtitle: widget.invoice.number ?? 'Invoice information',
            ),
            Expanded(
              child: SafeArea(
                top: false,
                child: _buildBody(
                  isLoading: isLoading,
                  error: error,
                  invoice: invoice,
                  onRetry: () =>
                      provider.fetchInvoiceDetail(_invoiceId, force: true),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: invoice == null ? null : _buildActionBar(invoice),
      ),
    );
  }

  Widget _buildActionBar(InvoiceDetailModel invoice) {
    final isBusy = _isDownloading || _isPrinting;
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    );

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 8.h),
        decoration: BoxDecoration(
          color: AppColorsTheme.cardBg(context),
          border: Border(
            top: BorderSide(color: AppColorsTheme.borderColor(context)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isBusy
                    ? null
                    : () => InvoicePdfPreviewScreen.open(
                        context,
                        invoice: invoice,
                      ),
                icon: Icon(Icons.picture_as_pdf_outlined, size: 15.sp),
                label: Text('Preview', style: TextStyle(fontSize: 10.sp)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryOrange,
                  side: BorderSide(color: primaryOrange.withValues(alpha: 0.6)),
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  shape: buttonShape,
                ),
              ),
            ),
            UIHelper.horizontalSpace(8.w),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: isBusy ? null : () => _printPdf(invoice),
                icon: _isPrinting
                    ? SizedBox(
                        width: 14.w,
                        height: 14.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(Icons.print_outlined, size: 15.sp),
                label: Text('Print', style: TextStyle(fontSize: 10.sp)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryOrange,
                  side: BorderSide(color: primaryOrange.withValues(alpha: 0.6)),
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  shape: buttonShape,
                ),
              ),
            ),
            UIHelper.horizontalSpace(8.w),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: isBusy ? null : () => _downloadPdf(invoice),
                icon: _isDownloading
                    ? SizedBox(
                        width: 14.w,
                        height: 14.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.download_rounded, size: 15.sp),
                label: Text('Download', style: TextStyle(fontSize: 10.sp)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 11.h),
                  shape: buttonShape,
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required String? error,
    required InvoiceDetailModel? invoice,
    required VoidCallback onRetry,
  }) {
    if (invoice == null && isLoading) {
      return Center(child: CircularProgressIndicator(color: primaryOrange));
    }
    if (invoice == null && error != null) {
      return _buildError(error, onRetry);
    }
    if (invoice == null) {
      return _buildError('Invoice details are unavailable', onRetry);
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 28.h),
      children: [
        if (error != null) ...[
          _buildInlineError(error, onRetry),
          UIHelper.verticalSpace(12.h),
        ],
        _buildSummaryCard(invoice),
        UIHelper.verticalSpace(16.h),
        _buildDetailsCard(invoice),
        if (invoice.items.isNotEmpty) ...[
          UIHelper.verticalSpace(16.h),
          _buildItemsCard(invoice.items),
        ],
      ],
    );
  }

  Widget _buildSummaryCard(InvoiceDetailModel invoice) {
    final statusColor = financeStatusColor(invoice.displayStatus.toUpperCase());
    final gradient = AppColorsTheme.heroGradient(context);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.18),
            blurRadius: 16.r,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 21.sp,
                ),
              ),
              UIHelper.horizontalSpace(10.w),
              Expanded(
                child: Text(
                  invoice.displayNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Text(
                  invoice.displayStatus.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 9.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(22.h),
          Text(
            'TOTAL AMOUNT',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          UIHelper.verticalSpace(3.h),
          Text(
            invoice.displayTotal,
            style: TextStyle(
              color: Colors.white,
              fontSize: 27.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (invoice.displayPurpose != '—') ...[
            UIHelper.verticalSpace(5.h),
            Text(
              invoice.displayPurpose,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailsCard(InvoiceDetailModel invoice) {
    final rows = <(String, String)>[
      ('Invoice number', invoice.displayNumber),
      if (invoice.displayCustomer != '—') ('Customer', invoice.displayCustomer),
      if (invoice.displayPurpose != '—') ('Purpose', invoice.displayPurpose),
      ('Issued date', invoice.issuedDateLabel),
      if (invoice.dueDateLabel != '—') ('Due date', invoice.dueDateLabel),
      ('Payment status', invoice.displayStatus),
      if (invoice.displayPaymentReference != '—')
        ('Payment reference', invoice.displayPaymentReference),
      if (invoice.paidDateLabel != '—') ('Paid date', invoice.paidDateLabel),
    ];

    return _sectionCard(
      title: 'Invoice information',
      icon: Icons.description_outlined,
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            _detailRow(rows[index].$1, rows[index].$2),
            if (index != rows.length - 1)
              Divider(height: 18.h, color: AppColorsTheme.borderColor(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard(List<InvoiceDetailLineModel> items) {
    return _sectionCard(
      title: 'Invoice items',
      icon: Icons.inventory_2_outlined,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _buildItemRow(items[index]),
            if (index != items.length - 1)
              Divider(height: 18.h, color: AppColorsTheme.borderColor(context)),
          ],
        ],
      ),
    );
  }

  Widget _buildItemRow(InvoiceDetailLineModel item) {
    final metadata = <String>[
      if (item.quantity?.isNotEmpty == true) 'Qty ${item.quantity}',
      if (item.rate?.isNotEmpty == true) 'Rate ${item.rate}',
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.description?.isNotEmpty == true
                    ? item.description!
                    : 'Invoice item',
                style: TextStyle(
                  color: AppColorsTheme.textMainColor(context),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (metadata.isNotEmpty) ...[
                UIHelper.verticalSpace(4.h),
                Text(
                  metadata.join('  •  '),
                  style: TextStyle(
                    color: AppColorsTheme.textMutedColor(context),
                    fontSize: 10.5.sp,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (item.amount?.isNotEmpty == true)
          Text(
            item.amount!,
            style: TextStyle(
              color: AppColorsTheme.textMainColor(context),
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
      ],
    );
  }

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: primaryOrange),
              UIHelper.horizontalSpace(8.w),
              Text(
                title,
                style: TextStyle(
                  color: AppColorsTheme.textMainColor(context),
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          child,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    final statusColor = label == 'Payment status'
        ? financeStatusColor(value.toUpperCase())
        : AppColorsTheme.textMainColor(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColorsTheme.textMutedColor(context),
              fontSize: 11.5.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: statusColor,
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 42.sp,
              color: AppColorsTheme.textMutedColor(context),
            ),
            UIHelper.verticalSpace(10.h),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColorsTheme.textMutedColor(context),
                fontSize: 13.sp,
              ),
            ),
            UIHelper.verticalSpace(6.h),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError(String error, VoidCallback onRetry) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AppColorsTheme.textMutedColor(context),
                fontSize: 11.sp,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
