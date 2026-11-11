import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../constants/color.dart';
import '../../../../helpers/all_routes.dart';
import '../../../../helpers/ui_helpers.dart';
import '../../../../networks/api_access.dart';
import '../../model/website_model.dart';

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
  String _selectedStatusFilter = 'Every status';
  bool _isLoading = true;
  MyWebsitesResponseModel? _responseModel;

  final List<String> _statusFilters = ['Every status', 'Active', 'Setup pending'];

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dataItems = _responseModel?.data ?? [];
    final allocItems = _responseModel?.allocations ?? [];

    // Combine dataItems and allocItems into a unified list of website items
    List<Map<String, String>> combinedList = [];

    for (var item in dataItems) {
      combinedList.add({
        'name': item.name ?? item.host ?? 'Partner Website',
        'host': item.host ?? 'feriwala.shop',
        'account': item.name ?? 'Partner Account',
        'status': item.statusLabel ?? item.status ?? 'Active',
        'connection': item.connectionHealth ?? 'Not connected yet',
        'lastSynced': item.lastSyncedAt ?? 'Never',
      });
    }

    for (var alloc in allocItems) {
      combinedList.add({
        'name': alloc.name ?? alloc.domainName ?? 'Partner Website',
        'host': alloc.domainName ?? alloc.website?.host ?? 'feriwala.shop',
        'account': alloc.partnerName ?? alloc.name ?? 'Partner Account',
        'status': alloc.statusLabel ?? alloc.status ?? 'Setup pending',
        'connection': 'Not connected yet',
        'lastSynced': 'Never',
      });
    }

    final filteredList = combinedList.where((item) {
      final name = (item['name'] ?? '').toLowerCase();
      final host = (item['host'] ?? '').toLowerCase();
      final status = (item['status'] ?? '').toLowerCase();

      final matchesSearch = name.contains(_searchQuery.toLowerCase()) ||
          host.contains(_searchQuery.toLowerCase());

      final matchesStatus = _selectedStatusFilter == 'Every status' ||
          status.contains(_selectedStatusFilter.toLowerCase());

      return matchesSearch && matchesStatus;
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: AppColorsTheme.background(context),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.r),
          topRight: Radius.circular(28.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag Handle bar
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

          // Header Title & Actions
          Padding(
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColorsTheme.cardBg(context),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColorsTheme.borderColor(context)),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20.sp,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(12.h),

                // New Website Button Action
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, Routes.addWebsiteScreen);
                    },
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
          ),
          UIHelper.verticalSpace(14.h),

          // Search & Filter Dropdown Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: AppColorsTheme.cardBg(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColorsTheme.borderColor(context)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search_rounded, color: primaryOrange, size: 18.sp),
                        UIHelper.horizontalSpace(8.w),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: (val) {
                              setState(() {
                                _searchQuery = val;
                              });
                            },
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

                // Dropdown Filter for Status
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppColorsTheme.cardBg(context),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColorsTheme.borderColor(context)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatusFilter,
                      icon: Icon(Icons.arrow_drop_down_rounded, color: AppColorsTheme.textMainColor(context)),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                      items: _statusFilters.map((String val) {
                        return DropdownMenuItem<String>(
                          value: val,
                          child: Text(val),
                        );
                      }).toList(),
                      onChanged: (newVal) {
                        if (newVal != null) {
                          setState(() {
                            _selectedStatusFilter = newVal;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          UIHelper.verticalSpace(14.h),

          // Scrollable Website List Cards
          Expanded(
            child: _isLoading
                ? _buildWebsiteShimmer(context)
                : combinedList.isEmpty
                    ? Center(
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
                      )
                    : filteredList.isEmpty
                        ? Center(
                            child: Text(
                              'No matching websites found',
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                color: AppColorsTheme.textMutedColor(context),
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final item = filteredList[index];
                              final name = item['name'] ?? '';
                              final host = item['host'] ?? '';
                              final account = item['account'] ?? '';
                              final status = item['status'] ?? 'Active';
                              final connection = item['connection'] ?? 'Not connected yet';
                              final lastSynced = item['lastSynced'] ?? 'Never';

                              final isActive = status.toLowerCase().contains('active');
                              final isHealthy = connection.toLowerCase().contains('healthy');

                              return Container(
                                margin: EdgeInsets.only(bottom: 12.h),
                                padding: EdgeInsets.all(14.w),
                                decoration: BoxDecoration(
                                  color: AppColorsTheme.cardBg(context),
                                  borderRadius: BorderRadius.circular(16.r),
                                  border: Border.all(
                                    color: AppColorsTheme.borderColor(context),
                                    width: 1.w,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                                      blurRadius: 8.r,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Address & Host URL
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(10.w),
                                          decoration: BoxDecoration(
                                            color: primaryOrange.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12.r),
                                          ),
                                          child: Icon(
                                            Icons.language_rounded,
                                            color: primaryOrange,
                                            size: 20.sp,
                                          ),
                                        ),
                                        UIHelper.horizontalSpace(12.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                name,
                                                style: TextStyle(
                                                  fontSize: 14.5.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColorsTheme.textMainColor(context),
                                                ),
                                              ),
                                              UIHelper.verticalSpace(2.h),
                                              Text(
                                                host,
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: AppColorsTheme.textMutedColor(context),
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status Pill Badge
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                          decoration: BoxDecoration(
                                            color: (isActive ? const Color(0xFF10B981) : const Color(0xFF0284C7)).withValues(alpha: 0.12),
                                            borderRadius: BorderRadius.circular(20.r),
                                            border: Border.all(
                                              color: (isActive ? const Color(0xFF10B981) : const Color(0xFF0284C7)).withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                isActive ? Icons.check_circle_outline_rounded : Icons.sync_rounded,
                                                size: 12.sp,
                                                color: isActive ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                                              ),
                                              UIHelper.horizontalSpace(4.w),
                                              Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: isActive ? const Color(0xFF10B981) : const Color(0xFF0284C7),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    UIHelper.verticalSpace(12.h),
                                    Divider(color: AppColorsTheme.borderColor(context)),
                                    UIHelper.verticalSpace(8.h),

                                    // Row 2: Account & Connection Status
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'ACCOUNT',
                                              style: TextStyle(
                                                fontSize: 9.5.sp,
                                                fontWeight: FontWeight.w800,
                                                color: AppColorsTheme.textMutedColor(context),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            UIHelper.verticalSpace(2.h),
                                            Text(
                                              account,
                                              style: TextStyle(
                                                fontSize: 12.5.sp,
                                                fontWeight: FontWeight.w600,
                                                color: AppColorsTheme.textMainColor(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              'CONNECTION',
                                              style: TextStyle(
                                                fontSize: 9.5.sp,
                                                fontWeight: FontWeight.w800,
                                                color: AppColorsTheme.textMutedColor(context),
                                                letterSpacing: 0.5,
                                              ),
                                            ),
                                            UIHelper.verticalSpace(2.h),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  isHealthy ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                                  size: 12.sp,
                                                  color: isHealthy ? const Color(0xFF10B981) : AppColorsTheme.textMutedColor(context),
                                                ),
                                                UIHelper.horizontalSpace(4.w),
                                                Text(
                                                  connection,
                                                  style: TextStyle(
                                                    fontSize: 11.5.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: isHealthy ? const Color(0xFF10B981) : AppColorsTheme.textMutedColor(context),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Text(
                                              lastSynced,
                                              style: TextStyle(
                                                fontSize: 10.sp,
                                                color: AppColorsTheme.textMutedColor(context),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: baseColor,
          highlightColor: highlightColor,
          child: Container(
            margin: EdgeInsets.only(bottom: 12.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColorsTheme.borderColor(context)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(width: 140.w, height: 14.h, color: Colors.white),
                          UIHelper.verticalSpace(6.h),
                          Container(width: 100.w, height: 11.h, color: Colors.white),
                        ],
                      ),
                    ),
                    Container(
                      width: 70.w,
                      height: 22.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                  ],
                ),
                UIHelper.verticalSpace(12.h),
                Container(width: double.infinity, height: 1.h, color: Colors.white),
                UIHelper.verticalSpace(8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 80.w, height: 14.h, color: Colors.white),
                    Container(width: 90.w, height: 14.h, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
