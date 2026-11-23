import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../../../networks/api_access.dart';
import '../../../../dashboard/model/location_division_model.dart';
import '../../../../dashboard/model/payment_model.dart';
import '../../../model/bank_branch_model.dart';
import '../../../model/bank_model.dart';
import '../finance_shared/finance_widgets.dart';
import 'bank_search_sheet.dart';
import 'payout_form_fields.dart';

/// Districts/branches loaded by the payout form. Owned by the screen so the
/// lists persist between openings of the sheet (unchanged behaviour).
class PayoutFormCache {
  List<DivisionData> districts = [];
  List<BankBranchItemModel> branches = [];
}

/// Add / edit payout method sheet. [existingMethod] is a [PaymentMethodModel],
/// a local method `Map`, or null for "add". Owns and disposes its controllers.
class PayoutMethodFormSheet extends StatefulWidget {
  static const String bankAccountType = 'Bank account';
  static const List<String> _fallbackBanks = [
    'AB BANK LIMITED',
    'AGRANI BANK LIMITED',
    'BRAC BANK LIMITED',
    'DUTCH-BANGLA BANK LIMITED',
    'ISLAMI BANK BANGLADESH LIMITED',
    'SONALI BANK LIMITED',
    'THE CITY BANK LIMITED',
  ];

  final dynamic existingMethod;
  final List<String> bankOptions;
  final List<BankItemModel> Function() banks;
  final List<DivisionData> Function() divisions;
  final PayoutFormCache cache;

  /// Called after a successful save, once the sheet has closed.
  final VoidCallback onSaved;

  const PayoutMethodFormSheet({
    super.key,
    required this.existingMethod,
    required this.bankOptions,
    required this.banks,
    required this.divisions,
    required this.cache,
    required this.onSaved,
  });

