import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../finance_shared/finance_widgets.dart';
import 'payout_form_fields.dart';

/// Searchable "Select Bank" sheet; calls [onSelectBank] and closes on tap.
class BankSearchSheet extends StatefulWidget {
  final List<String> bankList;
  final ValueChanged<String> onSelectBank;

  const BankSearchSheet({super.key, required this.bankList, required this.onSelectBank});

  static void show(BuildContext context, {required List<String> bankList, required ValueChanged<String> onSelectBank}) {
    showFinanceSheet(context, builder: (_) => BankSearchSheet(bankList: bankList, onSelectBank: onSelectBank));
  }

  @override
  State<BankSearchSheet> createState() => _BankSearchSheetState();
}

class _BankSearchSheetState extends State<BankSearchSheet> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredList = _searchQuery.isEmpty
        ? widget.bankList
        : widget.bankList.where((b) => b.toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 16.w, 12.h),
            child: FinanceSheetHeader(title: 'Select Bank', onClose: () => Navigator.pop(context)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
            child: TextField(
              autofocus: true,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
              decoration: payoutInputDecoration(
                context,
                hintText: 'Search bank name...',
                prefixIcon: Icon(Icons.search_rounded, color: primaryOrange, size: 20.sp),
                includeEnabledBorder: false,
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
                    separatorBuilder: (c, i) =>
                        Divider(color: AppColorsTheme.borderColor(context).withValues(alpha: 0.5), height: 1),
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
                          widget.onSelectBank(bankName);
                          Navigator.pop(context);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
