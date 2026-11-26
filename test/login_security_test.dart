import 'package:bbnij/feature/auth/model/response_model.dart';
import 'package:bbnij/feature/auth/presentation/widgets/auth_validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Email validation', () {
    for (final ok in [
      'buyer@example.com',
      'name+tag@gmail.com',
      "o'neil@shop.com.bd",
      'first.last@sub.domain.online',
      'a_b-c@x.agency',
    ]) {
      test('accepts $ok', () => expect(AuthValidators.email(ok), isNull));
    }
    for (final bad in [
      '',
      '   ',
      'plainaddress',
      '@example.com',
      'user@',
      'user@example',
      'user@.com',
      'user..name@example.com',
      '.user@example.com',
      'user@exa_mple.com',
      'user name@example.com',
    ]) {
      test('rejects "$bad"', () => expect(AuthValidators.email(bad), isNotNull));
    }
    test('rejects addresses longer than 254 characters', () {
      expect(AuthValidators.email('${'a' * 250}@x.com'), isNotNull);
    });
  });

  group('Login password validation', () {
    test('required, 6–128 characters, not trimmed', () {
      expect(AuthValidators.loginPassword(''), isNotNull);
      expect(AuthValidators.loginPassword('12345'), isNotNull);
      expect(AuthValidators.loginPassword('123456'), isNull);
      expect(AuthValidators.loginPassword('  pass  '), isNull);
      expect(AuthValidators.loginPassword('x' * 129), isNotNull);
    });
  });

  group('Login succeeds only when everything matches', () {
    Map<String, dynamic> user({String email = 'buyer@example.com', String status = 'active'}) => {
          'id': '01JUSER',
          'name': 'Buyer',
          'email': email,
          'identity_status': status,
          'platform_roles': [],
          'business_account': {'id': 'b1', 'name': 'Buyer Ltd', 'status': 'active', 'is_activated': true},
        };

    test('valid user login', () {
      final r = LoginResponse.fromJson({'token': '2|xyz', 'user': user()});
      expect(loginResponseProblem(r, enteredEmail: 'Buyer@Example.com '), isNull);
    });

    test('valid supplier login', () {
      final r = LoginResponse.fromJson({
        'token': '1|abc',
        'supplier': {'id': 's1', 'email': 'supplier@example.com', 'status': 'approved', 'is_operational': true},
      });
      expect(loginResponseProblem(r, enteredEmail: 'supplier@example.com'), isNull);
    });

    test('no token', () {
      expect(loginResponseProblem(LoginResponse.fromJson({'user': user()}), enteredEmail: 'buyer@example.com'),
          isNotNull);
      expect(loginResponseProblem(LoginResponse.fromJson({'token': '  ', 'user': user()})), isNotNull);
    });

    test('no account in the response', () {
      expect(loginResponseProblem(LoginResponse.fromJson({'token': 't'})), isNotNull);
    });

    test('a different account than the email typed', () {
      final r = LoginResponse.fromJson({'token': 't', 'user': user(email: 'someone.else@example.com')});
      expect(loginResponseProblem(r, enteredEmail: 'buyer@example.com'), isNotNull);
    });

    test('suspended / non-active identity', () {
      final r = LoginResponse.fromJson({'token': 't', 'user': user(status: 'suspended')});
      expect(loginResponseProblem(r, enteredEmail: 'buyer@example.com'), contains('suspended'));
    });
  });
}
