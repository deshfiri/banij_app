import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import 'address_widgets.dart';

/// Form section card: tinted icon, title, optional subtitle, then [children].
class AddressFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final List<Widget> children;

  const AddressFormSection({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 16.sp, color: primaryOrange),
              ),
              UIHelper.horizontalSpace(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                      ),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          ...children,
        ],
      ),
    );
  }
}

/// Field label; a trailing ` *` is drawn in orange to mark required fields.
class AddressFieldLabel extends StatelessWidget {
  final String text;

  const AddressFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final isRequired = text.endsWith('*');
    final label = isRequired ? text.substring(0, text.length - 1).trimRight() : text;
    return Text.rich(
      TextSpan(
        text: label,
        children: [
          if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: primaryOrange)),
        ],
      ),
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: AppColorsTheme.textMainColor(context),
      ),
    );
  }
}

/// Label, small gap, then [field]. Adds bottom spacing unless [isLast].
class AddressLabeledField extends StatelessWidget {
  final String label;
  final Widget field;
  final bool isLast;

  const AddressLabeledField({super.key, required this.label, required this.field, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AddressFieldLabel(label),
          UIHelper.verticalSpace(6.h),
          field,
        ],
      ),
    );
  }
}

/// Shared input decoration: filled, rounded, orange border on focus.
InputDecoration _fieldDecoration(BuildContext context, {required String hint, IconData? icon}) {
  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: color, width: width),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
    filled: true,
    fillColor: AppColorsTheme.background(context),
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
    prefixIcon: icon == null ? null : Icon(icon, size: 18.sp, color: primaryOrange),
    prefixIconConstraints: BoxConstraints(minWidth: 40.w),
    enabledBorder: border(AppColorsTheme.borderColor(context)),
    focusedBorder: border(primaryOrange, 1.5),
    border: border(AppColorsTheme.borderColor(context)),
  );
}

/// Rounded text field with an orange leading icon and orange focus ring.
class AddressTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final int maxLines;
  final TextInputAction? textInputAction;

  const AddressTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: maxLines > 1 ? TextInputType.multiline : keyboardType,
      maxLines: maxLines,
      minLines: 1,
      textInputAction: textInputAction ?? (maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
      textCapitalization: keyboardType == TextInputType.text ? TextCapitalization.words : TextCapitalization.none,
      cursorColor: primaryOrange,
      style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context)),
      decoration: _fieldDecoration(context, hint: hint, icon: icon),
    );
  }
}

/// Searchable dropdown for a location level (division, district, ...).
/// Items are raw maps with `name_en` / `name`. Disabled (faded) when
/// [onChanged] is null.
class LocationDropdown extends StatelessWidget {
  final String hint;
  final List<dynamic> items;
  final dynamic selectedValue;
  final ValueChanged<dynamic>? onChanged;
  final TextEditingController searchController;
  final IconData icon;

  const LocationDropdown({
    super.key,
    required this.hint,
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    required this.searchController,
    this.icon = Icons.place_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColorsTheme.textMainColor(context);
    final mutedColor = AppColorsTheme.textMutedColor(context);
    final isEnabled = onChanged != null;
    final hasValue = selectedValue != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled ? 1 : 0.55,
      child: Container(
        decoration: BoxDecoration(
          color: AppColorsTheme.background(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: hasValue ? primaryOrange.withValues(alpha: 0.6) : AppColorsTheme.borderColor(context),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<dynamic>(
            isExpanded: true,
            hint: Row(
              children: [
                Icon(icon, size: 18.sp, color: isEnabled ? primaryOrange : mutedColor),
                UIHelper.horizontalSpace(10.w),
                Expanded(
                  child: Text(
                    hint,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5.sp, color: mutedColor),
                  ),
                ),
              ],
            ),
            selectedItemBuilder: (context) => items.map((item) {
              final name = item['name_en'] ?? item['name'] ?? 'Item';
              return Row(
                children: [
                  Icon(icon, size: 18.sp, color: primaryOrange),
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: Text(
                      name.toString(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: mainColor),
                    ),
                  ),
                ],
              );
            }).toList(),
            items: items.map((item) {
              final name = item['name_en'] ?? item['name'] ?? 'Item';
              return DropdownMenuItem<dynamic>(
                value: item,
                child: Text(
                  name.toString(),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: mainColor),
                ),
              );
            }).toList(),
            value: selectedValue,
            onChanged: onChanged,
            buttonStyleData: ButtonStyleData(height: 48.h, padding: EdgeInsets.only(left: 12.w, right: 6.w)),
            iconStyleData: IconStyleData(
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              iconEnabledColor: primaryOrange,
              iconDisabledColor: mutedColor,
              iconSize: 22.sp,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 280.h,
              offset: Offset(0, -4.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14.r),
                color: AppColorsTheme.cardBg(context),
                border: Border.all(color: AppColorsTheme.borderColor(context)),
              ),
            ),
            menuItemStyleData: MenuItemStyleData(
              height: 42.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
            ),
            dropdownSearchData: DropdownSearchData(
              searchController: searchController,
              searchInnerWidgetHeight: 56.h,
              searchInnerWidget: Padding(
                padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 4.h),
                child: TextFormField(
                  controller: searchController,
                  cursorColor: primaryOrange,
                  style: TextStyle(fontSize: 13.sp, color: mainColor),
                  decoration: _fieldDecoration(context, hint: 'Search...', icon: Icons.search_rounded),
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
      ),
    );
  }
}

/// Business / Operational / Shipping selector: equal-width tiles with an
/// icon; the selected tile is tinted in its type colour.
class AddressTypeChips extends StatelessWidget {
  final List<String> types;
  final String selectedType;
  final ValueChanged<String> onSelected;

  const AddressTypeChips({super.key, required this.types, required this.selectedType, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < types.length; i++) ...[
          if (i > 0) UIHelper.horizontalSpace(8.w),
          Expanded(child: _TypeTile(type: types[i], isSelected: types[i] == selectedType, onTap: onSelected)),
        ],
      ],
    );
  }
}

class _TypeTile extends StatelessWidget {
  final String type;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const _TypeTile({required this.type, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final (icon, color) = addressTypeStyle(type);
    final label = type.isEmpty ? type : type[0].toUpperCase() + type.substring(1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => onTap(type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : AppColorsTheme.background(context),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? color : AppColorsTheme.borderColor(context),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20.sp, color: isSelected ? color : AppColorsTheme.textMutedColor(context)),
              UIHelper.verticalSpace(6.h),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? color : AppColorsTheme.textMainColor(context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sticky bottom bar holding the primary form button.
class AddressBottomBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const AddressBottomBar({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(14.r);
    final enabled = onPressed != null && !isLoading;
    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22.r)),
        border: Border(top: BorderSide(color: AppColorsTheme.borderColor(context))),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : primaryOrange.withValues(alpha: 0.1),
            blurRadius: 18.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Center(
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
              child: Opacity(
                opacity: enabled || isLoading ? 1 : 0.6,
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(color: primaryOrange.withValues(alpha: 0.3), blurRadius: 12.r, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: enabled ? onPressed : null,
                      borderRadius: radius,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (isLoading)
                            SizedBox.square(
                              dimension: 18.sp,
                              child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          else
                            Icon(icon, size: 19.sp, color: Colors.white),
                          UIHelper.horizontalSpace(8.w),
                          Text(
                            label,
                            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w800, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Centers content and limits it to [maxWidth] on tablets.
class AddressContentFrame extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const AddressContentFrame({super.key, required this.child, this.maxWidth = 720});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
    );
  }
}
