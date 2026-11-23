import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../networks/api_access.dart';
import '../../model/website_model.dart';
import 'order/sheet_parts.dart';
import 'website/website_card.dart';

class WebsiteSheet extends StatefulWidget {
  final String title;

  const WebsiteSheet({
    super.key,
    this.title = 'Partner websites',
  });

  static void show(BuildContext context, {String title = 'Partner websites'}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WebsiteSheet(title: title),
    );
  }

  @override
  State<WebsiteSheet> createState() => _WebsiteSheetState();
}

class _WebsiteSheetState extends State<WebsiteSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  static const String _everyStatus = 'Every status';
  static const List<String> _statusFilters = [_everyStatus, 'Active', 'Setup pending'];

  String _selectedStatusFilter = _everyStatus;
  bool _isLoading = true;
  MyWebsitesResponseModel? _responseModel;

  @override
  void initState() {
    super.initState();
    _fetchWebsites();
  }

  Future<void> _fetchWebsites() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _responseModel = await websiteRxObj.fetchWebsites();
    } catch (_) {
      _responseModel = MyWebsitesResponseModel(data: [], allocations: []);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final combinedList = WebsiteListItem.fromResponse(_responseModel);
    final filteredList =
        combinedList.where((item) => item.matches(_searchQuery, _selectedStatusFilter, _everyStatus)).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: sheetDecoration(context),
      child: Column(
        children: [
          const SheetDragHandle(),
          const _WebsiteSheetHeader(),
          UIHelper.verticalSpace(14.h),
          _WebsiteSearchBar(
            controller: _searchController,
            statusFilter: _selectedStatusFilter,
            statusFilters: _statusFilters,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            onStatusChanged: (val) => setState(() => _selectedStatusFilter = val),
          ),
          UIHelper.verticalSpace(14.h),
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                    itemCount: 4,
                    itemBuilder: (_, _) => const WebsiteCardShimmer(),
                  )
                : combinedList.isEmpty
                    ? const _NoWebsites()
                    : filteredList.isEmpty
                        ? const _NoMatchingWebsites()
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                            itemCount: filteredList.length,
                            itemBuilder: (_, index) => WebsiteCard(item: filteredList[index]),
                          ),
          ),
        ],
      ),
    );
  }
}

/// Title, subtitle, close button and the "New website" action.
class _WebsiteSheetHeader extends StatelessWidget {
  const _WebsiteSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partner websites'.tr,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      'Every dedicated storefront on the platform.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColorsTheme.textMutedColor(context),
                      ),
                    ),
                  ],
                ),
              ),
              SheetCircleButton.close(onTap: () => Navigator.pop(context)),
            ],
          ),
          UIHelper.verticalSpace(12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, Routes.addWebsiteScreen),
              icon: Icon(Icons.add_rounded, size: 18.sp),
              label: Text(
                'New website for a partner',
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryOrange,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Search field plus the status filter dropdown.
class _WebsiteSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String statusFilter;
  final List<String> statusFilters;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onStatusChanged;

  const _WebsiteSearchBar({
    required this.controller,
    required this.statusFilter,
    required this.statusFilters,
    required this.onSearchChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final boxDecoration = BoxDecoration(
      color: AppColorsTheme.cardBg(context),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: AppColorsTheme.borderColor(context)),
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: boxDecoration,
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: primaryOrange, size: 18.sp),
                  UIHelper.horizontalSpace(8.w),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onChanged: onSearchChanged,
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by name or address...',
                        hintStyle: TextStyle(
                          fontSize: 12.sp,
                          color: AppColorsTheme.textMutedColor(context),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
            decoration: boxDecoration,
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: statusFilter,
                icon: Icon(Icons.arrow_drop_down_rounded, color: AppColorsTheme.textMainColor(context)),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColorsTheme.textMainColor(context),
                ),
                items: [
                  for (final val in statusFilters) DropdownMenuItem<String>(value: val, child: Text(val)),
                ],
                onChanged: (newVal) {
                  if (newVal != null) onStatusChanged(newVal);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoWebsites extends StatelessWidget {
  const _NoWebsites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.language_rounded,
            size: 52.sp,
            color: AppColorsTheme.textMutedColor(context),
          ),
          UIHelper.verticalSpace(12.h),
          Text(
            'website is not found',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColorsTheme.textMutedColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoMatchingWebsites extends StatelessWidget {
  const _NoMatchingWebsites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No matching websites found',
        style: TextStyle(
          fontSize: 13.5.sp,
          color: AppColorsTheme.textMutedColor(context),
        ),
      ),
    );
  }
}
