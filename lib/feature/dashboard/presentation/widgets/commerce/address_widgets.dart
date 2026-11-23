import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../checkout/checkout_shimmer.dart';

/// Saved address card: icon, name (+ DEFAULT tag), type, actions menu,
/// phone chip and the full address box.
class AddressCard extends StatelessWidget {
  final String name;
  final String type;
  final String phone;
  final String fullAddress;
  final bool isDefault;
  final VoidCallback? onEdit;
  final VoidCallback? onSetDefault;
  final VoidCallback? onArchive;

  const AddressCard({
    super.key,
    required this.name,
    required this.type,
    required this.phone,
    required this.fullAddress,
    required this.isDefault,
    this.onEdit,
    this.onSetDefault,
    this.onArchive,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mainColor = AppColorsTheme.textMainColor(context);

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDefault ? primaryOrange : AppColorsTheme.borderColor(context),
          width: isDefault ? 1.5.w : 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDefault ? primaryOrange : Colors.black).withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(11.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Icon(Icons.location_on_rounded, color: primaryOrange, size: 22.sp),
              ),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w900, color: mainColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isDefault) ...[
                          UIHelper.horizontalSpace(8.w),
                          const _DefaultTag(),
                        ],
                      ],
                    ),
                    UIHelper.verticalSpace(4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                      decoration: BoxDecoration(
                        color: AppColorsTheme.background(context),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(color: AppColorsTheme.borderColor(context)),
                      ),
                      child: Text(
                        '${type.toUpperCase()} ADDRESS',
                        style: TextStyle(
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColorsTheme.textMutedColor(context),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              _AddressActionsMenu(onEdit: onEdit, onSetDefault: onSetDefault, onArchive: onArchive),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          if (phone.isNotEmpty) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColorsTheme.background(context),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone_android_rounded, size: 13.sp, color: primaryOrange),
                  UIHelper.horizontalSpace(6.w),
                  Text(phone, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: mainColor)),
                ],
              ),
            ),
            UIHelper.verticalSpace(10.h),
          ],
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.background(context),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColorsTheme.borderColor(context).withValues(alpha: 0.6)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.map_rounded, size: 15.sp, color: primaryOrange),
                UIHelper.horizontalSpace(8.w),
                Expanded(
                  child: Text(
                    fullAddress.isNotEmpty ? fullAddress : 'No detailed address provided',
                    style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w500, color: mainColor, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DefaultTag extends StatelessWidget {
  const _DefaultTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 10.sp, color: primaryOrange),
          UIHelper.horizontalSpace(3.w),
          Text(
            'DEFAULT',
            style: TextStyle(fontSize: 9.5.sp, fontWeight: FontWeight.w900, color: primaryOrange, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

/// ⋮ menu with Edit / Set as default / Archive.
class _AddressActionsMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onSetDefault;
  final VoidCallback? onArchive;

  const _AddressActionsMenu({this.onEdit, this.onSetDefault, this.onArchive});

  @override
  Widget build(BuildContext context) {
    PopupMenuItem<String> item(String value, IconData icon, Color iconColor, String label, {Color? textColor}) {
      return PopupMenuItem(
        value: value,
        child: Row(
          children: [
            Icon(icon, size: 16.sp, color: iconColor),
            UIHelper.horizontalSpace(8.w),
            Text(label, style: TextStyle(fontSize: 12.5.sp, color: textColor)),
          ],
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 20.sp, color: AppColorsTheme.textMutedColor(context)),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit?.call();
        } else if (value == 'default') {
          onSetDefault?.call();
        } else if (value == 'archive') {
          onArchive?.call();
        }
      },
      itemBuilder: (context) => [
        item('edit', Icons.edit_outlined, primaryOrange, 'Edit'),
        item('default', Icons.star_outline_rounded, Colors.amber, 'Set as default'),
        item('archive', Icons.archive_outlined, Colors.redAccent, 'Archive', textColor: Colors.redAccent),
      ],
    );
  }
}

/// Loading placeholder shaped like two address cards.
class AddressListShimmer extends StatelessWidget {
  const AddressListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CheckoutShimmerColors.of(context);

    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120.w, height: 16.h, color: Colors.white),
                UIHelper.verticalSpace(8.h),
                Container(width: 180.w, height: 12.h, color: Colors.white),
                UIHelper.verticalSpace(12.h),
                Container(width: double.infinity, height: 14.h, color: Colors.white),
              ],
            ),
          );
        },
      ),
    );
  }
}
