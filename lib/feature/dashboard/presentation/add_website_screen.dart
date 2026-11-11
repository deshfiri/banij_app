import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../constants/color.dart';
import '../../../helpers/toast.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/api_access.dart';
import '../data/website_api.dart';

class AddWebsiteScreen extends StatefulWidget {
  const AddWebsiteScreen({super.key});

  @override
  State<AddWebsiteScreen> createState() => _AddWebsiteScreenState();
}

class _AddWebsiteScreenState extends State<AddWebsiteScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _subdomainController = TextEditingController();

  bool _isLoading = false;
  String _subdomainPreview = 'subdomain';

  @override
  void dispose() {
    _nameController.dispose();
    _subdomainController.dispose();
    super.dispose();
  }

  void _onSubdomainChanged(String val) {
    setState(() {
      _subdomainPreview = val.trim().isEmpty ? 'subdomain' : val.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '');
    });
  }

  Future<void> _submitRequest() async {
    final name = _nameController.text.trim();
    final subdomain = _subdomainController.text.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9-]'), '');

    if (name.isEmpty) {
      ToastUtil.showErrorMessage('Please enter a website name');
      return;
    }

    if (subdomain.isEmpty) {
      ToastUtil.showErrorMessage('Please enter a valid subdomain');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final body = {
        'name': name,
        'subdomain': subdomain,
      };

      await WebsiteApi.instance.postWebsite(body);

      ToastUtil.showSuccessMessage('Website requested successfully!');
      websiteRxObj.fetchWebsites();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to request website');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColorsTheme.background(context),
      appBar: AppBar(
        backgroundColor: AppColorsTheme.cardBg(context),
        elevation: 1,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: AppColorsTheme.textMainColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Request New Website'.tr,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Banner Card
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: isDark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                    color: primaryOrange.withValues(alpha: 0.3),
                    width: 1.w,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.language_rounded,
                      color: primaryOrange,
                      size: 28.sp,
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dedicated Partner Website',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                          UIHelper.verticalSpace(3.h),
                          Text(
                            'Asks for a dedicated website. It opens in setup pending with its charges due.',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColorsTheme.textMutedColor(context),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(24.h),

              // Form Section Container
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: AppColorsTheme.cardBg(context),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColorsTheme.borderColor(context),
                    width: 1.w,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Field 1: Website Name
                    Text(
                      'Website Name',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.background(context),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColorsTheme.borderColor(context)),
                      ),
                      child: TextField(
                        controller: _nameController,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          color: AppColorsTheme.textMainColor(context),
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Nasrin Fashion House',
                          hintStyle: TextStyle(
                            fontSize: 13.sp,
                            color: AppColorsTheme.textMutedColor(context),
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                      ),
                    ),
                    UIHelper.verticalSpace(20.h),

                    // Field 2: Subdomain
                    Text(
                      'Subdomain Keyword',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColorsTheme.textMainColor(context),
                      ),
                    ),
                    UIHelper.verticalSpace(8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.background(context),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColorsTheme.borderColor(context)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subdomainController,
                              onChanged: _onSubdomainChanged,
                              style: TextStyle(
                                fontSize: 13.5.sp,
                                color: AppColorsTheme.textMainColor(context),
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: InputDecoration(
                                hintText: 'e.g. nasrin',
                                hintStyle: TextStyle(
                                  fontSize: 13.sp,
                                  color: AppColorsTheme.textMutedColor(context),
                                  fontWeight: FontWeight.normal,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                            ),
                          ),
                          Text(
                            '.feriwala.shop',
                            style: TextStyle(
                              fontSize: 12.5.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryOrange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    UIHelper.verticalSpace(12.h),

                    // Live Host URL Preview Box
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.background(context),
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(
                          color: primaryOrange.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.link_rounded, size: 16.sp, color: primaryOrange),
                          UIHelper.horizontalSpace(8.w),
                          Text(
                            'Live URL Preview: ',
                            style: TextStyle(
                              fontSize: 11.5.sp,
                              color: AppColorsTheme.textMutedColor(context),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'https://$_subdomainPreview.feriwala.shop',
                              style: TextStyle(
                                fontSize: 11.5.sp,
                                fontWeight: FontWeight.bold,
                                color: primaryOrange,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              UIHelper.verticalSpace(28.h),

              // Submit Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Request Website',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
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
