import 'dart:async';

import 'package:dio/dio.dart' show Options;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../helpers/auth_routing.dart';
import '../helpers/error_message.dart';
import '../constants/app_constants.dart';
import '../feature/auth/model/response_model.dart';
import '../helpers/all_routes.dart';
import '../helpers/di.dart';
import '../helpers/loading_helper.dart';
import '../helpers/navigation_service.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';
import '../networks/dio/dio.dart';
import '../networks/endpoints.dart';

class AuthProvider extends ChangeNotifier {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _rememberMe = false;
  bool _obscurePassword = true;
  bool _isSupplierMode = false;
  bool _isSupplierRegister = false;
  bool _isLoading = false;

  AuthProvider() {
    _loadSavedEmail();
  }

  /// "Remember me" keeps only the email. The password is never written to
  /// the device by the app (the system password manager can save it through
  /// the form's autofill hints). Passwords stored by older versions are
  /// deleted here.
  void _loadSavedEmail() {
    try {
      final box = Hive.box('auth_box');
      box.delete('password');
      final remember = box.get('rememberMe', defaultValue: false) as bool;
      if (remember) {
        _rememberMe = true;
        emailController.text = box.get('email', defaultValue: '') as String;
      }
    } catch (e) {
      debugPrint('AuthProvider._loadSavedEmail failed: $e');
    }
  }

  /// Saves (or forgets) the email after a successful sign-in.
  void _rememberEmail(String email) {
    try {
      final box = Hive.box('auth_box');
      box.put('rememberMe', _rememberMe);
      if (_rememberMe) {
        box.put('email', email);
      } else {
        box.delete('email');
      }
      box.delete('password');
    } catch (e) {
      debugPrint('AuthProvider._rememberEmail failed: $e');
    }
  }

  bool get rememberMe => _rememberMe;
  bool get obscurePassword => _obscurePassword;
  bool get isSupplierMode => _isSupplierMode;

  /// The Supplier toggle is on: sign in through the supplier login endpoint.
  bool get isSupplierLogin => _isSupplierRegister || _isSupplierMode;
  bool get isSupplierRegister => _isSupplierRegister;
  bool get isLoading => _isLoading;

