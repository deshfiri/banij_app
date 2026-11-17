import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/ui_helpers.dart';

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
    _selectedSort = widget.initialSort ?? 'placed_at';
    _selectedDirection = widget.initialDirection ?? 'desc';
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
      _selectedSort = 'placed_at';
      _selectedDirection = 'desc';
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
                  'Filter Orders',
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
                Text('Search Order Number / Name', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                UIHelper.verticalSpace(6.h),
                TextField(
                  controller: _searchController,
                  style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
                  decoration: InputDecoration(
                    hintText: 'Order number, phone or customer name...',
                    hintStyle: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMutedColor(context)),
                    filled: true,
                    fillColor: AppColorsTheme.cardBg(context),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: AppColorsTheme.borderColor(context))),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                // Order Source Dropdown
                Text('Order Source', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
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
                      value: _selectedSource,
                      hint: Text('Select Source', style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
                      isExpanded: true,
                      dropdownColor: AppColorsTheme.cardBg(context),
                      items: const [
                        DropdownMenuItem<String>(value: null, child: Text('All Sources')),
                        DropdownMenuItem<String>(value: 'website', child: Text('Website')),
                        DropdownMenuItem<String>(value: 'wholesale', child: Text('Wholesale')),
                        DropdownMenuItem<String>(value: 'external', child: Text('External')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedSource = val;
                        });
                      },
                    ),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                // Order Status Dropdown
                Text('Order Status', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
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
                      value: _selectedStatus,
                      hint: Text('Select Status', style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
                      isExpanded: true,
                      dropdownColor: AppColorsTheme.cardBg(context),
                      items: const [
                        DropdownMenuItem<String>(value: null, child: Text('All Statuses')),
                        DropdownMenuItem<String>(value: 'pending', child: Text('Pending')),
                        DropdownMenuItem<String>(value: 'processing', child: Text('Processing')),
                        DropdownMenuItem<String>(value: 'delivered', child: Text('Delivered')),
                        DropdownMenuItem<String>(value: 'cancelled', child: Text('Cancelled')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedStatus = val;
                        });
                      },
                    ),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                // Payment State
                Text('Payment State', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
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
                      value: _selectedPayment,
                      hint: Text('Select Payment State', style: TextStyle(fontSize: 13.sp, color: AppColorsTheme.textMutedColor(context))),
                      isExpanded: true,
                      dropdownColor: AppColorsTheme.cardBg(context),
                      items: const [
                        DropdownMenuItem<String>(value: null, child: Text('All Payment States')),
                        DropdownMenuItem<String>(value: 'paid', child: Text('Paid')),
                        DropdownMenuItem<String>(value: 'unpaid', child: Text('Unpaid / Pending')),
                        DropdownMenuItem<String>(value: 'refunded', child: Text('Refunded')),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedPayment = val;
                        });
                      },
                    ),
                  ),
                ),
                UIHelper.verticalSpace(16.h),

                // Date Range (YYYY-MM-DD)
                Text('Date Range (YYYY-MM-DD)', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                UIHelper.verticalSpace(6.h),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _fromDateController,
                        style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
                        decoration: InputDecoration(
                          hintText: 'From (2026-01-01)',
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
                        controller: _toDateController,
                        style: TextStyle(fontSize: 13.5.sp, color: AppColorsTheme.textMainColor(context)),
                        decoration: InputDecoration(
                          hintText: 'To (2026-12-31)',
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

                // Sort By & Direction
                Text('Sort Orders By', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
                UIHelper.verticalSpace(6.h),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(color: AppColorsTheme.cardBg(context), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColorsTheme.borderColor(context))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSort,
                            isExpanded: true,
                            dropdownColor: AppColorsTheme.cardBg(context),
                            items: const [
                              DropdownMenuItem<String>(value: 'placed_at', child: Text('Placed Date')),
                              DropdownMenuItem<String>(value: 'total', child: Text('Total Amount')),
                              DropdownMenuItem<String>(value: 'number', child: Text('Order Number')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedSort = val;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    UIHelper.horizontalSpace(10.w),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        decoration: BoxDecoration(color: AppColorsTheme.cardBg(context), borderRadius: BorderRadius.circular(12.r), border: Border.all(color: AppColorsTheme.borderColor(context))),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedDirection,
                            isExpanded: true,
                            dropdownColor: AppColorsTheme.cardBg(context),
                            items: const [
                              DropdownMenuItem<String>(value: 'desc', child: Text('Descending')),
                              DropdownMenuItem<String>(value: 'asc', child: Text('Ascending')),
                            ],
                            onChanged: (val) {
                              setState(() {
                                _selectedDirection = val;
                              });
                            },
                          ),
                        ),
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
