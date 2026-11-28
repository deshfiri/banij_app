import 'package:flutter/material.dart';

import '../../../../../constants/color.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import 'product_grid_card.dart';

/// Loading placeholder shaped like the product grid.
class ProductGridShimmer extends StatelessWidget {
  final int crossAxisCount;

  const ProductGridShimmer({super.key, this.crossAxisCount = 2});

  @override
  Widget build(BuildContext context) {

    return Shimmer.fromColors(
      baseColor: AppColorsTheme.shimmerBase(context),
      highlightColor: AppColorsTheme.shimmerHighlight(context),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 24.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          mainAxisExtent: ProductGridCard.extent,
        ),
        itemCount: 6,
        itemBuilder: (_, _) => Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r)),
        ),
      ),
    );
  }
}