  /// The choice is stored on the next successful sign-in; turning it off
  /// forgets the saved email right away.
  void toggleRememberMe(bool? value) {
    _rememberMe = value ?? false;
    if (!_rememberMe) _rememberEmail('');
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleSupplierMode(bool value) {
    _isSupplierMode = value;
    notifyListeners();
  }

  void toggleSupplierRegister(bool value) {
    _isSupplierRegister = value;
    notifyListeners();
  }

  /// Saves the session (token, user details, account type) and opens the
  /// account's home: the supplier dashboard for suppliers, otherwise the
  /// user dashboard (or KYC while the business account is not activated).
  /// Used by password login and by the 2FA challenge.
  Future<void> completeSignIn({
    required String token,
    UserModel? user,
    SupplierAccountModel? supplier,
    required bool isSupplier,
  }) async {
    await appData.write(kKeyAccessToken, token);
    DioSingleton.instance.update(token);
    await appData.write(kKeyIsLoggedIn, true);
    final name = user?.name ?? supplier?.displayName;
    final email = user?.email ?? supplier?.email;
    final id = user?.id ?? supplier?.id;
    if (name != null) await appData.write(KkName, name);
    if (email != null) await appData.write(KkUserEmail, email);
    if (id != null) await appData.write(KkID, id);
    await AuthRouting.saveAccountType(isSupplier: isSupplier || (user?.isSupplier ?? false));

    NavigationService.navigateToReplacementUntil(
      AuthRouting.homeRoute(
        isSupplier: isSupplier || (user?.isSupplier ?? false),
        isActivated: user?.businessAccount?.isActivated ?? true,
      ),
    );
  }

  /// Signs in on the user login (`/auth/login`) or the supplier login
  /// (`/supplier/auth/login`) — they are separate accounts. The Supplier
  /// toggle picks which is tried first; when that login rejects the
  /// credentials (401 / 422) the other one is tried with the same details.
  /// Throttling (429), network errors and 2FA are never retried.
  Future<LoginResponse> _loginEitherAccount({required String email, required String password}) async {
    Future<LoginResponse> attempt({required bool supplier}) async =>
        await loginRxObj.userLogin(email: email, password: password, isSupplier: supplier).waitingForSucess()
            as LoginResponse;

    final supplierFirst = isSupplierLogin;
    try {
      return await attempt(supplier: supplierFirst);
    } on LoginFailure catch (first) {
      if (!first.isRejectedCredentials) rethrow;
      try {
        return await attempt(supplier: !supplierFirst);
      } on LoginFailure catch (second) {
        // Rejected by both: the message of the login the person chose.
        if (second.isRejectedCredentials) throw first;
        rethrow;
      }
    }
  }

  /// Validates the form, signs in, and only starts a session when the
  /// response passes every check of [loginResponseProblem]. Otherwise the
  /// issued token (if any) is revoked and nothing is stored.
  Future<bool> handleSignIn(BuildContext context, GlobalKey<FormState> formKey) async {
    if (_isLoading) return false; // A sign-in is already running.
    FocusScope.of(context).unfocus();
    if (!(formKey.currentState?.validate() ?? false)) return false;

    final email = emailController.text.trim();
    final password = passwordController.text; // Never trimmed.

    _isLoading = true;
    notifyListeners();
    await _endPreviousSession();
    try {
      final response = await _loginEitherAccount(email: email, password: password);

      // 2FA: no session yet — the challenge screen finishes the sign-in.
      if (response.twoFactorRequired == true && (response.token?.isEmpty ?? true)) {
        final challengeToken = response.challengeToken;
        if (challengeToken == null || challengeToken.isEmpty) {
          ToastUtil.showErrorMessage(response.message ?? 'Two-factor verification is required.');
          return false;
        }
        _rememberEmail(email);
        passwordController.clear();
        NavigationService.navigateToWithObject(Routes.twoFactorChallengeScreen, challengeToken);
        return true;
      }

      final problem = loginResponseProblem(response, enteredEmail: email);
      if (problem != null) {
        final token = response.token;
        if (token != null && token.isNotEmpty) await _revokeToken(token, supplier: response.isSupplier);
        ToastUtil.showErrorMessage(problem);
        return false;
      }

      // Everything matched: keep the email (if asked), drop the password from
      // memory, let the system offer to save it securely, then start the
      // session. A `supplier` object → supplier dashboard, `user` → user.
      _rememberEmail(email);
      passwordController.clear();
      TextInput.finishAutofillContext();
      await completeSignIn(
        token: response.token!.trim(),
        user: response.user,
        supplier: response.supplier,
        isSupplier: response.isSupplier,
      );
      ToastUtil.showSuccessMessage('Login successful!');
      return true;
    } catch (e) {
      final message = e.apiErrorMessage;
      ToastUtil.showErrorMessage(
        message.isEmpty || message.contains('Failure') || message.contains('DioException')
            ? 'Failed to sign in. Please check your credentials and network connection.'
            : message,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// A new sign-in ends any session still saved on this device, so a failed
  /// attempt can never leave an older account signed in (the splash screen
  /// would otherwise reopen its dashboard) and the login request carries no
  /// old token. The old token is also revoked on the server.
  Future<void> _endPreviousSession() async {
    final oldToken = appData.read(kKeyAccessToken)?.toString() ?? '';
    final wasSupplier = appData.read(kKeyIsSupplier) == true;
    final wasLoggedIn = appData.read(kKeyIsLoggedIn) == true;
    if (oldToken.isEmpty && !wasLoggedIn) return;
    await AuthRouting.clearSession();
    if (oldToken.isNotEmpty) unawaited(_revokeToken(oldToken, supplier: wasSupplier));
  }

  /// Best-effort sign-out of a token that must not be used (its response
  /// failed the checks), so it does not stay valid on the server.
  Future<void> _revokeToken(String token, {required bool supplier}) async {
    try {
      await DioSingleton.instance.dio.post(
        supplier ? EndPoints.supplierLogout() : EndPoints.logout(),
        options: Options(headers: {NetworkConstants.AUTHORIZATION: 'Bearer $token'}),
      );
    } catch (e) {
      debugPrint('AuthProvider._revokeToken failed: $e');
    }
  }

  void resetLoginForm() {
    try {
      final box = Hive.box('auth_box');
      final remember = box.get('rememberMe', defaultValue: false) as bool;
      passwordController.clear();
      if (remember) {
        _rememberMe = true;
        emailController.text = box.get('email', defaultValue: '') as String;
      } else {
        emailController.clear();
        _rememberMe = false;
      }
    } catch (_) {
      emailController.clear();
      passwordController.clear();
      _rememberMe = false;
    }
    _obscurePassword = true;
    _isSupplierMode = false;
    _isSupplierRegister = false;
    _isLoading = false;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
