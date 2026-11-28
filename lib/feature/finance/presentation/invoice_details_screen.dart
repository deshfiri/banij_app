import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:printing/printing.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
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

  Widget _buildHeroHeader(BuildContext context, InvoiceDetailModel? invoice) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.2 : 0.28),
            blurRadius: 18.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back Button, White Logo & Share Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  Image.asset(
                    whiteLogo,
                    width: 105.w,
                    height: 34.h,
                    fit: BoxFit.contain,
                  ),
                  if (invoice != null)
                    IconButton(
                      onPressed: () => _sharePdf(invoice),
                      icon: Icon(
                        Icons.ios_share_rounded,
                        color: Colors.white,
                        size: 22.sp,
                      ),
                    )
                  else
                    SizedBox(width: 48.w),
                ],
              ),
              UIHelper.verticalSpace(12.h),

              // Title & Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice Details',
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      widget.invoice.number ?? 'Invoice information',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: Colors.white.withValues(alpha: 0.88),
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
            _buildHeroHeader(context, invoice),
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
        final details = _buildDetailsCard(invoice);
        final items = _buildItemsCard(invoice);

        final Widget content;
        if (isWide) {
          content = Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 5,
                child: Column(children: [summary, SizedBox(height: gap), details]),
              ),
              SizedBox(width: gap),
              Expanded(flex: 6, child: items),
            ],
          );
        } else {
          content = Column(
            children: [summary, SizedBox(height: gap), details, SizedBox(height: gap), items],
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
                      SizedBox(height: 22.h),
                      const _FooterNote(),
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

  /// Who it is billed to and the identifiers people copy (number, payment
  /// reference). Amount, status and dates live in the summary card.
  Widget _buildDetailsCard(InvoiceDetailModel invoice) {
    return _SectionCard(
      title: 'Billing details',
      icon: Icons.description_outlined,
      children: [
        if (invoice.displayCustomer != '—')
          _DetailRow(
            icon: Icons.storefront_outlined,
            label: 'Billed to',
            value: invoice.displayCustomer,
          ),
        _DetailRow(
          icon: Icons.tag_rounded,
          label: 'Invoice number',
          value: invoice.displayNumber,
          onCopy: () => _copy('Invoice number', invoice.displayNumber),
        ),
        if (invoice.displayPaymentReference != '—')
          _DetailRow(
            icon: Icons.confirmation_number_outlined,
            label: 'Payment reference',
            value: invoice.displayPaymentReference,
            onCopy: () => _copy('Payment reference', invoice.displayPaymentReference),
          ),
      ],
    );
  }

  /// Line items as a table, then the total and how it was settled. Without
  /// line items it is just the totals ("Summary").
  Widget _buildItemsCard(InvoiceDetailModel invoice) {
    final items = invoice.items;
    return _SectionCard(
      title: items.isEmpty ? 'Summary' : 'Invoice items',
      icon: items.isEmpty ? Icons.summarize_outlined : Icons.inventory_2_outlined,
      trailing: items.isEmpty ? null : _CountBadge(count: items.length),
      divideChildren: false,
      children: [
        if (items.isNotEmpty) ...[
          const _ItemsTableHeader(),
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: AppColorsTheme.borderColor(context)),
            _ItemRow(index: i + 1, item: items[i]),
          ],
        ],
        _TotalsBlock(invoice: invoice),
      ],
    );
  }

  Widget _buildActionBar(InvoiceDetailModel invoice) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        border: Border(top: BorderSide(color: AppColorsTheme.borderColor(context))),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : primaryOrange.withValues(alpha: 0.1),
            blurRadius: 18.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
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
                  padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 12.h),
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
                        child: _DownloadButton(
                          isLoading: _isDownloading,
                          onPressed: _isBusy ? null : () => _downloadPdf(invoice),
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

/// Shared surface for every card on this screen: cream (card colour in dark
/// mode), soft orange outline and an orange bar on the left.
BoxDecoration _cardDecoration(BuildContext context, {double radius = 18}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark ? AppColorsTheme.cardBg(context) : const Color(0xFFFFF7F2),
    borderRadius: BorderRadius.circular(radius.r),
    border: Border.all(
      color: isDark
              ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.22),
      width: 1.w,
    ),
    boxShadow: [
      BoxShadow(
        color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.07),
        blurRadius: 14.r,
        offset: const Offset(0, 4),
      ),
    ],
  );
}

