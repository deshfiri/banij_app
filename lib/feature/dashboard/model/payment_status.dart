import 'package:flutter/material.dart';

/// Payment status as the app understands it, mapped from whatever string
/// the backend sends (`status`, `payment_state`, `payment_status` …).
///
/// Mapping is by keyword so backend wording ("succeeded", "settled",
/// "partially_refunded", "awaiting_payment"…) lands on the right state
/// without hardcoding one exact vocabulary. Unrecognised values stay
/// [unknown] and are shown with the backend's own label.
enum PaymentStatus {
  unpaid,
  initiated,
  pending,
  processing,
  paid,
  failed,
  cancelled,
  refunded,
  partiallyRefunded,
  unknown;

  static PaymentStatus fromBackend(String? raw) {
    final s = raw?.toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_') ?? '';
    if (s.isEmpty) return PaymentStatus.unknown;
    if (s.contains('partial') && s.contains('refund')) return PaymentStatus.partiallyRefunded;
    if (s.contains('refund')) return PaymentStatus.refunded;
    if (s.contains('cancel')) return PaymentStatus.cancelled;
    if (s.contains('fail') || s.contains('declin') || s.contains('reject') || s.contains('expire') || s.contains('error')) {
      return PaymentStatus.failed;
    }
    if (s == 'unpaid' || s.contains('not_paid') || s.contains('awaiting') || s.contains('due')) {
      return PaymentStatus.unpaid;
    }
    if (s.contains('paid') || s.contains('success') || s.contains('succeed') || s.contains('complete') ||
        s.contains('settled') || s.contains('captured') || s == 'valid' || s == 'validated' || s.contains('verified')) {
      return PaymentStatus.paid;
    }
    if (s.contains('process') || s.contains('reconcil') || s.contains('review')) return PaymentStatus.processing;
    if (s.contains('initiat') || s.contains('created') || s.contains('open')) return PaymentStatus.initiated;
    if (s.contains('pending') || s.contains('hold') || s.contains('wait')) return PaymentStatus.pending;
    return PaymentStatus.unknown;
  }

  /// English label (translated with `.tr` by the badge).
  String get label => switch (this) {
        PaymentStatus.unpaid => 'Unpaid',
        PaymentStatus.initiated => 'Initiated',
        PaymentStatus.pending => 'Pending',
        PaymentStatus.processing => 'Processing',
        PaymentStatus.paid => 'Paid',
        PaymentStatus.failed => 'Failed',
        PaymentStatus.cancelled => 'Cancelled',
        PaymentStatus.refunded => 'Refunded',
        PaymentStatus.partiallyRefunded => 'Partially refunded',
        PaymentStatus.unknown => 'Unknown',
      };

  /// PAID green · PENDING/PROCESSING orange · FAILED red · CANCELLED grey ·
  /// REFUNDED blue.
  Color get color => switch (this) {
        PaymentStatus.paid => const Color(0xFF10B981),
        PaymentStatus.pending || PaymentStatus.processing || PaymentStatus.initiated => const Color(0xFFF59E0B),
        PaymentStatus.failed => const Color(0xFFEF4444),
        PaymentStatus.cancelled || PaymentStatus.unknown => const Color(0xFF64748B),
        PaymentStatus.refunded || PaymentStatus.partiallyRefunded => const Color(0xFF3B82F6),
        PaymentStatus.unpaid => const Color(0xFFF97316),
      };

  IconData get icon => switch (this) {
        PaymentStatus.paid => Icons.check_circle_rounded,
        PaymentStatus.pending || PaymentStatus.initiated => Icons.schedule_rounded,
        PaymentStatus.processing => Icons.sync_rounded,
        PaymentStatus.failed => Icons.error_rounded,
        PaymentStatus.cancelled => Icons.cancel_rounded,
        PaymentStatus.refunded || PaymentStatus.partiallyRefunded => Icons.undo_rounded,
        PaymentStatus.unpaid => Icons.payments_outlined,
        PaymentStatus.unknown => Icons.help_outline_rounded,
      };

  bool get isFinal => switch (this) {
        PaymentStatus.paid ||
        PaymentStatus.failed ||
        PaymentStatus.cancelled ||
        PaymentStatus.refunded ||
        PaymentStatus.partiallyRefunded =>
          true,
        _ => false,
      };
}
