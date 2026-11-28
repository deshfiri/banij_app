import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../providers/invoice_provider.dart';
import '../../../finance/presentation/widgets/invoices/finance_list_cards.dart';
import 'account_ui.dart';

/// Account › Invoices: the invoice list from `GET /invoices`. Tapping one
/// opens Invoice Details (detail API, PDF preview / print / download).
class AccountInvoicesSection extends StatefulWidget {
  const AccountInvoicesSection({super.key});

  @override
  State<AccountInvoicesSection> createState() => _AccountInvoicesSectionState();
}

class _AccountInvoicesSectionState extends State<AccountInvoicesSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InvoiceProvider>().fetchInvoices(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final invoices = provider.invoiceResponse?.data ?? const [];

    return _DocumentList(
      title: 'invoices_heading'.tr,
      subtitle: 'invoices_desc'.tr,
      count: invoices.length,
      isLoading: provider.isLoadingInvoices && invoices.isEmpty,
      error: invoices.isEmpty ? provider.invoiceError : null,
      emptyIcon: Icons.receipt_long_outlined,
      emptyText: 'No invoices found'.tr,
      onRetry: () => provider.fetchInvoices(force: true),
      children: [for (final invoice in invoices) InvoiceListCard(invoice: invoice)],
    );
  }
}

/// Account › Receipts: the receipt list from `GET /receipts`.
class AccountReceiptsSection extends StatefulWidget {
  const AccountReceiptsSection({super.key});

  @override
  State<AccountReceiptsSection> createState() => _AccountReceiptsSectionState();
}

class _AccountReceiptsSectionState extends State<AccountReceiptsSection> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<InvoiceProvider>().fetchReceipts(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InvoiceProvider>();
    final receipts = provider.receiptResponse?.data ?? const [];

    return _DocumentList(
      title: 'receipts_heading'.tr,
      subtitle: 'receipts_desc'.tr,
      count: receipts.length,
      isLoading: provider.isLoadingReceipts && receipts.isEmpty,
      error: receipts.isEmpty ? provider.receiptError : null,
      emptyIcon: Icons.payments_outlined,
      emptyText: 'No receipts found'.tr,
      onRetry: () => provider.fetchReceipts(force: true),
      children: [for (final receipt in receipts) ReceiptListCard(receipt: receipt)],
    );
  }
}

/// Title + count, then loading / error / empty state or the cards.
class _DocumentList extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final bool isLoading;
  final String? error;
  final IconData emptyIcon;
  final String emptyText;
  final VoidCallback onRetry;
  final List<Widget> children;

  const _DocumentList({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.isLoading,
    required this.error,
    required this.emptyIcon,
    required this.emptyText,
    required this.onRetry,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: AccountSectionTitle(title: title, subtitle: subtitle)),
            if (count > 0) ...[
              UIHelper.horizontalSpace(8.w),
              AccountStatusChip(label: '$count', color: primaryOrange),
            ],
          ],
        ),
        UIHelper.verticalSpace(16.h),
        if (isLoading)
          const _DocumentShimmer()
        else if (error != null)
          _StateMessage(icon: Icons.cloud_off_rounded, text: error!, actionLabel: 'retry'.tr, onAction: onRetry)
        else if (children.isEmpty)
          _StateMessage(icon: emptyIcon, text: emptyText)
        else
          ...children,
      ],
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String text;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateMessage({required this.icon, required this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 36.h, horizontal: 16.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 30.sp, color: primaryOrange),
          ),
          UIHelper.verticalSpace(12.h),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
          ),
          if (actionLabel != null && onAction != null) ...[
            UIHelper.verticalSpace(8.h),
            TextButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(actionLabel!),
              style: TextButton.styleFrom(foregroundColor: primaryOrange),
            ),
          ],
        ],
      ),
    );
  }
}

class _DocumentShimmer extends StatelessWidget {
  const _DocumentShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColorsTheme.shimmerBase(context),
      highlightColor: AppColorsTheme.shimmerHighlight(context),
      child: Column(
        children: List.generate(
          3,
          (_) => Container(
            margin: EdgeInsets.only(bottom: 10.h),
            height: 120.h,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
          ),
        ),
      ),
    );
  }
}