/// Orange left-side bar, clipped by the card's rounded corners.
const double _kBarWidth = 5;

Widget _leftBar() => Positioned(
      left: 0,
      top: 0,
      bottom: 0,
      width: _kBarWidth.w,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [primaryOrange, primaryOrange.withValues(alpha: 0.55)],
          ),
        ),
      ),
    );

/// The invoice at a glance: number (tap to copy) and status, the total and
/// purpose, then — below a perforated "ticket" line — issued / due / paid
/// dates. Paid and overdue invoices get a rotated stamp.
class _SummaryCard extends StatelessWidget {
  final InvoiceDetailModel invoice;
  final void Function(String label, String value) onCopy;

  const _SummaryCard({required this.invoice, required this.onCopy});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final status = invoice.displayStatus.toUpperCase();
    final dates = <(String, String)>[
      ('Issued', invoice.issuedDateLabel),
      if (invoice.dueDateLabel != '—') ('Due', invoice.dueDateLabel),
      if (invoice.paidDateLabel != '—') ('Paid', invoice.paidDateLabel),
    ];
    final radius = BorderRadius.circular(22.r);

    return Container(
      width: double.infinity,
      decoration: _cardDecoration(context, radius: 22),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(_kBarWidth.w + 14.w, 16.h, 16.w, 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 42.w,
                            height: 42.w,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [secondaryOrange, primaryOrange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(13.r),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryOrange.withValues(alpha: 0.3),
                                  blurRadius: 8.r,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(Icons.receipt_long_rounded, color: Colors.white, size: 21.sp),
                          ),
                          UIHelper.horizontalSpace(12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'INVOICE',
                                  style: TextStyle(
                                    color: muted,
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                                UIHelper.verticalSpace(1.h),
                                InkWell(
                                  borderRadius: BorderRadius.circular(6.r),
                                  onTap: () => onCopy('Invoice number', invoice.displayNumber),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          invoice.displayNumber,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: AppColorsTheme.textMainColor(context),
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      UIHelper.horizontalSpace(6.w),
                                      Icon(Icons.copy_rounded, size: 13.sp, color: primaryOrange),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          UIHelper.horizontalSpace(8.w),
                          _StatusPill(status: invoice.displayStatus),
                        ],
                      ),
                      UIHelper.verticalSpace(18.h),
                      Text(
                        'Total amount',
                        style: TextStyle(color: muted, fontSize: 11.5.sp, fontWeight: FontWeight.w600),
                      ),
                      UIHelper.verticalSpace(2.h),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          invoice.displayTotal,
                          style: TextStyle(
                            color: AppColorsTheme.textMainColor(context),
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                            height: 1.15,
                          ),
                        ),
                      ),
                      if (invoice.displayPurpose != '—') ...[
                        UIHelper.verticalSpace(6.h),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: primaryOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            invoice.displayPurpose,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryOrange,
                              fontSize: 11.5.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const _TicketDivider(),
                Padding(
                  padding: EdgeInsets.fromLTRB(_kBarWidth.w + 14.w, 14.h, 16.w, 16.h),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        for (var i = 0; i < dates.length; i++) ...[
                          if (i > 0)
                            VerticalDivider(
                              width: 20.w,
                              thickness: 1,
                              color: AppColorsTheme.borderColor(context),
                            ),
                          Expanded(child: _DateColumn(label: dates[i].$1, value: dates[i].$2)),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _leftBar(),
            if (status == 'PAID' || status == 'OVERDUE')
              Positioned(
                right: 18.w,
                top: 78.h,
                child: _Stamp(label: status, color: financeStatusColor(status)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Dashed line with a half-circle notch at each side, like a tear-off receipt.
class _TicketDivider extends StatelessWidget {
  const _TicketDivider();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notch = 18.w;
    // Page colour plus the card's outline, so the cut reads even though the
    // card and page colours are close.
    final notchDecoration = BoxDecoration(
      color: AppColorsTheme.background(context),
      shape: BoxShape.circle,
      border: Border.all(
        color: isDark
              ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.3),
        width: 1.w,
      ),
    );
    return SizedBox(
      height: notch,
      child: Row(
        children: [
          Transform.translate(
            offset: Offset(-notch / 2, 0),
            child: Container(width: notch, height: notch, decoration: notchDecoration),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dash = 6.0;
                const gap = 4.0;
                final count = (constraints.maxWidth / (dash + gap)).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < count; i++)
                      Container(width: dash, height: 1.2, color: AppColorsTheme.borderColor(context)),
                  ],
                );
              },
            ),
          ),
          Transform.translate(
            offset: Offset(notch / 2, 0),
            child: Container(width: notch, height: notch, decoration: notchDecoration),
          ),
        ],
      ),
    );
  }
}

