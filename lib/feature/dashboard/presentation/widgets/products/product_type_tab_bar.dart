import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../../constants/color.dart';
import 'product_list_type.dart';

/// Product-specific segmented tabs; category chips remain independently scrollable.
class ProductTypeTabBar extends StatelessWidget {
  final ProductListType selectedType;
  final ValueChanged<ProductListType> onSelected;

  const ProductTypeTabBar({
    super.key,
    required this.selectedType,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46.h,
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final type in ProductListType.values)
                _ProductTypeTab(
                  type: type,
                  isSelected: type == selectedType,
                  onTap: () => onSelected(type),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductTypeTab extends StatelessWidget {
  final ProductListType type;
  final bool isSelected;
  final VoidCallback onTap;

  const _ProductTypeTab({
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected
        ? Colors.white
        : AppColorsTheme.textMainColor(context);
    final radius = BorderRadius.circular(12.r);

    return Semantics(
      button: true,
      selected: isSelected,
      label: type.labelKey.tr,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [primaryOrange, secondaryOrange])
                : null,
            borderRadius: radius,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryOrange.withValues(alpha: 0.22),
                      blurRadius: 7.r,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                type.icon,
                size: 15.sp,
                color: isSelected
                    ? Colors.white
                    : AppColorsTheme.textMutedColor(context),
              ),
              SizedBox(width: 6.w),
              Text(
                type.labelKey.tr,
                maxLines: 1,
                softWrap: false,
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
