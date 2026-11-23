import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
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

  Widget _buildHeroHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
              : [primaryOrange, secondaryOrange],
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
              // Top Bar: Back Button, White Logo & Request Button
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
                  ElevatedButton.icon(
                    onPressed: _showRequestModal,
                    icon: Icon(Icons.payments_outlined, size: 14.sp, color: primaryOrange),
                    label: Text('Request', style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: primaryOrange)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 2,
                    ),
                  ),
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
                      'Withdrawals'.tr,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      'Requests to withdraw from your available balance.'.tr,
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                      maxLines: 2,
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

  @override
  Widget build(BuildContext context) {
    final apiItems = _withdrawalListModel?.data ?? [];

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroHeader(context),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
