import 'dart:io';
import 'dart:ui';


import 'package:bbnij/helpers/ui_helpers.dart';
import 'package:bbnij/helpers/update_helper.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../common_widget/custom_button.dart';
import '../constants/app_constants.dart';
import '../constants/text_font_style.dart';
import '../gen/colors.gen.dart';
import 'di.dart';

// String formatTimeOfDay(TimeOfDay time) {
//   final hour =
//       time.hourOfPeriod == 0
//           ? 12
//           : time.hourOfPeriod; // Convert 0 to 12 for AM/PM format
//   final period = time.period == DayPeriod.am ? "AM" : "PM";
//   final minute = time.minute.toString().padLeft(
//     2,
//     '0',
//   ); // Add leading zero to minutes if needed
//   return "$hour:$minute $period";
// }

// Future<String?> pickDate({
//   required BuildContext context,
//   required DateTime startDate,
//   required DateTime endDate,
//   String dateFormat = "yyyy-MM-dd",
// }) async {
//   final DateTime? pickedDate = await showDatePicker(
//     context: context,
//     initialDate: startDate,
//     firstDate: startDate,
//     lastDate: endDate,
//   );

//   if (pickedDate != null) {
//     return DateFormat(dateFormat).format(pickedDate);
//   }
//   return null;
// }

Future<void> showCustomDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  required Function(DateTime) onDatePicked,
}) async {
  final DateTime? pickedDate = await showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (pickedDate != null) {
    onDatePicked(pickedDate);
  }
}

String formatDate(DateTime date) {
  return DateFormat('MM/dd/yyyy').format(date);
}

String formatDateMonthYear(DateTime date) {
  return DateFormat('dd/MM/yyyy').format(date);
}

String formatDateYear(DateTime date) {
  return DateFormat('yyyy-MM-dd').format(date);
}

String dashFormatDate(DateTime date) {
  return DateFormat('MM-dd-yyyy').format(date);
}

DateTime formatStringIntoDate(String date) {
  return DateFormat("MM/dd/yyyy").parse(date);
}

String formatedDate(String? dateStr) {
  if (dateStr == null || dateStr.isEmpty) return '';
  try {
    final DateTime parsedDate = DateTime.parse(dateStr);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  } catch (e) {
    return dateStr; // fallback to original if parsing fails
  }
}
// Future<void> showCustomTimePicker({
//   required BuildContext context,
//   required TimeOfDay initialTime,
//   required Function(TimeOfDay) onTimePicked,
// }) async {
//   final TimeOfDay? pickedTime = await showTimePicker(
//     context: context,
//     initialTime: initialTime,
//   );

//   if (pickedTime != null) {
//     onTimePicked(pickedTime);
//   }
// }

// String formatTime(TimeOfDay time, BuildContext context) {
//   final now = DateTime.now();
//   final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
//   return TimeOfDay.fromDateTime(dt).format(context);
// }

// String formatedTime(TimeOfDay time) {
//   final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
//   final minute = time.minute.toString().padLeft(2, '0');
//   final period = time.period == DayPeriod.am ? 'AM' : 'PM';

//   return '$hour:$minute $period';
// }

// String formatTimeOfDay24Hour(TimeOfDay time) {
//   final int hour = time.hour;
//   final int minute = time.minute;
//   return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
// }

// TimeOfDay convertToTimeOfDay(String timeString) {
//   DateFormat dateFormat = DateFormat("hh:mm a");
//   DateTime dateTime = dateFormat.parse(timeString);
//   return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
// }

// TimeOfDay formatStringToTime(String timeString) {
//   try {
//     final parts = timeString.split(':');
//     final hour = int.parse(parts[0]);
//     final minute = int.parse(parts[1]);
//     return TimeOfDay(hour: hour, minute: minute);
//   } catch (e) {
//     throw FormatException("Invalid time format: $timeString");
//   }
// }

// Future<void> initInternetChecker() async {
//   InternetConnectionChecker.createInstance(
//     checkInterval: const Duration(seconds: 2),
//   ).onStatusChange.listen((status) {
//     switch (status) {
//       case InternetConnectionStatus.connected:
//         // ToastUtil.showShortToast('Data connection is available.');
//         break;
//       case InternetConnectionStatus.disconnected:
//         ToastUtil.showNoInternetToast();
//         break;
//       case InternetConnectionStatus.slow:
//         ToastUtil.showShortToast('Your internet connection is slow.');
//         break;
//     }
//   });
// }

// TimeOfDay parseTime(String timeString) {
//   // Example parsing format: "9:00 AM"
//   // Adjust this based on your app's time format (e.g., "hh:mm a")
//   final timeParts = timeString.split(':');
//   if (timeParts.length == 2) {
//     final hour = int.parse(timeParts[0]);
//     final minute = int.parse(timeParts[1].split(' ')[0]);
//     final isPM = timeString.contains('PM');

