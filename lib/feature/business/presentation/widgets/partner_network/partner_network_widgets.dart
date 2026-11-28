import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common_widget/accent_bar_card.dart';
import '../../../../../common_widget/tone_badge_widget.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/toast.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/referrals_model.dart';

// -----------------------------------------------------------------------------
// Building blocks
// -----------------------------------------------------------------------------

void _copy(String text, String toastMessage) {
  Clipboard.setData(ClipboardData(text: text));
  HapticFeedback.selectionClick();
  ToastUtil.showSuccessMessage(toastMessage);
}

/// White "Copy" pill for the orange code card.
class _CopyPill extends StatelessWidget {
  final String text;
  final String toastMessage;

  const _CopyPill({required this.text, required this.toastMessage});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: () => _copy(text, toastMessage),
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.copy_rounded, size: 13.sp, color: primaryOrange),
              UIHelper.horizontalSpace(4.w),
              Text('Copy', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: primaryOrange)),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Section · N" heading with the orange accent bar.
class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading(this.title);

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
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w900,
            color: AppColorsTheme.textMainColor(context),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Partner code
// -----------------------------------------------------------------------------

/// Orange card with the partner code in a coupon-style box and the
/// registration link, each copyable. Without a code (request failed) it
/// says so and offers [onRetry] instead of showing a made-up code.
class PartnerCodeCard extends StatelessWidget {
  final String? code;
  final String? link;
  final VoidCallback onRetry;

  const PartnerCodeCard({super.key, required this.code, required this.link, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final code = this.code?.trim();
    final link = this.link?.trim();
    final hasCode = code != null && code.isNotEmpty;

    return BrandHeroCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Icon(Icons.handshake_rounded, color: Colors.white, size: 21.sp),
              ),
              UIHelper.horizontalSpace(10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your partner code',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                    Text(
                      'Share it — businesses that join with it are linked to you.',
                      style: TextStyle(fontSize: 10.5.sp, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(14.h),
          if (!hasCode)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_off_rounded, size: 18.sp, color: Colors.white),
                  UIHelper.horizontalSpace(8.w),
                  Expanded(
                    child: Text(
                      'Your partner code could not be loaded.',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                  Material(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    child: InkWell(
                      onTap: onRetry,
                      borderRadius: BorderRadius.circular(20.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
                        child: Text(
                          'Try again',
                          style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: primaryOrange),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            // Coupon-style code box.
            CustomPaint(
              painter: _DashedBorderPainter(color: Colors.white.withValues(alpha: 0.7), radius: 12.r),
              child: Container(
                padding: EdgeInsets.fromLTRB(14.w, 10.h, 8.w, 10.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          code,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    UIHelper.horizontalSpace(10.w),
                    _CopyPill(text: code, toastMessage: 'Partner code copied!'),
                  ],
                ),
              ),
            ),
            if (link != null && link.isNotEmpty) ...[
              UIHelper.verticalSpace(10.h),
              Container(
                padding: EdgeInsets.fromLTRB(10.w, 6.h, 6.w, 6.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link_rounded, size: 15.sp, color: Colors.white),
                    UIHelper.horizontalSpace(6.w),
                    Expanded(
                      child: Text(
                        link,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11.sp, color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                    UIHelper.horizontalSpace(8.w),
                    _CopyPill(text: link, toastMessage: 'Partner link copied!'),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// Rounded dashed outline (coupon edge).
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;

  _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)));
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + dash), paint);
        distance += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter old) => old.color != color || old.radius != radius;
}

// -----------------------------------------------------------------------------
// Stats
// -----------------------------------------------------------------------------

/// Network size (members / active) as two tiles, then an earnings strip:
/// earned, waiting to be paid, taken back.
class PartnerStatsGrid extends StatelessWidget {
  final ReferralSummaryModel? summary;

  const PartnerStatsGrid({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    final summary = this.summary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.groups_rounded,
                  value: '${summary?.direct ?? 0}',
                  label: 'Direct members',
                ),
              ),
              UIHelper.horizontalSpace(12.w),
              Expanded(
                child: _StatTile(
                  icon: Icons.bolt_rounded,
                  value: '${summary?.directActive ?? 0}',
                  label: 'Active members',
                ),
              ),
            ],
          ),
        ),
        UIHelper.verticalSpace(12.h),
        AccentBarCard(
          padding: EdgeInsets.fromLTRB(14.w, 14.h, 14.w, 14.h),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _MoneyFigure(
                    label: 'Earned',
                    value: summary?.paid?.formatted ?? '৳0.00',
                    highlight: true,
                  ),
                ),
                VerticalDivider(width: 20.w, thickness: 1, color: AppColorsTheme.borderColor(context)),
                Expanded(child: _MoneyFigure(label: 'Waiting', value: summary?.pending?.formatted ?? '৳0.00')),
                VerticalDivider(width: 20.w, thickness: 1, color: AppColorsTheme.borderColor(context)),
                Expanded(child: _MoneyFigure(label: 'Taken back', value: summary?.reversed?.formatted ?? '৳0.00')),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatTile({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return AccentBarCard(
      padding: EdgeInsets.all(14.w),
      child: Row(
        children: [
          GradientIconTile(icon: icon, size: 40),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w900,
                      color: AppColorsTheme.textMainColor(context),
                    ),
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.sp, height: 1.25, color: AppColorsTheme.textMutedColor(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoneyFigure extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;

  const _MoneyFigure({required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9.5.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
            color: AppColorsTheme.textMutedColor(context),
          ),
        ),
        UIHelper.verticalSpace(4.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.5.sp,
              fontWeight: FontWeight.w900,
              color: highlight ? primaryOrange : AppColorsTheme.textMainColor(context),
            ),
          ),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// Lists
// -----------------------------------------------------------------------------

/// Gradient icon + title + description shown when a list is empty.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 8.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: primaryOrange.withValues(alpha: 0.1), shape: BoxShape.circle),
            child: Icon(icon, size: 26.sp, color: primaryOrange),
          ),
          UIHelper.verticalSpace(12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(4.h),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.5.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
          ),
        ],
      ),
    );
  }
}

