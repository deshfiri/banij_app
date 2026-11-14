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
    final methods = _withdrawalOptionsModel?.methods ?? [];
    WithdrawalMethodItemModel? selectedMethod = methods.isNotEmpty
        ? methods.firstWhere((m) => m.isDefault == true, orElse: () => methods.first)
        : null;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
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
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColorsTheme.background(context),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColorsTheme.borderColor(context)),
                ),
                child: methods.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Text(
                          'No payout method saved',
                          style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
                        ),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<WithdrawalMethodItemModel>(
                          value: selectedMethod,
                          isExpanded: true,
                          dropdownColor: AppColorsTheme.cardBg(context),
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                          items: methods.map((m) {
                            return DropdownMenuItem<WithdrawalMethodItemModel>(
                              value: m,
                              child: Row(
                                children: [
                                  Icon(Icons.credit_card_rounded, color: primaryOrange, size: 18.sp),
                                  UIHelper.horizontalSpace(8.w),
                                  Expanded(
                                    child: Text(
                                      '${m.typeLabel ?? m.label ?? 'Account'} (${m.maskedNumber ?? ''})',
                                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedMethod = val;
                              });
                            }
                          },
                        ),
                      ),
              ),
              UIHelper.verticalSpace(24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final amtStr = amountController.text.trim();
                          final amountNum = double.tryParse(amtStr) ?? 0;
                          if (amtStr.isEmpty || amountNum <= 0) {
                            ToastUtil.showErrorMessage('Please enter a valid withdrawal amount');
                            return;
                          }
                          if (methods.isEmpty || selectedMethod == null) {
                            ToastUtil.showErrorMessage('Please select a payout method');
                            return;
                          }

                          setModalState(() {
                            isSubmitting = true;
                          });

                          try {
                            final body = {
                              "payout_method_id": selectedMethod!.id,
                              "amount": amountNum.toStringAsFixed(2),
                            };
                            await requestWithdrawalRxObj.requestWithdrawal(body);
                            if (!ctx.mounted) return;
                            Navigator.pop(ctx);
                            ToastUtil.showSuccessMessage('Withdrawal request submitted successfully!');
                            _fetchWithdrawals();
                            _fetchWithdrawalOptions();
                          } catch (e) {
                            setModalState(() {
                              isSubmitting = false;
                            });
                            String err = e.toString().replaceAll('Exception: ', '');
                            ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to submit withdrawal request');
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text('Submit Request', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
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
            apiItems.isEmpty
                ? Container(
                    padding: EdgeInsets.all(36.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.payments_outlined, size: 48.sp, color: AppColorsTheme.textMutedColor(context)),
                          UIHelper.verticalSpace(12.h),
                          Text(
                            'No withdrawals yet',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                          ),
                          UIHelper.verticalSpace(4.h),
                          Text(
                            'Request a withdrawal from your wallet once you have a payout method saved.',
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
                  ),
          ],
        ),
      ),
    );
  }
}