//     // Adjust hour for AM/PM
//     final adjustedHour = isPM && hour != 12 ? hour + 12 : hour;
//     return TimeOfDay(hour: adjustedHour, minute: minute);
//   }
//   return TimeOfDay.now(); // Default to current time if parsing fails
// }

Future<void> setInitValue() async {
  await appData.writeIfNull(kKeyIsLoggedIn, false);
  await appData.writeIfNull(kKeyIsFirstTime, true);
  var deviceInfo = DeviceInfoPlugin();
  if (Platform.isIOS) {
    var iosDeviceInfo = await deviceInfo.iosInfo;
    appData.writeIfNull(kKeyDeviceID, iosDeviceInfo.identifierForVendor);
  } else if (Platform.isAndroid) {
    var androidDeviceInfo = await deviceInfo.androidInfo;
    appData.writeIfNull(kKeyDeviceID, androidDeviceInfo.id);
  }
  await Future.delayed(const Duration(seconds: 2));
}

void rotation() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

// void showSheet({
//   required BuildContext context,
//   String? title,
//   String? subTitle,
//   String? btnName,
//   VoidCallback? onLogout,
// }) {
//   showModalBottomSheet<void>(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     backgroundColor: AppColors.c2D2D2D,
//     builder: (BuildContext context) {
//       return SizedBox(
//         height: 250.h,
//         child: Center(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border(top: BorderSide(color: AppColors.cFFFFFF)),
//             ),
//             // margin: EdgeInsets.symmetric(horizontal: 22.w),
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 22.w),
//               child: Column(
//                 children: [
//                   UIHelper.verticalSpace(25.h),
//                   Text(
//                     title ?? 'Log Out',
//                     style: TextFontStyle.headline24w600CFFFFFFSatoshi.copyWith(
//                       color: AppColors.cFFFFFF,
//                     ),
//                   ),
//                   UIHelper.verticalSpace(13.h),
//                   Divider(color: AppColors.c5E5E5E),
//                   UIHelper.verticalSpace(18.h),
//                   Text(
//                     subTitle ?? "Are You Sure you Want to log out.",
//                     style: TextFontStyle.headline14w400CC1C4CCInter.copyWith(
//                       color: AppColors.c909090,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                   UIHelper.verticalSpace(26.h),
//                   Row(
//                     spacing: 19.w,
//                     children: [
//                       Expanded(
//                         child: CustomButton(
//                           height: 40.h,
//                           onTap: () {
//                             NavigationService.goBack;
//                           },
//                           btnName: "Cancle",
//                           borderColor: Colors.transparent,
//                         ),
//                       ),
//                       Expanded(
//                         child: GestureDetector(
//                           onTap: onLogout,
//                           child: Container(
//                             padding: EdgeInsets.symmetric(
//                               vertical: 8.h,
//                               horizontal: 16.w,
//                             ),
//                             decoration: BoxDecoration(
//                               border: Border.all(color: AppColors.cFFFFFF),
//                               borderRadius: BorderRadius.circular(8.r),
//                             ),
//                             child: Text(
//                               btnName ?? "Yes, Log Out",
//                               style: TextFontStyle.headline16w500CFFFFFFInter,
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// void removeFav(BuildContext context, {VoidCallback? onLogout}) {
//   showModalBottomSheet<void>(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     backgroundColor: AppColors.cFFFFFF,
//     builder: (BuildContext context) {
//       return SizedBox(
//         height: 400.h,
//         child: Center(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border(top: BorderSide(color: AppColors.cFFFFFF)),
//             ),
//             // margin: EdgeInsets.symmetric(horizontal: 22.w),
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 22.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   UIHelper.verticalSpace(10.h),
//                   Center(
//                     child: Container(
//                       alignment: Alignment.center,
//                       width: 64.w,
//                       height: 6.h,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(100.r),
//                         color: AppColors.cE6E6E6,
//                       ),
//                     ),
//                   ),
//                   UIHelper.verticalSpace(14.h),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Leave a Review",
//                         style: TextFontStyle.headline20w500CFFFFFFpoppins
//                             .copyWith(color: AppColors.c1A1A1A),
//                       ),
//                       Icon(Icons.clear_sharp, color: AppColors.c141414),
//                     ],
//                   ),
//                   UIHelper.verticalSpace(14.h),
//                   Divider(color: AppColors.cE6E6E6),
//                   UIHelper.verticalSpace(12.h),

