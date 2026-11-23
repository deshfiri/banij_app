import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

class CatalogAdvancedFilterSheet extends StatefulWidget {
  final String? initialSearch;
  final String? initialCategory;
  final String? initialBrand;
  final String? initialStock;
  final String? initialPriceMin;
  final String? initialPriceMax;
  final String? initialScope;
  final List<dynamic> categories;
  final List<dynamic> brands;
  final Function(Map<String, dynamic> filters) onApply;

  const CatalogAdvancedFilterSheet({
    super.key,
    this.initialSearch,
    this.initialCategory,
    this.initialBrand,
    this.initialStock,
    this.initialPriceMin,
    this.initialPriceMax,
    this.initialScope,
    required this.categories,
    required this.brands,
    required this.onApply,
  });

  static void show(
    BuildContext context, {
    String? initialSearch,
    String? initialCategory,
    String? initialBrand,
    String? initialStock,
    String? initialPriceMin,
    String? initialPriceMax,
    String? initialScope,
    required List<dynamic> categories,
    required List<dynamic> brands,
    required Function(Map<String, dynamic> filters) onApply,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CatalogAdvancedFilterSheet(
        initialSearch: initialSearch,
        initialCategory: initialCategory,
        initialBrand: initialBrand,
        initialStock: initialStock,
        initialPriceMin: initialPriceMin,
        initialPriceMax: initialPriceMax,
        initialScope: initialScope,
        categories: categories,
        brands: brands,
        onApply: onApply,
      ),
    );
  }

  @override
  State<CatalogAdvancedFilterSheet> createState() => _CatalogAdvancedFilterSheetState();
}

class _CatalogAdvancedFilterSheetState extends State<CatalogAdvancedFilterSheet> {
  late TextEditingController _searchController;
  late TextEditingController _priceMinController;
  late TextEditingController _priceMaxController;

