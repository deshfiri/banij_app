// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../gen/colors.gen.dart';

final class ToastUtil {
  ToastUtil._();

  /// Error Toast
  static void showErrorMessage(String message) {
    Get.snackbar(
      "Warning",
      message,
      titleText: Text(
        "Warning",
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.4,
        ),
      ),
      backgroundColor: AppColors.allPrimaryColor,
      borderRadius: 14.r,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      snackPosition: SnackPosition.TOP,
      colorText: Colors.white,
      icon: Icon(Icons.error_outline, color: Colors.white, size: 24.sp),
      shouldIconPulse: false,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Success Toast
  static void showSuccessMessage(String message) {
    Get.snackbar(
      "Success",
      message,
      titleText: Text(
        "Success",
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.4,
        ),
      ),
      backgroundColor: const Color(0xFFFD6B04),
      borderRadius: 14.r,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      snackPosition: SnackPosition.TOP,
      colorText: Colors.white,
      icon: Icon(Icons.check_circle_outline, color: Colors.white, size: 24.sp),
      shouldIconPulse: false,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  /// Info Toast (Optional)
  static void showInfoMessage(String message) {
    Get.snackbar(
      "Info",
      message,
      titleText: Text(
        "Information",
        style: TextStyle(
          fontSize: 15.sp,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: Colors.white,
          height: 1.4,
        ),
      ),
      backgroundColor: AppColors.allPrimaryColor,
      borderRadius: 14.r,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      snackPosition: SnackPosition.TOP,
      colorText: Colors.white,
      icon: Icon(Icons.info_outline, color: Colors.white, size: 24.sp),
      shouldIconPulse: false,
      duration: const Duration(seconds: 3),
      isDismissible: true,
    );
  }

  static void showShortToast(String message) {}
}
