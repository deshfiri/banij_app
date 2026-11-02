// import 'package:colten_app/common_widget/custom_network_image.dart';
// import 'package:colten_app/constants/text_font_style.dart';
// import 'package:colten_app/gen/colors.gen.dart';
// import 'package:colten_app/helpers/ui_helpers.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:gradient_borders/box_borders/gradient_box_border.dart';


// class CustomEventCard extends StatelessWidget {
//   final List<String>? imageUrls;
//   final String title;
//   final String date;
//   final String description;

//   const CustomEventCard({
//     super.key,
//     required this.title,
//     required this.date,
//     required this.description,
//     this.imageUrls,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
//           decoration: BoxDecoration(
//             border: GradientBoxBorder(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [AppColors.cADADAD, AppColors.c474747],
//               ),
//               width: 0.5,
//             ),
//             color: AppColors.cFFFFFF.withValues(alpha: 0.1),
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: Text(title,
//                         style: TextFontStyle.headline12w500CFFFFFFpoppins),
//                   ),
//                   Text(
//                     'Date: $date',
//                     style: TextFontStyle.headline10w300CFFFFFFpoppins.copyWith(
//                       color: AppColors.cACACAC,
//                     ),
//                   ),
//                 ],
//               ),
//               UIHelper.verticalSpace(8.h),
//               Text(description,
//                   style: TextFontStyle.headline12w300CFFFFFFpoppins),
//             ],
//           ),
//         ),
//         if (imageUrls != null && imageUrls!.isNotEmpty) ...[
//           UIHelper.verticalSpace(5.h),
//           _buildImageGrid(),
//         ],
//       ],
//     );
//   }

//   Widget _buildImageGrid() {
//     if (imageUrls == null || imageUrls!.isEmpty) return SizedBox.shrink();

//     if (imageUrls!.length == 1) {
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: CustomNetworkImage(
//           urls: imageUrls!.first,
//           width: double.infinity,
//           height: 209.h,
//         ),
//       );
//     } else if (imageUrls!.length == 2) {
//       return Row(
//         children: imageUrls!.map((url) {
//           return Expanded(
//             child: Padding(
//               padding: EdgeInsets.all(4.w),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: CustomNetworkImage(
//                   urls: url,
//                   width: double.infinity,
//                   height: 103.h,
//                 ),
//               ),
//             ),
//           );
//         }).toList(),
//       );
//     } else {
//       return GridView.count(
//         crossAxisCount: 2,
//         shrinkWrap: true,
//         padding: EdgeInsets.zero,
//         physics: NeverScrollableScrollPhysics(),
//         crossAxisSpacing: 5.w,
//         mainAxisSpacing: 5.h,
//         childAspectRatio: 1.5,
//         children: imageUrls!.map((url) {
//           return ClipRRect(
//             borderRadius: BorderRadius.circular(10),
//             child: CustomNetworkImage(
//               urls: url,
//               width: double.infinity,
//               height: 103.h,
//             ),
//           );
//         }).toList(),
//       );
//     }
//   }
// }
