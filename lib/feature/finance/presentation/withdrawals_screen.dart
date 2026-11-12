import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/withdrawal_list_model.dart';
import '../model/withdrawal_options_model.dart';

class WithdrawalsScreen extends StatefulWidget {
  const WithdrawalsScreen({super.key});

  @override
  State<WithdrawalsScreen> createState() => _WithdrawalsScreenState();
}

class _WithdrawalsScreenState extends State<WithdrawalsScreen> {
  WithdrawalOptionsModel? _withdrawalOptionsModel;
  WithdrawalListResponseModel? _withdrawalListModel;

  final List<Map<String, dynamic>> _dummyWithdrawals = [
    {
      'id': 'WD-2026-001',
      'amount': '৳10,000.00',
      'method': 'bKash (****5832)',
      'date': 'Nov 05, 2026',
      'status': 'Completed',
    },
    {
      'id': 'WD-2026-002',
      'amount': '৳5,500.00',
      'method': 'City Bank Account (****4912)',
      'date': 'Oct 28, 2026',
      'status': 'Pending',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchWithdrawalOptions();
    _fetchWithdrawals();
  }

  Future<void> _fetchWithdrawalOptions() async {
    try {
      final res = await withdrawalOptionsRxObj.fetchWithdrawalOptions();
      if (mounted) {
        setState(() {
          _withdrawalOptionsModel = res;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchWithdrawals() async {
    try {
      final res = await withdrawalListRxObj.fetchWithdrawalList();
      if (mounted) {
        setState(() {
          _withdrawalListModel = res;
        });
      }
    } catch (_) {}
  }

  void _showRequestModal(BuildContext context) {
    final TextEditingController amountController = TextEditingController();
    String selectedMethod = 'bKash (****5832)';

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
                  'Request Withdrawal',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Withdrawal Amount (BDT)',
                  style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                ),
                Text(
                  'Min: ${_withdrawalOptionsModel?.minimum?.formatted ?? '৳500.00'}',
                  style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: primaryOrange),
                ),
              ],
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
              'Payout Destination',
              style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
            ),
            UIHelper.verticalSpace(8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColorsTheme.background(context),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
              ),
              child: Row(
                children: [
                  Icon(Icons.credit_card_rounded, color: primaryOrange, size: 20.sp),
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: Text(
                      selectedMethod,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                    ),
                  ),
                ],
              ),
            ),
            UIHelper.verticalSpace(24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final amt = amountController.text.trim();
                  if (amt.isEmpty || (double.tryParse(amt) ?? 0) <= 0) {
                    ToastUtil.showErrorMessage('Please enter a valid withdrawal amount');
                    return;
                  }
                  Navigator.pop(ctx);
                  setState(() {
                    _dummyWithdrawals.insert(0, {
                      'id': 'WD-2026-003',
                      'amount': '৳$amt',
                      'method': selectedMethod,
                      'date': 'Today',
                      'status': 'Pending',
                    });
                  });
                  ToastUtil.showSuccessMessage('Withdrawal request of ৳$amt submitted successfully!');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
                child: Text('Submit Request', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiItems = _withdrawalListModel?.data ?? [];
    final hasApiItems = apiItems.isNotEmpty;

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
          'Withdrawals',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showRequestModal(context),
            icon: Icon(Icons.add_circle_outline_rounded, size: 16.sp, color: primaryOrange),
            label: Text('Request', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryOrange)),
          ),
          UIHelper.horizontalSpace(8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Requests to withdraw from your available balance.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showRequestModal(context),
                icon: Icon(Icons.payments_outlined, size: 18.sp),
                label: Text('Request withdrawal', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                  elevation: 0,
                ),
              ),
            ),
            UIHelper.verticalSpace(20.h),
            hasApiItems
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: apiItems.length,
                    itemBuilder: (context, index) {
                      final item = apiItems[index];
                      final isCompleted = item.status == 'paid' || item.status == 'approved' || item.statusTone == 'success';
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
                                color: (isCompleted ? Colors.green : Colors.orange).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.account_balance_wallet_outlined, color: isCompleted ? Colors.green : Colors.orange, size: 20.sp),
                            ),
                            UIHelper.horizontalSpace(12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.reference ?? item.id ?? 'WD-REQUEST',
                                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                                  ),
                                  UIHelper.verticalSpace(2.h),
                                  Text(
                                    '${item.payout?.typeLabel ?? item.payout?.label ?? 'Payout'} (${item.payout?.maskedNumber ?? ''})',
                                    style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item.amount?.formatted ?? '৳0.00',
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                                ),
                                UIHelper.verticalSpace(2.h),
                                Text(
                                  item.statusLabel ?? item.status ?? 'Pending',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? Colors.green : Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _dummyWithdrawals.length,
                    itemBuilder: (context, index) {
                      final item = _dummyWithdrawals[index];
                      final isCompleted = item['status'] == 'Completed';
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
                                color: (isCompleted ? Colors.green : Colors.orange).withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.account_balance_wallet_outlined, color: isCompleted ? Colors.green : Colors.orange, size: 20.sp),
                            ),
                            UIHelper.horizontalSpace(12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['id'],
                                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                                  ),
                                  UIHelper.verticalSpace(2.h),
                                  Text(
                                    item['method'],
                                    style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  item['amount'],
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                                ),
                                UIHelper.verticalSpace(2.h),
                                Text(
                                  item['status'],
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isCompleted ? Colors.green : Colors.orange,
                                  ),
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
}
