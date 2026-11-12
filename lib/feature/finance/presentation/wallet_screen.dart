import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../../dashboard/model/payment_model.dart';
import '../model/wallet_balance_model.dart';
import '../model/wallet_transaction_model.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  WalletBalanceResponseModel? _walletBalanceModel;
  WalletTransactionListModel? _walletTransactionListModel;

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
    _fetchWalletTransactions();
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final res = await walletBalanceRxObj.fetchWalletBalance();
      if (mounted) {
        setState(() {
          _walletBalanceModel = res;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchWalletTransactions() async {
    try {
      final res = await walletTransactionRxObj.fetchWalletTransactions();
      if (mounted) {
        setState(() {
          _walletTransactionListModel = res;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showTopUpModal(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    PaymentMethodResponseModel? paymentModel;
    bool isLoadingGateways = true;
    String selectedGatewayCode = 'bkash';
    bool isTopUpLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          if (isLoadingGateways && paymentModel == null) {
            paymentRxObj.fetchPaymentMethods().then((res) {
              if (ctx.mounted) {
                setModalState(() {
                  paymentModel = res;
                  isLoadingGateways = false;
                  if (res.data != null && res.data!.isNotEmpty) {
                    selectedGatewayCode = res.data!.first.code ?? res.data!.first.id ?? 'bkash';
                  } else if (res.types != null && res.types!.isNotEmpty) {
                    selectedGatewayCode = res.types!.first.value ?? 'bkash';
                  }
                });
              }
            }).catchError((_) {
              if (ctx.mounted) {
                setModalState(() {
                  isLoadingGateways = false;
                });
              }
            });
          }

          final apiMethods = paymentModel?.data ?? [];
          final apiTypes = paymentModel?.types ?? [];

          return Padding(
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
                isLoadingGateways
                    ? Center(child: Padding(padding: EdgeInsets.all(12.h), child: CircularProgressIndicator(color: primaryOrange, strokeWidth: 2)))
                    : Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: apiMethods.isNotEmpty
                            ? apiMethods.map((m) {
                                final code = (m.code ?? m.id ?? 'bkash').toLowerCase();
                                final name = m.name ?? code;
                                final isSelected = selectedGatewayCode.toLowerCase() == code;
                                return ChoiceChip(
                                  label: Text(name),
                                  selected: isSelected,
                                  selectedColor: primaryOrange,
                                  backgroundColor: AppColorsTheme.background(context),
                                  labelStyle: TextStyle(
                                    fontSize: 12.sp,
                                    color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  ),
                                  onSelected: (val) {
                                    setModalState(() {
                                      selectedGatewayCode = code;
                                    });
                                  },
                                );
                              }).toList()
                            : apiTypes.isNotEmpty
                                ? apiTypes.map((t) {
                                    final val = (t.value ?? 'bkash').toLowerCase();
                                    final label = t.label ?? val;
                                    final isSelected = selectedGatewayCode.toLowerCase() == val;
                                    return ChoiceChip(
                                      label: Text(label),
                                      selected: isSelected,
                                      selectedColor: primaryOrange,
                                      backgroundColor: AppColorsTheme.background(context),
                                      labelStyle: TextStyle(
                                        fontSize: 12.sp,
                                        color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                      onSelected: (valSel) {
                                        setModalState(() {
                                          selectedGatewayCode = val;
                                        });
                                      },
                                    );
                                  }).toList()
                                : [
                                    {'label': 'bKash', 'code': 'bkash'},
                                    {'label': 'Nagad', 'code': 'nagad'},
                                    {'label': 'SSLCommerz', 'code': 'sslcommerz'},
                                  ].map((item) {
                                    final code = item['code']!;
                                    final label = item['label']!;
                                    final isSelected = selectedGatewayCode == code;
                                    return ChoiceChip(
                                      label: Text(label),
                                      selected: isSelected,
                                      selectedColor: primaryOrange,
                                      backgroundColor: AppColorsTheme.background(context),
                                      labelStyle: TextStyle(
                                        fontSize: 12.sp,
                                        color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                      ),
                                      onSelected: (val) {
                                        setModalState(() {
                                          selectedGatewayCode = code;
                                        });
                                      },
                                    );
                                  }).toList(),
                      ),
                UIHelper.verticalSpace(24.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isTopUpLoading
                        ? null
                        : () async {
                            final amtStr = amountController.text.trim();
                            final amountNum = double.tryParse(amtStr) ?? 0;
                            if (amtStr.isEmpty || amountNum <= 0) {
                              ToastUtil.showErrorMessage('Please enter a valid amount');
                              return;
                            }

                            setModalState(() {
                              isTopUpLoading = true;
                            });

                            try {
                              final body = {
                                "amount": amountNum.toStringAsFixed(2),
                                "gateway": selectedGatewayCode,
                              };
                              final res = await walletTopUpRxObj.topUpWallet(body);
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                              if (res.redirectUrl != null && res.redirectUrl!.isNotEmpty) {
                                ToastUtil.showSuccessMessage('Top-up session created! Redirecting...');
                              } else {
                                ToastUtil.showSuccessMessage(res.message ?? 'Top-up initiated successfully!');
                              }
                              _fetchWalletBalance();
                              _fetchWalletTransactions();
                            } catch (e) {
                              setModalState(() {
                                isTopUpLoading = false;
                              });
                              String err = e.toString().replaceAll('Exception: ', '');
                              ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Top-up failed');
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                      elevation: 0,
                    ),
                    child: isTopUpLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.h,
                            child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text('Proceed to Payment', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final balanceData = _walletBalanceModel?.data;
    final apiTransactions = _walletTransactionListModel?.data ?? [];

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
                    color: (balanceData?.stateTone == 'success' ? Colors.green : primaryOrange).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded, size: 12.sp, color: balanceData?.stateTone == 'success' ? Colors.green : primaryOrange),
                      UIHelper.horizontalSpace(4.w),
                      Text(balanceData?.stateLabel ?? 'Healthy', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: balanceData?.stateTone == 'success' ? Colors.green : primaryOrange)),
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

            // 3 Balance Cards (Dynamic from GET /wallet)
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.25,
              children: [
                _buildBalanceCard(context, 'Total Balance', balanceData?.total?.formatted ?? '৳0.00', 'Your total wallet balance.', Icons.account_balance_wallet_rounded),
                _buildBalanceCard(context, 'Available Balance', balanceData?.usable?.formatted ?? '৳0.00', 'Available for orders.', Icons.account_balance_rounded),
                _buildBalanceCard(context, 'Withdrawable', balanceData?.withdrawable?.formatted ?? '৳0.00', 'Ready to withdraw.', Icons.payments_rounded),
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
                  _buildDetailRow(context, 'Platform credit', balanceData?.platformCredit?.formatted ?? '৳0.00', 'Withdrawable', balanceData?.withdrawable?.formatted ?? '৳0.00'),
                  UIHelper.verticalSpace(10.h),
                  _buildDetailRow(context, 'Pending', balanceData?.pending?.formatted ?? '৳0.00', 'On hold', balanceData?.hold?.formatted ?? '৳0.00'),
                  UIHelper.verticalSpace(10.h),
                  _buildDetailRow(context, 'Minimum balance', balanceData?.minimumBalance?.formatted ?? '৳0.00', 'COD Settlement', balanceData?.codReceivable?.formatted ?? '৳0.00'),
                  UIHelper.verticalSpace(10.h),
                  _buildDetailRow(context, 'Reserved', balanceData?.reserved?.formatted ?? '৳0.00', 'Required deposit', balanceData?.requiredDeposit?.formatted ?? '৳0.00'),
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

            // Transactions ListView (API data or empty state)
            apiTransactions.isEmpty
                ? Container(
                    padding: EdgeInsets.all(28.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 48.sp, color: AppColorsTheme.textMutedColor(context)),
                          UIHelper.verticalSpace(12.h),
                          Text(
                            'No transactions yet',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                          ),
                          UIHelper.verticalSpace(4.h),
                          Text(
                            'Top-ups, charges and earnings appear here as they happen.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: apiTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = apiTransactions[index];
                      final isCredit = tx.direction == 'credit';
                      final txColor = isCredit ? Colors.green : Colors.redAccent;
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
                                color: txColor.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                                color: txColor,
                                size: 20.sp,
                              ),
                            ),
                            UIHelper.horizontalSpace(12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    tx.typeLabel ?? tx.description ?? 'Transaction',
                                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                                  ),
                                  UIHelper.verticalSpace(2.h),
                                  Text(
                                    tx.at ?? 'Today',
                                    style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  tx.amount?.formatted ?? (isCredit ? '+${tx.credit?.formatted ?? '৳0.00'}' : '-${tx.debit?.formatted ?? '৳0.00'}'),
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: txColor),
                                ),
                                UIHelper.verticalSpace(2.h),
                                Text(
                                  tx.statusLabel ?? tx.status ?? 'Success',
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
