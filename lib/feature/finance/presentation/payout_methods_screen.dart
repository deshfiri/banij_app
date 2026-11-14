import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../../dashboard/model/location_division_model.dart';
import '../../dashboard/model/payment_model.dart';
import '../model/bank_branch_model.dart';
import '../model/bank_model.dart';

class PayoutMethodsScreen extends StatefulWidget {
  const PayoutMethodsScreen({super.key});

  @override
  State<PayoutMethodsScreen> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends State<PayoutMethodsScreen> {
  List<BankItemModel> _loadedBanks = [];
  List<DivisionData> _loadedDivisions = [];
  List<DivisionData> _loadedDistricts = [];
  List<BankBranchItemModel> _loadedBranches = [];
  PaymentMethodResponseModel? _paymentResponseModel;

  final List<Map<String, dynamic>> _payoutMethods = [
    {
      'title': 'bKash Personal',
      'detail': 'Mohammad Ashraf (****5832)',
      'isDefault': true,
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
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
      if (res.data != null && res.data!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _loadedBanks = res.data!;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final res = await paymentRxObj.fetchPaymentMethods();
      if (mounted) {
        setState(() {
          _paymentResponseModel = res;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchDivisions() async {
    try {
      final res = await locationDivisionRxObj.fetchDivisions();
      if (res.data != null && res.data!.isNotEmpty) {
        if (mounted) {
          setState(() {
            _loadedDivisions = res.data!;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchDistrictsForDivision(String divisionSourceId, StateSetter setModalState) async {
    try {
      final res = await locationChildRxObj.fetchChildren('divisions', divisionSourceId);
      if (res.data != null && res.data!.isNotEmpty) {
        setModalState(() {
          _loadedDistricts = res.data!;
        });
      } else {
        setModalState(() {
          _loadedDistricts = [];
        });
      }
    } catch (_) {
      setModalState(() {
        _loadedDistricts = [];
      });
    }
  }

  Future<void> _fetchBranchesForBank(String bankName, String? districtId, StateSetter setModalState) async {
    final matchedBank = _loadedBanks.firstWhere(
      (b) => (b.name ?? '').toLowerCase().contains(bankName.toLowerCase()) || bankName.toLowerCase().contains((b.name ?? '').toLowerCase()),
      orElse: () => _loadedBanks.isNotEmpty ? _loadedBanks.first : BankItemModel(bankCode: '020', name: bankName),
    );
    final bankCode = matchedBank.bankCode ?? '020';

    try {
      final res = await bankBranchRxObj.fetchBranches(bankCode, districtId: districtId);
      if (res.data != null && res.data!.isNotEmpty) {
        setModalState(() {
          _loadedBranches = res.data!;
        });
      } else {
        setModalState(() {
          _loadedBranches = [];
        });
      }
    } catch (_) {
      setModalState(() {
        _loadedBranches = [];
      });
    }
  }

  void _showBankSearchSheet(
    BuildContext context,
    List<String> bankList,
    ValueChanged<String> onSelectBank,
  ) {
    String searchQuery = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          final filteredList = searchQuery.isEmpty
              ? bankList
              : bankList.where((b) => b.toLowerCase().contains(searchQuery.toLowerCase())).toList();

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Bank',
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
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                  child: TextField(
                    autofocus: true,
                    onChanged: (val) => setSheetState(() => searchQuery = val),
                    style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
                    decoration: InputDecoration(
                      hintText: 'Search bank name...',
                      hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                      prefixIcon: Icon(Icons.search_rounded, color: primaryOrange, size: 20.sp),
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                      filled: true,
                      fillColor: AppColorsTheme.background(context),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: primaryOrange, width: 1.5.w),
                      ),
                    ),
                  ),
                ),
                UIHelper.verticalSpace(8.h),
                Divider(color: AppColorsTheme.borderColor(context), height: 1),
                Expanded(
                  child: filteredList.isEmpty
                      ? Center(
                          child: Text(
                            'No bank found',
                            style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                          itemCount: filteredList.length,
                          separatorBuilder: (c, i) => Divider(color: AppColorsTheme.borderColor(context).withValues(alpha: 0.5), height: 1),
                          itemBuilder: (context, index) {
                            final bankName = filteredList[index];
                            return ListTile(
                              leading: Icon(Icons.account_balance_rounded, color: primaryOrange, size: 20.sp),
                              title: Text(
                                bankName,
                                style: TextStyle(
                                  fontSize: 13.5.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColorsTheme.textMainColor(context),
                                ),
                              ),
                              onTap: () {
                                onSelectBank(bankName);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddMethodModal(BuildContext context) {
    String selectedType = 'Bank account';
    String? selectedBank;
    String? selectedDivision;
    String? selectedDistrict;
    String? selectedBranch;
    String? selectedAccountType;
    bool isMakeDefault = false;

    final TextEditingController labelController = TextEditingController();
    final TextEditingController holderNameController = TextEditingController();
    final TextEditingController accountNumberController = TextEditingController();
    final TextEditingController confirmAccountNumberController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    final List<String> typeOptions = ['Bank account', 'bKash', 'Nagad'];
    final List<String> bankOptions = _loadedBanks.isNotEmpty
        ? _loadedBanks.map((b) => b.name ?? '').where((n) => n.isNotEmpty).toList()
        : ['AB BANK LIMITED', 'AGRANI BANK LIMITED', 'BRAC BANK LIMITED', 'DUTCH-BANGLA BANK LIMITED', 'ISLAMI BANK BANGLADESH LIMITED', 'SONALI BANK LIMITED', 'THE CITY BANK LIMITED'];

    final List<String> accountTypeOptions = ['Savings account', 'Current account', 'Business account'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          final divisionOptions = _loadedDivisions.map((d) => d.nameEn ?? d.nameBn ?? '').where((n) => n.isNotEmpty).toList();
          final districtOptions = _loadedDistricts.map((d) => d.nameEn ?? d.nameBn ?? '').where((n) => n.isNotEmpty).toList();
          final branchOptions = _loadedBranches.isNotEmpty
              ? _loadedBranches.map((b) => b.name ?? '').where((n) => n.isNotEmpty).toList()
              : ['Principal Branch', 'Gulshan Branch', 'Banani Branch', 'Agrabad Branch', 'Dhanmondi Branch'];

          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.88,
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Add payout method',
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
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Divider(color: AppColorsTheme.borderColor(context), height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel(context, 'Type'),
                        _buildDropdownField(
                          context,
                          value: selectedType,
                          items: typeOptions,
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                selectedType = val;
                              });
                            }
                          },
                        ),
                        UIHelper.verticalSpace(14.h),

                        _buildFieldLabel(context, 'Label'),
                        _buildTextField(context, controller: labelController, hintText: 'e.g. Primary Bank Account'),
                        UIHelper.verticalSpace(14.h),

                        if (selectedType == 'Bank account') ...[
                          _buildFieldLabel(context, 'Bank'),
                          GestureDetector(
                            onTap: () {
                              _showBankSearchSheet(context, bankOptions, (selected) {
                                setModalState(() {
                                  selectedBank = selected;
                                  selectedBranch = null;
                                  _loadedBranches = [];
                                });
                                final matchedDist = _loadedDistricts.firstWhere(
                                  (d) => (d.nameEn ?? d.nameBn ?? '') == selectedDistrict,
                                  orElse: () => DivisionData(),
                                );
                                _fetchBranchesForBank(selected, matchedDist.sourceId ?? matchedDist.id?.toString(), setModalState);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: AppColorsTheme.background(context),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: AppColorsTheme.borderColor(context)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      selectedBank ?? 'Select...',
                                      style: TextStyle(
                                        fontSize: 13.5.sp,
                                        color: selectedBank != null
                                            ? AppColorsTheme.textMainColor(context)
                                            : AppColorsTheme.textMutedColor(context),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.arrow_drop_down_rounded, color: AppColorsTheme.textMutedColor(context)),
                                ],
                              ),
                            ),
                          ),
                          UIHelper.verticalSpace(14.h),

                          // Division
                          _buildFieldLabel(context, 'Division'),
                          _buildDropdownField(
                            context,
                            value: selectedDivision,
                            hintText: 'Select...',
                            items: divisionOptions,
                            onChanged: (val) {
                              setModalState(() {
                                selectedDivision = val;
                                selectedDistrict = null;
                                selectedBranch = null;
                                _loadedDistricts = [];
                                _loadedBranches = [];
                              });
                              if (val != null) {
                                final matchedDiv = _loadedDivisions.firstWhere(
                                  (d) => (d.nameEn ?? d.nameBn ?? '') == val,
                                  orElse: () => DivisionData(),
                                );
                                final divSourceId = matchedDiv.sourceId ?? matchedDiv.id?.toString();
                                if (divSourceId != null) {
                                  _fetchDistrictsForDivision(divSourceId, setModalState);
                                }
                              }
                            },
                          ),
                          UIHelper.verticalSpace(14.h),

                          // District
                          _buildFieldLabel(context, 'District'),
                          _buildDropdownField(
                            context,
                            value: selectedDistrict,
                            hintText: 'Select...',
                            items: districtOptions,
                            onChanged: (val) {
                              setModalState(() {
                                selectedDistrict = val;
                                selectedBranch = null;
                                _loadedBranches = [];
                              });
                              if (selectedBank != null && val != null) {
                                final matchedDist = _loadedDistricts.firstWhere(
                                  (d) => (d.nameEn ?? d.nameBn ?? '') == val,
                                  orElse: () => DivisionData(),
                                );
                                final distId = matchedDist.sourceId ?? matchedDist.id?.toString();
                                _fetchBranchesForBank(selectedBank!, distId, setModalState);
                              }
                            },
                          ),
                          UIHelper.verticalSpace(14.h),

                          // Branch
                          _buildFieldLabel(context, 'Branch'),
                          _buildDropdownField(
                            context,
                            value: selectedBranch,
                            hintText: 'Select...',
                            items: branchOptions,
                            onChanged: (val) => setModalState(() => selectedBranch = val),
                          ),
                          UIHelper.verticalSpace(14.h),
                        ],

                        _buildFieldLabel(context, 'Account holder name'),
                        _buildTextField(context, controller: holderNameController, hintText: 'e.g. Mohammad Ashraf'),
                        UIHelper.verticalSpace(14.h),

                        _buildFieldLabel(context, selectedType == 'Bank account' ? 'Account number' : 'Mobile number'),
                        _buildTextField(
                          context,
                          controller: accountNumberController,
                          hintText: selectedType == 'Bank account' ? 'e.g. 1251092840001' : 'e.g. 01619005832',
                          keyboardType: selectedType == 'Bank account' ? TextInputType.number : TextInputType.phone,
                        ),
                        UIHelper.verticalSpace(14.h),

                        if (selectedType == 'Bank account') ...[
                          _buildFieldLabel(context, 'Account type'),
                          _buildDropdownField(
                            context,
                            value: selectedAccountType,
                            hintText: 'Select...',
                            items: accountTypeOptions,
                            onChanged: (val) => setModalState(() => selectedAccountType = val),
                          ),
                          UIHelper.verticalSpace(14.h),
                        ],

                        _buildFieldLabel(context, 'Confirm account number'),
                        _buildTextField(
                          context,
                          controller: confirmAccountNumberController,
                          hintText: 'Re-enter account/mobile number',
                          keyboardType: selectedType == 'Bank account' ? TextInputType.number : TextInputType.phone,
                        ),
                        UIHelper.verticalSpace(14.h),

                        Row(
                          children: [
                            SizedBox(
                              width: 22.w,
                              height: 22.h,
                              child: Checkbox(
                                value: isMakeDefault,
                                activeColor: primaryOrange,
                                onChanged: (val) {
                                  setModalState(() {
                                    isMakeDefault = val ?? false;
                                  });
                                },
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
                        ),
                        UIHelper.verticalSpace(14.h),

                        _buildFieldLabel(context, 'Current password'),
                        _buildTextField(
                          context,
                          controller: passwordController,
                          hintText: 'Enter current password for security',
                          obscureText: true,
                        ),
                        UIHelper.verticalSpace(24.h),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final label = labelController.text.trim();
                              final holderName = holderNameController.text.trim();
                              final accNum = accountNumberController.text.trim();
                              final confirmAccNum = confirmAccountNumberController.text.trim();
                              final password = passwordController.text.trim();

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
                              if (selectedType == 'Bank account') {
                                if (selectedBank == null) {
                                  ToastUtil.showErrorMessage('Please select a Bank');
                                  return;
                                }
                                if (selectedBranch == null) {
                                  ToastUtil.showErrorMessage('Please select a Branch');
                                  return;
                                }
                              }
                              if (password.isEmpty) {
                                ToastUtil.showErrorMessage('Current password is required');
                                return;
                              }

                              Navigator.pop(ctx);
                              setState(() {
                                if (isMakeDefault) {
                                  for (var m in _payoutMethods) {
                                    m['isDefault'] = false;
                                  }
                                }
                                final maskNum = accNum.length > 4 ? "****${accNum.substring(accNum.length - 4)}" : accNum;
                                final displayBankName = selectedType == 'Bank account' ? (selectedBank ?? 'Bank Account') : selectedType;
                                _payoutMethods.insert(0, {
                                  'title': label.isNotEmpty ? label : displayBankName,
                                  'detail': '$holderName ($maskNum)',
                                  'isDefault': isMakeDefault,
                                  'icon': selectedType == 'Bank account' ? Icons.account_balance_rounded : Icons.account_balance_wallet_rounded,
                                });
                              });
                              ToastUtil.showSuccessMessage('Payout method saved successfully!');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryOrange,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                              elevation: 0,
                            ),
                            child: Text('Save Payout Method', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        UIHelper.verticalSpace(20.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String labelText) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        labelText,
        style: TextStyle(
          fontSize: 12.5.sp,
          fontWeight: FontWeight.bold,
          color: AppColorsTheme.textMainColor(context),
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        filled: true,
        fillColor: AppColorsTheme.background(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: primaryOrange, width: 1.5.w),
        ),
      ),
    );
  }

  Widget _buildDropdownField(
    BuildContext context, {
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String hintText = 'Select...',
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          hint: Text(hintText, style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context))),
          dropdownColor: AppColorsTheme.cardBg(context),
          style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final apiMethods = _paymentResponseModel?.data ?? [];
    final apiTypes = _paymentResponseModel?.types ?? [];
    final hasApiMethods = apiMethods.isNotEmpty || apiTypes.isNotEmpty;

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
          'Payout methods',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _showAddMethodModal(context),
            icon: Icon(Icons.add_circle_outline_rounded, size: 16.sp, color: primaryOrange),
            label: Text('Add', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: primaryOrange)),
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
              'Where your withdrawals are paid. Only the last four digits are ever shown again after saving.',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppColorsTheme.textMutedColor(context),
              ),
            ),
            UIHelper.verticalSpace(16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showAddMethodModal(context),
                icon: Icon(Icons.credit_card_rounded, size: 18.sp),
                label: Text('Add payout method', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
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
            hasApiMethods
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: apiMethods.isNotEmpty ? apiMethods.length : apiTypes.length,
                    itemBuilder: (context, index) {
                      final title = apiMethods.isNotEmpty
                          ? (apiMethods[index].name ?? 'Payout Method')
                          : (apiTypes[index].label ?? apiTypes[index].value ?? 'Payout Method');
                      final subtitle = apiMethods.isNotEmpty
                          ? (apiMethods[index].description ?? 'Configured account')
                          : 'Fields: ${apiTypes[index].fields?.join(", ") ?? ""}';

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
                                color: primaryOrange.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.account_balance_wallet_rounded, color: primaryOrange, size: 20.sp),
                            ),
                            UIHelper.horizontalSpace(12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                                  ),
                                  UIHelper.verticalSpace(2.h),
                                  Text(
                                    subtitle,
                                    style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded, size: 18.sp, color: AppColorsTheme.textMutedColor(context)),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  ToastUtil.showSuccessMessage('Edit payout method');
                                } else if (value == 'archive') {
                                  ToastUtil.showSuccessMessage('Payout method archived');
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 16.sp, color: primaryOrange),
                                      UIHelper.horizontalSpace(8.w),
                                      Text('Edit', style: TextStyle(fontSize: 12.5.sp)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'archive',
                                  child: Row(
                                    children: [
                                      Icon(Icons.archive_outlined, size: 16.sp, color: Colors.redAccent),
                                      UIHelper.horizontalSpace(8.w),
                                      Text('Archive', style: TextStyle(fontSize: 12.5.sp, color: Colors.redAccent)),
                                    ],
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
                    itemCount: _payoutMethods.length,
                    itemBuilder: (context, index) {
                      final item = _payoutMethods[index];
                      final isDefault = item['isDefault'] == true;
                      return Container(
                        margin: EdgeInsets.only(bottom: 10.h),
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColorsTheme.cardBg(context),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: isDefault ? primaryOrange : AppColorsTheme.borderColor(context)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: primaryOrange.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(item['icon'], color: primaryOrange, size: 20.sp),
                            ),
                            UIHelper.horizontalSpace(12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item['title'],
                                        style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                                      ),
                                      if (isDefault) ...[
                                        UIHelper.horizontalSpace(8.w),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                          decoration: BoxDecoration(
                                            color: primaryOrange.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6.r),
                                          ),
                                          child: Text('Default', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: primaryOrange)),
                                        ),
                                      ],
                                    ],
                                  ),
                                  UIHelper.verticalSpace(2.h),
                                  Text(
                                    item['detail'],
                                    style: TextStyle(fontSize: 11.5.sp, color: AppColorsTheme.textMutedColor(context)),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert_rounded, size: 18.sp, color: AppColorsTheme.textMutedColor(context)),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  ToastUtil.showSuccessMessage('Edit payout method');
                                } else if (value == 'archive') {
                                  setState(() {
                                    _payoutMethods.removeAt(index);
                                  });
                                  ToastUtil.showSuccessMessage('Payout method archived');
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 16.sp, color: primaryOrange),
                                      UIHelper.horizontalSpace(8.w),
                                      Text('Edit', style: TextStyle(fontSize: 12.5.sp)),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'archive',
                                  child: Row(
                                    children: [
                                      Icon(Icons.archive_outlined, size: 16.sp, color: Colors.redAccent),
                                      UIHelper.horizontalSpace(8.w),
                                      Text('Archive', style: TextStyle(fontSize: 12.5.sp)),
                                    ],
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
