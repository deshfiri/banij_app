import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../helpers/all_routes.dart';
import '../../../networks/api_access.dart';
import '../model/verification_history_model.dart';
import 'widgets/common/sub_screen_top_bar.dart';
import 'widgets/verification_history/verification_history_widgets.dart';

/// Past KYC submissions with their status, requirements and deadline.
class VerificationHistoryScreen extends StatefulWidget {
  const VerificationHistoryScreen({super.key});

  @override
  State<VerificationHistoryScreen> createState() => _VerificationHistoryScreenState();
}

class _VerificationHistoryScreenState extends State<VerificationHistoryScreen> {
  bool _isLoading = true;
  VerificationHistoryResponseModel? _responseModel;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      _responseModel = await verificationHistoryRxObj.fetchVerificationHistory();
    } catch (_) {
      _responseModel = VerificationHistoryResponseModel(data: []);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _openKyc() {
    Navigator.pushNamed(context, Routes.kycVerificationScreen).then((_) {
      // The screen may have been closed while KYC was open.
      if (mounted) _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final records = _responseModel?.data ?? [];

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      body: SafeArea(
        child: Column(
          children: [
            SubScreenTopBar(title: 'verification_history'.tr, verticalPadding: 14),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openKyc,
                  icon: Icon(Icons.verified_user_rounded, size: 18.sp),
                  label: Text('Submit your KYC documents', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const VerificationHistoryShimmer()
                  : records.isEmpty
                      ? const VerificationHistoryEmpty()
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                          itemCount: records.length,
                          itemBuilder: (context, index) => VerificationRecordCard(record: records[index]),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
