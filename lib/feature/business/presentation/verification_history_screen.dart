import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../networks/api_access.dart';
import '../model/verification_history_model.dart';
import 'widgets/verification_history/verification_history_widgets.dart';

/// Every KYC verification of this account: status, dates, due date and the
/// documents that were asked for. Opened from Business tools › Verification.
class VerificationHistoryScreen extends StatefulWidget {
  const VerificationHistoryScreen({super.key});

  @override
  State<VerificationHistoryScreen> createState() => _VerificationHistoryScreenState();
}

class _VerificationHistoryScreenState extends State<VerificationHistoryScreen> {
  bool _isLoading = true;
  List<VerificationRecordModel> _records = const [];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData({bool showLoader = true}) async {
    if (showLoader) setState(() => _isLoading = true);
    List<VerificationRecordModel> records = const [];
    try {
      final response = await verificationHistoryRxObj.fetchVerificationHistory();
      records = response.data ?? const [];
    } catch (error) {
      debugPrint('Verification history failed: $error');
    }
    if (!mounted) return;
    setState(() {
      _records = records;
      _isLoading = false;
    });
  }

  void _openKyc() {
    Navigator.pushNamed(context, Routes.kycVerificationScreen).then((_) {
      if (mounted) _fetchData(showLoader: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsTheme.background(context),
        body: Column(
          children: [
            HeroPageHeader(
              title: 'verification_history'.tr,
              subtitle: 'verification_history_subtitle'.tr,
            ),
            Expanded(
              child: RefreshIndicator(
                color: primaryOrange,
                onRefresh: () => _fetchData(showLoader: false),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // Keep cards readable on tablets.
                    final side = constraints.maxWidth > 760 ? (constraints.maxWidth - 720) / 2 : 16.w;
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(side, 18.h, side, 24.h),
                      children: [
                        if (_isLoading)
                          const VerificationHistoryShimmer()
                        else if (_records.isEmpty)
                          const VerificationHistoryEmpty()
                        else ...[
                          // The API lists the latest verification first.
                          VerificationSummaryBanner(record: _records.first),
                          SizedBox(height: 22.h),
                          VerificationSectionHeading(count: _records.length),
                          SizedBox(height: 12.h),
                          for (final (index, record) in _records.indexed)
                            VerificationRecordCard(record: record, highlighted: index == 0),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildSubmitBar(),
      ),
    );
  }

  Widget _buildSubmitBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = BorderRadius.circular(14.r);
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
              child: Container(
                height: 48.h,
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
                    onTap: _openKyc,
                    borderRadius: radius,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.upload_file_rounded, size: 18.sp, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          'vh_submit_kyc'.tr,
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
    );
  }
}
