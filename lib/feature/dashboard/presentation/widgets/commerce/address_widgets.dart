import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../checkout/checkout_shimmer.dart';

const Color _blue = Color(0xFF3B82F6);
const Color _green = Color(0xFF10B981);
const Color _red = Color(0xFFEF4444);

/// Icon + accent colour for an address type (business / operational / shipping).
/// Shared by the address list and the add/edit form.
(IconData, Color) addressTypeStyle(String type) => switch (type.toLowerCase()) {
      'operational' => (Icons.warehouse_rounded, _blue),
      'shipping' => (Icons.local_shipping_rounded, _green),
      _ => (Icons.storefront_rounded, primaryOrange),
    };

/// Saved address card: type icon, name (+ DEFAULT tag), type pill, actions
/// menu, phone + address rows and quick Edit / Set-as-default buttons.
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
    final (typeIcon, typeColor) = addressTypeStyle(type);
    final border = AppColorsTheme.borderColor(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: isDefault ? primaryOrange : border, width: isDefault ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: (isDefault ? primaryOrange : Colors.black).withValues(alpha: isDark ? 0.15 : (isDefault ? 0.10 : 0.04)),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: icon, name, type, menu.
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 4.w, 10.h),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20.sp),
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14.5.sp, fontWeight: FontWeight.w800, color: mainColor),
                            ),
                          ),
                          if (isDefault) ...[
                            UIHelper.horizontalSpace(6.w),
                            const _DefaultTag(),
                          ],
                        ],
                      ),
                      UIHelper.verticalSpace(4.h),
                      _TypePill(label: '${type.toUpperCase()} ADDRESS', color: typeColor),
                    ],
                  ),
                ),
                _AddressActionsMenu(onEdit: onEdit, onSetDefault: onSetDefault, onArchive: onArchive),
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: border),
          // Details.
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 4.h),
            child: Column(
              children: [
                if (phone.isNotEmpty) _InfoRow(icon: Icons.phone_android_rounded, text: phone, bold: true),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  text: fullAddress.isNotEmpty ? fullAddress : 'No detailed address provided',
                ),
              ],
            ),
          ),
          // Quick actions.
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 2.h, 14.w, 14.h),
            child: Row(
              children: [
                Expanded(
                  child: _CardActionButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit',
                    onPressed: onEdit,
                  ),
                ),
                if (!isDefault) ...[
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: _CardActionButton(
                      icon: Icons.star_outline_rounded,
                      label: 'Set as default',
                      onPressed: onSetDefault,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;

  const _InfoRow({required this.icon, required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15.sp, color: AppColorsTheme.textMutedColor(context)),
          UIHelper.horizontalSpace(8.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12.5.sp,
                height: 1.4,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  const _CardActionButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 15.sp),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(label, style: TextStyle(fontSize: 11.5.sp, fontWeight: FontWeight.w700)),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryOrange,
        side: BorderSide(color: primaryOrange.withValues(alpha: 0.4)),
        minimumSize: Size(0, 36.h),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;
  final Color color;

  const _TypePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: color, letterSpacing: 0.5),
      ),
    );
  }
}

class _DefaultTag extends StatelessWidget {
  const _DefaultTag();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: primaryOrange,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 10.sp, color: Colors.white),
          UIHelper.horizontalSpace(3.w),
          Text(
            'DEFAULT',
            style: TextStyle(fontSize: 8.5.sp, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 0.5),
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
            Text(label, style: TextStyle(fontSize: 12.5.sp, color: textColor ?? AppColorsTheme.textMainColor(context))),
          ],
        ),
      );
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 20.sp, color: AppColorsTheme.textMutedColor(context)),
      color: AppColorsTheme.cardBg(context),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
        item('archive', Icons.archive_outlined, _red, 'Archive', textColor: _red),
      ],
    );
  }
}

/// "N saved addresses" line above the list.
class AddressCountHeader extends StatelessWidget {
  final int count;

  const AddressCountHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.bookmark_rounded, size: 16.sp, color: primaryOrange),
        UIHelper.horizontalSpace(6.w),
        Text(
          count == 1 ? '1 saved address' : '$count saved addresses',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ],
    );
  }
}

/// Lays out [children] in one column on phones and two on wide screens.
class ResponsiveCardGrid extends StatelessWidget {
  final List<Widget> children;
  final double wideBreakpoint;

  const ResponsiveCardGrid({super.key, required this.children, this.wideBreakpoint = 640});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= wideBreakpoint ? 2 : 1;
        final spacing = 14.w;
        final width = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: 14.h,
          children: [for (final child in children) SizedBox(width: width, child: child)],
        );
      },
    );
  }
}

/// Loading placeholder shaped like two address cards.
class AddressListShimmer extends StatelessWidget {
  const AddressListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = CheckoutShimmerColors.of(context);
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6.r)),
        );

    return Shimmer.fromColors(
      baseColor: colors.base,
      highlightColor: colors.highlight,
      child: ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 18.h),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.only(bottom: 14.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: AppColorsTheme.cardBg(context),
              borderRadius: BorderRadius.circular(18.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    bar(40.w, 40.w),
                    UIHelper.horizontalSpace(12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [bar(130.w, 14.h), UIHelper.verticalSpace(6.h), bar(90.w, 10.h)],
                    ),
                  ],
                ),
                UIHelper.verticalSpace(16.h),
                bar(140.w, 12.h),
                UIHelper.verticalSpace(8.h),
                bar(double.infinity, 12.h),
                UIHelper.verticalSpace(14.h),
                bar(double.infinity, 34.h),
              ],
            ),
          );
        },
      ),
    );
  }
}
