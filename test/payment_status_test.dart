import 'package:bbnij/feature/dashboard/model/checkout_model.dart';
import 'package:bbnij/feature/dashboard/model/payment_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PaymentStatus.fromBackend', () {
    final cases = <String?, PaymentStatus>{
      'paid': PaymentStatus.paid,
      'Succeeded': PaymentStatus.paid,
      'settled': PaymentStatus.paid,
      'VALID': PaymentStatus.paid,
      'pending': PaymentStatus.pending,
      'on_hold': PaymentStatus.pending,
      'processing': PaymentStatus.processing,
      'reconciling': PaymentStatus.processing,
      'initiated': PaymentStatus.initiated,
      'failed': PaymentStatus.failed,
      'declined': PaymentStatus.failed,
      'expired': PaymentStatus.failed,
      'cancelled': PaymentStatus.cancelled,
      'canceled': PaymentStatus.cancelled,
      'unpaid': PaymentStatus.unpaid,
      'awaiting_payment': PaymentStatus.unpaid,
      'refunded': PaymentStatus.refunded,
      'partially_refunded': PaymentStatus.partiallyRefunded,
      'something_new': PaymentStatus.unknown,
      null: PaymentStatus.unknown,
    };
    cases.forEach((raw, expected) {
      test('$raw → $expected', () => expect(PaymentStatus.fromBackend(raw), expected));
    });
  });

  group('CheckoutModel (GET /checkout/payment)', () {
    test('open attempt keeps polling', () {
      final m = CheckoutModel.fromJson({'data': {'status': 'pending', 'is_open': true}});
      expect(m.paymentStatus, PaymentStatus.pending);
      expect(m.isFinal, isFalse);
    });
    test('settled attempt is paid', () {
      final m = CheckoutModel.fromJson({'data': {'status': 'settled', 'is_open': false, 'is_settled': true}});
      expect(m.paymentStatus, PaymentStatus.paid);
      expect(m.isFinal, isTrue);
    });
    test('reconciling is not final', () {
      final m = CheckoutModel.fromJson({'data': {'status': 'pending', 'is_open': false, 'is_reconciling': true}});
      expect(m.paymentStatus, PaymentStatus.processing);
      expect(m.isFinal, isFalse);
    });
    test('closed without payment is failed', () {
      final m = CheckoutModel.fromJson({'data': {'status': 'expired', 'is_open': false}});
      expect(m.paymentStatus, PaymentStatus.failed);
      expect(m.isFinal, isTrue);
    });
    test('cancelled stays cancelled', () {
      final m = CheckoutModel.fromJson({'data': {'status': 'cancelled', 'is_open': false}});
      expect(m.paymentStatus, PaymentStatus.cancelled);
    });
    test('pay response exposes redirect_url', () {
      final m = CheckoutModel.fromJson({'redirect_url': 'https://sandbox.sslcommerz.com/EasyCheckOut/x'});
      expect(m.redirectUrl, startsWith('https://sandbox.sslcommerz.com'));
    });
  });
}
