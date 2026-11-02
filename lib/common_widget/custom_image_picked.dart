import 'dart:io';



import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';

import '../gen/colors.gen.dart';

class CustomImgePicked extends StatelessWidget {
  final ValueNotifier<List<XFile>> imageListNotifier;

  const CustomImgePicked({super.key, required this.imageListNotifier});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<XFile>>(
      valueListenable: imageListNotifier,
      builder: (context, images, _) {
        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 11.w,
            mainAxisSpacing: 11.h,
            childAspectRatio: 1.5,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: images.length, 
          itemBuilder: (context, index) {
            final image = images[index];
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.file(
                    File(image.path),
                    width: 162.w,
                    height: 101.h,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 10.h,
                  right: 10.r,
                  child: InkWell(
                    onTap: () {
                      final updatedImages = List<XFile>.from(images)
                        ..removeAt(index);
                      imageListNotifier.value = updatedImages;
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        color: AppColors.cFFFFFF.withValues(alpha: 0.6),
                      ),
                      child: SvgPicture.asset(""),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
