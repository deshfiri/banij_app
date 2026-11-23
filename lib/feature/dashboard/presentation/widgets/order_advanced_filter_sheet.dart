import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common_widget/gradient_button.dart';
import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';
import 'order/order_sheet_header.dart';
import 'order/sheet_parts.dart';

class OrderAdvancedFilterSheet extends StatefulWidget {
  final String? initialSearch;
  final String? initialSource;
  final String? initialStore;
  final String? initialStatus;
  final String? initialPayment;
  final String? initialFromDate;
  final String? initialToDate;
  final String? initialSort;
  final String? initialDirection;
  final Function(Map<String, dynamic> filters) onApply;

  const OrderAdvancedFilterSheet({
    super.key,
    this.initialSearch,
    this.initialSource,
    this.initialStore,
    this.initialStatus,
    this.initialPayment,
    this.initialFromDate,
    this.initialToDate,
    this.initialSort,
    this.initialDirection,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    String? initialSearch,
    String? initialSource,
    String? initialStore,
    String? initialStatus,
    String? initialPayment,
    String? initialFromDate,
    String? initialToDate,
    String? initialSort,
    String? initialDirection,
    required Function(Map<String, dynamic> filters) onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderAdvancedFilterSheet(
        initialSearch: initialSearch,
        initialSource: initialSource,
        initialStore: initialStore,
        initialStatus: initialStatus,
        initialPayment: initialPayment,
        initialFromDate: initialFromDate,
        initialToDate: initialToDate,
        initialSort: initialSort,
        initialDirection: initialDirection,
        onApply: onApply,
      ),
    );
  }

  @override
  State<OrderAdvancedFilterSheet> createState() => _OrderAdvancedFilterSheetState();
}

class _OrderAdvancedFilterSheetState extends State<OrderAdvancedFilterSheet> {
  late TextEditingController _searchController;
  late TextEditingController _fromDateController;
  late TextEditingController _toDateController;

