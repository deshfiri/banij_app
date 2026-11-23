import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../networks/api_access.dart';
import '../../../model/withdrawal_options_model.dart';
import '../finance_shared/finance_widgets.dart';

/// "Request Withdrawal" bottom sheet: amount, payout destination, submit.
/// Owns (and disposes) its amount controller.
class WithdrawalRequestSheet extends StatefulWidget {
  final WithdrawalOptionsModel? options;

  /// Called after a successful request, once the sheet has closed.
  final VoidCallback onSubmitted;

  const WithdrawalRequestSheet({super.key, required this.options, required this.onSubmitted});

  static void show(BuildContext context, {required WithdrawalOptionsModel? options, required VoidCallback onSubmitted}) {
    showFinanceSheet(
      context,
      builder: (_) => WithdrawalRequestSheet(options: options, onSubmitted: onSubmitted),
    );
  }

  @override
  State<WithdrawalRequestSheet> createState() => _WithdrawalRequestSheetState();
}

class _WithdrawalRequestSheetState extends State<WithdrawalRequestSheet> {
  final TextEditingController _amountController = TextEditingController();
  late final List<WithdrawalMethodItemModel> _methods = widget.options?.methods ?? [];
  late WithdrawalMethodItemModel? _selectedMethod = _methods.isNotEmpty
      ? _methods.firstWhere((m) => m.isDefault == true, orElse: () => _methods.first)
      : null;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amtStr = _amountController.text.trim();
    final amountNum = double.tryParse(amtStr) ?? 0;
    if (amtStr.isEmpty || amountNum <= 0) {
      ToastUtil.showErrorMessage('Please enter a valid withdrawal amount');
      return;
    }
    if (_methods.isEmpty || _selectedMethod == null) {
      ToastUtil.showErrorMessage('Please select a payout method');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final body = {
        "payout_method_id": _selectedMethod!.id,
        "amount": amountNum.toStringAsFixed(2),
      };
      await requestWithdrawalRxObj.requestWithdrawal(body);
      if (!mounted) return;
      Navigator.pop(context);
      ToastUtil.showSuccessMessage('Withdrawal request submitted successfully!');
      widget.onSubmitted();
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to submit withdrawal request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 30.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinanceSheetHeader(title: 'Request Withdrawal', onClose: () => Navigator.pop(context)),
          UIHelper.verticalSpace(16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const FinanceSheetLabel('Withdrawal Amount (BDT)'),
              Text(
                'Min: ${widget.options?.minimum?.formatted ?? '৳500.00'}',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: primaryOrange),
              ),
            ],
          ),
          UIHelper.verticalSpace(6.h),
          FinanceAmountField(controller: _amountController),
          UIHelper.verticalSpace(16.h),
          const FinanceSheetLabel('Payout Destination'),
          UIHelper.verticalSpace(8.h),
          _PayoutDestinationPicker(
            methods: _methods,
            selected: _selectedMethod,
            onChanged: (val) => setState(() => _selectedMethod = val),
          ),
          UIHelper.verticalSpace(24.h),
          FinanceSubmitButton(label: 'Submit Request', isLoading: _isSubmitting, onPressed: _submit),
        ],
      ),
    );
  }
}

/// Bordered dropdown of saved payout methods (or a "none saved" message).
class _PayoutDestinationPicker extends StatelessWidget {
  final List<WithdrawalMethodItemModel> methods;
  final WithdrawalMethodItemModel? selected;
  final ValueChanged<WithdrawalMethodItemModel> onChanged;

  const _PayoutDestinationPicker({required this.methods, required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                value: selected,
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
                  if (val != null) onChanged(val);
                },
              ),
            ),
    );
  }
}
