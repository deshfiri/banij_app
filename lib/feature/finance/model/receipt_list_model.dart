import 'dart:convert';

class ReceiptListResponseModel {
  final List<ReceiptItemModel> data;

  const ReceiptListResponseModel({this.data = const []});

  factory ReceiptListResponseModel.fromRawJson(String source) =>
      ReceiptListResponseModel.fromJson(json.decode(source));

  factory ReceiptListResponseModel.fromJson(dynamic input) {
    final json = _jsonMap(input);
    final rawData = json['data'] ?? json['receipts'];
    if (rawData is! List) {
      throw const FormatException('Receipt response is missing its data list');
    }

    return ReceiptListResponseModel(
      data: rawData
          .map((item) => ReceiptItemModel.fromJson(_jsonMap(item)))
          .toList(),
    );
  }
}

class ReceiptItemModel {
  final String? receiptNo;
  final String? gateway;
  final String? date;
  final String? amount;
  final String? status;

  const ReceiptItemModel({
    this.receiptNo,
    this.gateway,
    this.date,
    this.amount,
    this.status,
  });

  factory ReceiptItemModel.fromJson(Map<String, dynamic> json) {
    return ReceiptItemModel(
      receiptNo: json['receipt_no']?.toString() ?? json['number']?.toString(),
      gateway: json['gateway']?.toString(),
      date:
          json['date']?.toString() ??
          json['paid_at']?.toString() ??
          json['created_at']?.toString(),
      amount: _amountText(json['amount'] ?? json['total']),
      status:
          json['status']?.toString() ??
          json['payment_status']?.toString(),
    );
  }

  String get displayNumber =>
      receiptNo?.isNotEmpty == true ? receiptNo! : 'Receipt';

  String get displayGateway =>
      gateway?.isNotEmpty == true ? gateway! : 'Payment';

  String get displayDate => date?.isNotEmpty == true ? date! : '—';

  String get displayAmount => amount?.isNotEmpty == true ? amount! : '—';

  String get displayStatus =>
      status?.trim().isNotEmpty == true ? status!.trim() : 'Unknown';
}

String _amountText(dynamic value) {
  if (value is Map) {
    return value['formatted']?.toString() ?? value['amount']?.toString() ?? '';
  }
  return value?.toString() ?? '';
}

Map<String, dynamic> _jsonMap(dynamic input) {
  final decoded = input is String ? json.decode(input) : input;
  if (decoded is Map<String, dynamic>) return decoded;
  if (decoded is Map) {
    return decoded.map((key, value) => MapEntry(key.toString(), value));
  }
  throw const FormatException('Expected an object in the receipt response');
}
