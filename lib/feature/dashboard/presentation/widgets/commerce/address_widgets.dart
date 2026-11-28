import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common_widget/accent_bar_card.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../checkout/checkout_shimmer.dart';

/// Icon + accent colour for an address type (business / operational /
/// shipping). Shared by the address list and the add/edit form; every type
/// uses the brand orange, the icon tells them apart.
(IconData, Color) addressTypeStyle(String type) => switch (type.toLowerCase()) {
      'operational' => (Icons.warehouse_rounded, primaryOrange),
      'shipping' => (Icons.local_shipping_rounded, primaryOrange),
      _ => (Icons.storefront_rounded, primaryOrange),
    };

/// Saved address card: orange left bar (solid outline when it is the
/// default), type icon, contact name with a DEFAULT tag, type pill, phone
/// and address rows, and the actions that were provided.
class AddressCard extends StatelessWidget {
  final String name;
  final String type;
  final String phone;
  final String fullAddress;
  final bool isDefault;
  final VoidCallback? onEdit;

  /// Optional; the button / menu entry only shows when set.
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
    final (typeIcon, _) = addressTypeStyle(type);
    final typeLabel = type.isEmpty ? 'Address' : '${type[0].toUpperCase()}${type.substring(1).toLowerCase()} address';
    final hasMenu = onArchive != null || (onSetDefault != null && !isDefault);

    return AccentBarCard(
      highlighted: isDefault,
      padding: EdgeInsets.fromLTRB(14.w, 14.h, 10.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GradientIconTile(icon: typeIcon, size: 42),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            name.isEmpty ? 'No contact name' : name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14.5.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColorsTheme.textMainColor(context),
                            ),
                          ),
                        ),
                        if (isDefault) ...[
                          UIHelper.horizontalSpace(6.w),
                          const _DefaultTag(),
                        ],
                      ],
                    ),
                    UIHelper.verticalSpace(4.h),
                    _TypePill(label: typeLabel),
                  ],
                ),
              ),
              if (hasMenu)
                _AddressActionsMenu(onEdit: onEdit, onSetDefault: isDefault ? null : onSetDefault, onArchive: onArchive),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColorsTheme.innerCardBg(context).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                if (phone.isNotEmpty) ...[
                  _InfoRow(icon: Icons.phone_iphone_rounded, text: phone, bold: true),
                  Divider(height: 1, thickness: 1, color: AppColorsTheme.borderColor(context).withValues(alpha: 0.7)),
                ],
                _InfoRow(
                  icon: Icons.location_on_rounded,
                  text: fullAddress.isNotEmpty ? fullAddress : 'No detailed address provided',
                  muted: fullAddress.isEmpty,
                ),
              ],
            ),
          ),
          if (onEdit != null || (onSetDefault != null && !isDefault)) ...[
            UIHelper.verticalSpace(12.h),
            Row(
              children: [
                if (onEdit != null)
                  Expanded(child: _CardActionButton(icon: Icons.edit_rounded, label: 'Edit address', onPressed: onEdit)),
                if (onSetDefault != null && !isDefault) ...[
                  UIHelper.horizontalSpace(10.w),
                  Expanded(
                    child: _CardActionButton(icon: Icons.star_outline_rounded, label: 'Set as default', onPressed: onSetDefault),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool bold;
  final bool muted;

  const _InfoRow({required this.icon, required this.text, this.bold = false, this.muted = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(icon, size: 14.sp, color: primaryOrange),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 4.h),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  height: 1.4,
                  fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                  fontStyle: muted ? FontStyle.italic : FontStyle.normal,
                  color: muted ? AppColorsTheme.textMutedColor(context) : AppColorsTheme.textMainColor(context),
                ),
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
        child: Text(label, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800)),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryOrange,
        backgroundColor: primaryOrange.withValues(alpha: 0.06),
        side: BorderSide(color: primaryOrange.withValues(alpha: 0.4)),
        minimumSize: Size(0, 38.h),
        padding: EdgeInsets.symmetric(horizontal: 8.w),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
    );
  }
}

class _TypePill extends StatelessWidget {
  final String label;

  const _TypePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w800, color: primaryOrange, letterSpacing: 0.6),
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
        gradient: const LinearGradient(colors: [primaryOrange, secondaryOrange]),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 10.sp, color: Colors.white),
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

/// ⋮ menu with the provided actions (Edit / Set as default / Archive).
class _AddressActionsMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onSetDefault;
  final VoidCallback? onArchive;

  const _AddressActionsMenu({this.onEdit, this.onSetDefault, this.onArchive});

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFEF4444);
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
      onSelected: (value) => switch (value) {
        'edit' => onEdit?.call(),
        'default' => onSetDefault?.call(),
        'archive' => onArchive?.call(),
        _ => null,
      },
      itemBuilder: (context) => [
        if (onEdit != null) item('edit', Icons.edit_outlined, primaryOrange, 'Edit'),
        if (onSetDefault != null) item('default', Icons.star_outline_rounded, primaryOrange, 'Set as default'),
        if (onArchive != null) item('archive', Icons.archive_outlined, red, 'Archive', textColor: red),
      ],
    );
  }
}

/// "Saved addresses · N" heading above the list.
class AddressCountHeader extends StatelessWidget {
  final int count;

  const AddressCountHeader({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 17.h,
          decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(2.r)),
        ),
        UIHelper.horizontalSpace(8.w),
        Text(
          'Saved addresses',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
        UIHelper.horizontalSpace(8.w),
        CountPill(label: '$count'),
      ],
    );
  }
}

/// Shown when the account has no saved addresses.
class AddressEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const AddressEmptyState({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return AccentBarCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
      child: Column(
        children: [
          const GradientIconTile(icon: Icons.add_location_alt_rounded, size: 64),
          UIHelper.verticalSpace(16.h),
          Text(
            'No addresses yet',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            'Add your business, operational or shipping address so orders and invoices go to the right place.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.5.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
          ),
          UIHelper.verticalSpace(16.h),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: Icon(Icons.add_rounded, size: 17.sp),
            label: Text('Add your first address', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w800)),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryOrange,
              backgroundColor: primaryOrange.withValues(alpha: 0.06),
              side: BorderSide(color: primaryOrange.withValues(alpha: 0.5)),
              minimumSize: Size(0, 42.h),
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
            ),
          ),
        ],
      ),
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
