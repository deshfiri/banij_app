import '../../helpers/auth_routing.dart';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../../constants/app_constants.dart';
import '../../helpers/all_routes.dart';
import '../../helpers/di.dart';
import '../../helpers/navigation_service.dart';
import '../../helpers/toast.dart';
import '../endpoints.dart';

/// Adds the saved bearer token to every request, logs traffic in debug
/// builds only (with the token masked), and ends the session on a 401 from
/// an authenticated request.
final class Logger extends Interceptor {
  /// Auth endpoints answer 401 for wrong credentials — that is not an
  /// expired session, so it must not log the user out.
  static const _authPaths = ['/auth/login', '/auth/two-factor-challenge', '/register', '/password/'];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = appData.read(kKeyAccessToken);
    if (token != null && token.toString().isNotEmpty) {
      options.headers[NetworkConstants.AUTHORIZATION] = "Bearer $token";
    }
    if (kDebugMode) {
      log("= = = Dio Request = = =");
      log("${_maskedHeaders(options.headers)}");
      log("${_maskedBody(options.data)}");
      log("${options.contentType}");
      log("${options.baseUrl}${options.path}");
    }
    return super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      log("= = = Dio Success Response = = =");
      log(json.encode(response.data));
      log("${response.requestOptions.uri}");
      log("${response.statusCode} ${response.statusMessage ?? ''}");
    }
    return super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log("= = = Dio Error Response = = =");
      log('Error Response: ${err.response}');
      log('Error Message: ${err.message}');
      log('Error Type: ${err.type}');
      log('Error: ${err.error}');
      log('Error Req: ${err.requestOptions.uri}');
    }

    if (_isSessionExpired(err)) {
      AuthRouting.clearSession();

      ToastUtil.showErrorMessage('Session expired. Please log in again.');
      NavigationService.navigateToReplacementUntil(Routes.onboardingScreen);
    }

    return super.onError(err, handler);
  }

  /// 401 / "Unauthenticated" on a request that carried a token, outside the
  /// login / register / password flows.
  bool _isSessionExpired(DioException err) {
    final unauthorized = err.response?.statusCode == 401 ||
        err.response?.data?.toString().contains('Unauthenticated') == true;
    if (!unauthorized) return false;
    final path = err.requestOptions.path;
    if (_authPaths.any(path.contains)) return false;
    return err.requestOptions.headers[NetworkConstants.AUTHORIZATION] != null;
  }

  /// Request body with passwords, codes and tokens hidden (debug logs get
  /// copied and shared).
  static Object? _maskedBody(Object? data) {
    if (data is! Map) return data;
    const secret = ['password', 'code', 'recovery_code', 'challenge_token', 'token', 'secret'];
    return data.map((key, value) {
      final name = key.toString().toLowerCase();
      return MapEntry(key, secret.any(name.contains) && value != null ? '••••••' : value);
    });
  }

  /// Headers with the bearer token shortened so it never lands in logs.
  static Map<String, dynamic> _maskedHeaders(Map<String, dynamic> headers) {
    final copy = Map<String, dynamic>.from(headers);
    final auth = copy[NetworkConstants.AUTHORIZATION]?.toString();
    if (auth != null && auth.length > 16) copy[NetworkConstants.AUTHORIZATION] = '${auth.substring(0, 14)}…';
    return copy;
  }
}
