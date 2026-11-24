import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/referrals_model.dart';

const Color _green = Color(0xFF10B981);
const Color _amber = Color(0xFFF59E0B);
const Color _red = Color(0xFFEF4444);
const Color _blue = Color(0xFF3B82F6);

// -----------------------------------------------------------------------------
// Building blocks
// -----------------------------------------------------------------------------

/// Rounded card with a border and soft shadow, used for each section.
class PartnerSectionCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PartnerSectionCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.cardBg(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Section heading: tinted icon, bold title and an optional trailing widget.
class PartnerCardTitle extends StatelessWidget {
  final String text;
  final IconData icon;
  final Widget? trailing;

  const PartnerCardTitle(this.text, {super.key, required this.icon, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(7.w),
          decoration: BoxDecoration(
            color: primaryOrange.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 16.sp, color: primaryOrange),
        ),
        UIHelper.horizontalSpace(10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

/// Small pill showing how many entries a section has.
class PartnerCountBadge extends StatelessWidget {
  final int count;

  const PartnerCountBadge({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
          color: AppColorsTheme.textMutedColor(context),
        ),
      ),
    );
  }
}

/// Copies [text] to the clipboard and shows [toastMessage].
/// [onHero] styles it for the orange gradient card.
class PartnerCopyButton extends StatelessWidget {
  final String text;
  final String toastMessage;
  final bool onHero;

  const PartnerCopyButton({
    super.key,
    required this.text,
    required this.toastMessage,
    this.onHero = false,
  });

  void _copy() {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.selectionClick();
    ToastUtil.showSuccessMessage(toastMessage);
  }

  @override
  Widget build(BuildContext context) {
    final foreground = onHero ? primaryOrange : Colors.white;
    return ElevatedButton.icon(
      onPressed: _copy,
      icon: Icon(Icons.copy_rounded, size: 12.sp),
      label: Text('Copy', style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w800)),
      style: ElevatedButton.styleFrom(
        backgroundColor: onHero ? Colors.white : primaryOrange,
        foregroundColor: foreground,
        elevation: 0,
        minimumSize: Size(0, 28.h),
        padding: EdgeInsets.symmetric(horizontal: 9.w),
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Partner code
// -----------------------------------------------------------------------------

/// Hero-gradient card with the partner code and the registration link,
/// each copyable.
class PartnerCodeCard extends StatelessWidget {
  final String code;
  final String link;

  const PartnerCodeCard({super.key, required this.code, required this.link});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColorsTheme.heroGradient(context),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.22),
            blurRadius: 12.r,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: Stack(
          children: [
            Positioned(right: -30.w, top: -30.w, child: _circle(100.w, 0.10)),
            Positioned(left: -24.w, bottom: -40.w, child: _circle(80.w, 0.07)),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(5.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 15.sp),
                      ),
                      UIHelper.horizontalSpace(8.w),
                      Text(
                        'YOUR PARTNER CODE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  UIHelper.verticalSpace(8.h),
                  Row(
                    children: [
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            code,
                            style: TextStyle(
                              fontSize: 19.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      UIHelper.horizontalSpace(12.w),
                      PartnerCopyButton(text: code, toastMessage: 'Partner code copied!', onHero: true),
                    ],
                  ),
                  UIHelper.verticalSpace(10.h),
                  Text(
                    'Your Partner Network link',
                    style: TextStyle(fontSize: 9.5.sp, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                  UIHelper.verticalSpace(4.h),
                  Container(
                    padding: EdgeInsets.fromLTRB(10.w, 4.h, 4.w, 4.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.link_rounded, size: 13.sp, color: Colors.white),
                        UIHelper.horizontalSpace(6.w),
                        Expanded(
                          child: Text(
                            link,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        UIHelper.horizontalSpace(8.w),
                        PartnerCopyButton(text: link, toastMessage: 'Partner link copied!', onHero: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: alpha)),
      );
}

// -----------------------------------------------------------------------------
// Stats
// -----------------------------------------------------------------------------

/// The five summary stats. Two per row on phones, three on wider screens;
/// tiles size to their content so long labels never overflow.
class PartnerStatsGrid extends StatelessWidget {
  final ReferralSummaryModel? summary;

  const PartnerStatsGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    final stats = [
      _PartnerStat(Icons.groups_rounded, primaryOrange, 'Direct Partner Network members', '${summary?.direct ?? 0}'),
      _PartnerStat(Icons.bolt_rounded, _blue, 'Active', '${summary?.directActive ?? 0}'),
      _PartnerStat(Icons.account_balance_wallet_rounded, _green, 'Earned', summary?.paid?.formatted ?? '৳0.00'),
      _PartnerStat(Icons.hourglass_top_rounded, _amber, 'Waiting to be paid', summary?.pending?.formatted ?? '৳0.00'),
      _PartnerStat(Icons.undo_rounded, _red, 'Taken back', summary?.reversed?.formatted ?? '৳0.00'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 600 ? 3 : 2;
        final spacing = 12.w;
        final tileWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats) SizedBox(width: tileWidth, child: _PartnerStatCard(stat: stat)),
          ],
        );
      },
    );
  }
}

class _PartnerStat {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _PartnerStat(this.icon, this.color, this.title, this.value);
}

class _PartnerStatCard extends StatelessWidget {
  final _PartnerStat stat;

  const _PartnerStatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return PartnerSectionCard(
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(7.w),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(stat.icon, size: 17.sp, color: stat.color),
          ),
          UIHelper.verticalSpace(10.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              stat.value,
              style: TextStyle(
                fontSize: 17.sp,
                fontWeight: FontWeight.w900,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ),
          UIHelper.verticalSpace(2.h),
          Text(
            stat.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context), height: 1.3),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Lists
// -----------------------------------------------------------------------------

/// Circle icon + title + description shown when a list is empty.
class PartnerEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final double? messageHeight;

  const PartnerEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.messageHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 8.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28.sp, color: primaryOrange),
          ),
          UIHelper.verticalSpace(14.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(6.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColorsTheme.textMutedColor(context),
              height: messageHeight ?? 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Bordered row used for list items inside the section cards.
class PartnerListTile extends StatelessWidget {
  final Widget child;

  const PartnerListTile({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColorsTheme.innerCardBg(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColorsTheme.borderColor(context)),
      ),
      child: child,
    );
  }
}

/// "Businesses in your Partner Network" card: direct members or an empty state.
class PartnerMembersCard extends StatelessWidget {
  final List<ReferralDirectItemModel> members;

  const PartnerMembersCard({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return PartnerSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PartnerCardTitle(
            'Businesses in your Partner Network',
            icon: Icons.storefront_outlined,
            trailing: members.isEmpty ? null : PartnerCountBadge(count: members.length),
          ),
          UIHelper.verticalSpace(14.h),
          if (members.isEmpty)
            const PartnerEmptyState(
              icon: Icons.share_outlined,
              title: 'Nobody is in your Partner Network yet',
              message: 'Share your link. Businesses that register with it appear here.',
            )
          else
            for (final member in members) _PartnerMemberTile(member: member),
        ],
      ),
    );
  }
}

class _PartnerMemberTile extends StatelessWidget {
  final ReferralDirectItemModel member;

  const _PartnerMemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    final name = member.name ?? 'Business Member';
    final initial = name.trim().isEmpty ? 'B' : name.trim()[0].toUpperCase();

    return PartnerListTile(
      child: Row(
        children: [
          Container(
            width: 38.sp,
            height: 38.sp,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: AppColorsTheme.heroGradient(context)),
              shape: BoxShape.circle,
            ),
            child: Text(
              initial,
              style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w900),
            ),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(2.h),
                Row(
                  children: [
                    Icon(Icons.event_outlined, size: 12.sp, color: AppColorsTheme.textMutedColor(context)),
                    UIHelper.horizontalSpace(4.w),
                    Flexible(
                      child: Text(
                        'Since: ${member.since ?? 'N/A'}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              member.state ?? 'Active',
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w800, color: primaryOrange),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Your earnings" card: earnings rows or an empty state.
class PartnerEarningsCard extends StatelessWidget {
  final List<dynamic> earnings;

  const PartnerEarningsCard({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return PartnerSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PartnerCardTitle(
            'Your earnings',
            icon: Icons.payments_outlined,
            trailing: earnings.isEmpty ? null : PartnerCountBadge(count: earnings.length),
          ),
          UIHelper.verticalSpace(14.h),
          if (earnings.isEmpty)
            const PartnerEmptyState(
              icon: Icons.groups_outlined,
              title: 'No earnings yet',
              message:
                  'When a business in your chain is activated and the programme pays, each earning appears here with its level.',
              messageHeight: 1.4,
            )
          else
            for (final earning in earnings)
              PartnerListTile(
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: _green.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Icons.trending_up_rounded, size: 16.sp, color: _green),
                    ),
                    UIHelper.horizontalSpace(12.w),
                    Expanded(
                      child: Text(
                        earning.toString(),
                        style: TextStyle(fontSize: 12.5.sp, color: AppColorsTheme.textMainColor(context)),
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

// -----------------------------------------------------------------------------
// Loading
// -----------------------------------------------------------------------------

/// Loading placeholder shaped like the Partner Network content.
class PartnerNetworkShimmer extends StatelessWidget {
  const PartnerNetworkShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget block(double height, {double? width}) => Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r)),
        );

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
        child: Column(
          children: [
            block(130.h),
            UIHelper.verticalSpace(14.h),
            Row(children: [Expanded(child: block(100.h)), UIHelper.horizontalSpace(12.w), Expanded(child: block(100.h))]),
            UIHelper.verticalSpace(12.h),
            Row(children: [Expanded(child: block(100.h)), UIHelper.horizontalSpace(12.w), Expanded(child: block(100.h))]),
            UIHelper.verticalSpace(14.h),
            block(180.h),
          ],
        ),
      ),
    );
  }
}
