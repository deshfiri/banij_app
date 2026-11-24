import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_sslcommerz/model/SSLCAdditionalInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/PhysicalGoods.dart';
import 'package:flutter_sslcommerz/model/sslproductinitilizer/SSLCProductInitializer.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

import '../../../constants/sslcommerz_config.dart';
import '../model/sslcommerz_models.dart';

/// Talks to SSLCommerz sandbox directly (see [SslCommerzConfig]). Uses its
/// own Dio so the app's auth headers / base URL are never sent to it.
final class SslCommerzService {
  SslCommerzService._();
  static final SslCommerzService instance = SslCommerzService._();

  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 30),
      contentType: Headers.formUrlEncodedContentType,
      responseType: ResponseType.json,
    ),
  );

  /// Pays with the official SSLCommerz SDK (`flutter_sslcommerz`): opens
  /// SSLCommerz's native payment UI and returns the result (status `VALID`
  /// when paid, `FAILED`, or `Closed` when the user left).
  Future<SslCommerzTransaction> payWithSdk(SslCommerzPaymentRequest request) async {
    final sslcommerz = Sslcommerz(
      initializer: SSLCommerzInitialization(
        store_id: SslCommerzConfig.storeId,
        store_passwd: SslCommerzConfig.storePassword,
        total_amount: double.parse(request.amount.toStringAsFixed(2)),
        currency: SSLCurrencyType.BDT,
        tran_id: request.transactionId,
        product_category: 'Wholesale',
        sdkType: SslCommerzConfig.directSandboxEnabled ? SSLCSdkType.TESTBOX : SSLCSdkType.LIVE,
        // The SDK fails the payment for an invalid IPN, so only send a real one.
        ipn_url: SslCommerzConfig.ipnUrl.isEmpty ? null : SslCommerzConfig.ipnUrl,
        multi_card_name: '',
      ),
    )
      ..addCustomerInfoInitializer(
        customerInfoInitializer: SSLCCustomerInfoInitializer(
          customerName: request.customerName,
          customerEmail: request.customerEmail,
          customerAddress1: request.customerAddress,
          customerCity: request.customerCity,
          customerState: request.customerCity,
          customerPostCode: request.customerPostcode,
          customerCountry: 'Bangladesh',
          customerPhone: request.customerPhone,
        ),
      )
      ..addProductInitializer(
        sslcProductInitializer: SSLCProductInitializer.WithPhysicalGoodsProfile(
          productName: request.productName,
          productCategory: 'Wholesale',
          physicalGoods: PhysicalGoods(productProfile: 'physical-goods', physicalGoods: 'Wholesale goods'),
        ),
      )
      ..addAdditionalInitializer(
        sslcAdditionalInitializer: SSLCAdditionalInitializer(valueA: request.transactionId),
      );

    final SSLCTransactionInfoModel result = await sslcommerz.payNow();
    return SslCommerzTransaction(
      transactionId: result.tranId ?? request.transactionId,
      status: result.status,
      valId: result.valId,
      amount: result.amount,
      currency: result.currencyType,
      cardType: result.cardType,
      bankTransactionId: result.bankTranId,
      tranDate: result.tranDate,
    );
  }

  /// Creates a payment session and returns the `GatewayPageURL` to open.
  /// Throws an [Exception] with SSLCommerz's reason on failure.
  Future<String> createSession(SslCommerzPaymentRequest request) async {
    final body = <String, dynamic>{
      'store_id': SslCommerzConfig.storeId,
      'store_passwd': SslCommerzConfig.storePassword,
      'total_amount': request.amount.toStringAsFixed(2),
      'currency': request.currency,
      'tran_id': request.transactionId,
      'success_url': SslCommerzConfig.successUrl,
      'fail_url': SslCommerzConfig.failUrl,
      'cancel_url': SslCommerzConfig.cancelUrl,
      if (SslCommerzConfig.ipnUrl.isNotEmpty) 'ipn_url': SslCommerzConfig.ipnUrl,
      'shipping_method': 'NO',
      'product_name': request.productName,
      'product_category': 'Wholesale',
      'product_profile': 'general',
      'cus_name': request.customerName,
      'cus_email': request.customerEmail,
      'cus_add1': request.customerAddress,
      'cus_city': request.customerCity,
      'cus_postcode': request.customerPostcode,
      'cus_country': 'Bangladesh',
      'cus_phone': request.customerPhone,
      'value_a': request.transactionId,
    };

    try {
      final response = await _dio.post(SslCommerzConfig.sessionUrl, data: body);
      final data = response.data;
      if (data is Map && data['status']?.toString().toUpperCase() == 'SUCCESS') {
        final url = data['GatewayPageURL']?.toString();
        if (url != null && url.isNotEmpty) return url;
      }
      final reason = data is Map ? data['failedreason']?.toString() : null;
      throw Exception(reason?.isNotEmpty == true ? reason : 'Could not start SSLCommerz payment');
    } on DioException catch (e) {
      debugPrint('SSLCommerz session failed: ${e.message}');
      throw Exception('Could not reach SSLCommerz. Check your connection and try again.');
    }
  }

  /// Looks the payment up by our [transactionId]. Returns the most relevant
  /// record (a paid one if any), or null when SSLCommerz has none yet.
  Future<SslCommerzTransaction?> findTransaction(String transactionId) async {
    try {
      final response = await _dio.get(
        SslCommerzConfig.transactionQueryUrl,
        queryParameters: {
          'tran_id': transactionId,
          'store_id': SslCommerzConfig.storeId,
          'store_passwd': SslCommerzConfig.storePassword,
          'format': 'json',
        },
      );
      final data = response.data;
      final elements = data is Map ? data['element'] : null;
      if (elements is! List || elements.isEmpty) return null;
      final records = elements.whereType<Map>().map(SslCommerzTransaction.fromJson).toList();
      return records.firstWhere((t) => t.isPaid, orElse: () => records.first);
    } on DioException catch (e) {
      debugPrint('SSLCommerz lookup failed: ${e.message}');
      return null;
    }
  }
}