  String? _selectedSource;
  String? _selectedStatus;
  String? _selectedPayment;
  String? _selectedSort;
  String? _selectedDirection;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch ?? '');
    _fromDateController = TextEditingController(text: widget.initialFromDate ?? '');
    _toDateController = TextEditingController(text: widget.initialToDate ?? '');
    _selectedSource = widget.initialSource;
    _selectedStatus = widget.initialStatus;
    _selectedPayment = widget.initialPayment;
    _selectedSort = widget.initialSort ?? _defaultSort;
    _selectedDirection = widget.initialDirection ?? _defaultDirection;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      _selectedSource = null;
      _selectedStatus = null;
      _selectedPayment = null;
      _selectedSort = _defaultSort;
      _selectedDirection = _defaultDirection;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    if (_searchController.text.isNotEmpty) filters['search'] = _searchController.text.trim();
    if (_selectedSource != null && _selectedSource!.isNotEmpty) filters['source'] = _selectedSource;
    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) filters['status'] = _selectedStatus;
    if (_selectedPayment != null && _selectedPayment!.isNotEmpty) filters['payment'] = _selectedPayment;
    if (_fromDateController.text.isNotEmpty) filters['from'] = _fromDateController.text.trim();
    if (_toDateController.text.isNotEmpty) filters['to'] = _toDateController.text.trim();
    if (_selectedSort != null) filters['sort'] = _selectedSort;
    if (_selectedDirection != null) filters['direction'] = _selectedDirection;

    Navigator.pop(context);
    widget.onApply(filters);
  }

  // Defaults the sort controls reset to.
  static const String _defaultSort = 'placed_at';
  static const String _defaultDirection = 'desc';

  /// (value sent to the API, label key). A null value means "all".
  static const List<(String?, String)> _sourceItems = [
    (null, 'All Sources'),
    ('website', 'Website'),
    ('wholesale', 'Wholesale'),
    ('external', 'External'),
  ];

  static const List<(String?, String)> _statusItems = [
    (null, 'All Statuses'),
    ('pending', 'Pending'),
    ('processing', 'Processing'),
    ('delivered', 'Delivered'),
    ('cancelled', 'Cancelled'),
  ];

  static const List<(String?, String)> _paymentItems = [
    (null, 'All Payment States'),
    ('paid', 'Paid'),
    ('unpaid', 'Unpaid / Pending'),
    ('refunded', 'Refunded'),
  ];

  static const List<(String?, String)> _sortItems = [
    ('placed_at', 'Placed Date'),
    ('total', 'Total Amount'),
    ('number', 'Order Number'),
  ];

  static const List<(String?, String)> _directionItems = [
    ('desc', 'Descending'),
    ('asc', 'Ascending'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: sheetDecoration(context, withShadow: false),
      child: Column(
        children: [
          OrderSheetHero(
            title: 'Filter Orders'.tr,
            subtitle: 'Narrow down orders by source, status, payment and date'.tr,
            actions: [GlassTextButton(label: 'Reset All'.tr, onTap: _resetFilters)],
          ),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 10.h),
              children: [
                _FilterLabel('Search Order Number / Name'.tr, icon: Icons.search_rounded),
                _FilterTextField(
                  controller: _searchController,
                  hintText: 'Order number, phone or customer name...'.tr,
                  hintFontSize: 12.5,
                ),
                UIHelper.verticalSpace(16.h),

                _FilterLabel('Order Source'.tr, icon: Icons.hub_outlined),
                _FilterDropdown(
                  value: _selectedSource,
                  hint: 'Select Source'.tr,
                  items: _sourceItems,
                  onChanged: (val) => setState(() => _selectedSource = val),
                ),
                UIHelper.verticalSpace(16.h),

                _FilterLabel('Order Status'.tr, icon: Icons.local_shipping_outlined),
                _FilterDropdown(
                  value: _selectedStatus,
                  hint: 'Select Status'.tr,
                  items: _statusItems,
                  onChanged: (val) => setState(() => _selectedStatus = val),
                ),
                UIHelper.verticalSpace(16.h),

                _FilterLabel('Payment State'.tr, icon: Icons.payments_outlined),
                _FilterDropdown(
                  value: _selectedPayment,
                  hint: 'Select Payment State'.tr,
                  items: _paymentItems,
                  onChanged: (val) => setState(() => _selectedPayment = val),
                ),
                UIHelper.verticalSpace(16.h),

                _FilterLabel('Date Range (YYYY-MM-DD)'.tr, icon: Icons.date_range_rounded),
                Row(
                  children: [
                    Expanded(
                      child: _FilterTextField(
                        controller: _fromDateController,
                        hintText: 'From (2026-01-01)'.tr,
                        hintFontSize: 12,
                      ),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: _FilterTextField(
                        controller: _toDateController,
                        hintText: 'To (2026-12-31)'.tr,
                        hintFontSize: 12,
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(16.h),

                _FilterLabel('Sort Orders By'.tr, icon: Icons.sort_rounded),
                Row(
                  children: [
                    Expanded(
                      child: _FilterDropdown(
                        value: _selectedSort,
                        items: _sortItems,
                        horizontalPadding: 10,
                        onChanged: (val) => setState(() => _selectedSort = val),
                      ),
                    ),
                    UIHelper.horizontalSpace(10.w),
                    Expanded(
                      child: _FilterDropdown(
                        value: _selectedDirection,
                        items: _directionItems,
                        horizontalPadding: 10,
                        onChanged: (val) => setState(() => _selectedDirection = val),
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(30.h),
              ],
            ),
          ),

          // Apply Button Footer
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              border: Border(top: BorderSide(color: AppColorsTheme.borderColor(context), width: 1.w)),
            ),
            child: SafeArea(
              top: false,
              child: GradientButton(
                label: 'Apply Filters'.tr,
                trailingIcon: Icons.check_rounded,
                onPressed: _applyFilters,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Field label with a small orange icon and the 8-point gap below it.
class _FilterLabel extends StatelessWidget {
  final String text;
  final IconData icon;

  const _FilterLabel(this.text, {required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 15.sp, color: primaryOrange),
          UIHelper.horizontalSpace(6.w),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared input surface: tinted fill, soft orange border, orange when focused.
BoxDecoration _fieldDecoration(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
    borderRadius: BorderRadius.circular(14.r),
    border: Border.all(color: isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.2)),
  );
}

/// Filled, rounded text input used for search and dates.
class _FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double hintFontSize;

  const _FilterTextField({required this.controller, required this.hintText, required this.hintFontSize});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: color, width: width),
        );

    return TextField(
      controller: controller,
      style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: hintFontSize.sp, color: AppColorsTheme.textMutedColor(context)),
        filled: true,
        fillColor: isDark ? AppColorsTheme.innerCardBg(context) : lightBackground,
        border: border(AppColorsTheme.borderColor(context)),
        enabledBorder: border(isDark ? darkCardBorderColor : primaryOrange.withValues(alpha: 0.2)),
        focusedBorder: border(primaryOrange, 1.5),
      ),
    );
  }
}

/// Bordered dropdown; [hint] is shown when [value] is null.
class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String? hint;
  final List<(String?, String)> items;
  final ValueChanged<String?> onChanged;
  final double horizontalPadding;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
    this.horizontalPadding = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding.w),
      decoration: _fieldDecoration(context),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: hint == null
              ? null
              : Text(hint!, style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: primaryOrange, size: 22.sp),
          borderRadius: BorderRadius.circular(14.r),
          dropdownColor: AppColorsTheme.cardBg(context),
          style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
          items: [
            for (final (itemValue, label) in items)
              DropdownMenuItem<String>(
                value: itemValue,
                child: Text(label.tr, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}