  static void show(
    BuildContext context, {
    dynamic existingMethod,
    required List<BankItemModel> Function() banks,
    required List<DivisionData> Function() divisions,
    required PayoutFormCache cache,
    required VoidCallback onSaved,
  }) {
    final loadedBanks = banks();
    final bankOptions = loadedBanks.isNotEmpty
        ? loadedBanks.map((b) => b.name ?? '').where((n) => n.isNotEmpty).toList()
        : _fallbackBanks;

    showFinanceSheet(
      context,
      builder: (_) => PayoutMethodFormSheet(
        existingMethod: existingMethod,
        bankOptions: bankOptions,
        banks: banks,
        divisions: divisions,
        cache: cache,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<PayoutMethodFormSheet> createState() => _PayoutMethodFormSheetState();
}

class _PayoutMethodFormSheetState extends State<PayoutMethodFormSheet> {
  static const List<String> _typeOptions = [PayoutMethodFormSheet.bankAccountType, 'bKash', 'Nagad'];
  static const List<String> _accountTypeOptions = ['Savings account', 'Current account', 'Business account'];
  static const List<String> _fallbackBranches = [
    'Principal Branch',
    'Gulshan Branch',
    'Banani Branch',
    'Agrabad Branch',
    'Dhanmondi Branch',
  ];

  late final bool _isEditMode = widget.existingMethod != null;
  late final String? _methodId;
  late String _selectedType;
  String? _selectedBank;
  String? _selectedDivision;
  String? _selectedDistrict;
  String? _selectedBranch;
  String? _selectedAccountType;
  late bool _isMakeDefault;
  bool _isSubmitting = false;

  late final TextEditingController _labelController;
  final TextEditingController _holderNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _confirmAccountNumberController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  PayoutFormCache get _cache => widget.cache;
  bool get _isBank => _selectedType == PayoutMethodFormSheet.bankAccountType;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingMethod;

    _methodId = _isEditMode
        ? (existing is PaymentMethodModel ? existing.id : (existing is Map ? existing['id']?.toString() : null))
        : null;

    _selectedType = PayoutMethodFormSheet.bankAccountType;
    if (_isEditMode) {
      final nameStr = existing is PaymentMethodModel
          ? (existing.code ?? existing.name ?? '')
          : (existing is Map ? (existing['title'] ?? '') : '');
      if (nameStr.toLowerCase().contains('bkash')) {
        _selectedType = 'bKash';
      } else if (nameStr.toLowerCase().contains('nagad')) {
        _selectedType = 'Nagad';
      }
    }

    _isMakeDefault = _isEditMode ? (existing is Map ? (existing['isDefault'] == true) : false) : false;

    _labelController = TextEditingController(
      text: _isEditMode
          ? (existing is PaymentMethodModel ? existing.name : (existing is Map ? existing['title'] : ''))
          : '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _holderNameController.dispose();
    _accountNumberController.dispose();
    _confirmAccountNumberController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Rebuilds the sheet if it is still open (lists are updated either way).
  void _refresh(VoidCallback update) {
    if (mounted) {
      setState(update);
    } else {
      update();
    }
  }

  String _divisionName(DivisionData d) => d.nameEn ?? d.nameBn ?? '';

  Future<void> _fetchDistrictsForDivision(String divisionSourceId) async {
    try {
      final res = await locationChildRxObj.fetchChildren('divisions', divisionSourceId);
      final districts = (res.data != null && res.data!.isNotEmpty) ? res.data! : <DivisionData>[];
      _refresh(() => _cache.districts = districts);
    } catch (_) {
      _refresh(() => _cache.districts = []);
    }
  }

  Future<void> _fetchBranchesForBank(String bankName, String? districtId) async {
    final loadedBanks = widget.banks();
    final matchedBank = loadedBanks.firstWhere(
      (b) =>
          (b.name ?? '').toLowerCase().contains(bankName.toLowerCase()) ||
          bankName.toLowerCase().contains((b.name ?? '').toLowerCase()),
      orElse: () => loadedBanks.isNotEmpty ? loadedBanks.first : BankItemModel(bankCode: '020', name: bankName),
    );
    final bankCode = matchedBank.bankCode ?? '020';

    try {
      final res = await bankBranchRxObj.fetchBranches(bankCode, districtId: districtId);
      final branches = (res.data != null && res.data!.isNotEmpty) ? res.data! : <BankBranchItemModel>[];
      _refresh(() => _cache.branches = branches);
    } catch (_) {
      _refresh(() => _cache.branches = []);
    }
  }

  String? _districtIdFor(String? districtName) {
    final matched = _cache.districts.firstWhere(
      (d) => _divisionName(d) == districtName,
      orElse: () => DivisionData(),
    );
    return matched.sourceId ?? matched.id?.toString();
  }

  void _openBankSearch() {
    BankSearchSheet.show(
      context,
      bankList: widget.bankOptions,
      onSelectBank: (selected) {
        setState(() {
          _selectedBank = selected;
          _selectedBranch = null;
          _cache.branches = [];
        });
        _fetchBranchesForBank(selected, _districtIdFor(_selectedDistrict));
      },
    );
  }

  void _onDivisionChanged(String? val) {
    setState(() {
      _selectedDivision = val;
      _selectedDistrict = null;
      _selectedBranch = null;
      _cache.districts = [];
      _cache.branches = [];
    });
    if (val != null) {
      final matchedDiv = widget.divisions().firstWhere(
            (d) => _divisionName(d) == val,
            orElse: () => DivisionData(),
          );
      final divSourceId = matchedDiv.sourceId ?? matchedDiv.id?.toString();
      if (divSourceId != null) _fetchDistrictsForDivision(divSourceId);
    }
  }

  void _onDistrictChanged(String? val) {
    setState(() {
      _selectedDistrict = val;
      _selectedBranch = null;
      _cache.branches = [];
    });
    if (_selectedBank != null && val != null) {
      _fetchBranchesForBank(_selectedBank!, _districtIdFor(val));
    }
  }

  Future<void> _submit() async {
    final label = _labelController.text.trim();
    final holderName = _holderNameController.text.trim();
    final accNum = _accountNumberController.text.trim();
    final confirmAccNum = _confirmAccountNumberController.text.trim();
    final password = _passwordController.text.trim();

    if (holderName.isEmpty) {
      ToastUtil.showErrorMessage('Account holder name is required');
      return;
    }
    if (accNum.isEmpty) {
      ToastUtil.showErrorMessage('Account number is required');
      return;
    }
    if (accNum != confirmAccNum) {
      ToastUtil.showErrorMessage('Account numbers do not match');
      return;
    }
    if (_isBank) {
      if (_selectedBank == null) {
        ToastUtil.showErrorMessage('Please select a Bank');
        return;
      }
      if (_selectedBranch == null) {
        ToastUtil.showErrorMessage('Please select a Branch');
        return;
      }
    }
    if (password.isEmpty) {
      ToastUtil.showErrorMessage('Current password is required');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final apiType = _isBank ? 'bank_account' : _selectedType.toLowerCase();

      String? bankCode;
      String? routingNumber;
      if (_isBank && _selectedBank != null) {
        final matchedBank = widget.banks().firstWhere(
              (b) => (b.name ?? '').toLowerCase().contains(_selectedBank!.toLowerCase()),
              orElse: () => BankItemModel(),
            );
        bankCode = matchedBank.bankCode;

        if (_selectedBranch != null) {
          final matchedBranch = _cache.branches.firstWhere(
            (br) => (br.name ?? '').toLowerCase() == _selectedBranch!.toLowerCase(),
            orElse: () => BankBranchItemModel(),
          );
          routingNumber = matchedBranch.routingNumber;
        }
      }

      final body = {
        "current_password": password,
        "type": apiType,
        "label": label.isNotEmpty ? label : (_isBank ? (_selectedBank ?? 'Bank Account') : _selectedType),
        "details": {
          "account_holder_name": holderName,
          "account_number": accNum,
        },
        if (bankCode != null && bankCode.isNotEmpty) "bank_code": bankCode,
        if (routingNumber != null && routingNumber.isNotEmpty) "routing_number": routingNumber,
        "is_default": _isMakeDefault,
      };

      if (_isEditMode && _methodId != null && _methodId.isNotEmpty) {
        await paymentRxObj.updatePayoutMethod(_methodId, body);
      } else {
        await paymentRxObj.addPayoutMethod(body);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ToastUtil.showSuccessMessage(
        _isEditMode ? 'Payout method updated successfully!' : 'Payout method saved successfully!',
      );
      widget.onSaved();
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to save payout method');
    }
  }

  @override
  Widget build(BuildContext context) {
    final divisionOptions = widget.divisions().map(_divisionName).where((n) => n.isNotEmpty).toList();
    final districtOptions = _cache.districts.map(_divisionName).where((n) => n.isNotEmpty).toList();
    final branchOptions = _cache.branches.isNotEmpty
        ? _cache.branches.map((b) => b.name ?? '').where((n) => n.isNotEmpty).toList()
        : _fallbackBranches;
    final numberKeyboard = _isBank ? TextInputType.number : TextInputType.phone;
    final gap = UIHelper.verticalSpace(14.h);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.88,
      child: Column(
        children: [
          _FormHeader(isEditMode: _isEditMode, onClose: () => Navigator.pop(context)),
          Divider(color: AppColorsTheme.borderColor(context), height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const PayoutFieldLabel('Type'),
                  PayoutDropdownField(
                    value: _selectedType,
                    items: _typeOptions,
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedType = val);
                    },
                  ),
                  gap,

                  const PayoutFieldLabel('Label'),
                  PayoutTextField(controller: _labelController, hintText: 'e.g. Primary Bank Account'),
                  gap,

                  if (_isBank) ...[
                    const PayoutFieldLabel('Bank'),
                    PayoutSelectField(value: _selectedBank, onTap: _openBankSearch),
                    gap,

                    const PayoutFieldLabel('Division'),
                    PayoutDropdownField(
                      value: _selectedDivision,
                      items: divisionOptions,
                      onChanged: _onDivisionChanged,
                    ),
                    gap,

                    const PayoutFieldLabel('District'),
                    PayoutDropdownField(
                      value: _selectedDistrict,
                      items: districtOptions,
                      onChanged: _onDistrictChanged,
                    ),
                    gap,

                    const PayoutFieldLabel('Branch'),
                    PayoutDropdownField(
                      value: _selectedBranch,
                      items: branchOptions,
                      onChanged: (val) => setState(() => _selectedBranch = val),
                    ),
                    gap,
                  ],

                  const PayoutFieldLabel('Account holder name'),
                  PayoutTextField(controller: _holderNameController, hintText: 'e.g. Mohammad Ashraf'),
                  gap,

                  PayoutFieldLabel(_isBank ? 'Account number' : 'Mobile number'),
                  PayoutTextField(
                    controller: _accountNumberController,
                    hintText: _isBank ? 'e.g. 1251092840001' : 'e.g. 01619005832',
                    keyboardType: numberKeyboard,
                  ),
                  gap,

                  if (_isBank) ...[
                    const PayoutFieldLabel('Account type'),
                    PayoutDropdownField(
                      value: _selectedAccountType,
                      items: _accountTypeOptions,
                      onChanged: (val) => setState(() => _selectedAccountType = val),
                    ),
                    gap,
                  ],

                  const PayoutFieldLabel('Confirm account number'),
                  PayoutTextField(
                    controller: _confirmAccountNumberController,
                    hintText: 'Re-enter account/mobile number',
                    keyboardType: numberKeyboard,
                  ),
                  gap,

                  _MakeDefaultCheckbox(
                    value: _isMakeDefault,
                    onChanged: (val) => setState(() => _isMakeDefault = val),
                  ),
                  gap,

                  const PayoutFieldLabel('Current password'),
                  PayoutTextField(
                    controller: _passwordController,
                    hintText: 'Enter current password for security',
                    obscureText: true,
                  ),
                  UIHelper.verticalSpace(24.h),

                  FinanceSubmitButton(
                    label: _isEditMode ? 'Update Payout Method' : 'Save Payout Method',
                    isLoading: _isSubmitting,
                    onPressed: _submit,
                  ),
                  UIHelper.verticalSpace(20.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Title + explanation + close button at the top of the form sheet.
class _FormHeader extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onClose;

  const _FormHeader({required this.isEditMode, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditMode ? 'Edit payout method' : 'Add payout method',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  'Where your withdrawals are paid. Only the last four digits are ever shown again after saving.',
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close_rounded, color: AppColorsTheme.textMainColor(context)),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _MakeDefaultCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _MakeDefaultCheckbox({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 22.w,
          height: 22.h,
          child: Checkbox(
            value: value,
            activeColor: primaryOrange,
            onChanged: (val) => onChanged(val ?? false),
          ),
        ),
        UIHelper.horizontalSpace(8.w),
        Text(
          'Make default',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ],
    );
  }
}
