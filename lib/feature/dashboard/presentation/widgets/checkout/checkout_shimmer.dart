import 'package:flutter/material.dart';

import '../../../../../constants/color.dart';

/// Shimmer base/highlight colours used by the checkout loading placeholders.
class CheckoutShimmerColors {
  final Color base;
  final Color highlight;

  const CheckoutShimmerColors._(this.base, this.highlight);

  factory CheckoutShimmerColors.of(BuildContext context) {
    return CheckoutShimmerColors._(AppColorsTheme.shimmerBase(context), AppColorsTheme.shimmerHighlight(context));
  }
}
