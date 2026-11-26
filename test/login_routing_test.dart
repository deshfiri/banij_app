import 'package:bbnij/feature/auth/model/response_model.dart';
import 'package:bbnij/helpers/all_routes.dart';
import 'package:bbnij/helpers/auth_routing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Supplier detection from the login JSON', () {
    LoginResponse login(Map<String, dynamic> json) => LoginResponse.fromJson({'token': 't', ...json});

    test('role / type / account_type on the user', () {
      expect(login({'user': {'id': '1', 'role': 'supplier'}}).isSupplier, isTrue);
      expect(login({'user': {'id': '1', 'type': 'SUPPLIER'}}).isSupplier, isTrue);
      expect(login({'user': {'id': '1', 'account_type': 'supplier_admin'}}).isSupplier, isTrue);
    });

    test('platform_roles as strings or objects', () {
      expect(login({'user': {'platform_roles': ['supplier']}}).isSupplier, isTrue);
      expect(
        login({
          'user': {
            'platform_roles': [
              {'name': 'Supplier', 'slug': 'supplier'},
            ],
          },
        }).isSupplier,
        isTrue,
      );
    });

    test('business account type, is_supplier flag, supplier object, top-level role', () {
      expect(login({'user': {'business_account': {'type': 'supplier'}}}).isSupplier, isTrue);
      expect(login({'user': {'is_supplier': true}}).isSupplier, isTrue);
      expect(login({'user': {'supplier': {'id': 9}}}).isSupplier, isTrue);
      expect(login({'role': 'supplier'}).isSupplier, isTrue);
    });

    test('a normal business user is not a supplier', () {
      final response = login({
        'user': {
          'id': '1',
          'name': 'Buyer',
          'platform_roles': [],
          'business_account': {'id': 'b1', 'status': 'active', 'is_activated': true},
          'supplier': null,
        },
      });
      expect(response.isSupplier, isFalse);
      expect(response.user!.isSupplier, isFalse);
    });

    test('2FA challenge token and numeric ids are read', () {
      final r = LoginResponse.fromJson({'two_factor_required': true, 'challenge_token': 'abc'});
      expect(r.twoFactorRequired, isTrue);
      expect(r.challengeToken, 'abc');
      expect(UserModel.fromJson({'id': 42}).id, '42');
    });
  });

  group('Real response shapes (from /docs/mobile.json)', () {
    test('POST /supplier/auth/login → supplier', () {
      final r = LoginResponse.fromJson({
        'token': '1|abc',
        'token_type': 'Bearer',
        'expires_at': null,
        'supplier': {
          'id': '01JSUPPLIER',
          'reference': 'SUP-0001',
          'business_name': 'Dhaka Traders',
          'contact_person_name': 'Rahim',
          'email': 'supplier@example.com',
          'mobile': '01700000000',
          'locale': 'en',
          'email_verified': true,
          'mobile_verified': true,
          'status': 'approved',
          'status_label': 'Approved',
          'status_tone': 'success',
          'is_operational': true,
        },
      });
      expect(r.isSupplier, isTrue);
      expect(r.user, isNull);
      expect(r.supplier!.displayName, 'Rahim');
      expect(r.supplier!.email, 'supplier@example.com');
      expect(r.supplier!.isOperational, isTrue);
      expect(AuthRouting.homeRoute(isSupplier: r.isSupplier), Routes.supplierDashboardScreen);
    });

    test('POST /auth/login → user', () {
      final r = LoginResponse.fromJson({
        'two_factor_required': false,
        'token': '2|xyz',
        'token_type': 'Bearer',
        'expires_at': null,
        'user': {
          'id': '01JUSER',
          'name': 'Buyer',
          'email': 'buyer@example.com',
          'mobile': null,
          'locale': 'en',
          'email_verified': true,
          'mobile_verified': true,
          'two_factor_enabled': false,
          'identity_status': 'active',
          'platform_roles': [],
          'business_account': {'id': 'b1', 'name': 'Buyer Ltd', 'status': 'active', 'is_activated': true},
        },
      });
      expect(r.isSupplier, isFalse);
      expect(r.supplier, isNull);
      expect(
        AuthRouting.homeRoute(isSupplier: r.isSupplier, isActivated: r.user!.businessAccount!.isActivated ?? true),
        Routes.dashboardScreen,
      );
    });

    test('only rejected credentials are retried on the other login', () {
      expect(const LoginFailure('bad', statusCode: 422).isRejectedCredentials, isTrue);
      expect(const LoginFailure('bad', statusCode: 401).isRejectedCredentials, isTrue);
      expect(const LoginFailure('slow down', statusCode: 429).isRejectedCredentials, isFalse);
      expect(const LoginFailure('server', statusCode: 500).isRejectedCredentials, isFalse);
      expect(const LoginFailure('These credentials do not match.').toString(), 'These credentials do not match.');
    });
  });

  group('AuthRouting.homeRoute', () {
    test('supplier → supplier dashboard', () {
      expect(AuthRouting.homeRoute(isSupplier: true), Routes.supplierDashboardScreen);
      expect(AuthRouting.homeRoute(isSupplier: true, isActivated: false), Routes.supplierDashboardScreen);
    });
    test('user → dashboard, or KYC when not activated', () {
      expect(AuthRouting.homeRoute(isSupplier: false), Routes.dashboardScreen);
      expect(AuthRouting.homeRoute(isSupplier: false, isActivated: false), Routes.kycVerificationScreen);
    });
  });
}