/// Card listing [rows] under a title with a count, or [empty] when there
/// are none. Rows are separated by hairlines.
class _ListCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> rows;
  final Widget empty;

  const _ListCard({required this.icon, required this.title, required this.rows, required this.empty});

  @override
  Widget build(BuildContext context) {
    return AccentBarCard(
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 16.w, 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AccentCardTitle(
            icon: icon,
            title: title,
            trailing: rows.isEmpty ? null : CountPill(label: '${rows.length}'),
          ),
          UIHelper.verticalSpace(8.h),
          if (rows.isEmpty)
            empty
          else
            for (var i = 0; i < rows.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 50.w,
                  color: AppColorsTheme.borderColor(context).withValues(alpha: 0.7),
                ),
              rows[i],
            ],
          UIHelper.verticalSpace(6.h),
        ],
      ),
    );
  }
}

/// "Businesses in your Partner Network": direct members or an empty state.
class PartnerMembersCard extends StatelessWidget {
  final List<ReferralDirectItemModel> members;

  const PartnerMembersCard({super.key, required this.members});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionHeading('Your network'),
        UIHelper.verticalSpace(12.h),
        _ListCard(
          icon: Icons.storefront_rounded,
          title: 'Businesses in your Partner Network',
          rows: [for (final member in members) _MemberRow(member: member)],
          empty: const _EmptyState(
            icon: Icons.share_outlined,
            title: 'Nobody is in your Partner Network yet',
            message: 'Share your link. Businesses that register with it appear here.',
          ),
        ),
      ],
    );
  }
}

class _MemberRow extends StatelessWidget {
  final ReferralDirectItemModel member;

  const _MemberRow({required this.member});

  @override
  Widget build(BuildContext context) {
    final name = member.name?.trim().isNotEmpty == true ? member.name!.trim() : 'Business member';
    final initial = name.characters.first.toUpperCase();
    final state = member.state?.trim();
    final active = state == null || state.toLowerCase().contains('active');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [secondaryOrange, primaryOrange]),
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
                if (member.since?.isNotEmpty == true) ...[
                  UIHelper.verticalSpace(2.h),
                  Text(
                    'Joined ${_date(member.since)}',
                    style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context)),
                  ),
                ],
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          ToneBadge(label: _humanize(state ?? 'Active'), tone: active ? 'success' : 'neutral'),
        ],
      ),
    );
  }
}

