import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../networks/api_access.dart';
import '../../../../dashboard/model/payment_model.dart';
import '../finance_shared/finance_widgets.dart';

/// "Top up your wallet" bottom sheet: amount, gateway chips, proceed.
/// Loads the payment gateways once when opened and disposes its controller.
class WalletTopUpSheet extends StatefulWidget {
  /// Called after a successful top-up, once the sheet has closed.
  final VoidCallback onToppedUp;

  const WalletTopUpSheet({super.key, required this.onToppedUp});

  static void show(BuildContext context, {required VoidCallback onToppedUp}) {
    showFinanceSheet(context, builder: (_) => WalletTopUpSheet(onToppedUp: onToppedUp));
  }

  @override
  State<WalletTopUpSheet> createState() => _WalletTopUpSheetState();
}

class _WalletTopUpSheetState extends State<WalletTopUpSheet> {
  static const List<Map<String, String>> _fallbackGateways = [
    {'label': 'bKash', 'code': 'bkash'},
    {'label': 'Nagad', 'code': 'nagad'},
    {'label': 'SSLCommerz', 'code': 'sslcommerz'},
  ];

  final TextEditingController _amountController = TextEditingController();
  PaymentMethodResponseModel? _paymentModel;
  bool _isLoadingGateways = true;
  String _selectedGatewayCode = 'bkash';
  bool _isTopUpLoading = false;

  @override
  void initState() {
    super.initState();
    _loadGateways();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _loadGateways() {
    paymentRxObj.fetchPaymentMethods().then((res) {
      if (!mounted) return;
      setState(() {
        _paymentModel = res;
        _isLoadingGateways = false;
        if (res.data != null && res.data!.isNotEmpty) {
          _selectedGatewayCode = res.data!.first.code ?? res.data!.first.id ?? 'bkash';
        } else if (res.types != null && res.types!.isNotEmpty) {
          _selectedGatewayCode = res.types!.first.value ?? 'bkash';
        }
      });
    }).catchError((_) {
      if (mounted) setState(() => _isLoadingGateways = false);
    });
  }

  Future<void> _proceed() async {
    final amtStr = _amountController.text.trim();
    final amountNum = double.tryParse(amtStr) ?? 0;
    if (amtStr.isEmpty || amountNum <= 0) {
      ToastUtil.showErrorMessage('Please enter a valid amount');
      return;
    }

    setState(() => _isTopUpLoading = true);

    try {
      final body = {
        "amount": amountNum.toStringAsFixed(2),
        "gateway": _selectedGatewayCode,
      };
      final res = await walletTopUpRxObj.topUpWallet(body);
      if (!mounted) return;
      Navigator.pop(context);
      if (res.redirectUrl != null && res.redirectUrl!.isNotEmpty) {
        ToastUtil.showSuccessMessage('Top-up session created! Redirecting...');
      } else {
        ToastUtil.showSuccessMessage(res.message ?? 'Top-up initiated successfully!');
      }
      widget.onToppedUp();
    } catch (e) {
      if (mounted) setState(() => _isTopUpLoading = false);
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Top-up failed');
    }
  }

  /// Chips from the API methods, else API types, else the built-in fallbacks.
  /// API codes are compared case-insensitively; fallback codes exactly (as before).
  List<Widget> _gatewayChips() {
    final apiMethods = _paymentModel?.data ?? [];
    final apiTypes = _paymentModel?.types ?? [];
    void select(String code) => setState(() => _selectedGatewayCode = code);

    if (apiMethods.isNotEmpty) {
      return apiMethods.map((m) {
        final code = (m.code ?? m.id ?? 'bkash').toLowerCase();
        return _GatewayChip(
          label: m.name ?? code,
          selected: _selectedGatewayCode.toLowerCase() == code,
          onSelected: () => select(code),
        );
      }).toList();
    }
    if (apiTypes.isNotEmpty) {
      return apiTypes.map((t) {
        final val = (t.value ?? 'bkash').toLowerCase();
        return _GatewayChip(
          label: t.label ?? val,
          selected: _selectedGatewayCode.toLowerCase() == val,
          onSelected: () => select(val),
        );
      }).toList();
    }
    return _fallbackGateways.map((item) {
      final code = item['code']!;
      return _GatewayChip(
        label: item['label']!,
        selected: _selectedGatewayCode == code,
        onSelected: () => select(code),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, MediaQuery.of(context).viewInsets.bottom + 30.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FinanceSheetHeader(title: 'Top up your wallet', onClose: () => Navigator.pop(context)),
          UIHelper.verticalSpace(16.h),
          const FinanceSheetLabel('Enter Top-up Amount (BDT)'),
          UIHelper.verticalSpace(6.h),
          FinanceAmountField(controller: _amountController),
          UIHelper.verticalSpace(16.h),
          const FinanceSheetLabel('Select Payment Gateway'),
          UIHelper.verticalSpace(8.h),
          _isLoadingGateways
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(12.h),
                    child: CircularProgressIndicator(color: primaryOrange, strokeWidth: 2),
                  ),
                )
              : Wrap(spacing: 8.w, runSpacing: 8.h, children: _gatewayChips()),
          UIHelper.verticalSpace(24.h),
          FinanceSubmitButton(label: 'Proceed to Payment', isLoading: _isTopUpLoading, onPressed: _proceed),
        ],
      ),
    );
  }
}

class _GatewayChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onSelected;

  const _GatewayChip({required this.label, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: primaryOrange,
      backgroundColor: AppColorsTheme.background(context),
      labelStyle: TextStyle(
        fontSize: 12.sp,
        color: selected ? Colors.white : AppColorsTheme.textMainColor(context),
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
      ),
      onSelected: (_) => onSelected(),
    );
  }
}
