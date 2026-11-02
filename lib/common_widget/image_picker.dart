// import 'dart:developer';
// import 'dart:io';
 

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:get/utils.dart';
// import 'package:image_picker/image_picker.dart';

 
// void showPickImageBottomSheet(
//   BuildContext context,
//   ValueNotifier<XFile?> imageFileNotifier, {
//   bool showCameraOption = true,
// }) {
//   final textTheme = Theme.of(
//     context,
//   ).textTheme.apply(displayColor: Theme.of(context).colorScheme.onSurface);
 
//   showCupertinoModalPopup(
//     context: context,
//     builder:
//         (BuildContext context) => CupertinoActionSheet(
//           title: TextStyleExample(
//             name: 'Choose Image',
//             style: textTheme.headlineSmall!.copyWith(
//               color: AppColors.c000000,
//               letterSpacing: 0.1,
//             ),
//           ),
//           message: TextStyleExample(
//             name: "Choose an image from your camera or existing gallery.",
//             style: textTheme.bodyMedium!.copyWith(letterSpacing: 0.1),
//           ),
//           actions: <Widget>[
//             // List of actions
//             showCameraOption
//                 ? CupertinoActionSheetAction(
//                   child: TextStyleExample(
//                     name: 'Camera',
//                     style: textTheme.titleMedium!.copyWith(
//                       color: AppColors.c000000,
//                     ),
//                   ),
//                   onPressed: () {
//                     log("message1");
//                     NavigationService.goBack;
//                     selectImageFromCamera(context, imageFileNotifier);
//                   },
//                 )
//                 : const SizedBox.shrink(),
//             CupertinoActionSheetAction(
//               child: TextStyleExample(
//                 name: 'Gallery',
//                 style: textTheme.titleMedium!.copyWith(
//                   color: AppColors.c000000,
//                 ),
//               ),
//               onPressed: () {
//                 log("message");
//                 NavigationService.goBack;
//                 selectImageFromGallery(context, imageFileNotifier);
//               },
//             ),
//           ],
//           // A cancel button at the bottom of the modal popup
//           // cancelButton: CupertinoActionSheetAction(
//           //   child: TextStyleExample(
//           //     name: 'Close',
//           //     style: textTheme.titleLarge!.copyWith(
//           //       color: Colors.grey,
//           //       letterSpacing: 0.1,
//           //     ),
//           //   ),
//           //   onPressed: () {
//           //     Navigator.pop(context); // Close the modal popup
//           //   },
//           // ),
//         ),
//   );
// }
 
// Future<void> selectImageFromCamera(
//   BuildContext context,
//   ValueNotifier<XFile?> imageFileNotifier,
// ) async {
//   final picker = ImagePicker();
//   final pickedFile = await picker.pickImage(source: ImageSource.camera);
//   if (pickedFile != null) {
//     imageFileNotifier.value = pickedFile;
//   }
//   // Collapse the modal popup menu for hiding bottom sheet
//   if (context.mounted) {
//     Navigator.pop(context);
//   }
// }
 
// Future<void> selectImageFromGallery(
//   BuildContext context,
//   ValueNotifier<XFile?> imageFileNotifier,
// ) async {
//   final picker = ImagePicker();
//   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//   if (pickedFile != null) {
//     imageFileNotifier.value = pickedFile;
//     // Collapse the modal popup menu for hiding bottom sheet
//     if (context.mounted) {
//       Navigator.pop(context);
//     }
//   }
// }
 
// class TextStyleExample extends StatelessWidget {
//   const TextStyleExample({super.key, required this.name, required this.style});
 
//   final String name;
//   final TextStyle style;
 
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(1.sp),
//       child: Text(name, style: style.copyWith(letterSpacing: 1.0)),
//     );
//   }
// }
 
// imagePickerDialog(BuildContext context, ValueNotifier<File?> imageNotifier) {
//   return showModalBottomSheet(
//     showDragHandle: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//     ),
//     context: context,
//     builder:
//         (_) => Container(
//           height: 90.h,
//           padding: EdgeInsets.symmetric(horizontal: 20.w),
//           child: Column(
//             children: [
//               InkWell(
//                 onTap: () {
//                   Navigator.pop(context);
//                   pickImage(imageNotifier, ImageSource.camera);
//                 },
//                 child: Row(
//                   children: [
//                     SvgPicture.asset(Assets.icons.cameraIcon),
//                     UIHelper.horizontalSpaceSmall,
//                     Text(
//                       "Take a Photo".tr,
//                       style: TextFontStyle.headline14w300CFFFFFFpoppins.copyWith(color: AppColors.c000000),
//                     ),
//                   ],
//                 ),
//               ),
//               UIHelper.verticalSpace(16.h),
//               InkWell(
//                 onTap: () {
//                   NavigationService.goBack;
//                   pickImage(imageNotifier, ImageSource.gallery);
//                 },
//                 child: Row(
//                   children: [
//                     SvgPicture.asset(Assets.icons.cameraIcon),
//                     UIHelper.horizontalSpaceSmall,
//                     Text(
//                       "Choose from Album".tr,
//                       style: TextFontStyle.headline14w300CFFFFFFpoppins.copyWith(color: AppColors.c000000),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//   );
// }
 
// Future<void> pickImage(
//   ValueNotifier<File?> imageNotifier,
//   ImageSource source,
// ) async {
//   final ImagePicker picker = ImagePicker();
//   final pickedFile = await picker.pickImage(source: source);
 
//   if (pickedFile != null) {
//     imageNotifier.value = File(pickedFile.path); // Update the ValueNotifier
//   }
// }
 