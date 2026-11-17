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

  @override
  Widget build(BuildContext context) {
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
          // Drag handle & Header
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
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Reset All',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: primaryOrange,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: AppColorsTheme.borderColor(context)),

          // Scrollable Filter Sections
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              children: [
                // Search Keyword
                Text('Search Query', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                UIHelper.verticalSpace(6.h),
                TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
                  decoration: InputDecoration(
                    hintText: 'Matches product name or SKU...',
                    hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                    filled: true,
                    fillColor: AppColorsTheme.cardBg(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColorsTheme.borderColor(context))),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                // Category Dropdown
                Text('Category', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                UIHelper.verticalSpace(6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColorsTheme.borderColor(context)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      hint: Text('Select Category', style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
                      isExpanded: true,
                      dropdownColor: AppColorsTheme.cardBg(context),
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('All Categories')),
                        ...widget.categories.map((cat) {
                          final value = cat.value?.toString() ?? '';
                          final label = cat.label?.toString() ?? value;
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(label, style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context))),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedCategory = val;
                        });
                      },
                    ),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                // Brand Dropdown
                Text('Brand', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                UIHelper.verticalSpace(6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColorsTheme.borderColor(context)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedBrand,
                      hint: Text('Select Brand', style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
                      isExpanded: true,
                      dropdownColor: AppColorsTheme.cardBg(context),
                      items: [
                        const DropdownMenuItem<String>(value: null, child: Text('All Brands')),
                        ...widget.brands.map((brand) {
                          final value = brand.value?.toString() ?? '';
                          final label = brand.label?.toString() ?? value;
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(label, style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMainColor(context))),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedBrand = val;
                        });
                      },
                    ),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                // Stock status (Wholesale only)
                Text('Stock Status (Wholesale)', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                UIHelper.verticalSpace(6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColorsTheme.borderColor(context)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStock,
                      hint: Text('Select Stock Status', style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
                      isExpanded: true,
                      dropdownColor: AppColorsTheme.cardBg(context),
                      items: const [
                        DropdownMenuItem<String>(value: null, child: Text('Any')),
                        DropdownMenuItem<String>(value: '1', child: Text('In Stock Only')),
                        DropdownMenuItem<String>(value: '0', child: Text('Out of Stock')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedStock = val;
                        });
                      },
                    ),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                // Price Range (Price Min & Price Max)
                Text('Price Range (Wholesale Taka)', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                UIHelper.verticalSpace(6.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceMinController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
                        decoration: InputDecoration(
                          hintText: 'Min Price',
                          hintStyle: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
                          filled: true,
                          fillColor: AppColorsTheme.cardBg(context),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColorsTheme.borderColor(context))),
                        ),
                      ),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: TextField(
                        controller: _priceMaxController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
                        decoration: InputDecoration(
                          hintText: 'Max Price',
                          hintStyle: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
                          filled: true,
                          fillColor: AppColorsTheme.cardBg(context),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColorsTheme.borderColor(context))),
                        ),
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(16.h),

                // Scope
                Text('Scope', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                UIHelper.verticalSpace(6.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColorsTheme.borderColor(context)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedScope,
                      hint: Text('Select Scope', style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
                      isExpanded: true,
                      dropdownColor: AppColorsTheme.cardBg(context),
                      items: const [
                        DropdownMenuItem<String>(value: null, child: Text('All')),
                        DropdownMenuItem<String>(value: 'mine', child: Text('Mine (Purchased by account)')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedScope = val;
                        });
                      },
                    ),
                  ),
                ),
                UIHelper.verticalSpace(30.h),
              ],
            ),
          ),

          // Apply Button Footer
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
                child: Text(
                  'Apply Filters',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
