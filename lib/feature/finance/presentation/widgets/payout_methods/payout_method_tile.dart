import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../finance_shared/finance_widgets.dart';

/// A saved payout method row with an Edit / Archive menu.
///
/// [isDefault] adds the orange border + "Default" badge (local list only);
/// [titleInRow] keeps the local list's title-row layout; [redArchiveLabel]
/// colours the "Archive" text red (API list only) — all as before.
class PayoutMethodTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDefault;
  final bool titleInRow;
  final bool redArchiveLabel;
  final VoidCallback onEdit;
  final VoidCallback onArchive;

  const PayoutMethodTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onArchive,
    this.isDefault = false,
    this.titleInRow = false,
    this.redArchiveLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleText = FinanceListCard.titleText(context, title);

    return FinanceListCard(
      icon: icon,
      iconColor: primaryOrange,
      borderColor: isDefault ? primaryOrange : null,
      title: titleInRow
          ? Row(
              children: [
                titleText,
                if (isDefault) ...[
                  UIHelper.horizontalSpace(8.w),
                  const _DefaultBadge(),
                ],
              ],
            )
          : titleText,
      subtitle: subtitle,
      subtitleSize: 11.5,
      trailing: _PayoutActionsMenu(onEdit: onEdit, onArchive: onArchive, redArchiveLabel: redArchiveLabel),
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: primaryOrange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text('Default', style: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.bold, color: primaryOrange)),
    );
  }
}

class _PayoutActionsMenu extends StatelessWidget {
  final VoidCallback onEdit;
  final VoidCallback onArchive;
  final bool redArchiveLabel;

  const _PayoutActionsMenu({required this.onEdit, required this.onArchive, required this.redArchiveLabel});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 18.sp, color: AppColorsTheme.textMutedColor(context)),
      onSelected: (value) {
        if (value == 'edit') {
          onEdit();
        } else if (value == 'archive') {
          onArchive();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 16.sp, color: primaryOrange),
              UIHelper.horizontalSpace(8.w),
              Text('Edit', style: TextStyle(fontSize: 12.5.sp)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              Icon(Icons.archive_outlined, size: 16.sp, color: Colors.redAccent),
              UIHelper.horizontalSpace(8.w),
              Text(
                'Archive',
                style: TextStyle(fontSize: 12.5.sp, color: redArchiveLabel ? Colors.redAccent : null),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
