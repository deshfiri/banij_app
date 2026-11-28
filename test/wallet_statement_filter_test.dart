import 'package:bbnij/feature/finance/model/wallet_transaction_model.dart';
import 'package:bbnij/feature/finance/presentation/widgets/wallet/wallet_widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final credit = WalletTransactionItemModel(id: '1', direction: 'credit');
  final debit = WalletTransactionItemModel(id: '2', direction: 'DEBIT');
  final unknown = WalletTransactionItemModel(id: '3');
  final all = [credit, debit, unknown];

  test('All keeps every transaction', () {
    expect(all.where(WalletStatementFilter.all.matches), all);
  });

  test('Money in keeps credits only', () {
    expect(all.where(WalletStatementFilter.credit.matches), [credit]);
  });

  test('Money out keeps debits only, case-insensitively', () {
    expect(all.where(WalletStatementFilter.debit.matches), [debit]);
  });
}
