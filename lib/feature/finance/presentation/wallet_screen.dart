import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/wallet_balance_model.dart';
import '../model/wallet_transaction_model.dart';
import 'widgets/wallet/wallet_top_up_sheet.dart';
import 'widgets/wallet/wallet_widgets.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

/// Wallet: balance card with Top up / Withdraw / Payouts, a deposit alert
/// when one is due, the balance breakdown and the filterable statement.
class _WalletScreenState extends State<WalletScreen> {
  WalletStatementFilter _filter = WalletStatementFilter.all;
  WalletBalanceResponseModel? _walletBalanceModel;
  WalletTransactionListModel? _walletTransactionListModel;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  /// [showLoader] is false for pull-to-refresh, which keeps the content.
  Future<void> _loadData({bool showLoader = true}) async {
    if (!mounted) return;
    if (showLoader) setState(() => _isLoading = true);
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

  Widget _buildHeroHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balance = _walletBalanceModel?.data;

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
              // Top Bar: Back Button, White Logo & Top-Up Button
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
                    onPressed: _showTopUpModal,
                    icon: Icon(Icons.add_circle_outline_rounded, size: 14.sp, color: primaryOrange),
                    label: Text('Top Up', style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: primaryOrange)),
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

              // Title, Subtitle & Health Badge Row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wallet',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          UIHelper.verticalSpace(2.h),
                          Text(
                            'What your account holds, and every movement behind it.',
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
                    UIHelper.horizontalSpace(8.w),
                    WalletStateBadge(label: balance?.stateLabel, tone: balance?.stateTone),
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            _buildHeroHeader(context),
            const Expanded(child: WalletShimmer()),
          ],
        ),
      );
    }

    final balance = _walletBalanceModel?.data;
    final transactions = _walletTransactionListModel?.data ?? const <WalletTransactionItemModel>[];
    final visible = transactions.where(_filter.matches).toList();

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: Column(
        children: [
          _buildHeroHeader(context),
          Expanded(
            child: RefreshIndicator(
              color: primaryOrange,
              onRefresh: () => _loadData(showLoader: false),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 28.h),
                children: [
                  WalletBalanceHero(
                    balance: balance,
                    onTopUp: _showTopUpModal,
                    onWithdraw: () => Navigator.pushNamed(context, Routes.withdrawalsScreen),
                    onPayoutMethods: () => Navigator.pushNamed(context, Routes.payoutMethodsScreen),
                  ),
                  if (WalletDepositAlert.shouldShow(balance)) ...[
                    UIHelper.verticalSpace(14.h),
                    WalletDepositAlert(balance: balance!, onTopUp: _showTopUpModal),
                  ],
                  UIHelper.verticalSpace(16.h),
                  WalletBreakdownCard(balance: balance),
                  UIHelper.verticalSpace(24.h),
                  WalletStatementHeader(
                    count: transactions.length,
                    filter: _filter,
                    onChanged: (value) => setState(() => _filter = value),
                  ),
                  UIHelper.verticalSpace(12.h),
                  if (visible.isEmpty)
                    WalletNoTransactions(filtered: transactions.isNotEmpty)
                  else
                    WalletStatementCard(transactions: visible),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
