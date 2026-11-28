import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../constants/image_const.dart';
import '../../../helpers/all_routes.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../model/website_model.dart';
import 'widgets/website/website_card.dart';

class WebsiteScreen extends StatefulWidget {
  final String title;

  const WebsiteScreen({
    super.key,
    this.title = 'Partner websites',
  });

  static Future<void> open(BuildContext context, {String title = 'Partner websites'}) {
    return Navigator.push(context, MaterialPageRoute(builder: (_) => WebsiteScreen(title: title)));
  }

  @override
  State<WebsiteScreen> createState() => _WebsiteScreenState();
}

class _WebsiteScreenState extends State<WebsiteScreen> {
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

  Widget _buildHeroHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.2 : 0.28),
            blurRadius: 18.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Back Button, White Logo & New Website Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 24.sp,
                    ),
                  ),
                  Image.asset(
                    whiteLogo,
                    width: 105.w,
                    height: 34.h,
                    fit: BoxFit.contain,
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, Routes.addWebsiteScreen),
                    icon: Icon(Icons.add_rounded, size: 14.sp, color: primaryOrange),
                    label: Text('New website', style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.bold, color: primaryOrange)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                      elevation: 2,
                    ),
                  ),
                ],
              ),
              UIHelper.verticalSpace(12.h),

              // Title & Subtitle
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title.tr,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    UIHelper.verticalSpace(2.h),
                    Text(
                      'Every dedicated storefront on the platform.',
                      style: TextStyle(
                        fontSize: 11.5.sp,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final combinedList = WebsiteListItem.fromResponse(_responseModel);
    final filteredList =
        combinedList.where((item) => item.matches(_searchQuery, _selectedStatusFilter, _everyStatus)).toList();

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: Column(
        children: [
          _buildHeroHeader(context),
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
