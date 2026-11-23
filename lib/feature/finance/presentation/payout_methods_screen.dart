import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../../dashboard/model/location_division_model.dart';
import '../../dashboard/model/payment_model.dart';
import '../model/bank_model.dart';
import 'widgets/finance_shared/finance_widgets.dart';
import 'widgets/payout_methods/payout_method_form_sheet.dart';
import 'widgets/payout_methods/payout_method_tile.dart';

class PayoutMethodsScreen extends StatefulWidget {
  const PayoutMethodsScreen({super.key});

  @override
  State<PayoutMethodsScreen> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends State<PayoutMethodsScreen> {
  static const String _intro =
      'Where your withdrawals are paid. Only the last four digits are ever shown again after saving.';

  List<BankItemModel> _loadedBanks = [];
  List<DivisionData> _loadedDivisions = [];
  final PayoutFormCache _formCache = PayoutFormCache();
  PaymentMethodResponseModel? _paymentResponseModel;

  /// Shown until the API returns methods/types. Kept as maps: the form
  /// sheet's edit mode reads `id`, `title` and `isDefault` from them.
  final List<Map<String, dynamic>> _payoutMethods = [
    {
      'id': '01M77QBDG2C1RCV76J97VCXNY8',
      'title': 'bKash Personal',
      'detail': 'Mohammad Ashraf (****5832)',
      'isDefault': true,
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'id': '01M77QBDG2C1RCV76J97VCXNY9',
      'title': 'City Bank Account',
      'detail': 'Mohammad Ashraf (****4912)',
      'isDefault': false,
      'icon': Icons.account_balance_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchBanks();
    _fetchPaymentMethods();
    _fetchDivisions();
  }

  Future<void> _fetchBanks() async {
    try {
      final res = await bankRxObj.fetchBankList();
      if (res.data != null && res.data!.isNotEmpty && mounted) {
        setState(() => _loadedBanks = res.data!);
      }
    } catch (_) {}
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final res = await paymentRxObj.fetchPaymentMethods();
      if (mounted) setState(() => _paymentResponseModel = res);
    } catch (_) {}
  }

  Future<void> _fetchDivisions() async {
    try {
      final res = await locationDivisionRxObj.fetchDivisions();
      if (res.data != null && res.data!.isNotEmpty && mounted) {
        setState(() => _loadedDivisions = res.data!);
      }
    } catch (_) {}
  }

  void _showAddMethodModal({dynamic existingMethod}) {
    PayoutMethodFormSheet.show(
      context,
      existingMethod: existingMethod,
      banks: () => _loadedBanks,
      divisions: () => _loadedDivisions,
      cache: _formCache,
      onSaved: _fetchPaymentMethods,
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiMethods = _paymentResponseModel?.data ?? [];
    final apiTypes = _paymentResponseModel?.types ?? [];
    final hasApiMethods = apiMethods.isNotEmpty || apiTypes.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: financeAppBar(context, title: 'Payout methods', actionLabel: 'Add', onAction: _showAddMethodModal),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FinanceIntroText(_intro),
            UIHelper.verticalSpace(16.h),
            FinancePrimaryButton(
              icon: Icons.credit_card_rounded,
              label: 'Add payout method',
              onPressed: _showAddMethodModal,
            ),
            UIHelper.verticalSpace(20.h),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: hasApiMethods
                  ? (apiMethods.isNotEmpty ? apiMethods.length : apiTypes.length)
                  : _payoutMethods.length,
              itemBuilder: (context, index) => hasApiMethods
                  ? _buildApiTile(apiMethods, apiTypes, index)
                  : _buildLocalTile(index),
            ),
          ],
        ),
      ),
    );
  }

  /// Saved methods from the API, or (when none) the available method types.
  Widget _buildApiTile(List<PaymentMethodModel> apiMethods, List<PaymentTypeModel> apiTypes, int index) {
    final fromMethods = apiMethods.isNotEmpty;
    final item = fromMethods ? apiMethods[index] : null;

    return PayoutMethodTile(
      icon: Icons.account_balance_wallet_rounded,
      title: fromMethods
          ? (apiMethods[index].name ?? 'Payout Method')
          : (apiTypes[index].label ?? apiTypes[index].value ?? 'Payout Method'),
      subtitle: fromMethods
          ? (apiMethods[index].description ?? 'Configured account')
          : 'Fields: ${apiTypes[index].fields?.join(", ") ?? ""}',
      redArchiveLabel: true,
      onEdit: () => _showAddMethodModal(existingMethod: item),
      onArchive: () => ToastUtil.showSuccessMessage('Payout method archived'),
    );
  }

  /// Built-in placeholder methods (archive removes them locally).
  Widget _buildLocalTile(int index) {
    final item = _payoutMethods[index];

    return PayoutMethodTile(
      icon: item['icon'],
      title: item['title'],
      subtitle: item['detail'],
      isDefault: item['isDefault'] == true,
      titleInRow: true,
      onEdit: () => _showAddMethodModal(existingMethod: item),
      onArchive: () {
        setState(() => _payoutMethods.removeAt(index));
        ToastUtil.showSuccessMessage('Payout method archived');
      },
    );
  }
}
