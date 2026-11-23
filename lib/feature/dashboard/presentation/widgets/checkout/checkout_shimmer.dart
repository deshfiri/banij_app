import 'package:flutter/material.dart';

/// Shimmer base/highlight colours used by the checkout loading placeholders.
class CheckoutShimmerColors {
  final Color base;
  final Color highlight;

  const CheckoutShimmerColors._(this.base, this.highlight);

  factory CheckoutShimmerColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark
        ? CheckoutShimmerColors._(Colors.grey[800]!, Colors.grey[700]!)
        : CheckoutShimmerColors._(Colors.grey[300]!, Colors.grey[100]!);
  }
}
