import 'dart:convert';

class FinanceModel {
  final bool? success;
  final String? message;
  final List<InvoiceDto>? invoices;
  final List<ReceiptDto>? receipts;
  final InvoiceDetailDto? invoiceDetail;
  final ReceiptDetailDto? receiptDetail;

  FinanceModel({
    this.success,
    this.message,
    this.invoices,
    this.receipts,
    this.invoiceDetail,
    this.receiptDetail,
  });

  factory FinanceModel.fromRawJson(String str) => FinanceModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory FinanceModel.fromJson(Map<String, dynamic> json) => FinanceModel(
        success: json["success"],
        message: json["message"],
        invoices: json["invoices"] == null ? null : List<InvoiceDto>.from(json["invoices"].map((x) => InvoiceDto.fromJson(x))),
        receipts: json["receipts"] == null ? null : List<ReceiptDto>.from(json["receipts"].map((x) => ReceiptDto.fromJson(x))),
        invoiceDetail: json["invoice_detail"] == null ? null : InvoiceDetailDto.fromJson(json["invoice_detail"]),
        receiptDetail: json["receipt_detail"] == null ? null : ReceiptDetailDto.fromJson(json["receipt_detail"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "invoices": invoices == null ? null : List<dynamic>.from(invoices!.map((x) => x.toJson())),
        "receipts": receipts == null ? null : List<dynamic>.from(receipts!.map((x) => x.toJson())),
        "invoice_detail": invoiceDetail?.toJson(),
        "receipt_detail": receiptDetail?.toJson(),
      };
}

class InvoiceDto {
  final String? invoiceNo;
  final String? clientName;
  final String? date;
  final String? dueDate;
  final String? amount;
  final String? status;

  InvoiceDto({
    this.invoiceNo,
    this.clientName,
    this.date,
    this.dueDate,
    this.amount,
    this.status,
  });

  factory InvoiceDto.fromJson(Map<String, dynamic> json) => InvoiceDto(
        invoiceNo: json["invoice_no"],
        clientName: json["client_name"],
        date: json["date"],
        dueDate: json["due_date"],
        amount: json["amount"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "invoice_no": invoiceNo,
        "client_name": clientName,
        "date": date,
        "due_date": dueDate,
        "amount": amount,
        "status": status,
      };
}

class ReceiptDto {
  final String? receiptNo;
  final String? gateway;
  final String? date;
  final String? amount;
  final String? status;

  ReceiptDto({
    this.receiptNo,
    this.gateway,
    this.date,
    this.amount,
    this.status,
  });

  factory ReceiptDto.fromJson(Map<String, dynamic> json) => ReceiptDto(
        receiptNo: json["receipt_no"],
        gateway: json["gateway"],
        date: json["date"],
        amount: json["amount"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "receipt_no": receiptNo,
        "gateway": gateway,
        "date": date,
        "amount": amount,
        "status": status,
      };
}

class InvoiceDetailDto {
  final String? invoiceNo;
  final String? clientName;
  final String? date;
  final String? dueDate;
  final String? amount;
  final String? status;
  final List<String>? items;

  InvoiceDetailDto({
    this.invoiceNo,
    this.clientName,
    this.date,
    this.dueDate,
    this.amount,
    this.status,
    this.items,
  });

  factory InvoiceDetailDto.fromJson(Map<String, dynamic> json) => InvoiceDetailDto(
        invoiceNo: json["invoice_no"],
        clientName: json["client_name"],
        date: json["date"],
        dueDate: json["due_date"],
        amount: json["amount"],
        status: json["status"],
        items: json["items"] == null ? null : List<String>.from(json["items"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "invoice_no": invoiceNo,
        "client_name": clientName,
        "date": date,
        "due_date": dueDate,
        "amount": amount,
        "status": status,
        "items": items == null ? null : List<dynamic>.from(items!.map((x) => x)),
      };
}

class ReceiptDetailDto {
  final String? receiptNo;
  final String? gateway;
  final String? date;
  final String? amount;
  final String? status;
  final String? notes;

  ReceiptDetailDto({
    this.receiptNo,
    this.gateway,
    this.date,
    this.amount,
    this.status,
    this.notes,
  });

  factory ReceiptDetailDto.fromJson(Map<String, dynamic> json) => ReceiptDetailDto(
        receiptNo: json["receipt_no"],
        gateway: json["gateway"],
        date: json["date"],
        amount: json["amount"],
        status: json["status"],
        notes: json["notes"],
      );

  Map<String, dynamic> toJson() => {
        "receipt_no": receiptNo,
        "gateway": gateway,
        "date": date,
        "amount": amount,
        "status": status,
        "notes": notes,
      };
}