class _DateColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DateColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: AppColorsTheme.textMutedColor(context),
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        UIHelper.verticalSpace(4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              color: AppColorsTheme.textMainColor(context),
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// Rotated outlined "PAID" / "OVERDUE" stamp.
class _Stamp extends StatelessWidget {
  final String label;
  final Color color;

  const _Stamp({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: -0.22,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: color.withValues(alpha: 0.55), width: 2.2),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color.withValues(alpha: 0.6),
              fontSize: 17.sp,
              fontWeight: FontWeight.w900,
              letterSpacing: 3,
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

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
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: color.withValues(alpha: 0.35)),
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

/// Titled card with the screen's shared surface and orange left bar.
/// Children are separated by hairlines unless [divideChildren] is false.
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;
  final bool divideChildren;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
    this.divideChildren = true,
  });

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      thickness: 1,
      color: AppColorsTheme.borderColor(context),
    );
    final radius = BorderRadius.circular(18.r);
    return Container(
      width: double.infinity,
      decoration: _cardDecoration(context),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(_kBarWidth.w + 12.w, 14.h, 16.w, 12.h),
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
                            fontSize: 14.sp,
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
                  padding: EdgeInsets.fromLTRB(_kBarWidth.w + 12.w, 4.h, 16.w, 4.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < children.length; i++) ...[
                        children[i],
                        if (divideChildren && i != children.length - 1) divider,
                      ],
                    ],
                  ),
                ),
              ],
            ),
            _leftBar(),
          ],
        ),
      ),
    );
  }
}

/// Label on the left, value on the right; tap (or long-press) copies when
/// [onCopy] is set.
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onCopy;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    return InkWell(
      onTap: onCopy,
      onLongPress: onCopy,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: muted),
            UIHelper.horizontalSpace(10.w),
            Expanded(
              flex: 4,
              child: Text(label, style: TextStyle(color: muted, fontSize: 12.sp)),
            ),
            UIHelper.horizontalSpace(10.w),
            Expanded(
              flex: 5,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      textAlign: TextAlign.end,
                      style: TextStyle(
                        color: AppColorsTheme.textMainColor(context),
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onCopy != null) ...[
                    UIHelper.horizontalSpace(6.w),
                    Icon(Icons.copy_rounded, size: 13.sp, color: primaryOrange),
                  ],
                ],
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
      // Horizontal inset matches _ItemsTableHeader so the columns line up.
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
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