  String? _selectedCategory;
  String? _selectedBrand;
  String? _selectedStock;
  String? _selectedScope;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearch ?? '');
    _priceMinController = TextEditingController(text: widget.initialPriceMin ?? '');
    _priceMaxController = TextEditingController(text: widget.initialPriceMax ?? '');
    _selectedCategory = widget.initialCategory;
    _selectedBrand = widget.initialBrand;
    _selectedStock = widget.initialStock;
    _selectedScope = widget.initialScope;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _priceMinController.dispose();
    _priceMaxController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _priceMinController.clear();
      _priceMaxController.clear();
      _selectedCategory = null;
      _selectedBrand = null;
      _selectedStock = null;
      _selectedScope = null;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    if (_searchController.text.isNotEmpty) filters['search'] = _searchController.text.trim();
    if (_selectedCategory != null && _selectedCategory!.isNotEmpty) filters['category'] = _selectedCategory;
    if (_selectedBrand != null && _selectedBrand!.isNotEmpty) filters['brand'] = _selectedBrand;
    if (_selectedStock != null && _selectedStock!.isNotEmpty) filters['stock'] = _selectedStock;
    if (_priceMinController.text.isNotEmpty) filters['price_min'] = _priceMinController.text.trim();
    if (_priceMaxController.text.isNotEmpty) filters['price_max'] = _priceMaxController.text.trim();
    if (_selectedScope != null && _selectedScope!.isNotEmpty) filters['scope'] = _selectedScope;

    Navigator.pop(context);
    widget.onApply(filters);
  }

  /// Dropdown items for API option objects (`value` / `label`), led by an
  /// "all" entry with a null value.
  List<DropdownMenuItem<String>> _optionItems(List<dynamic> options, String allLabel) {
    return [
      DropdownMenuItem<String>(value: null, child: Text(allLabel)),
      ...options.map((option) {
        final value = option.value?.toString() ?? '';
        final label = option.label?.toString() ?? value;
        return DropdownMenuItem<String>(
          value: value,
          child: Text(label, style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context))),
        );
      }),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final mainColor = AppColorsTheme.textMainColor(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
      ),
      child: Column(
        children: [
          UIHelper.verticalSpace(12.h),
          Center(
            child: Container(
              width: 42.w,
              height: 4.5.h,
              decoration: BoxDecoration(
                color: AppColorsTheme.textMutedColor(context).withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
          ),
          UIHelper.verticalSpace(12.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Filters',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w900, color: mainColor),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset All',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: primaryOrange),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColorsTheme.borderColor(context)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              children: [
                const _FilterLabel('Search Query'),
                UIHelper.verticalSpace(6.h),
                _FilterTextField(
                  controller: _searchController,
                  hintText: 'Matches product name or SKU...',
                  hintFontSize: 12.5.sp,
                ),
                UIHelper.verticalSpace(16.h),
                const _FilterLabel('Category'),
                UIHelper.verticalSpace(6.h),
                _FilterDropdown(
                  value: _selectedCategory,
                  hint: 'Select Category',
                  items: _optionItems(widget.categories, 'All Categories'),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                ),
                UIHelper.verticalSpace(16.h),
                const _FilterLabel('Brand'),
                UIHelper.verticalSpace(6.h),
                _FilterDropdown(
                  value: _selectedBrand,
                  hint: 'Select Brand',
                  items: _optionItems(widget.brands, 'All Brands'),
                  onChanged: (val) => setState(() => _selectedBrand = val),
                ),
                UIHelper.verticalSpace(16.h),
                const _FilterLabel('Stock Status (Wholesale)'),
                UIHelper.verticalSpace(6.h),
                _FilterDropdown(
                  value: _selectedStock,
                  hint: 'Select Stock Status',
                  items: const [
                    DropdownMenuItem<String>(value: null, child: Text('Any')),
                    DropdownMenuItem<String>(value: '1', child: Text('In Stock Only')),
                    DropdownMenuItem<String>(value: '0', child: Text('Out of Stock')),
                  ],
                  onChanged: (val) => setState(() => _selectedStock = val),
                ),
                UIHelper.verticalSpace(16.h),
                const _FilterLabel('Price Range (Wholesale Taka)'),
                UIHelper.verticalSpace(6.h),
                Row(
                  children: [
                    Expanded(
                      child: _FilterTextField(
                        controller: _priceMinController,
                        hintText: 'Min Price',
                        hintFontSize: 12.sp,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: _FilterTextField(
                        controller: _priceMaxController,
                        hintText: 'Max Price',
                        hintFontSize: 12.sp,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(16.h),
                const _FilterLabel('Scope'),
                UIHelper.verticalSpace(6.h),
                _FilterDropdown(
                  value: _selectedScope,
                  hint: 'Select Scope',
                  items: const [
                    DropdownMenuItem<String>(value: null, child: Text('All')),
                    DropdownMenuItem<String>(value: 'mine', child: Text('Mine (Purchased by account)')),
                  ],
                  onChanged: (val) => setState(() => _selectedScope = val),
                ),
                UIHelper.verticalSpace(30.h),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              border: Border(top: BorderSide(color: AppColorsTheme.borderColor(context), width: 1.w)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48.h,
              child: ElevatedButton(
                onPressed: _applyFilters,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryOrange,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 0,
                ),
                child: Text('Apply Filters', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterLabel extends StatelessWidget {
  final String text;

  const _FilterLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context)),
    );
  }
}

/// Filled rounded text field used for search and price inputs.
class _FilterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final double hintFontSize;
  final TextInputType? keyboardType;

  const _FilterTextField({
    required this.controller,
    required this.hintText,
    required this.hintFontSize,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(fontSize: hintFontSize, color: AppColorsTheme.textMutedColor(context)),
        filled: true,
        fillColor: AppColorsTheme.cardBg(context),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColorsTheme.borderColor(context)),
        ),
      ),
    );
  }
}

/// Bordered dropdown box used for category, brand, stock and scope.
class _FilterDropdown extends StatelessWidget {
  final String? value;
  final String hint;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({required this.value, required this.hint, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
          isExpanded: true,
          dropdownColor: AppColorsTheme.cardBg(context),
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
