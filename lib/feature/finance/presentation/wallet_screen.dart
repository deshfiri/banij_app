import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
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

  Widget _buildHeroHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final balance = _walletBalanceModel?.data;

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
    final apiTransactions = _walletTransactionListModel?.data ?? [];
    final sectionTitleStyle =
        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context));

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
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColorsTheme.cardBg(context)
                          : const Color(0xFFFFF7F2),
                      borderRadius: BorderRadius.circular(18.r),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF374151)
                            : primaryOrange.withValues(alpha: 0.22),
                        width: 1.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryOrange.withValues(
                            alpha: Theme.of(context).brightness == Brightness.dark ? 0.08 : 0.05,
                          ),
                          blurRadius: 10.r,
                          offset: const Offset(0, 3),
                        ),
                      ],
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
