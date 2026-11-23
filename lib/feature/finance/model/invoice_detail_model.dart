import 'dart:convert';

import 'invoice_list_model.dart';

class InvoiceDetailModel {
  final String? id;
  final String? number;
  final String? purpose;
  final String? purposeLabel;
  final String? customerName;
  final InvoiceTotalModel? total;
  final String? issuedAt;
  final String? dueAt;
  final bool? isPaid;
  final String? paymentReference;
  final String? paymentStatus;
  final String? paidAt;
  final List<InvoiceDetailLineModel> items;

  const InvoiceDetailModel({
    this.id,
    this.number,
    this.purpose,
    this.purposeLabel,
    this.customerName,
    this.total,
    this.issuedAt,
    this.dueAt,
    this.isPaid,
    this.paymentReference,
    this.paymentStatus,
    this.paidAt,
    this.items = const [],
  });

  factory InvoiceDetailModel.fromJson(dynamic input) {
    final root = _jsonMap(input);
    final data = _detailMap(root);
    final rawAmount = data['total'] ?? data['amount'];
    final rawItems =
        data['items'] ?? data['line_items'] ?? data['invoice_items'];
    if (rawItems != null && rawItems is! List) {
      throw const FormatException('Invoice detail items must be a list');
    }

    return InvoiceDetailModel(
      id: data['id']?.toString(),
      number: (data['number'] ?? data['invoice_no'])?.toString(),
      purpose: data['purpose']?.toString(),
      purposeLabel: data['purpose_label']?.toString(),
      customerName: _customerName(
        data['customer'] ??
            data['client'] ??
            data['client_name'] ??
            data['customer_name'],
      ),
      total: rawAmount == null ? null : InvoiceTotalModel.fromJson(rawAmount),
      issuedAt: (data['issued_at'] ?? data['date'])?.toString(),
      dueAt: (data['due_at'] ?? data['due_date'])?.toString(),
      isPaid: _parseBool(data['is_paid']),
      paymentReference: data['payment_reference']?.toString(),
      paymentStatus: (data['payment_status'] ?? data['status'])?.toString(),
      paidAt: data['paid_at']?.toString(),
      items: rawItems == null
          ? const []
          : (rawItems as List)
                .map<InvoiceDetailLineModel>(InvoiceDetailLineModel.fromJson)
                .toList(),
    );
  }

  InvoiceDetailModel withListSummary(InvoiceItemModel summary) {
    return InvoiceDetailModel(
      id: id ?? summary.id,
      number: number ?? summary.number,
      purpose: purpose ?? summary.purpose,
      purposeLabel: purposeLabel ?? summary.purposeLabel,
      customerName: customerName,
      total: total ?? summary.total,
      issuedAt: issuedAt ?? summary.issuedAt,
      dueAt: dueAt,
      isPaid: isPaid ?? summary.isPaid,
      paymentReference: paymentReference ?? summary.paymentReference,
      paymentStatus: paymentStatus ?? summary.paymentStatus,
      paidAt: paidAt ?? summary.paidAt,
      items: items,
    );
  }

  String get displayNumber => _nonEmpty(number) ?? id ?? 'Invoice';

  String get displayPurpose =>
      _nonEmpty(purposeLabel) ?? _nonEmpty(purpose) ?? '—';

  String get displayTotal {
    final formatted = _nonEmpty(total?.formatted);
    if (formatted != null) return formatted;
    final amount = _nonEmpty(total?.amount);
    if (amount == null) return '—';
    if (total?.currency == 'BDT') return '৳$amount';
    final currency = _nonEmpty(total?.currency);
    return currency == null ? amount : '$currency $amount';
  }

  String get displayStatus {
    final status = _nonEmpty(paymentStatus);
    if (status != null) return status;
    if (isPaid == true) return 'Paid';
    if (isPaid == false) return 'Pending';
    return 'Unknown';
  }

  String get displayCustomer => _nonEmpty(customerName) ?? '—';
  String get issuedDateLabel => formatFinanceDate(issuedAt);
  String get dueDateLabel => formatFinanceDate(dueAt);
  String get paidDateLabel => formatFinanceDate(paidAt);
  String get displayPaymentReference => _nonEmpty(paymentReference) ?? '—';
}

class InvoiceDetailLineModel {
  final String? description;
  final String? quantity;
  final String? rate;
  final String? amount;

  const InvoiceDetailLineModel({
    this.description,
    this.quantity,
    this.rate,
    this.amount,
  });

  factory InvoiceDetailLineModel.fromJson(dynamic input) {
    if (input is String || input is num) {
      return InvoiceDetailLineModel(description: input.toString());
    }
    final json = _jsonMap(input);
    return InvoiceDetailLineModel(
      description:
          (json['description'] ?? json['name'] ?? json['title'] ?? json['item'])
              ?.toString(),
      quantity: (json['quantity'] ?? json['qty'])?.toString(),
      rate: _moneyText(json['rate'] ?? json['unit_price']),
      amount: _moneyText(json['amount'] ?? json['total']),
    );
  }
}

Map<String, dynamic> _detailMap(Map<String, dynamic> root) {
  const detailKeys = {
    'id',
    'number',
    'invoice_no',
    'total',
    'amount',
    'issued_at',
    'date',
    'payment_status',
    'status',
    'items',
    'line_items',
  };
  if (root.keys.any(detailKeys.contains)) return root;

  for (final key in ['data', 'invoice_detail', 'invoice']) {
    final value = root[key];
    if (value is Map) {
      final nested = _jsonMap(value);
      if (nested.keys.any(detailKeys.contains)) return nested;
      if (nested.keys.any(
        (key) => ['data', 'invoice_detail', 'invoice'].contains(key),
      )) {
        return _detailMap(nested);
      }
    }
  }
  throw const FormatException('Invoice detail response is missing its detail');
}

String? _customerName(dynamic value) {
  if (value is Map) {
    final json = _jsonMap(value);
    return (json['name'] ??
            json['company_name'] ??
            json['business_name'] ??
            json['client_name'])
        ?.toString();
  }
  return value?.toString();
}

String? _moneyText(dynamic value) {
  if (value is Map) {
    return value['formatted']?.toString() ?? value['amount']?.toString();
  }
  return value?.toString();
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

Map<String, dynamic> _jsonMap(dynamic input) {
  final decoded = input is String ? json.decode(input) : input;
  if (decoded is Map<String, dynamic>) return decoded;
  if (decoded is Map) {
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }
  throw const FormatException(
    'Expected an object in the invoice detail response',
  );
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