/// "Your earnings": one row per earning, or an empty state. Earnings arrive
/// as loosely shaped maps, so each field is read defensively.
class PartnerEarningsCard extends StatelessWidget {
  final List<dynamic> earnings;

  const PartnerEarningsCard({super.key, required this.earnings});

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      icon: Icons.payments_rounded,
      title: 'Your earnings',
      rows: [for (final earning in earnings) _EarningRow(earning: earning)],
      empty: const _EmptyState(
        icon: Icons.savings_outlined,
        title: 'No earnings yet',
        message: 'When a business in your chain is activated and the programme pays, each earning appears here with its level.',
      ),
    );
  }
}

class _EarningRow extends StatelessWidget {
  final dynamic earning;

  const _EarningRow({required this.earning});

  static String? _pick(Map map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value == null) continue;
      if (value is Map) {
        final nested = value['formatted'] ?? value['name'] ?? value['label'] ?? value['amount'];
        if (nested != null && nested.toString().trim().isNotEmpty) return nested.toString().trim();
        continue;
      }
      if (value.toString().trim().isNotEmpty) return value.toString().trim();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final map = earning is Map ? earning as Map : const {};
    final title = _pick(map, ['from', 'business', 'business_name', 'member', 'name', 'description']) ??
        (earning is Map ? 'Partner earning' : earning.toString());
    final amount = _pick(map, ['amount', 'formatted', 'value']);
    final level = _pick(map, ['level', 'tier']);
    final date = _date(_pick(map, ['paid_at', 'created_at', 'date', 'earned_at']));
    final status = _pick(map, ['status', 'state']);
    final meta = [if (level != null) 'Level $level', if (date.isNotEmpty) date].join(' · ');

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11.r),
            ),
            child: Icon(Icons.trending_up_rounded, size: 19.sp, color: primaryOrange),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                if (meta.isNotEmpty) ...[
                  UIHelper.verticalSpace(2.h),
                  Text(meta, style: TextStyle(fontSize: 11.sp, color: AppColorsTheme.textMutedColor(context))),
                ],
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (amount != null)
                Text(
                  amount.startsWith('৳') ? amount : '৳$amount',
                  style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: primaryOrange),
                ),
              if (status != null) ...[
                UIHelper.verticalSpace(3.h),
                Text(
                  _humanize(status),
                  style: TextStyle(fontSize: 10.5.sp, color: AppColorsTheme.textMutedColor(context)),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

String _humanize(String value) {
  final text = value.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  return text.isEmpty ? value : text[0].toUpperCase() + text.substring(1);
}

/// "Nov 9, 2026" for ISO dates; other strings as they are.
String _date(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final parsed = DateTime.tryParse(raw.trim());
  return parsed == null ? raw.trim() : DateFormat('MMM d, yyyy').format(parsed.toLocal());
}

// -----------------------------------------------------------------------------
// Loading
// -----------------------------------------------------------------------------

/// Loading placeholder shaped like the Partner Network content.
class PartnerNetworkShimmer extends StatelessWidget {
  const PartnerNetworkShimmer({super.key});

  @override
  Widget build(BuildContext context) {

    Widget block(double height, {double? width}) => Container(
          width: width ?? double.infinity,
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18.r)),
        );

    return Shimmer.fromColors(
      baseColor: AppColorsTheme.shimmerBase(context),
      highlightColor: AppColorsTheme.shimmerHighlight(context),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 18.h, 16.w, 24.h),
        child: Column(
          children: [
            block(170.h),
            UIHelper.verticalSpace(16.h),
            Row(children: [Expanded(child: block(72.h)), UIHelper.horizontalSpace(12.w), Expanded(child: block(72.h))]),
            UIHelper.verticalSpace(12.h),
            block(70.h),
            UIHelper.verticalSpace(22.h),
            block(200.h),
          ],
        ),
      ),
    );
  }
}
