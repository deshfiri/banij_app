import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/wallet_balance_model.dart';
import '../model/wallet_transaction_model.dart';
import 'widgets/finance_shared/finance_widgets.dart';
import 'widgets/wallet/wallet_top_up_sheet.dart';
import 'widgets/wallet/wallet_widgets.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  static const String _zero = '৳0.00';
  static const List<String> _filters = ['All', 'Credit', 'Debit'];

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  WalletBalanceResponseModel? _walletBalanceModel;
  WalletTransactionListModel? _walletTransactionListModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    await Future.wait([
      _fetchWalletBalance(),
      _fetchWalletTransactions(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final res = await walletBalanceRxObj.fetchWalletBalance();
      if (mounted) setState(() => _walletBalanceModel = res);
    } catch (_) {}
  }

  Future<void> _fetchWalletTransactions() async {
    try {
      final res = await walletTransactionRxObj.fetchWalletTransactions();
      if (mounted) setState(() => _walletTransactionListModel = res);
    } catch (_) {}
  }

  void _showTopUpModal() => WalletTopUpSheet.show(context, onToppedUp: _loadData);

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        appBar: financeAppBar(context, title: 'Wallet'),
        body: const WalletShimmer(),
      );
    }

    final balance = _walletBalanceModel?.data;
    final apiTransactions = _walletTransactionListModel?.data ?? [];
    final sectionTitleStyle =
        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context));

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: financeAppBar(
        context,
        title: 'Wallet',
        backgroundColor: AppColorsTheme.cardBg(context),
        elevation: 1,
        actionLabel: 'Top Up',
        onAction: _showTopUpModal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(child: FinanceIntroText('What your account holds, and every movement behind it.')),
                WalletStateBadge(label: balance?.stateLabel, tone: balance?.stateTone),
              ],
            ),
            UIHelper.verticalSpace(16.h),
            WalletTopUpBanner(onTopUp: _showTopUpModal),
            UIHelper.verticalSpace(20.h),

            // Balance cards (from GET /wallet)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.25,
              children: [
                WalletBalanceCard(
                  title: 'Total Balance',
                  amount: balance?.total?.formatted ?? _zero,
                  subtitle: 'Your total wallet balance.',
                  icon: Icons.account_balance_wallet_rounded,
                ),
                WalletBalanceCard(
                  title: 'Available Balance',
                  amount: balance?.usable?.formatted ?? _zero,
                  subtitle: 'Available for orders.',
                  icon: Icons.account_balance_rounded,
                ),
                WalletBalanceCard(
                  title: 'Withdrawable',
                  amount: balance?.withdrawable?.formatted ?? _zero,
                  subtitle: 'Ready to withdraw.',
                  icon: Icons.payments_rounded,
                ),
              ],
            ),
            UIHelper.verticalSpace(24.h),

            // Balance details
            Text('Balance details', style: sectionTitleStyle),
            UIHelper.verticalSpace(2.h),
            Text(
              'What sits behind the figures above.',
              style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
            ),
            UIHelper.verticalSpace(12.h),
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColorsTheme.cardBg(context),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
              ),
              child: Column(
                children: [
                  WalletDetailRow(
                    label1: 'Platform credit',
                    value1: balance?.platformCredit?.formatted ?? _zero,
                    label2: 'Withdrawable',
                    value2: balance?.withdrawable?.formatted ?? _zero,
                  ),
                  UIHelper.verticalSpace(10.h),
                  WalletDetailRow(
                    label1: 'Pending',
                    value1: balance?.pending?.formatted ?? _zero,
                    label2: 'On hold',
                    value2: balance?.hold?.formatted ?? _zero,
                  ),
                  UIHelper.verticalSpace(10.h),
                  WalletDetailRow(
                    label1: 'Minimum balance',
                    value1: balance?.minimumBalance?.formatted ?? _zero,
                    label2: 'COD Settlement',
                    value2: balance?.codReceivable?.formatted ?? _zero,
                  ),
                  UIHelper.verticalSpace(10.h),
                  WalletDetailRow(
                    label1: 'Reserved',
                    value1: balance?.reserved?.formatted ?? _zero,
                    label2: 'Required deposit',
                    value2: balance?.requiredDeposit?.formatted ?? _zero,
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(24.h),

            // Statement + filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Statement', style: sectionTitleStyle),
                _StatementFilter(
                  value: _selectedFilter,
                  options: _filters,
                  onChanged: (val) => setState(() => _selectedFilter = val),
                ),
              ],
            ),
            UIHelper.verticalSpace(12.h),

            apiTransactions.isEmpty
                ? const WalletNoTransactions()
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: apiTransactions.length,
                    itemBuilder: (context, index) => WalletTransactionTile(tx: apiTransactions[index]),
                  ),
          ],
        ),
      ),
    );
  }
}

/// Bordered All / Credit / Debit dropdown beside "Statement".
class _StatementFilter extends StatelessWidget {
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;

  const _StatementFilter({required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: DropdownButton<String>(
        value: value,
        dropdownColor: AppColorsTheme.cardBg(context),
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
        underline: const SizedBox.shrink(),
        items: options.map((val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
      ),
    );
  }
}
