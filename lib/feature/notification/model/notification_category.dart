import 'package:flutter/material.dart';

import '../../../constants/color.dart';

/// What a notification is about. Drives its icon, accent colour, label and
/// the category filter chips on the notification screen.
enum NotificationCategory {
  order(Icons.local_shipping_outlined, infoBlue, 'notif_cat_order'),
  payment(Icons.account_balance_wallet_outlined, successGreen, 'notif_cat_payment'),
  verification(Icons.verified_user_outlined, purpleAccent, 'notif_cat_verification'),
  subscription(Icons.workspace_premium_outlined, warningYellow, 'notif_cat_subscription'),
  security(Icons.shield_outlined, errorRed, 'notif_cat_security'),
  product(Icons.inventory_2_outlined, Color(0xFF0D9488), 'notif_cat_product'),
  promotion(Icons.local_offer_outlined, Color(0xFFDB2777), 'notif_cat_promotion'),
  general(Icons.notifications_none_rounded, primaryOrange, 'notif_cat_general');

  final IconData icon;
  final Color color;

  /// Translation key for the label.
  final String labelKey;

  const NotificationCategory(this.icon, this.color, this.labelKey);

  /// Accent for icons and labels. Lifted towards white in dark mode so the
  /// deeper palette colours (blue, red, purple) stay readable on dark cards.
  Color accent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? Color.lerp(color, Colors.white, 0.28)! : color;
  }

  /// Soft background behind the category icon.
  Color tint(BuildContext context, {bool strong = true}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final alpha = isDark ? (strong ? 0.2 : 0.12) : (strong ? 0.13 : 0.08);
    return color.withValues(alpha: alpha);
  }

  /// Checked in order: the first category with a matching keyword wins, so
  /// "Payment received for order #12" is a payment, and "Subscription
  /// payment failed" is a subscription.
  ///
  /// Keywords are substrings, so avoid short or generic ones ("sale" would
  /// match every "wholesale" message in this app).
  static const List<(NotificationCategory, List<String>)> _keywords = [
    (security, ['security', 'password', 'login', 'log in', 'sign in', 'otp', 'পাসওয়ার্ড', 'লগইন', 'নিরাপত্তা']),
    (verification, ['kyc', 'verif', 'document', 'trade license', 'কেওয়াইসি', 'ভেরিফিকেশন', 'যাচাই']),
    (subscription, ['subscription', 'membership', 'renew', 'সাবস্ক্রিপশন']),
    (payment, [
      'payment', 'paid', 'wallet', 'withdraw', 'payout', 'refund', 'invoice', 'transaction', 'balance', 'deposit',
      'settlement', 'bkash', 'nagad', 'পেমেন্ট', 'ওয়ালেট', 'উত্তোলন', 'ইনভয়েস',
    ]),
    (order, [
      'order', 'ship', 'deliver', 'dispatch', 'parcel', 'courier', 'pickup', 'picked up', 'return', 'exchange',
      'অর্ডার', 'ডেলিভারি', 'পার্সেল',
    ]),
    (product, ['product', 'stock', 'inventory', 'damage', 'sku', 'listing', 'পণ্য', 'প্রোডাক্ট', 'স্টক']),
    (promotion, ['offer', 'promo', 'discount', 'campaign', 'coupon', 'অফার', 'ছাড়', 'ক্যাম্পেইন']),
  ];

  /// Picks the category from the API [type] when it names one (e.g.
  /// `order_shipped` or `App\Notifications\PaymentReceived`), otherwise from
  /// the words in [title] and [message]. Falls back to [general].
  static NotificationCategory resolve({String? type, String title = '', String message = ''}) {
    return _match(type ?? '') ?? _match('$title $message') ?? general;
  }

  static NotificationCategory? _match(String text) {
    final haystack = text.toLowerCase();
    if (haystack.trim().isEmpty) return null;
    for (final (category, words) in _keywords) {
      if (words.any(haystack.contains)) return category;
    }
    return null;
  }
}
