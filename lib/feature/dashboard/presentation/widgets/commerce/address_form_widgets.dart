import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';

/// Bold field label.
class AddressFieldLabel extends StatelessWidget {
  final String text;

  const AddressFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
    );
  }
}

/// Label, 6px gap, then [field].
class AddressLabeledField extends StatelessWidget {
  final String label;
  final Widget field;

  const AddressLabeledField({super.key, required this.label, required this.field});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AddressFieldLabel(label),
        UIHelper.verticalSpace(6.h),
        field,
      ],
    );
  }
}

/// Rounded text field with an orange leading icon.
class AddressTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;

  const AddressTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final isMultiline = maxLines > 1;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(top: isMultiline ? 12.h : 0),
            child: Icon(icon, size: 18.sp, color: primaryOrange),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Searchable dropdown for a location level (division, district, ...).
/// Items are raw maps with `name_en` / `name`. Disabled when [onChanged] is null.
class LocationDropdown extends StatelessWidget {
  final String hint;
  final List<dynamic> items;
  final dynamic selectedValue;
  final ValueChanged<dynamic>? onChanged;
  final TextEditingController searchController;

  const LocationDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.searchController,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColorsTheme.textMainColor(context);
    final mutedColor = AppColorsTheme.textMutedColor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<dynamic>(
          isExpanded: true,
          hint: Text(hint, style: TextStyle(fontSize: 12.5.sp, color: mutedColor)),
          items: items.map((item) {
            final name = item['name_en'] ?? item['name'] ?? 'Item';
            return DropdownMenuItem<dynamic>(
              value: item,
              child: Text(
                name.toString(),
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: mainColor),
              ),
            );
          }).toList(),
          value: selectedValue,
          onChanged: onChanged,
          buttonStyleData: ButtonStyleData(height: 48.h, padding: EdgeInsets.symmetric(horizontal: 12.w)),
          iconStyleData: IconStyleData(
            icon: const Icon(Icons.arrow_drop_down_rounded, color: primaryOrange),
            iconSize: 24.sp,
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250.h,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r), color: AppColorsTheme.cardBg(context)),
          ),
          dropdownSearchData: DropdownSearchData(
            searchController: searchController,
            searchInnerWidgetHeight: 55.h,
            searchInnerWidget: Container(
              height: 55.h,
              padding: EdgeInsets.all(8.w),
              child: TextFormField(
                controller: searchController,
                style: TextStyle(fontSize: 13.sp, color: mainColor),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                  hintText: 'Search...',
                  hintStyle: TextStyle(fontSize: 12.sp, color: mutedColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
                  ),
                ),
              ),
            ),
            searchMatchFn: (item, searchValue) {
              final name = (item.child as Text).data ?? '';
              return name.toLowerCase().contains(searchValue.toLowerCase());
            },
          ),
          onMenuStateChange: (isOpen) {
            if (!isOpen) {
              searchController.clear();
            }
          },
        ),
      ),
    );
  }
}

/// BUSINESS / OPERATIONAL / SHIPPING choice chips.
class AddressTypeChips extends StatelessWidget {
  final List<String> types;
  final String selectedType;
  final ValueChanged<String> onSelected;

  const AddressTypeChips({super.key, required this.types, required this.selectedType, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: types.map((type) {
        final isSelected = selectedType == type;
        return Padding(
          padding: EdgeInsets.only(right: 10.w),
          child: ChoiceChip(
            label: Text(type.toUpperCase()),
            selected: isSelected,
            selectedColor: primaryOrange,
            backgroundColor: AppColorsTheme.cardBg(context),
            labelStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppColorsTheme.textMainColor(context),
            ),
            side: BorderSide(color: isSelected ? primaryOrange : AppColorsTheme.borderColor(context)),
            onSelected: (selected) {
              if (selected) onSelected(type);
            },
          ),
        );
      }).toList(),
    );
  }
}
