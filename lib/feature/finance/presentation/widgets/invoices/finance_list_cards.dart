import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/invoice_list_model.dart';
import '../../../model/receipt_list_model.dart';
import '../../invoice_details_screen.dart';
import '../finance_shared/finance_widgets.dart';
import '../invoice_receipt_preview_modal.dart';
import 'finance_document_card.dart';

/// Invoice row from `GET /invoices`; tap opens [InvoiceDetailsScreen]
/// (which loads the invoice detail API). Used by Finance › Invoices and
/// Account › Invoices.
class InvoiceListCard extends StatelessWidget {
  final InvoiceItemModel invoice;

  const InvoiceListCard({super.key, required this.invoice});

  void _openDetails(BuildContext context) {
    if (invoice.id?.trim().isNotEmpty != true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice ID is unavailable')),
      );
      return;
    }
    InvoiceDetailsScreen.open(context, invoice: invoice);
  }

  @override
  Widget build(BuildContext context) {
    final status = invoice.displayStatus;
    final statusColor = financeStatusColor(status.toUpperCase());
    final muted = AppColorsTheme.textMutedColor(context);
    final paidAt = invoice.paidDateLabel;
    final paymentMeta = paidAt != '—'
        ? 'Paid: $paidAt'
        : invoice.paymentReference == null
            ? null
            : 'Payment ref: ${invoice.paymentReference}';

    return FinanceDocumentCard(
      icon: Icons.receipt_long_rounded,
      iconColor: primaryOrange,
      number: invoice.number ?? invoice.id ?? 'Invoice',
      status: status.toUpperCase(),
      statusColor: statusColor,
      badgeHorizontalPadding: 7,
      badgeRadius: 10,
      shadowOffsetY: 2,
      detailTitle: invoice.displayPurpose,
      detailGap: 2,
      detailMeta: Row(
        children: [
          FinanceMetaItem(
            icon: Icons.calendar_today_rounded,
            iconColor: muted,
            text: 'Issued: ${invoice.issuedDateLabel}',
            weight: FontWeight.w500,
            textColor: muted,
          ),
          if (paymentMeta != null) ...[
            UIHelper.horizontalSpace(8.w),
            FinanceMetaItem(
              icon: Icons.payments_outlined,
              iconColor: statusColor,
              text: paymentMeta,
              weight: FontWeight.w700,
              textColor: statusColor,
            ),
          ],
        ],
      ),
      amountLabel: 'Total Amount',
      amountLabelSize: 9,
      amount: invoice.displayTotal,
      amountColor: primaryOrange,
      buttonColor: primaryOrange,
      onCardTap: () => _openDetails(context),
      onPreview: () => _openDetails(context),
    );
  }
}

/// Receipt row from `GET /receipts`; tap opens the receipt preview.
class ReceiptListCard extends StatelessWidget {
  final ReceiptItemModel receipt;

  const ReceiptListCard({super.key, required this.receipt});

  @override
  Widget build(BuildContext context) {
    final status = receipt.displayStatus;
    final statusColor = financeStatusColor(status.toUpperCase());
    final muted = AppColorsTheme.textMutedColor(context);

    return FinanceDocumentCard(
      icon: Icons.payments_rounded,
      iconColor: statusColor,
      number: receipt.displayNumber,
      status: status.toUpperCase(),
      statusColor: statusColor,
      badgeHorizontalPadding: 8,
      badgeRadius: 12,
      shadowOffsetY: 3,
      detailTitle: receipt.displayGateway,
      detailGap: 3,
      detailMeta: Row(
        children: [
          FinanceMetaItem(
            icon: Icons.access_time_rounded,
            iconColor: muted,
            text: receipt.displayDate,
            weight: FontWeight.w500,
            textColor: muted,
          ),
        ],
      ),
      amountLabel: 'Verified Amount',
      amountLabelSize: 9.5,
      amount: receipt.displayAmount,
      amountColor: statusColor,
      buttonColor: statusColor,
      onPreview: () => InvoiceReceiptPreviewModal.show(
        context,
        title: 'Receipt',
        docNo: receipt.displayNumber,
        clientOrGateway: receipt.displayGateway,
        date: receipt.displayDate,
        dueDateOrTime: receipt.displayDate,
        amount: receipt.displayAmount,
        status: status,
        isInvoice: false,
      ),
    );
  }
}
