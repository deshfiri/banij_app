/// What SSLCommerz needs to open a payment session.
class SslCommerzPaymentRequest {
  /// Our unique reference for this payment (also used to look it up).
  final String transactionId;
  final double amount;
  final String currency;
  final String productName;
  final String customerName;
  final String customerEmail;
  final String customerPhone;
  final String customerAddress;
  final String customerCity;
  final String customerPostcode;

  const SslCommerzPaymentRequest({
    required this.transactionId,
    required this.amount,
    this.currency = 'BDT',
    required this.productName,
    required this.customerName,
    required this.customerEmail,
    required this.customerPhone,
    required this.customerAddress,
    this.customerCity = 'Dhaka',
    this.customerPostcode = '1000',
  });
}

/// A transaction as SSLCommerz reports it.
class SslCommerzTransaction {
  final String? transactionId;
  final String? status; // VALID, VALIDATED, FAILED, CANCELLED, PENDING …
  final String? valId;
  final String? amount;
  final String? currency;
  final String? cardType; // e.g. "BKASH-BKash", "VISA-Dutch Bangla"
  final String? bankTransactionId;
  final String? tranDate;

  const SslCommerzTransaction({
    this.transactionId,
    this.status,
    this.valId,
    this.amount,
    this.currency,
    this.cardType,
    this.bankTransactionId,
    this.tranDate,
  });

  factory SslCommerzTransaction.fromJson(Map json) => SslCommerzTransaction(
        transactionId: json['tran_id']?.toString(),
        status: json['status']?.toString(),
        valId: json['val_id']?.toString(),
        amount: json['amount']?.toString(),
        currency: json['currency']?.toString() ?? json['currency_type']?.toString(),
        cardType: json['card_type']?.toString(),
        bankTransactionId: json['bank_tran_id']?.toString(),
        tranDate: json['tran_date']?.toString(),
      );

  /// SSLCommerz marks successful payments VALID (or VALIDATED once checked).
  bool get isPaid => const {'VALID', 'VALIDATED'}.contains(status?.toUpperCase());

  bool get isFailed => const {'FAILED', 'CANCELLED', 'EXPIRED', 'UNATTEMPTED'}.contains(status?.toUpperCase());

  /// "BKASH-BKash" → "BKash".
  String? get methodLabel {
    final card = cardType;
    if (card == null || card.isEmpty) return null;
    final parts = card.split('-');
    return parts.length > 1 ? parts.sublist(1).join('-').trim() : card;
  }
}
