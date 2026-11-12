import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  final List<Map<String, dynamic>> _dummyTransactions = [
    {
      'title': 'Wallet Top-up via bKash',
      'type': 'Credit',
      'amount': '+৳5,000.00',
      'date': 'Nov 12, 2026 - 10:45 AM',
      'status': 'Success',
      'icon': Icons.arrow_downward_rounded,
      'color': Colors.green,
    },
    {
      'title': 'Wholesale Order Payment #ORD-9821',
      'type': 'Debit',
      'amount': '-৳2,450.00',
      'date': 'Nov 10, 2026 - 02:15 PM',
      'status': 'Completed',
      'icon': Icons.arrow_upward_rounded,
      'color': Colors.redAccent,
    },
    {
      'title': 'Affiliate Commission Bonus',
      'type': 'Credit',
      'amount': '+৳1,200.00',
      'date': 'Nov 08, 2026 - 11:30 AM',
      'status': 'Success',
      'icon': Icons.card_giftcard_rounded,
      'color': Colors.green,
    },
    {
      'title': 'Bank Withdrawal WD-2026-001',
      'type': 'Debit',
      'amount': '-৳10,000.00',
      'date': 'Nov 05, 2026 - 09:20 AM',
      'status': 'Processed',
      'icon': Icons.account_balance_rounded,
      'color': Colors.redAccent,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTopUpModal(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    String selectedGateway = 'bKash';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(ctx).viewInsets.bottom + 30.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top up your wallet',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColorsTheme.textMainColor(context)),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            UIHelper.verticalSpace(16.h),
            Text(
              'Enter Top-up Amount (BDT)',
              style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
            ),
            UIHelper.verticalSpace(6.h),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 14.sp, color: AppColorsTheme.textMainColor(context)),
              decoration: InputDecoration(
                hintText: 'e.g. 5000',
                hintStyle: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
                ),
              ),
            ),
            UIHelper.verticalSpace(16.h),
            Text(
              'Select Payment Gateway',
              style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
            ),
            UIHelper.verticalSpace(8.h),
            StatefulBuilder(
              builder: (context, setModalState) => Row(
                children: ['bKash', 'Nagad', 'Card'].map((gw) {
                  final isSelected = selectedGateway == gw;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setModalState(() {
                          selectedGateway = gw;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(vertical: 10.h),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryOrange.withValues(alpha: 0.15) : AppColorsTheme.background(context),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context),
                            width: isSelected ? 1.5.w : 1.w,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            gw,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? primaryOrange : AppColorsTheme.textMainColor(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            UIHelper.verticalSpace(24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amt = amountController.text.trim();
                  if (amt.isEmpty || (double.tryParse(amt) ?? 0) <= 0) {
                    ToastUtil.showErrorMessage('Please enter a valid amount');
                    return;
                  }
                  Navigator.pop(ctx);
                  ToastUtil.showSuccessMessage('Successfully topped up ৳$amt via $selectedGateway!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                child: Text('Proceed to Payment', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredTransactions = _selectedFilter == 'All'
        ? _dummyTransactions
        : _dummyTransactions.where((t) => t['type'] == _selectedFilter).toList();

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.cardBg(context),
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColorsTheme.textMainColor(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Wallet',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showTopUpModal(context),
            icon: Icon(Icons.add_circle_outline_rounded, size: 16.sp, color: primaryOrange),
            label: Text('Top Up', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryOrange)),
          ),
          UIHelper.horizontalSpace(8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'What your account holds, and every movement behind it.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColorsTheme.textMutedColor(context),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12.sp, color: Colors.green),
                      UIHelper.horizontalSpace(4.w),
                      Text('Healthy', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(16.h),

            // Professional Top Up Banner CTA
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryOrange, primaryOrange.withValues(alpha: 0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: primaryOrange.withValues(alpha: 0.3),
                    blurRadius: 12.r,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24.sp),
                  ),
                  UIHelper.horizontalSpace(14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add funds instantly',
                          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        UIHelper.verticalSpace(2.h),
                        Text(
                          'Top up via bKash, Nagad or Card',
                          style: TextStyle(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.9)),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showTopUpModal(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: primaryOrange,
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                      elevation: 0,
                    ),
                    child: Text('Top Up', style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(20.h),

            // 3 Balance Cards (Responsive 2-column Grid with Icons)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.25,
              children: [
                _buildBalanceCard(context, 'Total Balance', '৳24,500.00', 'Your total wallet balance.', Icons.account_balance_wallet_rounded),
                _buildBalanceCard(context, 'Available Balance', '৳18,200.00', 'Available for orders.', Icons.account_balance_rounded),
                _buildBalanceCard(context, 'Withdrawable', '৳12,000.00', 'Ready to withdraw.', Icons.payments_rounded),
              ],
            ),
            UIHelper.verticalSpace(24.h),

            // Balance Details Section
            Text(
              'Balance details',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
            ),
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
                  _buildDetailRow(context, 'Platform credit', '৳1,500.00', 'Withdrawable', '৳12,000.00'),
                  UIHelper.verticalSpace(10.h),
                  _buildDetailRow(context, 'Pending', '৳500.00', 'On hold', '৳0.00'),
                  UIHelper.verticalSpace(10.h),
                  _buildDetailRow(context, 'Minimum balance', '৳1,000.00', 'COD Settlement', '৳4,700.00'),
                  UIHelper.verticalSpace(10.h),
                  _buildDetailRow(context, 'Reserved', '৳0.00', 'Required deposit', '৳0.00'),
                ],
              ),
            ),
            UIHelper.verticalSpace(24.h),

            // Statement Section & Filter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Statement',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColorsTheme.borderColor(context)),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    dropdownColor: AppColorsTheme.cardBg(context),
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                    underline: const SizedBox.shrink(),
                    items: ['All', 'Credit', 'Debit'].map((val) {
                      return DropdownMenuItem(value: val, child: Text(val));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedFilter = val;
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            UIHelper.verticalSpace(12.h),

            // Transactions ListView
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredTransactions.length,
              itemBuilder: (context, index) {
                final tx = filteredTransactions[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 10.h),
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: AppColorsTheme.borderColor(context)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: (tx['color'] as Color).withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(tx['icon'], color: tx['color'], size: 20.sp),
                      ),
                      UIHelper.horizontalSpace(12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx['title'],
                              style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                            ),
                            UIHelper.verticalSpace(2.h),
                            Text(
                              tx['date'],
                              style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            tx['amount'],
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: tx['color']),
                          ),
                          UIHelper.verticalSpace(2.h),
                          Text(
                            tx['status'],
                            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, String title, String amount, String subtitle, IconData icon) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: primaryOrange.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryOrange, size: 14.sp),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: AppColorsTheme.textMainColor(context)),
                overflow: TextOverflow.ellipsis,
              ),
              UIHelper.verticalSpace(2.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 10.5.sp, color: AppColorsTheme.textMutedColor(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label1, String val1, String label2, String val2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label1,
                  style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              UIHelper.horizontalSpace(4.w),
              Text(val1, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
            ],
          ),
        ),
        UIHelper.horizontalSpace(16.w),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label2,
                  style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              UIHelper.horizontalSpace(4.w),
              Text(val2, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
            ],
          ),
        ),
      ],
    );
  }
}
