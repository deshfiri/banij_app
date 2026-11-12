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
      'detail': '01619005832 (****5832)',
      'isDefault': true,
      'icon': Icons.account_balance_wallet_rounded,
    },
    {
      'title': 'City Bank Account',
      'detail': '1251092840001 (****4912)',
      'isDefault': false,
      'icon': Icons.account_balance_rounded,
    },
  ];

  void _showAddMethodModal(BuildContext context) {
    String selectedType = 'bKash';
    final TextEditingController nameController = TextEditingController();
    final TextEditingController numberController = TextEditingController();

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
                  'Add Payout Method',
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
              'Select Method Type',
              style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
            ),
            UIHelper.verticalSpace(8.h),
            StatefulBuilder(
              builder: (context, setModalState) => Row(
                children: ['bKash', 'Nagad', 'Bank'].map((type) {
                  final isSelected = selectedType == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setModalState(() {
                          selectedType = type;
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
                            type,
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
            UIHelper.verticalSpace(16.h),
            Text(
              'Account Holder Name',
              style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
            ),
            UIHelper.verticalSpace(6.h),
            TextField(
              controller: nameController,
              style: TextStyle(fontSize: 14.sp, color: AppColorsTheme.textMainColor(context)),
              decoration: InputDecoration(
                hintText: 'e.g. Mohammad Ashraf',
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
              selectedType == 'Bank' ? 'Account Number' : 'Mobile Number',
              style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
            ),
            UIHelper.verticalSpace(6.h),
            TextField(
              controller: numberController,
              keyboardType: selectedType == 'Bank' ? TextInputType.number : TextInputType.phone,
              style: TextStyle(fontSize: 14.sp, color: AppColorsTheme.textMainColor(context)),
              decoration: InputDecoration(
                hintText: selectedType == 'Bank' ? 'e.g. 1251092840001' : 'e.g. 01619005832',
                hintStyle: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context)),
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
                ),
              ),
            ),
            UIHelper.verticalSpace(24.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final numVal = numberController.text.trim();
                  if (name.isEmpty || numVal.isEmpty) {
                    ToastUtil.showErrorMessage('Please fill in all fields');
                    return;
                  }
                  Navigator.pop(ctx);
                  setState(() {
                    _payoutMethods.add({
                      'title': '$selectedType Account',
                      'detail': '$name (${numVal.length > 4 ? "****${numVal.substring(numVal.length - 4)}" : numVal})',
                      'isDefault': false,
                      'icon': selectedType == 'Bank' ? Icons.account_balance_rounded : Icons.account_balance_wallet_rounded,
                    });
                  });
                  ToastUtil.showSuccessMessage('Payout method added successfully!');
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
          ],
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