/// Column captions above the line items.
class _ItemsTableHeader extends StatelessWidget {
  const _ItemsTableHeader();

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      color: AppColorsTheme.textMutedColor(context),
      fontSize: 9.5.sp,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.8,
    );
    return Container(
      margin: EdgeInsets.only(top: 10.h, bottom: 2.h),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          // Same widths as _ItemRow: index badge + gap.
          SizedBox(width: 26.sp + 10.w, child: Text('#', style: style)),
          Expanded(child: Text('ITEM', style: style)),
          Text('AMOUNT', style: style),
        ],
      ),
    );
  }
}

/// Highlighted total, then "Paid in full" (with the paid date) or
/// "Amount due" (with the due date).
class _TotalsBlock extends StatelessWidget {
  final InvoiceDetailModel invoice;

  const _TotalsBlock({required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final status = invoice.displayStatus.toUpperCase();
    final isPaid = invoice.isPaid == true || status == 'PAID' || status == 'VERIFIED';
    final isOverdue = status == 'OVERDUE';
    final settleColor = isPaid
        ? financeStatusColor('PAID')
        : (isOverdue ? financeStatusColor('OVERDUE') : primaryOrange);
    final settleDate = isPaid ? invoice.paidDateLabel : invoice.dueDateLabel;

    return Padding(
      padding: EdgeInsets.only(top: 10.h, bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  primaryOrange.withValues(alpha: isDark ? 0.2 : 0.12),
                  primaryOrange.withValues(alpha: isDark ? 0.08 : 0.04),
                ],
              ),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: primaryOrange.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                Text(
                  'Total',
                  style: TextStyle(
                    color: AppColorsTheme.textMainColor(context),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                UIHelper.horizontalSpace(12.w),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      invoice.displayTotal,
                      style: TextStyle(
                        color: primaryOrange,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(10.h),
          Row(
            children: [
              Icon(
                isPaid ? Icons.check_circle_rounded : (isOverdue ? Icons.error_rounded : Icons.schedule_rounded),
                size: 16.sp,
                color: settleColor,
              ),
              UIHelper.horizontalSpace(6.w),
              Text(
                isPaid ? 'Paid in full' : 'Amount due',
                style: TextStyle(color: settleColor, fontSize: 12.5.sp, fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              if (settleDate != '—')
                Text(
                  isPaid ? 'on $settleDate' : 'by $settleDate',
                  style: TextStyle(color: AppColorsTheme.textMutedColor(context), fontSize: 11.5.sp),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Faded wordmark and a thank-you line closing the invoice.
class _FooterNote extends StatelessWidget {
  const _FooterNote();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Opacity(
      opacity: 0.6,
      child: Column(
        children: [
          Image.asset(isDark ? whiteLogo : blackLogo, width: 70.w, height: 22.h, fit: BoxFit.contain),
          UIHelper.verticalSpace(6.h),
          Text(
            'Thank you for your business',
            style: TextStyle(
              color: AppColorsTheme.textMutedColor(context),
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary "Download PDF" button on the orange gradient.
class _DownloadButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback? onPressed;

  const _DownloadButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r);
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled || isLoading ? 1 : 0.55,
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
          borderRadius: radius,
          boxShadow: [
            BoxShadow(color: primaryOrange.withValues(alpha: 0.3), blurRadius: 12.r, offset: const Offset(0, 4)),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: radius,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isLoading)
                      SizedBox.square(
                        dimension: 16.sp,
                        child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    else
                      Icon(Icons.download_rounded, size: 18.sp, color: Colors.white),
                    UIHelper.horizontalSpace(8.w),
                    Text(
                      isLoading ? 'Saving…' : 'Download PDF',
                      style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
      backgroundColor: primaryOrange.withValues(alpha: 0.07),
      side: BorderSide(color: primaryOrange.withValues(alpha: 0.35)),
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
    Widget block(double height, {double radius = 18}) => Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(radius.r),
          ),
        );

    return Shimmer.fromColors(
      baseColor: AppColorsTheme.shimmerBase(context),
      highlightColor: AppColorsTheme.shimmerHighlight(context),
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
