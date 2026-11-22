import 'package:flutter/material.dart';

import '../../../../../constants/image_const.dart';
import '../../../../../helpers/all_routes.dart';
import '../invoices_receipts_sheet.dart';

/// One finance shortcut. [titleKey] is a translation key.
class FinanceAction {
  final String titleKey;
  final String iconAsset;
  final void Function(BuildContext context) open;

  const FinanceAction({
    required this.titleKey,
    required this.iconAsset,
    required this.open,
  });

  /// Wallet, withdrawals, payout methods, invoices, receipts.
  static final List<FinanceAction> all = [
    FinanceAction(
      titleKey: 'Wallet',
      iconAsset: walletModuleIconAsset,
      open: (ctx) => Navigator.pushNamed(ctx, Routes.walletScreen),
    ),
    FinanceAction(
      titleKey: 'Withdrawals',
      iconAsset: withdrawalsIconAsset,
      open: (ctx) => Navigator.pushNamed(ctx, Routes.withdrawalsScreen),
    ),
    FinanceAction(
      titleKey: 'Payout methods',
      iconAsset: payoutMethodsIconAsset,
      open: (ctx) => Navigator.pushNamed(ctx, Routes.payoutMethodsScreen),
    ),
    FinanceAction(
      titleKey: 'Invoice',
      iconAsset: invoiceIconAsset,
      open: (ctx) => InvoicesReceiptsSheet.show(ctx, initialTab: 'Invoices'),
    ),
    FinanceAction(
      titleKey: 'Receipts',
      iconAsset: receiptIconAsset,
      open: (ctx) => InvoicesReceiptsSheet.show(ctx, initialTab: 'Receipts'),
    ),
  ];
}
