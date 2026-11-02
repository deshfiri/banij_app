import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../gen/assets.gen.dart';
import '../gen/colors.gen.dart';

class CustomNetworkImage extends StatelessWidget {
  final String urls;
  final double? width;
  final double? height;
  final double? borderRadius;

  const CustomNetworkImage({
    super.key,
    required this.urls,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius ?? 0.0),
      child: CachedNetworkImage(
        imageUrl: urls,
        width: width ?? 70.w,
        height: height ?? 70.h,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: width ?? 90.w,
                height: height ?? 70.h,
                color: Colors.white,
              ),
            ),
        errorWidget:
            (context, url, error) => Container(
              width: width ?? 90.w,
              height: height ?? 70.h,
              color: AppColors.cFFFFFF,
              child: Image.asset(Assets.images.noImg.path, fit: BoxFit.cover),
            ),
      ),
    );
  }
}
