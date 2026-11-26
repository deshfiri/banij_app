import 'package:bbnij/feature/dashboard/model/checkout_model.dart';
import 'package:bbnij/feature/dashboard/model/checkout_response_model.dart';
import 'package:bbnij/feature/dashboard/model/payment_status.dart';
import 'package:bbnij/feature/dashboard/model/wholesale_checkout_model.dart';
import 'package:bbnij/feature/dashboard/presentation/sslcommerz_payment_screen.dart';
import 'package:flutter_test/flutter_test.dart';

const _api = 'https://staging.deshfiri.com/api/mobile/v1';

void main() {
  group('Negated statuses are never paid', () {
    final cases = <String, PaymentStatus>{
      'unsuccessful': PaymentStatus.failed,
      'invalid': PaymentStatus.failed,
      'incomplete': PaymentStatus.pending,
      'unsettled': PaymentStatus.pending,
      'unverified': PaymentStatus.pending,
      'not_paid': PaymentStatus.unpaid,
      'notpaid': PaymentStatus.unpaid,
      'unpaid': PaymentStatus.unpaid,
      // Positive forms still map to paid.
      'successful': PaymentStatus.paid,
      'completed': PaymentStatus.paid,
      'settled': PaymentStatus.paid,
      'paid_in_full': PaymentStatus.paid,
    };
    cases.forEach((raw, expected) {
      test('$raw → $expected', () => expect(PaymentStatus.fromBackend(raw), expected));
    });
  });

  group('CheckoutModel settlement flags', () {
    test('an amount under "paid" is not a settlement flag', () {
      final m = CheckoutModel.fromJson({
        'data': {'status': 'pending', 'is_open': true, 'paid': 1500},
      });
      expect(m.isPaid, isFalse);
      expect(m.paymentStatus, isNot(PaymentStatus.paid));
    });
    test('is_paid: 1 is a settlement flag', () {
      final m = CheckoutModel.fromJson({
        'data': {'is_paid': 1, 'is_open': false},
      });
      expect(m.isPaid, isTrue);
    });
    test('"unsuccessful" closed attempt is final and not paid', () {
      final m = CheckoutModel.fromJson({
        'data': {'status': 'unsuccessful', 'is_open': false},
      });
      expect(m.isPaid, isFalse);
      expect(m.paymentStatus, PaymentStatus.failed);
      expect(m.isFinal, isTrue);
    });
  });

  group('GatewayReturnDetector', () {
    test('root domains', () {
      expect(GatewayReturnDetector.rootDomainOf('staging.deshfiri.com'), 'deshfiri.com');
      expect(GatewayReturnDetector.rootDomainOf('pay.shop.com.bd'), 'shop.com.bd');
      expect(GatewayReturnDetector.rootDomainOf('deshfiri.com'), 'deshfiri.com');
      expect(GatewayReturnDetector.rootDomainOf('192.168.0.10'), '192.168.0.10');
    });

    test('gateway, bank and wallet pages never count as the return', () {
      final d = GatewayReturnDetector(
        paymentUrl: 'https://sandbox.sslcommerz.com/EasyCheckOut/testcde4',
        apiBaseUrl: _api,
      );
      expect(d.check('https://sandbox.sslcommerz.com/EasyCheckOut/testcde4'), isNull);
      expect(d.reachedGateway, isTrue);
      expect(d.check('https://payment.bkash.com/?paymentId=TR1&status=success'), isNull);
      expect(d.check('https://acs.mybank.com/3ds/challenge?result=success'), isNull);
      expect(d.check('https://securepay.nagad.com.bd/check-out/payment/error'), isNull);
    });

    test('shop return page after the gateway gives the outcome hint', () {
      GatewayReturnDetector fresh() {
        final d = GatewayReturnDetector(paymentUrl: 'https://sandbox.sslcommerz.com/EasyCheckOut/x', apiBaseUrl: _api);
        d.check('https://sandbox.sslcommerz.com/EasyCheckOut/x');
        return d;
      }

      expect(
        fresh().check('https://staging.deshfiri.com/payment/sslcommerz/success?tran_id=1'),
        GatewayOutcome.success,
      );
      expect(fresh().check('https://staging.deshfiri.com/payment/sslcommerz/fail'), GatewayOutcome.failed);
      expect(fresh().check('https://staging.deshfiri.com/payment/sslcommerz/cancel'), GatewayOutcome.cancelled);
      expect(fresh().check('https://deshfiri.com/checkout/return'), GatewayOutcome.unknown);
    });

    test('a payment link on the shop domain is not mistaken for the return', () {
      final d = GatewayReturnDetector(paymentUrl: 'https://staging.deshfiri.com/payment/abc', apiBaseUrl: _api);
      expect(d.check('https://staging.deshfiri.com/payment/abc'), isNull); // the link itself
      expect(d.check('https://staging.deshfiri.com/payment/abc/start'), isNull); // redirect step
      d.check('https://sandbox.sslcommerz.com/EasyCheckOut/abc');
      expect(d.check('https://staging.deshfiri.com/payment/abc/return'), GatewayOutcome.unknown);
    });
  });

  group('Quote and order parsing', () {
    test('is_payable as a number and object lines', () {
      final data = CheckoutData.fromJson({
        'package': {'slug': 'growth', 'name': 'Growth'},
        'quote': {
          'is_payable': 1,
          'lines': [
            {
              'label': 'Growth package',
              'amount': {'formatted': '৳5,000.00'},
            },
            'Activation fee',
          ],
          'total': {'amount': '5000.00', 'formatted': '৳5,000.00'},
        },
        'coupon': {'code': 'WELCOME10'},
      });
      expect(data.quote!.isPayable, isTrue);
      expect(data.quote!.lineItems.map((l) => l.label), ['Growth package', 'Activation fee']);
      expect(data.quote!.lineItems.first.amount, '৳5,000.00');
      expect(data.coupon, 'WELCOME10');
    });

    test("an order's own url is not a payment link", () {
      final noLink = WholesaleCheckoutResponseModel.fromJson({
        'data': {
          'order': {'id': 7, 'url': 'https://staging.deshfiri.com/orders/7'},
        },
      });
      expect(noLink.redirectUrl, isNull);
      final withLink = WholesaleCheckoutResponseModel.fromJson({
        'data': {'payment_url': 'https://sandbox.sslcommerz.com/EasyCheckOut/abc'},
      });
      expect(withLink.redirectUrl, 'https://sandbox.sslcommerz.com/EasyCheckOut/abc');
    });
  });
}
