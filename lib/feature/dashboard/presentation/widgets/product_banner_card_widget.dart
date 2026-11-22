import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color.dart';
import 'dashboard_card_decoration.dart';

/// Image banner with an orange call-to-action button in the bottom-left corner.
class ProductBannerCardWidget extends StatelessWidget {
  final String imagePath;
  final String buttonText;
  final VoidCallback onTap;

  const ProductBannerCardWidget({
    super.key,
    required this.imagePath,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 102.h,
        clipBehavior: Clip.antiAlias,
        decoration: DashboardCardDecoration.of(context, radius: 18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(imagePath, fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(7.w),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryOrange,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    elevation: 2,
                  ),
                  child: Text(
                    buttonText,
                    style: TextStyle(fontSize: 8.5.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
