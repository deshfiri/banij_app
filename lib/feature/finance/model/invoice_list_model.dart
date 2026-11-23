import 'dart:convert';

import 'package:intl/intl.dart';

class InvoiceListResponseModel {
  final List<InvoiceItemModel> data;
  final InvoicePaginationLinks? links;
  final InvoicePaginationMeta? meta;

  const InvoiceListResponseModel({this.data = const [], this.links, this.meta});

  factory InvoiceListResponseModel.fromRawJson(String source) =>
      InvoiceListResponseModel.fromJson(json.decode(source));

  factory InvoiceListResponseModel.fromJson(dynamic input) {
    final json = _jsonMap(input);
    final rawData = json['data'];
    if (rawData is! List) {
      throw const FormatException('Invoice response is missing its data list');
    }

    return InvoiceListResponseModel(
      data: rawData
          .map((item) => InvoiceItemModel.fromJson(_jsonMap(item)))
          .toList(),
      links: json['links'] == null
          ? null
          : InvoicePaginationLinks.fromJson(_jsonMap(json['links'])),
      meta: json['meta'] == null
          ? null
          : InvoicePaginationMeta.fromJson(_jsonMap(json['meta'])),
    );
  }
}

class InvoiceItemModel {
  final String? id;
  final String? number;
  final String? purpose;
  final String? purposeLabel;
  final InvoiceTotalModel? total;
  final String? issuedAt;
  final bool? isPaid;
  final String? paymentReference;
  final String? paymentStatus;
  final String? paidAt;

  const InvoiceItemModel({
    this.id,
    this.number,
    this.purpose,
    this.purposeLabel,
    this.total,
    this.issuedAt,
    this.isPaid,
    this.paymentReference,
    this.paymentStatus,
    this.paidAt,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id']?.toString(),
      number: json['number']?.toString(),
      purpose: json['purpose']?.toString(),
      purposeLabel: json['purpose_label']?.toString(),
      total: json['total'] == null
          ? null
          : InvoiceTotalModel.fromJson(json['total']),
      issuedAt: json['issued_at']?.toString(),
      isPaid: _parseBool(json['is_paid']),
      paymentReference: json['payment_reference']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      paidAt: json['paid_at']?.toString(),
    );
  }

  String get displayStatus {
    final status = paymentStatus?.trim();
    if (status != null && status.isNotEmpty) return status;
    if (isPaid == true) return 'Paid';
    if (isPaid == false) return 'Pending';
    return 'Unknown';
  }

  String get displayPurpose => purposeLabel?.trim().isNotEmpty == true
      ? purposeLabel!
      : purpose?.trim().isNotEmpty == true
      ? purpose!
      : 'Invoice';

  String get displayTotal {
    final formatted = total?.formatted;
    if (formatted != null && formatted.isNotEmpty) return formatted;
    final amount = total?.amount;
    if (amount == null || amount.isEmpty) return '—';
    if (total?.currency == 'BDT') return '৳$amount';
    final currency = total?.currency;
    return currency == null || currency.isEmpty ? amount : '$currency $amount';
  }

  String get issuedDateLabel => formatFinanceDate(issuedAt);
  String get paidDateLabel => formatFinanceDate(paidAt);
}

class InvoiceTotalModel {
  final String? amount;
  final String? currency;
  final String? formatted;

  const InvoiceTotalModel({this.amount, this.currency, this.formatted});

  factory InvoiceTotalModel.fromJson(dynamic input) {
    if (input is Map) {
      return InvoiceTotalModel(
        amount: input['amount']?.toString(),
        currency: input['currency']?.toString(),
        formatted: input['formatted']?.toString(),
      );
    }
    return InvoiceTotalModel(formatted: input?.toString());
  }
}

class InvoicePaginationLinks {
  final String? first;
  final String? last;
  final String? previous;
  final String? next;

  const InvoicePaginationLinks({
    this.first,
    this.last,
    this.previous,
    this.next,
  });

  factory InvoicePaginationLinks.fromJson(Map<String, dynamic> json) {
    return InvoicePaginationLinks(
      first: json['first']?.toString(),
      last: json['last']?.toString(),
      previous: json['prev']?.toString(),
      next: json['next']?.toString(),
    );
  }
}

class InvoicePaginationMeta {
  final int? currentPage;
  final int? lastPage;
  final int? perPage;
  final int? total;

  const InvoicePaginationMeta({
    this.currentPage,
    this.lastPage,
    this.perPage,
    this.total,
  });

  factory InvoicePaginationMeta.fromJson(Map<String, dynamic> json) {
    return InvoicePaginationMeta(
      currentPage: _parseInt(json['current_page']),
      lastPage: _parseInt(json['last_page']),
      perPage: _parseInt(json['per_page']),
      total: _parseInt(json['total']),
    );
  }
}

String formatFinanceDate(String? value) {
  if (value == null || value.isEmpty) return '—';
  final datePart = value.length >= 10 ? value.substring(0, 10) : value;
  final date = DateTime.tryParse(datePart);
  return date == null ? value : DateFormat('dd MMM yyyy').format(date);
}

Map<String, dynamic> _jsonMap(dynamic input) {
  final decoded = input is String ? json.decode(input) : input;
  if (decoded is Map<String, dynamic>) return decoded;
  if (decoded is Map) {
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }
  throw const FormatException('Expected an object in the finance response');
}

bool? _parseBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  return switch (value?.toString().toLowerCase()) {
    'true' || '1' || 'yes' => true,
    'false' || '0' || 'no' => false,
    _ => null,
  };
}

int? _parseInt(dynamic value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}
