import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';

class PayoutMethodsScreen extends StatefulWidget {
  const PayoutMethodsScreen({super.key});

  @override
  State<PayoutMethodsScreen> createState() => _PayoutMethodsScreenState();
}

class _PayoutMethodsScreenState extends State<PayoutMethodsScreen> {
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
    final List<String> bankOptions = ['City Bank', 'Dutch-Bangla Bank', 'BRAC Bank', 'Islami Bank', 'Eastern Bank', 'Sonali Bank', 'Pubali Bank'];
    final List<String> divisionOptions = ['Dhaka', 'Chittagong', 'Rajshahi', 'Khulna', 'Barisal', 'Sylhet', 'Rangpur', 'Mymensingh'];
    final List<String> districtOptions = ['Dhaka', 'Gazipur', 'Narayanganj', 'Chittagong', 'Sylhet', 'Bogura'];
    final List<String> branchOptions = ['Principal Branch', 'Gulshan Branch', 'Banani Branch', 'Agrabad Branch', 'Dhanmondi Branch'];
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
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.88,
            child: Column(
              children: [
                // Modal Header
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

                // Form Fields Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Type
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

                        // 2. Label
                        _buildFieldLabel(context, 'Label'),
                        _buildTextField(context, controller: labelController, hintText: 'e.g. Primary Bank Account'),
                        UIHelper.verticalSpace(14.h),

                        if (selectedType == 'Bank account') ...[
                          // 3. Bank
                          _buildFieldLabel(context, 'Bank'),
                          _buildDropdownField(
                            context,
                            value: selectedBank,
                            hintText: 'Select...',
                            items: bankOptions,
                            onChanged: (val) => setModalState(() => selectedBank = val),
                          ),
                          UIHelper.verticalSpace(14.h),

                          // 4. Division
                          _buildFieldLabel(context, 'Division'),
                          _buildDropdownField(
                            context,
                            value: selectedDivision,
                            hintText: 'Select...',
                            items: divisionOptions,
                            onChanged: (val) => setModalState(() => selectedDivision = val),
                          ),
                          UIHelper.verticalSpace(14.h),

                          // 5. District
                          _buildFieldLabel(context, 'District'),
                          _buildDropdownField(
                            context,
                            value: selectedDistrict,
                            hintText: 'Select...',
                            items: districtOptions,
                            onChanged: (val) => setModalState(() => selectedDistrict = val),
                          ),
                          UIHelper.verticalSpace(14.h),

                          // 6. Branch
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

                        // 7. Account holder name
                        _buildFieldLabel(context, 'Account holder name'),
                        _buildTextField(context, controller: holderNameController, hintText: 'e.g. Mohammad Ashraf'),
                        UIHelper.verticalSpace(14.h),

                        // 8. Account number
                        _buildFieldLabel(context, selectedType == 'Bank account' ? 'Account number' : 'Mobile number'),
                        _buildTextField(
                          context,
                          controller: accountNumberController,
                          hintText: selectedType == 'Bank account' ? 'e.g. 1251092840001' : 'e.g. 01619005832',
                          keyboardType: selectedType == 'Bank account' ? TextInputType.number : TextInputType.phone,
                        ),
                        UIHelper.verticalSpace(14.h),

                        if (selectedType == 'Bank account') ...[
                          // 9. Account type
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

                        // 10. Confirm account number
                        _buildFieldLabel(context, 'Confirm account number'),
                        _buildTextField(
                          context,
                          controller: confirmAccountNumberController,
                          hintText: 'Re-enter account/mobile number',
                          keyboardType: selectedType == 'Bank account' ? TextInputType.number : TextInputType.phone,
                        ),
                        UIHelper.verticalSpace(14.h),

                        // 11. Make default Checkbox
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

                        // 12. Current password
                        _buildFieldLabel(context, 'Current password'),
                        _buildTextField(
                          context,
                          controller: passwordController,
                          hintText: 'Enter current password for security',
                          obscureText: true,
                        ),
                        UIHelper.verticalSpace(24.h),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              final label = labelController.text.trim();
                              final holderName = holderNameController.text.trim();
                              final accNum = accountNumberController.text.trim();
                              final confirmAccNum = confirmAccountNumberController.text.trim();
                              final password = passwordController.text.trim();

                              // Validation checks
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
            _payoutMethods.isEmpty
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
                          Icon(Icons.credit_card_rounded, size: 48.sp, color: AppColorsTheme.textMutedColor(context)),
                          UIHelper.verticalSpace(12.h),
                          Text(
                            'No payout method yet',
                            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
                          ),
                          UIHelper.verticalSpace(4.h),
                          Text(
                            'Add a bank account, bKash or Nagad number before requesting a withdrawal.',
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
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, size: 18.sp, color: Colors.redAccent),
                              onPressed: () {
                                setState(() {
                                  _payoutMethods.removeAt(index);
                                });
                                ToastUtil.showSuccessMessage('Payout method removed');
                              },
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
