import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../constants/color.dart';
import '../../../../../helpers/ui_helpers.dart';
import '../../../model/wallet_transaction_model.dart';
import '../finance_shared/finance_widgets.dart';

/// Wallet health pill ("Healthy"); green when the API tone is "success".
class WalletStateBadge extends StatelessWidget {
  final String? label;
  final String? tone;

  const WalletStateBadge({super.key, required this.label, required this.tone});

  @override
  Widget build(BuildContext context) {
    final color = tone == 'success' ? Colors.green : primaryOrange;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, size: 12.sp, color: color),
          UIHelper.horizontalSpace(4.w),
          Text(label ?? 'Healthy', style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

/// Orange "Add funds instantly" banner with a Top Up button.
class WalletTopUpBanner extends StatelessWidget {
  final VoidCallback onTopUp;

  const WalletTopUpBanner({super.key, required this.onTopUp});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryOrange, primaryOrange.withValues(alpha: 0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: 0.3),
            blurRadius: 12.r,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 24.sp),
          ),
          UIHelper.horizontalSpace(14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add funds instantly',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                UIHelper.verticalSpace(2.h),
                Text(
                  'Top up via bKash, Nagad or Card',
                  style: TextStyle(fontSize: 11.5.sp, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTopUp,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primaryOrange,
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
              elevation: 0,
            ),
            child: Text('Top Up', style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

/// One of the three balance tiles (Total / Available / Withdrawable).
class WalletBalanceCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final IconData icon;

  const WalletBalanceCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isDark ? AppColorsTheme.cardBg(context) : const Color(0xFFFFF7F2),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : primaryOrange.withValues(alpha: 0.22),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryOrange.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 10.r,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.5.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColorsTheme.textMutedColor(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: primaryOrange.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: primaryOrange, size: 14.sp),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColorsTheme.textMainColor(context),
                ),
                overflow: TextOverflow.ellipsis,
              ),
              UIHelper.verticalSpace(2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColorsTheme.textMutedColor(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Two label/value pairs side by side in the "Balance details" card.
class WalletDetailRow extends StatelessWidget {
  final String label1;
  final String value1;
  final String label2;
  final String value2;

  const WalletDetailRow({
    super.key,
    required this.label1,
    required this.value1,
    required this.label2,
    required this.value2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: _pair(context, label1, value1)),
        UIHelper.horizontalSpace(16.w),
        Expanded(child: _pair(context, label2, value2)),
      ],
    );
  }

  Widget _pair(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        UIHelper.horizontalSpace(4.w),
        Text(value, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColorsTheme.textMainColor(context))),
      ],
    );
  }
}

/// A statement row: credit (green, down arrow) or debit (red, up arrow).
class WalletTransactionTile extends StatelessWidget {
  final WalletTransactionItemModel tx;

  const WalletTransactionTile({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.direction == 'credit';
    final txColor = isCredit ? Colors.green : Colors.redAccent;

    return FinanceListCard(
      icon: isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
      iconColor: txColor,
      title: FinanceListCard.titleText(context, tx.typeLabel ?? tx.description ?? 'Transaction'),
      subtitle: tx.at ?? 'Today',
      subtitleSize: 11,
      trailing: FinanceAmountStatus(
        amount: tx.amount?.formatted ??
            (isCredit ? '+${tx.credit?.formatted ?? '৳0.00'}' : '-${tx.debit?.formatted ?? '৳0.00'}'),
        amountColor: txColor,
        status: tx.statusLabel ?? tx.status ?? 'Success',
        statusColor: Colors.green,
      ),
    );
  }
}

/// Loading placeholder shaped like the wallet page.
class WalletShimmer extends StatelessWidget {
  const WalletShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;
    Widget box(double height, double radius) => Container(
          height: height,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
        );

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 240.w, height: 14.h, color: Colors.white),
            UIHelper.verticalSpace(16.h),
            SizedBox(width: double.infinity, child: box(80.h, 18.r)),
            UIHelper.verticalSpace(20.h),
            Row(
              children: [
                Expanded(child: box(90.h, 16.r)),
                UIHelper.horizontalSpace(12.w),
                Expanded(child: box(90.h, 16.r)),
              ],
            ),
            UIHelper.verticalSpace(24.h),
            Container(width: 140.w, height: 16.h, color: Colors.white),
            UIHelper.verticalSpace(12.h),
            SizedBox(width: double.infinity, child: box(120.h, 16.r)),
          ],
        ),
      ),
    );
  }
}

/// Empty statement card.
class WalletNoTransactions extends StatelessWidget {
  const WalletNoTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    return const FinanceEmptyCard(
      icon: Icons.receipt_long_outlined,
      title: 'No transactions yet',
      subtitle: 'Top-ups, charges and earnings appear here as they happen.',
      padding: 28,
    );
  }
}
