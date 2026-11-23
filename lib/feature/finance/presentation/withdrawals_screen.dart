import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/withdrawal_list_model.dart';
import '../model/withdrawal_options_model.dart';
import 'widgets/finance_shared/finance_widgets.dart';
import 'widgets/withdrawals/withdrawal_request_sheet.dart';

class WithdrawalsScreen extends StatefulWidget {
  const WithdrawalsScreen({super.key});

  @override
  State<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends State<WithdrawalsScreen> {
  WithdrawalOptionsModel? _withdrawalOptionsModel;
  WithdrawalListResponseModel? _withdrawalListModel;

  @override
  void initState() {
    super.initState();
    _fetchWithdrawalOptions();
    _fetchWithdrawals();
  }

  Future<void> _fetchWithdrawalOptions() async {
    try {
      final res = await withdrawalOptionsRxObj.fetchWithdrawalOptions();
      if (mounted) setState(() => _withdrawalOptionsModel = res);
    } catch (_) {}
  }

  Future<void> _fetchWithdrawals() async {
    try {
      final res = await withdrawalListRxObj.fetchWithdrawalList();
      if (mounted) setState(() => _withdrawalListModel = res);
    } catch (_) {}
  }

  void _showRequestModal() {
    WithdrawalRequestSheet.show(
      context,
      options: _withdrawalOptionsModel,
      onSubmitted: () {
        _fetchWithdrawals();
        _fetchWithdrawalOptions();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiItems = _withdrawalListModel?.data ?? [];

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: financeAppBar(context, title: 'Withdrawals', actionLabel: 'Request', onAction: _showRequestModal),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FinanceIntroText('Requests to withdraw from your available balance.'),
            UIHelper.verticalSpace(16.h),
            FinancePrimaryButton(
              icon: Icons.payments_outlined,
              label: 'Request withdrawal',
              onPressed: _showRequestModal,
            ),
            UIHelper.verticalSpace(20.h),
            apiItems.isEmpty
                ? const FinanceEmptyCard(
                    icon: Icons.payments_outlined,
                    title: 'No withdrawals yet',
                    subtitle: 'Request a withdrawal from your wallet once you have a payout method saved.',
                    padding: 36,
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: apiItems.length,
                    itemBuilder: (context, index) => _WithdrawalTile(item: apiItems[index]),
                  ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawalTile extends StatelessWidget {
  final WithdrawalItemModel item;

  const _WithdrawalTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isCompleted = item.status == 'paid' || item.status == 'approved' || item.statusTone == 'success';
    final statusColor = isCompleted ? Colors.green : Colors.orange;

    return FinanceListCard(
      icon: Icons.account_balance_wallet_outlined,
      iconColor: statusColor,
      title: FinanceListCard.titleText(context, item.reference ?? item.id ?? 'WD-REQUEST'),
      subtitle: '${item.payout?.typeLabel ?? item.payout?.label ?? 'Payout'} (${item.payout?.maskedNumber ?? ''})',
      subtitleSize: 11.5,
      trailing: FinanceAmountStatus(
        amount: item.amount?.formatted ?? '৳0.00',
        amountColor: primaryOrange,
        status: item.statusLabel ?? item.status ?? 'Pending',
        statusColor: statusColor,
      ),
    );
  }
}
