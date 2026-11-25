import 'dart:convert';

import 'payment_status.dart';

/// Response of the `/checkout` actions (pay, coupon, payment status, verify).
///
/// `POST /checkout` answers with a [redirectUrl] to open in a browser view;
/// `GET /checkout/payment` reports the payment [status] afterwards.
class CheckoutModel {
  final bool? success;
  final String? message;
  final Map<String, dynamic>? data;

  /// Gateway page to open (from `redirect_url`, top level or inside `data`).
  final String? redirectUrl;

  /// Payment status, e.g. `pending`, `paid`, `failed` (top level, in `data`
  /// or in `data.payment`).
  final String? status;

  /// `GET /checkout/payment`: the attempt is still open — keep polling.
  final bool? isOpen;

  /// The payment has been settled by the gateway.
  final bool? isSettled;

  /// The payment is being reconciled (not final yet).
  final bool? isReconciling;

  /// The screen the API says to show next.
  final String? next;

  CheckoutModel({
    this.success,
    this.message,
    this.data,
    this.redirectUrl,
    this.status,
    this.isOpen,
    this.isSettled,
    this.isReconciling,
    this.next,
  });

  factory CheckoutModel.fromRawJson(String str) => CheckoutModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CheckoutModel.fromJson(Map<String, dynamic> json) {
    final data = json["data"] is Map ? Map<String, dynamic>.from(json["data"] as Map) : null;
    final payment = data?["payment"] is Map
        ? data!["payment"] as Map
        : (json["payment"] is Map ? json["payment"] as Map : null);

    String? pick(List<dynamic> values) {
      for (final value in values) {
        final text = value?.toString().trim();
        if (text != null && text.isNotEmpty && text != 'null') return text;
      }
      return null;
    }

    bool? flag(List<String> keys) {
      for (final source in [json, data, payment]) {
        if (source == null) continue;
        for (final key in keys) {
          final value = source[key];
          if (value is bool) return value;
          if (value is num) return value != 0;
          if (value is String && (value == 'true' || value == 'false')) return value == 'true';
        }
      }
      return null;
    }

    final nextValue = json["next"] ?? data?["next"] ?? payment?["next"];

    return CheckoutModel(
      isOpen: flag(['is_open', 'open']),
      isSettled: flag(['is_settled', 'settled', 'is_paid', 'paid']),
      isReconciling: flag(['is_reconciling', 'reconciling', 'being_reconciled']),
      next: nextValue is Map
          ? pick([nextValue['screen'], nextValue['name'], nextValue['route'], nextValue['key']])
          : pick([nextValue]),
      success: json["success"] is bool ? json["success"] as bool : null,
      message: json["message"]?.toString(),
      data: data,
      redirectUrl: pick([json["redirect_url"], data?["redirect_url"], payment?["redirect_url"], json["url"]]),
      status: pick([
        json["status"],
        data?["status"],
        payment?["status"],
        json["payment_status"],
        data?["payment_status"],
      ]),
    );
  }

  /// The backend's payment state as a [PaymentStatus]. Settlement flags win
  /// over the status word; an open attempt that is not paid is processing.
  PaymentStatus get paymentStatus {
    if (isPaid) return PaymentStatus.paid;
    final mapped = PaymentStatus.fromBackend(status);
    if (mapped.isFinal) return mapped;
    if (isReconciling == true) return PaymentStatus.processing;
    if (isOpen == true) return mapped == PaymentStatus.unknown ? PaymentStatus.pending : mapped;
    return mapped == PaymentStatus.unknown && isOpen == false ? PaymentStatus.failed : mapped;
  }

  /// Our payment reference, when the backend includes one.
  String? get reference {
    for (final source in [data, data?['payment']]) {
      if (source is! Map) continue;
      for (final key in const ['reference', 'tran_id', 'transaction_id', 'id', 'number']) {
        final value = source[key]?.toString();
        if (value != null && value.isNotEmpty) return value;
      }
    }
    return null;
  }

  /// Amount of the attempt as formatted text, when the backend includes it.
  String? get amountText {
    for (final source in [data, data?['payment']]) {
      if (source is! Map) continue;
      final amount = source['amount'] ?? source['total'];
      if (amount is Map) return (amount['formatted'] ?? amount['amount'])?.toString();
      if (amount != null) return amount.toString();
    }
    return null;
  }

  /// True when the payment went through (settled, or a paid-like [status]).
  bool get isPaid => isSettled == true && !_failedStatus || _paidStatus;

  /// True when the payment will not complete.
  bool get isFailed => _failedStatus;

  /// The attempt is closed and not reconciling: polling can stop.
  bool get isFinal => isPaid || isFailed || (isOpen == false && isReconciling != true);

  bool get _paidStatus => const {
    'paid',
    'succeeded',
    'success',
    'successful',
    'completed',
    'complete',
    'settled',
    'captured',
    'approved',
    'verified',
  }.contains(status?.toLowerCase());

  bool get _failedStatus => const {
    'failed',
    'failure',
    'cancelled',
    'canceled',
    'declined',
    'expired',
    'rejected',
    'error',
  }.contains(status?.toLowerCase());

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data,
    "redirect_url": redirectUrl,
    "status": status,
    "is_open": isOpen,
    "is_settled": isSettled,
    "is_reconciling": isReconciling,
    "next": next,
  };
}
