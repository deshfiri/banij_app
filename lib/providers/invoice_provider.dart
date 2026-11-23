import 'package:flutter/material.dart';

import '../feature/finance/model/invoice_detail_model.dart';
import '../feature/finance/model/invoice_list_model.dart';
import '../feature/finance/model/receipt_list_model.dart';
import '../helpers/error_message.dart';
import '../networks/api_access.dart';

class InvoiceProvider extends ChangeNotifier {
  InvoiceListResponseModel? invoiceResponse;
  ReceiptListResponseModel? receiptResponse;
  final Map<String, InvoiceDetailModel> _invoiceDetails = {};
  final Set<String> _loadingInvoiceDetails = {};
  final Map<String, String> _invoiceDetailErrors = {};

  bool _isLoadingInvoices = false;
  bool get isLoadingInvoices => _isLoadingInvoices;

  bool _isLoadingReceipts = false;
  bool get isLoadingReceipts => _isLoadingReceipts;

  String? invoiceError;
  String? receiptError;

  bool _hasLoadedInvoices = false;
  bool _hasLoadedReceipts = false;

  InvoiceDetailModel? invoiceDetailFor(String id) => _invoiceDetails[id];

  bool isLoadingInvoiceDetail(String id) => _loadingInvoiceDetails.contains(id);

  String? invoiceDetailErrorFor(String id) => _invoiceDetailErrors[id];

  Future<void> fetchInvoiceDetail(String id, {bool force = false}) async {
    final normalizedId = id.trim();
    if (normalizedId.isEmpty) {
      _invoiceDetailErrors[id] = 'Invoice ID is unavailable';
      notifyListeners();
      return;
    }
    if (_loadingInvoiceDetails.contains(normalizedId) ||
        (!force && _invoiceDetails.containsKey(normalizedId))) {
      return;
    }

    _loadingInvoiceDetails.add(normalizedId);
    _invoiceDetailErrors.remove(normalizedId);
    notifyListeners();

    try {
      _invoiceDetails[normalizedId] = await invoiceDetailRxObj
          .fetchInvoiceDetail(normalizedId);
    } catch (error) {
      final message = error.apiErrorMessage;
      _invoiceDetailErrors[normalizedId] = message.isEmpty
          ? 'Failed to load invoice details'
          : message;
    } finally {
      _loadingInvoiceDetails.remove(normalizedId);
      notifyListeners();
    }
  }

  Future<void> fetchInvoices({bool force = false}) async {
    if (_isLoadingInvoices || (_hasLoadedInvoices && !force)) return;

    _isLoadingInvoices = true;
    invoiceError = null;
    notifyListeners();

    try {
      invoiceResponse = await invoiceRxObj.fetchInvoices();
      _hasLoadedInvoices = true;
    } catch (error) {
      final message = error.apiErrorMessage;
      invoiceError = message.isEmpty ? 'Failed to load invoices' : message;
    } finally {
      _isLoadingInvoices = false;
      notifyListeners();
    }
  }

  Future<void> fetchReceipts({bool force = false}) async {
    if (_isLoadingReceipts || (_hasLoadedReceipts && !force)) return;

    _isLoadingReceipts = true;
    receiptError = null;
    notifyListeners();

    try {
      receiptResponse = await receiptRxObj.fetchReceipts();
      _hasLoadedReceipts = true;
    } catch (error) {
      final message = error.apiErrorMessage;
      receiptError = message.isEmpty ? 'Failed to load receipts' : message;
    } finally {
      _isLoadingReceipts = false;
      notifyListeners();
    }
  }
}
