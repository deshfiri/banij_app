import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../common_widget/accent_bar_card.dart';
import '../../../../../common_widget/tone_badge_widget.dart';
import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/wallet_balance_model.dart';
import '../../../model/wallet_transaction_model.dart';

const String _zero = '৳0.00';
const Color _credit = Color(0xFF10B981);
const Color _debit = Color(0xFFEF4444);

bool _isZero(String? formatted) {
  final digits = (formatted ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty || int.tryParse(digits) == 0;
}

String _humanize(String value) {
  final text = value.replaceAll(RegExp(r'[_-]+'), ' ').trim();
  return text.isEmpty ? value : text[0].toUpperCase() + text.substring(1);
}

/// Wallet health pill ("Healthy") coloured by the API tone.
class WalletStateBadge extends StatelessWidget {
  final String? label;
  final String? tone;

  const WalletStateBadge({super.key, required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    if (label == null || label!.trim().isEmpty) return const SizedBox.shrink();
    final (color, icon) = ToneBadge.styleFor(tone);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          UIHelper.horizontalSpace(4.w),
          Text(
            label!,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w800, color: Color.lerp(color, Colors.black, 0.2)),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Balance hero
// -----------------------------------------------------------------------------

/// Orange balance card: total, available for orders / ready to withdraw,
/// and the Top up / Withdraw / Payouts actions.
class WalletBalanceHero extends StatelessWidget {
  final WalletBalanceDataModel? balance;
  final VoidCallback onTopUp;
  final VoidCallback onWithdraw;
  final VoidCallback onPayoutMethods;

  const WalletBalanceHero({
    super.key,
    required this.balance,
    required this.onTopUp,
    required this.onWithdraw,
    required this.onPayoutMethods,
  });

  @override
  Widget build(BuildContext context) {
    return BrandHeroCard(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 18.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34.w,
                height: 34.w,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                ),
                child: Icon(Icons.account_balance_wallet_rounded, size: 18.sp, color: Colors.white),
              ),
              UIHelper.horizontalSpace(10.w),
              Text(
                'Total balance',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          UIHelper.verticalSpace(10.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              balance?.total?.formatted ?? _zero,
              style: TextStyle(
                fontSize: 32.sp,
                height: 1.1,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
                color: Colors.white,
              ),
            ),
          ),
          UIHelper.verticalSpace(16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _HeroFigure(
                      icon: Icons.shopping_bag_outlined,
                      label: 'Available for orders',
                      value: balance?.usable?.formatted ?? _zero,
                    ),
                  ),
                  VerticalDivider(width: 22.w, thickness: 1, color: Colors.white.withValues(alpha: 0.3)),
                  Expanded(
                    child: _HeroFigure(
                      icon: Icons.payments_outlined,
                      label: 'Ready to withdraw',
                      value: balance?.withdrawable?.formatted ?? _zero,
                    ),
                  ),
                ],
              ),
            ),
          ),
          UIHelper.verticalSpace(14.h),
          Row(
            children: [
              Expanded(child: _HeroAction(icon: Icons.add_rounded, label: 'Top up', primary: true, onTap: onTopUp)),
              UIHelper.horizontalSpace(8.w),
              Expanded(child: _HeroAction(icon: Icons.north_east_rounded, label: 'Withdraw', onTap: onWithdraw)),
              UIHelper.horizontalSpace(8.w),
              Expanded(
                child: _HeroAction(icon: Icons.account_balance_outlined, label: 'Payouts', onTap: onPayoutMethods),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroFigure extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _HeroFigure({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12.sp, color: Colors.white.withValues(alpha: 0.85)),
            UIHelper.horizontalSpace(4.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10.5.sp, color: Colors.white.withValues(alpha: 0.85)),
              ),
            ),
          ],
        ),
        UIHelper.verticalSpace(3.h),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w900, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class _HeroAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _HeroAction({required this.icon, required this.label, required this.onTap, this.primary = false});

  @override
  Widget build(BuildContext context) {
    final foreground = primary ? primaryOrange : Colors.white;
    return Material(
      color: primary ? Colors.white : Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: primary ? null : Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 16.sp, color: foreground),
                  UIHelper.horizontalSpace(5.w),
                  Text(label, style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w800, color: foreground)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Deposit / obligation alert
// -----------------------------------------------------------------------------

/// Amber card shown only when the wallet does not meet its required deposit
/// or an obligation: the shortfall, the due date and a Top up button.
class WalletDepositAlert extends StatelessWidget {
  final WalletBalanceDataModel balance;
  final VoidCallback onTopUp;

  const WalletDepositAlert({super.key, required this.balance, required this.onTopUp});

  static bool shouldShow(WalletBalanceDataModel? balance) =>
      balance != null && (balance.meetsRequiredDeposit == false || balance.meetsObligation == false);

  @override
  Widget build(BuildContext context) {
    const amber = Color(0xFFF59E0B);
    final shortfall = balance.meetsRequiredDeposit == false
        ? (balance.shortfall?.formatted ?? balance.requiredDeposit?.formatted)
        : balance.obligationShortfall?.formatted;
    final due = _formatDate(balance.depositDueAt ?? balance.graceEndsAt);
    final title = balance.meetsRequiredDeposit == false ? 'Deposit needed' : 'Balance below what is owed';
    final parts = [if (shortfall != null) 'Add $shortfall to your wallet', if (due != null) 'by $due'];
    final message = parts.isEmpty ? 'Top up your wallet to keep using every feature.' : '${parts.join(' ')}.';

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: amber.withValues(alpha: 0.45)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: amber.withValues(alpha: 0.18), shape: BoxShape.circle),
            child: Icon(Icons.warning_amber_rounded, size: 18.sp, color: amber),
          ),
          UIHelper.horizontalSpace(10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColorsTheme.textMainColor(context),
                  ),
                ),
                UIHelper.verticalSpace(3.h),
                Text(
                  message,
                  style: TextStyle(fontSize: 12.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
                ),
                UIHelper.verticalSpace(10.h),
                SizedBox(
                  height: 34.h,
                  child: ElevatedButton.icon(
                    onPressed: onTopUp,
                    icon: Icon(Icons.add_rounded, size: 16.sp),
                    label: Text('Top up now', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w800)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryOrange,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 14.w),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                    ),
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
// Balance details
// -----------------------------------------------------------------------------

/// "Balance details": what sits behind the figures, one row per amount.
/// Zero amounts are muted so the non-zero ones stand out.
class WalletBreakdownCard extends StatelessWidget {
  final WalletBalanceDataModel? balance;

  const WalletBreakdownCard({super.key, required this.balance});

  @override
  Widget build(BuildContext context) {
    final b = balance;
    final rows = <(IconData, String, String?)>[
      (Icons.card_giftcard_rounded, 'Platform credit', b?.platformCredit?.formatted),
      (Icons.payments_outlined, 'Withdrawable', b?.withdrawable?.formatted),
      (Icons.hourglass_top_rounded, 'Pending', b?.pending?.formatted),
      (Icons.pause_circle_outline_rounded, 'On hold', b?.hold?.formatted),
      (Icons.lock_outline_rounded, 'Reserved', b?.reserved?.formatted),
      (Icons.shield_outlined, 'Minimum balance', b?.minimumBalance?.formatted),
      (Icons.savings_outlined, 'Required deposit', b?.requiredDeposit?.formatted),
      (Icons.local_shipping_outlined, 'COD settlement', b?.codReceivable?.formatted),
    ];

    return AccentBarCard(
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 16.w, 6.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AccentCardTitle(
            icon: Icons.pie_chart_outline_rounded,
            title: 'Balance details',
            subtitle: 'What sits behind the figures above.',
          ),
          UIHelper.verticalSpace(8.h),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 40.w,
                color: AppColorsTheme.borderColor(context).withValues(alpha: 0.7),
              ),
            _BreakdownRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3 ?? _zero),
          ],
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BreakdownRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final zero = _isZero(value);
    final muted = AppColorsTheme.textMutedColor(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: BoxDecoration(
              color: primaryOrange.withValues(alpha: zero ? 0.06 : 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 14.sp, color: zero ? primaryOrange.withValues(alpha: 0.5) : primaryOrange),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5.sp, color: zero ? muted : AppColorsTheme.textMainColor(context)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: zero ? FontWeight.w600 : FontWeight.w900,
              color: zero ? muted : AppColorsTheme.textMainColor(context),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Statement
// -----------------------------------------------------------------------------

/// Statement filter values.
enum WalletStatementFilter {
  all('All'),
  credit('Money in'),
  debit('Money out');

  final String label;

  const WalletStatementFilter(this.label);

  bool matches(WalletTransactionItemModel tx) => switch (this) {
        WalletStatementFilter.all => true,
        WalletStatementFilter.credit => tx.direction?.toLowerCase() == 'credit',
        WalletStatementFilter.debit => tx.direction?.toLowerCase() == 'debit',
      };
}

/// "Statement · N" heading and the All / Money in / Money out chips.
class WalletStatementHeader extends StatelessWidget {
  final int count;
  final WalletStatementFilter filter;
  final ValueChanged<WalletStatementFilter> onChanged;

  const WalletStatementHeader({super.key, required this.count, required this.filter, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4.w,
              height: 17.h,
              decoration: BoxDecoration(color: primaryOrange, borderRadius: BorderRadius.circular(2.r)),
            ),
            UIHelper.horizontalSpace(8.w),
            Text(
              'Statement',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w900,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.horizontalSpace(8.w),
            CountPill(label: '$count'),
          ],
        ),
        UIHelper.verticalSpace(12.h),
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: AppColorsTheme.cardBg(context),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColorsTheme.borderColor(context)),
          ),
          child: Row(
            children: [
              for (final option in WalletStatementFilter.values)
                Expanded(
                  child: GestureDetector(
                    onTap: () => onChanged(option),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(vertical: 9.h),
                      decoration: BoxDecoration(
                        gradient: option == filter
                            ? const LinearGradient(colors: [primaryOrange, secondaryOrange])
                            : null,
                        borderRadius: BorderRadius.circular(11.r),
                      ),
                      child: Text(
                        option.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.5.sp,
                          fontWeight: FontWeight.w800,
                          color: option == filter ? Colors.white : AppColorsTheme.textMutedColor(context),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

DateTime? _parse(String? raw) => raw == null ? null : DateTime.tryParse(raw.trim())?.toLocal();

String? _formatDate(String? raw) {
  final date = _parse(raw);
  if (date == null) return raw?.trim().isEmpty == true ? null : raw;
  return DateFormat('MMM d, yyyy').format(date);
}

/// Transactions in one card, under "Today" / "Yesterday" / date headings
/// when the API gives parseable timestamps.
class WalletStatementCard extends StatelessWidget {
  final List<WalletTransactionItemModel> transactions;

  const WalletStatementCard({super.key, required this.transactions});

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'Today';
    if (day == DateTime(now.year, now.month, now.day - 1)) return 'Yesterday';
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final grouped = transactions.any((tx) => _parse(tx.at) != null);
    final children = <Widget>[];
    String? currentGroup;
    for (var i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final date = _parse(tx.at);
      final group = grouped ? (date == null ? 'Earlier' : _dayLabel(date)) : null;
      if (group != null && group != currentGroup) {
        currentGroup = group;
        children.add(_GroupLabel(label: group, first: children.isEmpty));
      } else if (children.isNotEmpty) {
        children.add(Divider(
          height: 1,
          thickness: 1,
          indent: 50.w,
          color: AppColorsTheme.borderColor(context).withValues(alpha: 0.7),
        ));
      }
      children.add(WalletTransactionTile(tx: tx));
    }

    return AccentBarCard(
      padding: EdgeInsets.fromLTRB(14.w, 6.h, 16.w, 6.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String label;
  final bool first;

  const _GroupLabel({required this.label, required this.first});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: first ? 8.h : 14.h, bottom: 2.h),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: primaryOrange,
        ),
      ),
    );
  }
}

/// A statement row: direction icon, type and time / reference, signed
/// amount (green in, red out), status and the balance after it.
class WalletTransactionTile extends StatelessWidget {
  final WalletTransactionItemModel tx;

  const WalletTransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final muted = AppColorsTheme.textMutedColor(context);
    final isCredit = tx.direction?.toLowerCase() == 'credit';
    final color = isCredit ? _credit : _debit;
    final raw = tx.amount?.formatted ?? (isCredit ? tx.credit?.formatted : tx.debit?.formatted) ?? _zero;
    final amount = raw.startsWith('+') || raw.startsWith('-') ? raw : '${isCredit ? '+' : '−'}$raw';
    final date = _parse(tx.at);
    final time = date != null ? DateFormat('h:mm a').format(date) : tx.at;
    final meta = [
      if (time != null && time.trim().isNotEmpty) time,
      if (tx.reference?.trim().isNotEmpty == true) tx.reference!.trim(),
    ].join(' · ');
    final status = tx.statusLabel ?? (tx.status == null ? null : _humanize(tx.status!));
    final (statusColor, _) = ToneBadge.styleFor(tx.statusTone);
    final balanceAfter = tx.balanceAfter?.formatted;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 11.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(11.r)),
            child: Icon(isCredit ? Icons.south_west_rounded : Icons.north_east_rounded, size: 18.sp, color: color),
          ),
          UIHelper.horizontalSpace(12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.typeLabel ?? tx.description ?? 'Transaction',
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
                  Text(meta, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11.sp, color: muted)),
                ],
                if (tx.isCorrection == true && tx.reason?.isNotEmpty == true) ...[
                  UIHelper.verticalSpace(2.h),
                  Text(tx.reason!, style: TextStyle(fontSize: 11.sp, fontStyle: FontStyle.italic, color: muted)),
                ],
              ],
            ),
          ),
          UIHelper.horizontalSpace(8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(amount, style: TextStyle(fontSize: 13.5.sp, fontWeight: FontWeight.w900, color: color)),
              if (status != null) ...[
                UIHelper.verticalSpace(3.h),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    UIHelper.horizontalSpace(4.w),
                    Text(status, style: TextStyle(fontSize: 10.5.sp, fontWeight: FontWeight.w600, color: muted)),
                  ],
                ),
              ],
              if (balanceAfter != null) ...[
                UIHelper.verticalSpace(2.h),
                Text('Bal. $balanceAfter', style: TextStyle(fontSize: 10.sp, color: muted)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Empty / loading
// -----------------------------------------------------------------------------

/// Empty statement card; [filtered] when a filter hides every transaction.
class WalletNoTransactions extends StatelessWidget {
  final bool filtered;

  const WalletNoTransactions({super.key, this.filtered = false});

  @override
  Widget build(BuildContext context) {
    return AccentBarCard(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 28.h),
      child: Column(
        children: [
          const GradientIconTile(icon: Icons.receipt_long_rounded, size: 56),
          UIHelper.verticalSpace(14.h),
          Text(
            filtered ? 'Nothing here' : 'No transactions yet',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: AppColorsTheme.textMainColor(context),
            ),
          ),
          UIHelper.verticalSpace(4.h),
          Text(
            filtered
                ? 'No transactions match this filter.'
                : 'Top-ups, charges and earnings appear here as they happen.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder shaped like the wallet page.
class WalletShimmer extends StatelessWidget {
  const WalletShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    Widget box(double height, double radius) => Container(
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
        );

    return Shimmer.fromColors(
      baseColor: AppColorsTheme.shimmerBase(context),
      highlightColor: AppColorsTheme.shimmerHighlight(context),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            box(230.h, 20.r),
            UIHelper.verticalSpace(16.h),
            box(300.h, 18.r),
            UIHelper.verticalSpace(22.h),
            box(44.h, 14.r),
            UIHelper.verticalSpace(12.h),
            box(220.h, 18.r),
          ],
        ),
      ),
    );
  }
}
