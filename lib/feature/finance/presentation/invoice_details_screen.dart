import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../providers/invoice_provider.dart';
import '../data/invoice_pdf_service.dart';
import '../model/invoice_detail_model.dart';
import '../model/invoice_list_model.dart';
import 'invoice_pdf_preview_screen.dart';
import 'widgets/finance_shared/finance_widgets.dart';

/// Widths (logical px) where the layout changes.
const double _kWideBreakpoint = 720;
const double _kCompactBreakpoint = 360;
const double _kMaxContentWidth = 1080;

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
  bool _isSharing = false;

  bool get _isBusy => _isDownloading || _isPrinting || _isSharing;

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

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  Future<void> _downloadPdf(InvoiceDetailModel invoice) async {
    if (_isBusy) return;
    setState(() => _isDownloading = true);
    try {
      final saved = await InvoicePdfService.saveToDevice(invoice);
      if (!mounted) return;
      HapticFeedback.mediumImpact();
      await _showDownloadedSheet(saved);
    } catch (error, stackTrace) {
      debugPrint('Invoice PDF download failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage(
        error is InvoiceDownloadException
            ? error.message
            : 'Could not save the invoice PDF. Please try again.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _printPdf(InvoiceDetailModel invoice) async {
    if (_isBusy) return;
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
      _showMessage('Could not print the invoice. Please try again.',
          isError: true);
    } finally {
      if (mounted) setState(() => _isPrinting = false);
    }
  }

  Future<void> _sharePdf(InvoiceDetailModel invoice) async {
    if (_isBusy) return;
    setState(() => _isSharing = true);
    try {
      final bytes = await InvoicePdfService.generate(invoice);
      await Printing.sharePdf(
        bytes: bytes,
        filename: InvoicePdfService.fileName(invoice),
      );
    } catch (error, stackTrace) {
      debugPrint('Invoice PDF sharing failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      _showMessage('Could not share the invoice. Please try again.',
          isError: true);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  Future<void> _openSaved(SavedInvoicePdf saved) async {
    try {
      await InvoicePdfService.openSaved(saved);
    } catch (error) {
      debugPrint('Opening invoice PDF failed: $error');
      _showMessage('No app found to open PDF files.', isError: true);
    }
  }

  void _copy(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    HapticFeedback.selectionClick();
    _showMessage('$label copied');
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError ? const Color(0xFFEF4444) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          content: Text(message),
        ),
      );
  }

  Future<void> _showDownloadedSheet(SavedInvoicePdf saved) {
    const success = Color(0xFF10B981);
    return showFinanceSheet<void>(
      context,
      builder: (sheetContext) => SafeArea(
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColorsTheme.borderColor(context),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                  UIHelper.verticalSpace(20.h),
                  Container(
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: success.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.download_done_rounded,
                        color: success, size: 32.sp),
                  ),
                  UIHelper.verticalSpace(14.h),
                  Text(
                    'Invoice downloaded',
                    style: TextStyle(
                      color: AppColorsTheme.textMainColor(context),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  UIHelper.verticalSpace(6.h),
                  Text(
                    'Saved to your phone storage',
                    style: TextStyle(
                      color: AppColorsTheme.textMutedColor(context),
                      fontSize: 12.sp,
                    ),
                  ),
                  UIHelper.verticalSpace(14.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.innerCardBg(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: AppColorsTheme.borderColor(context),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.folder_rounded,
                            color: primaryOrange, size: 20.sp),
                        UIHelper.horizontalSpace(10.w),
                        Expanded(
                          child: Text(
                            saved.location,
                            style: TextStyle(
                              color: AppColorsTheme.textMainColor(context),
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  UIHelper.verticalSpace(18.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          style: _outlinedStyle(),
                          child: Text('Close',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ),
                      UIHelper.horizontalSpace(10.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _openSaved(saved);
                          },
                          icon: Icon(Icons.open_in_new_rounded, size: 17.sp),
                          label: Text('Open PDF',
                              style: TextStyle(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w700)),
                          style: _filledStyle(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Layout
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final detail = provider.invoiceDetailFor(_invoiceId);
    final error = provider.invoiceDetailErrorFor(_invoiceId);
    final isLoading = provider.isLoadingInvoiceDetail(_invoiceId);
    final invoice = detail?.withListSummary(widget.invoice);

    Future<void> refresh() =>
        provider.fetchInvoiceDetail(_invoiceId, force: true);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'Invoice Details',
              subtitle: widget.invoice.number ?? 'Invoice information',
              trailing: invoice == null
                  ? null
                  : HeroIconButton(
                      icon: Icons.ios_share_rounded,
                      onTap: () => _sharePdf(invoice),
                    ),
            ),
            Expanded(
              child: SafeArea(
                top: false,
                bottom: invoice == null,
                child: _buildBody(
                  isLoading: isLoading,
                  error: error,
                  invoice: invoice,
                  onRefresh: refresh,
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: invoice == null ? null : _buildActionBar(invoice),
      ),
    );
  }

  Widget _buildBody({
    required bool isLoading,
    required String? error,
    required InvoiceDetailModel? invoice,
    required Future<void> Function() onRefresh,
  }) {
    if (invoice == null && isLoading) return const _InvoiceDetailsSkeleton();
    if (invoice == null) {
      return _buildError(error ?? 'Invoice details are unavailable', onRefresh);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = math.min(constraints.maxWidth, _kMaxContentWidth);
        final isWide = width >= _kWideBreakpoint;
        final gap = isWide ? 20.0 : 14.h;
        final hPadding = isWide ? 24.0 : 16.w;

        final summary = _SummaryCard(invoice: invoice, onCopy: _copy);
        final info = _buildInformationCard(invoice);
        final payment = _buildPaymentCard(invoice);
        final items = invoice.items.isEmpty ? null : _buildItemsCard(invoice);

        final Widget content;
        if (isWide) {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(children: [summary, SizedBox(height: gap), payment]),
              ),
              SizedBox(width: gap),
              Expanded(
                flex: 6,
                child: Column(
                  children: [
                    info,
                    if (items != null) ...[SizedBox(height: gap), items],
                  ],
                ),
              ),
            ],
          );
        } else {
          content = Column(
            children: [
              summary,
              SizedBox(height: gap),
              info,
              SizedBox(height: gap),
              payment,
              if (items != null) ...[SizedBox(height: gap), items],
            ],
          );
        }

        return RefreshIndicator(
          color: primaryOrange,
          onRefresh: onRefresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPadding, 18.h, hPadding, 24.h),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
                  child: Column(
                    children: [
                      if (error != null) ...[
                        _buildInlineError(error, onRefresh),
                        SizedBox(height: gap),
                      ],
                      content,
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInformationCard(InvoiceDetailModel invoice) {
    return _SectionCard(
      title: 'Invoice information',
      icon: Icons.description_outlined,
      children: [
        _DetailRow(
          icon: Icons.tag_rounded,
          label: 'Invoice number',
          value: invoice.displayNumber,
          onCopy: () => _copy('Invoice number', invoice.displayNumber),
        ),
        if (invoice.displayCustomer != '—')
          _DetailRow(
            icon: Icons.person_outline_rounded,
            label: 'Billed to',
            value: invoice.displayCustomer,
          ),
        if (invoice.displayPurpose != '—')
          _DetailRow(
            icon: Icons.category_outlined,
            label: 'Purpose',
            value: invoice.displayPurpose,
          ),
        _DetailRow(
          icon: Icons.event_outlined,
          label: 'Issued date',
          value: invoice.issuedDateLabel,
        ),
        if (invoice.dueDateLabel != '—')
          _DetailRow(
            icon: Icons.event_busy_outlined,
            label: 'Due date',
            value: invoice.dueDateLabel,
          ),
      ],
    );
  }

  Widget _buildPaymentCard(InvoiceDetailModel invoice) {
    final status = invoice.displayStatus;
    return _SectionCard(
      title: 'Payment',
      icon: Icons.account_balance_wallet_outlined,
      children: [
        _DetailRow(
          icon: Icons.verified_outlined,
          label: 'Status',
          valueWidget: _StatusPill(status: status),
        ),
        _DetailRow(
          icon: Icons.payments_outlined,
          label: 'Amount',
          value: invoice.displayTotal,
          emphasize: true,
        ),
        if (invoice.displayPaymentReference != '—')
          _DetailRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Reference',
            value: invoice.displayPaymentReference,
            onCopy: () =>
                _copy('Payment reference', invoice.displayPaymentReference),
          ),
        if (invoice.paidDateLabel != '—')
          _DetailRow(
            icon: Icons.event_available_outlined,
            label: 'Paid date',
            value: invoice.paidDateLabel,
          ),
      ],
    );
  }

  Widget _buildItemsCard(InvoiceDetailModel invoice) {
    final items = invoice.items;
    return _SectionCard(
      title: 'Invoice items',
      icon: Icons.inventory_2_outlined,
      trailing: _CountBadge(count: items.length),
      children: [
        for (var i = 0; i < items.length; i++)
          _ItemRow(index: i + 1, item: items[i]),
        _TotalRow(total: invoice.displayTotal),
      ],
    );
  }

  Widget _buildActionBar(InvoiceDetailModel invoice) {
    return Material(
      color: AppColorsTheme.cardBg(context),
      elevation: 12,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < _kCompactBreakpoint;
                return Padding(
                  padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
                  child: Row(
                    children: [
                      _SecondaryAction(
                        compact: compact,
                        icon: Icons.visibility_outlined,
                        label: 'Preview',
                        onPressed: _isBusy
                            ? null
                            : () => InvoicePdfPreviewScreen.open(
                                  context,
                                  invoice: invoice,
                                ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      _SecondaryAction(
                        compact: compact,
                        icon: Icons.print_outlined,
                        label: 'Print',
                        isLoading: _isPrinting,
                        onPressed: _isBusy ? null : () => _printPdf(invoice),
                      ),
                      UIHelper.horizontalSpace(10.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _isBusy ? null : () => _downloadPdf(invoice),
                          icon: _isDownloading
                              ? SizedBox.square(
                                  dimension: 16.sp,
                                  child: const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Icon(Icons.download_rounded, size: 18.sp),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _isDownloading ? 'Saving…' : 'Download PDF',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          style: _filledStyle(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  ButtonStyle _filledStyle() => ElevatedButton.styleFrom(
        backgroundColor: primaryOrange,
        foregroundColor: Colors.white,
        disabledBackgroundColor: primaryOrange.withValues(alpha: 0.55),
        disabledForegroundColor: Colors.white,
        minimumSize: Size(0, 48.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        elevation: 0,
      );

  ButtonStyle _outlinedStyle() => OutlinedButton.styleFrom(
        foregroundColor: primaryOrange,
        side: BorderSide(color: primaryOrange.withValues(alpha: 0.6)),
        minimumSize: Size(0, 48.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
      );

  Widget _buildError(String error, Future<void> Function() onRetry) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: primaryOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded,
                  size: 38.sp, color: primaryOrange),
            ),
            UIHelper.verticalSpace(14.h),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: AppColorsTheme.textMainColor(context),
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
            UIHelper.verticalSpace(6.h),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColorsTheme.textMutedColor(context),
                  fontSize: 12.5.sp,
                ),
              ),
            ),
            UIHelper.verticalSpace(16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: _filledStyle(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineError(String error, Future<void> Function() onRetry) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 6.h, 4.w, 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFEF4444).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: const Color(0xFFEF4444).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 18.sp, color: const Color(0xFFEF4444)),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: AppColorsTheme.textMainColor(context),
                fontSize: 11.5.sp,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Widgets
// -----------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  final InvoiceDetailModel invoice;
  final void Function(String label, String value) onCopy;

  const _SummaryCard({required this.invoice, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final dates = <(IconData, String, String)>[
      (Icons.event_outlined, 'Issued', invoice.issuedDateLabel),
      if (invoice.dueDateLabel != '—')
        (Icons.event_busy_outlined, 'Due', invoice.dueDateLabel),
      if (invoice.paidDateLabel != '—')
        (Icons.event_available_outlined, 'Paid', invoice.paidDateLabel),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.22),
            blurRadius: 18.r,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.r),
        child: Stack(
          children: [
            // Decorative circles.
            Positioned(
              right: -40.w,
              top: -40.w,
              child: _circle(140.w, 0.10),
            ),
            Positioned(
              right: 40.w,
              bottom: -60.w,
              child: _circle(120.w, 0.07),
            ),
            Padding(
              padding: EdgeInsets.all(18.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(9.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(Icons.receipt_long_rounded,
                            color: Colors.white, size: 20.sp),
                      ),
                      UIHelper.horizontalSpace(10.w),
                      Expanded(
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.r),
                          onTap: () =>
                              onCopy('Invoice number', invoice.displayNumber),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 4.h),
                            child: Row(
                              children: [
                                Flexible(
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
                                UIHelper.horizontalSpace(6.w),
                                Icon(Icons.copy_rounded,
                                    size: 13.sp,
                                    color:
                                        Colors.white.withValues(alpha: 0.8)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      _StatusPill(status: invoice.displayStatus, onHero: true),
                    ],
                  ),
                  UIHelper.verticalSpace(20.h),
                  Text(
                    'TOTAL AMOUNT',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  UIHelper.verticalSpace(2.h),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      invoice.displayTotal,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.sp,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
                    ),
                  ),
                  if (invoice.displayPurpose != '—') ...[
                    UIHelper.verticalSpace(4.h),
                    Text(
                      invoice.displayPurpose,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  UIHelper.verticalSpace(16.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      for (final (icon, label, value) in dates)
                        _HeroDateChip(icon: icon, label: label, value: value),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );
}

class _HeroDateChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroDateChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13.sp, color: Colors.white),
          UIHelper.horizontalSpace(5.w),
          Text(
            '$label  ',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final bool onHero;

  const _StatusPill({required this.status, this.onHero = false});

  IconData get _icon => switch (status.toUpperCase()) {
        'PAID' || 'VERIFIED' => Icons.check_circle_rounded,
        'OVERDUE' => Icons.error_rounded,
        _ => Icons.schedule_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final color = financeStatusColor(status.toUpperCase());
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: onHero ? Colors.white : color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 12.sp, color: color),
          UIHelper.horizontalSpace(4.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: AppColorsTheme.borderColor(context),
    );
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 12.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(7.w),
                  decoration: BoxDecoration(
                    color: primaryOrange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, size: 16.sp, color: primaryOrange),
                ),
                UIHelper.horizontalSpace(10.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: AppColorsTheme.textMainColor(context),
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
          ),
          divider,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1) divider,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback? onCopy;
  final bool emphasize;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
    this.onCopy,
    this.emphasize = false,
  });

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    return InkWell(
      onTap: onCopy,
      onLongPress: onCopy,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 11.h),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: muted),
            UIHelper.horizontalSpace(10.w),
            Expanded(
              flex: 4,
              child: Text(
                label,
                style: TextStyle(color: muted, fontSize: 12.sp),
              ),
            ),
            UIHelper.horizontalSpace(10.w),
            Expanded(
              flex: 5,
              child: Align(
                alignment: Alignment.centerRight,
                child: valueWidget ??
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            value ?? '—',
                            textAlign: TextAlign.end,
                            style: TextStyle(
                              color: emphasize
                                  ? primaryOrange
                                  : AppColorsTheme.textMainColor(context),
                              fontSize: emphasize ? 13.5.sp : 12.sp,
                              fontWeight:
                                  emphasize ? FontWeight.w900 : FontWeight.w700,
                            ),
                          ),
                        ),
                        if (onCopy != null) ...[
                          UIHelper.horizontalSpace(6.w),
                          Icon(Icons.copy_rounded,
                              size: 13.sp, color: primaryOrange),
                        ],
                      ],
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;

  const _CountBadge({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        count == 1 ? '1 item' : '$count items',
        style: TextStyle(
          color: AppColorsTheme.textMutedColor(context),
          fontSize: 10.5.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  final int index;
  final InvoiceDetailLineModel item;

  const _ItemRow({required this.index, required this.item});

  @override
  Widget build(BuildContext context) {
    final hasQty = item.quantity?.isNotEmpty == true;
    final hasRate = item.rate?.isNotEmpty == true;
    final meta = hasQty && hasRate
        ? '${item.quantity} × ${item.rate}'
        : hasQty
            ? 'Qty ${item.quantity}'
            : hasRate
                ? 'Rate ${item.rate}'
                : null;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26.sp,
            height: 26.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                color: primaryOrange,
                fontSize: 11.sp,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          UIHelper.horizontalSpace(10.w),
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
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (meta != null) ...[
                  UIHelper.verticalSpace(3.h),
                  Text(
                    meta,
                    style: TextStyle(
                      color: AppColorsTheme.textMutedColor(context),
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (item.amount?.isNotEmpty == true) ...[
            UIHelper.horizontalSpace(10.w),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 130.w),
              child: Text(
                item.amount!,
                textAlign: TextAlign.end,
                style: TextStyle(
                  color: AppColorsTheme.textMainColor(context),
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String total;

  const _TotalRow({required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
        children: [
          Text(
            'Total',
            style: TextStyle(
              color: AppColorsTheme.textMainColor(context),
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w900,
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                total,
                style: TextStyle(
                  color: primaryOrange,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final bool compact;
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SecondaryAction({
    required this.compact,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconWidget = isLoading
        ? SizedBox.square(
            dimension: 16.sp,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryOrange,
            ),
          )
        : Icon(icon, size: 18.sp);

    final style = OutlinedButton.styleFrom(
      foregroundColor: primaryOrange,
      side: BorderSide(color: primaryOrange.withValues(alpha: 0.5)),
      minimumSize: Size(48.h, 48.h),
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : 12.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
    );

    final button = compact
        ? OutlinedButton(onPressed: onPressed, style: style, child: iconWidget)
        : OutlinedButton.icon(
            onPressed: onPressed,
            style: style,
            icon: iconWidget,
            label: Text(
              label,
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
            ),
          );
    return Tooltip(message: label, child: button);
  }
}

class _InvoiceDetailsSkeleton extends StatelessWidget {
  const _InvoiceDetailsSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Widget block(double height, {double radius = 18}) => Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius.r),
          ),
        );

    return Shimmer.fromColors(
      baseColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
      highlightColor: isDark ? const Color(0xFF334155) : const Color(0xFFF9FAFB),
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _kMaxContentWidth),
              child: Column(
                children: [
                  block(190.h, radius: 22),
                  UIHelper.verticalSpace(14.h),
                  block(250.h),
                  UIHelper.verticalSpace(14.h),
                  block(170.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