//                   Text(
//                     "How was your order?",
//                     style: TextFontStyle.headline16w400CFFFFFFpoppins.copyWith(
//                       color: AppColors.c000000,
//                     ),
//                   ),
//                   UIHelper.verticalSpace(4.h),
//                   Text(
//                     "Please give your rating and also your review.",
//                     style: TextFontStyle.headline14w400CFFFFFFpoppins.copyWith(
//                       color: AppColors.c808080,
//                     ),
//                   ),
//                   UIHelper.verticalSpace(17.h),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.star, color: AppColors.cFFA928),
//                       Icon(Icons.star, color: AppColors.cFFA928),
//                       Icon(Icons.star, color: AppColors.cFFA928),
//                       Icon(Icons.star, color: AppColors.cFFA928),
//                       Icon(Icons.star, color: AppColors.cFFA928),
//                     ],
//                   ),
//                   UIHelper.verticalSpace(20.h),
//                   CustomFormField(hintText: "Write your review...", maxline: 3),

//                   UIHelper.verticalSpace(16.h),
//                   CustomButton(
//                     height: 40.h,
//                     onTap: () {
//                       NavigationService.goBack;
//                     },
//                     btnName: "Submit",
//                     borderColor: Colors.transparent,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// void allMenuBottom(BuildContext context, {VoidCallback? onLogout}) {
//   showModalBottomSheet<void>(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     backgroundColor: AppColors.cFFFFFF,
//     builder: (BuildContext context) {
//       return SizedBox(
//         height: 400.h,
//         child: Center(
//           child: Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(16.r),
//               border: Border(top: BorderSide(color: AppColors.cFFFFFF)),
//             ),
//             // margin: EdgeInsets.symmetric(horizontal: 22.w),
//             child: Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: GridView.builder(
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 4,
//                         crossAxisSpacing: 20.w,
//                         mainAxisSpacing: 16.h,
//                         childAspectRatio: .70,
//                       ),
//                       itemCount: 9,
//                       itemBuilder: (context, index) {
//                         return CustomAllMenuWidget(
//                           titile: 'Fruits & vegetables',
//                           img: Assets.icons.fruiteIcon,
//                           ontap: () {
//                             NavigationService.navigateTo(
//                               Routes.foodAndVegetablesScreen,
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }

// void cancleMethod(BuildContext context, {required VoidCallback onLogout}) {
//   showModalBottomSheet<void>(
//     context: context,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//     ),
//     backgroundColor: AppColors.cFFFFFF,
//     builder: (BuildContext context) {
//       String selectedValue = ''; // Local state

//       return StatefulBuilder(
//         builder: (context, setState) {
//           return SizedBox(
//             height: 250.h,
//             child: Center(
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16.r),
//                   border: Border(top: BorderSide(color: AppColors.cFFFFFF)),
//                 ),
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 16.w,
//                     vertical: 28.h,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       RadioOptionTile(
//                         text: "I need to go to a different destination",
//                         value: "different_destination",
//                         groupValue: selectedValue,
//                         onChanged: (val) {
//                           setState(() {
//                             selectedValue = val!;
//                           });
//                         },
//                       ),
//                       RadioOptionTile(
//                         text: "I want to cancel for another reason",
//                         value: "another_reason",
//                         groupValue: selectedValue,
//                         onChanged: (val) {
//                           setState(() {
//                             selectedValue = val!;
//                           });
//                         },
//                       ),
//                       UIHelper.verticalSpace(32.h),
//                       CustomButton(onTap: onLogout, btnName: "Submit"),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       );
//     },
//   );
// }

