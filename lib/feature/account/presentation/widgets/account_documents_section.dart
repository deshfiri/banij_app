import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../finance/presentation/widgets/invoice_receipt_preview_modal.dart';
import 'account_ui.dart';

/// Invoices tab: the sample invoice row and its preview (unchanged data).
class AccountInvoicesSection extends StatelessWidget {
  const AccountInvoicesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountSectionCard(
      title: 'invoices_heading'.tr,
      subtitle: 'invoices_desc'.tr,
      child: AccountSettingTile(
        icon: Icons.receipt_long_outlined,
        title: 'Invoice #INV-2026-001',
        subtitle: '৳49,500.00 · Unpaid',
        onTap: () {
          InvoiceReceiptPreviewModal.show(
            context,
            title: 'Invoice',
            docNo: 'INV-2026-001',
            clientOrGateway: 'Considine Supermarket Ltd',
            date: '05 Nov 2026',
            dueDateOrTime: '20 Nov 2026',
            amount: '৳49,500.00',
            status: 'PENDING',
            isInvoice: true,
          );
        },
      ),
    );
  }
}

/// Receipts tab: the sample receipt row and its preview (unchanged data).
class AccountReceiptsSection extends StatelessWidget {
  const AccountReceiptsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return AccountSectionCard(
      title: 'receipts_heading'.tr,
      subtitle: 'receipts_desc'.tr,
      child: AccountSettingTile(
        icon: Icons.payments_outlined,
        title: 'Receipt #REC-2026-089',
        subtitle: '৳25,500.00 · Completed',
        onTap: () {
          InvoiceReceiptPreviewModal.show(
            context,
            title: 'Receipt',
            docNo: 'REC-2026-089',
            clientOrGateway: 'bKash Merchant Payment',
            date: '04 Nov 2026, 04:30 PM',
            dueDateOrTime: '04 Nov 2026, 04:30 PM',
            amount: '৳25,500.00',
            status: 'VERIFIED',
            isInvoice: false,
          );
        },
      ),
    );
  }
}