void showBottomDialog({
  required BuildContext context,
  required String titile,
  required TextStyle style,
  required String btnName,
  required VoidCallback onConfirm,
  required VoidCallback onCancel,
}) {
  showModalBottomSheet(
    context: context,
    //  barrierColor: AppColors.c121212.withValues(alpha: 0.8),
    backgroundColor: Colors.transparent,
    isDismissible: true,
    enableDrag: true,
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Container(
        margin: EdgeInsets.only(bottom: 24.h, left: 16.w, right: 16.w),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.cFFFFFF, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: titile, style: style),
                  TextSpan(
                    text: ' your account',
                    style: TextFontStyle.headline20w500CFFFFFFpoppins,
                  ),
                ],
              ),
            ),

            UIHelper.verticalSpace(28.h),
            Row(
              children: [
                Expanded(
                  child: CustomButton(onTap: onCancel, btnName: 'Cancel'),
                ),
                UIHelper.horizontalSpace(16.w),
                Expanded(
                  child: CustomButton(
                    onTap: onConfirm,
                    color: AppColors.c303134,
                    btnName: btnName,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// void registatinSuccess({
//   required BuildContext context,

//   required VoidCallback onTap,
// }) {
//   showDialog(
//     context: context,

//     builder:
//         (context) => AlertDialog(
//           backgroundColor: AppColors.cFFFFFF,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(20.r),
//           ),
//           content: Padding(
//             padding: EdgeInsets.all(24.sp),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Image.asset(
//                   Assets.images.congratulations6.path,
//                   width: 122.w,
//                   height: 95.h,
//                 ),
//                 UIHelper.verticalSpace(35.h),
//                 Text(
//                   "Congratulations!",
//                   style: TextFontStyle.headline24w600CFFFFFFpoppins.copyWith(
//                     color: AppColors.c141414,
//                   ),
//                 ),
//                 UIHelper.verticalSpace(12.h),
//                 Text(
//                   textAlign: TextAlign.center,
//                   "You have successfully created your account. Please wait some minute, we are confirm you.",
//                   style: TextFontStyle.headline14w400CFFFFFFpoppins.copyWith(
//                     color: AppColors.c5A5C5F,
//                   ),
//                 ),
//                 UIHelper.verticalSpace(24.h),
//                 Divider(color: AppColors.cB3BAC5, height: 1.h),
//                 UIHelper.verticalSpace(24.h),
//                 GestureDetector(
//                   onTap: onTap,
//                   child: CustomTextGradient(
//                     titile: "Continue",
//                     //  textStyle: TextStyle(decoration: TextDecoration.underline),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//   );
// }

void showRejectDialog(
  BuildContext context,
  String ammount,
  String reqNo,
  String text,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CustomRejectDialog(
        text: text,
        ammount: ammount,
        rejectbtn: () {
          // reviewRejectRxObj.rejectReq(reqNo).then((response) {
          //   log("reject req");
          //
          //   showDialog(
          //     context: context,
          //     barrierDismissible: false,
          //     builder: (_) => CustomStatusDialog(
          //       iconData: response.success == true
          //           ? Icons.check_circle
          //           : Icons.error_outline,
          //       title: response.success == true ? "Success" : "Failed",
          //       iconColor: response.success == true ? Colors.green : Colors.red,
          //       message: response.message,
          //       secondButtonText: "Done",
          //       secondButtonTap: () {
          //         NavigationService.navigateToReplacementUntil(
          //           Routes.finaceScreen,
          //         );
          //       },
          //     ),
          //   );
          // });
          //
          //

          },
      );
    },
  );
}

void showRejectDialogCancel(
  BuildContext context,
  String ammount,
  String reqNo,
  String rowId,
  String crn,
  String text,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CustomRejectDialog(
        text: text,
        ammount: ammount,
        // rejectbtn: () async {
        //   await requestAllApproveRxObj
        //       .acceptRequest(rowId, reqNo, crn, "cancel")
        //       .then((response) {
        //         NavigationService.goBack;
        //         showDialog(
        //           context: context,
        //           barrierDismissible: false,
        //           builder: (_) => CustomStatusDialog(
        //             iconData: response.success == true
        //                 ? Icons.check_circle
        //                 : Icons.error_outline,
        //             title: response.success == true ? "Success" : "Failed",
        //             iconColor: response.success == true
        //                 ? Colors.green
        //                 : Colors.red,
        //             message: response.message,
        //             secondButtonText: "Done",
        //             secondButtonTap: () {
        //               NavigationService.navigateToReplacementUntil(
        //                 Routes.finaceScreen,
        //               );
        //             },
        //           ),
        //         );
        //       });
        // },
        //
        //
      );
    },
  );
}

void logoutDialog(
  BuildContext context,
  String title,
  String text,
  VoidCallback logout,
  String yesBtn,
  String noBtn,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CustomRejectDialog(
        title: title,
        text: text,
        rejectbtn: logout,
        btnName: yesBtn,
        btnName1: noBtn,
      );
    },
  );
}

void showApprove(
  BuildContext context,
  String ammount,
  String btnName,
  String title,
  Color btnCOlor,
  Color icon,
  String text,
  IconData iconData,
  VoidCallback acceptBtn,
) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return CustomRejectDialog(
        title: title,
        text: text,
        ammount: ammount,
        btnName: btnName,
        btnColor: btnCOlor,
        icon: icon,
        iconData: iconData,
        rejectbtn: acceptBtn,
      );
    },
  );
}

class LoadingHelper {
  static final ValueNotifier<bool> _loading = ValueNotifier(false);

  static void show() {
    _loading.value = true;
  }

  static void hide() {
    _loading.value = false;
  }

  static Widget overlay({required Widget child}) {
    return Stack(
      children: [
        child,

        ValueListenableBuilder<bool>(
          valueListenable: _loading,
          builder: (context, isLoading, _) {
            if (!isLoading) return const SizedBox();

            return Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(child: CircularProgressIndicator()),
            );
          },
        ),
      ],
    );
  }
}
