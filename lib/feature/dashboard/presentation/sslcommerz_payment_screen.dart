import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';
import '../../../networks/endpoints.dart' as endpoints;

/// How the gateway page ended — only a hint: the backend decides the result.
enum GatewayOutcome { success, failed, cancelled, unknown }

/// Result of [SslCommerzPaymentScreen]: the outcome plus the query values of
/// the return page (e.g. `tran_id`, `status`), when there are any.
class GatewayResult {
  final GatewayOutcome outcome;
  final Map<String, String> params;

  const GatewayResult(this.outcome, [this.params = const {}]);
}

/// Decides when the payer is back on the shop after SSLCommerz.
///
/// Only a page on the shop's own domain (taken from the API base URL), seen
/// after the SSLCommerz pages, counts as the return. Bank, wallet and 3-D
/// Secure pages on other domains never do — even when their address
/// contains words like "payment" or "success".
class GatewayReturnDetector {
  final Uri _initialUri;
  final String _shopRootDomain;
  bool _reachedGateway = false;

  GatewayReturnDetector({required String paymentUrl, String apiBaseUrl = endpoints.url})
    : _initialUri = Uri.parse(paymentUrl),
      _shopRootDomain = rootDomainOf(Uri.parse(apiBaseUrl).host);

  /// The payer has been on an SSLCommerz page.
  bool get reachedGateway => _reachedGateway;

  /// Registrable domain of [host]: `staging.deshfiri.com` → `deshfiri.com`,
  /// `pay.shop.com.bd` → `shop.com.bd`. IP addresses are returned as is.
  static String rootDomainOf(String host) {
    final lower = host.toLowerCase();
    if (RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(lower)) return lower;
    final parts = lower.split('.').where((p) => p.isNotEmpty).toList();
    if (parts.length <= 2) return parts.join('.');
    const secondLevel = {'com', 'net', 'org', 'gov', 'edu', 'ac', 'co', 'info', 'biz'};
    final hasCountrySecondLevel = parts.last.length == 2 && secondLevel.contains(parts[parts.length - 2]);
    return parts.sublist(parts.length - (hasCountrySecondLevel ? 3 : 2)).join('.');
  }

  static bool isGatewayHost(String host) => host.toLowerCase().contains('sslcommerz');

  bool isShopHost(String host) {
    final lower = host.toLowerCase();
    return lower == _shopRootDomain || lower.endsWith('.$_shopRootDomain');
  }

  /// The outcome when [url] is the shop's return page, otherwise null.
  GatewayOutcome? check(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host.isEmpty) return null;
    if (isGatewayHost(uri.host)) {
      _reachedGateway = true;
      return null;
    }
    // Bank / wallet / 3-D Secure pages.
    if (!isShopHost(uri.host)) return null;
    // The payment link itself (it may be on the shop's domain and redirect).
    if (_isInitial(uri)) return null;

    final hint = _hintFrom('${uri.path} ${uri.query}'.toLowerCase());
    // A shop page before the gateway is a redirect step, not the return —
    // unless its address says how the payment ended.
    if (!_reachedGateway && hint == null) return null;
    return hint ?? GatewayOutcome.unknown;
  }

  bool _isInitial(Uri uri) =>
      uri.host.toLowerCase() == _initialUri.host.toLowerCase() &&
      uri.path == _initialUri.path &&
      uri.query == _initialUri.query;

  static GatewayOutcome? _hintFrom(String text) {
    if (text.contains('cancel')) return GatewayOutcome.cancelled;
    if (RegExp(r'fail|declin|error').hasMatch(text)) return GatewayOutcome.failed;
    if (RegExp(r'success|succeed|complete').hasMatch(text)) return GatewayOutcome.success;
    return null;
  }
}

/// SSLCommerz's official hosted checkout (the `redirect_url` the backend
/// returns) in an in-app web view. Closes itself once the payer is back on
/// the shop's return page — after that page has loaded, so the backend
/// always receives SSLCommerz's callback.
///
/// No store credentials live in the app: the backend creates the SSLCommerz
/// session and settles it (IPN / validation).
class SslCommerzPaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const SslCommerzPaymentScreen({super.key, required this.paymentUrl});

  static Future<GatewayResult> open(BuildContext context, String paymentUrl) async {
    final result = await Navigator.push<GatewayResult>(
      context,
      MaterialPageRoute(fullscreenDialog: true, builder: (_) => SslCommerzPaymentScreen(paymentUrl: paymentUrl)),
    );
    return result ?? const GatewayResult(GatewayOutcome.cancelled);
  }

  @override
  State<SslCommerzPaymentScreen> createState() => _SslCommerzPaymentScreenState();
}

class _SslCommerzPaymentScreenState extends State<SslCommerzPaymentScreen> {
  /// Close anyway if the return page never finishes loading.
  static const Duration _returnTimeout = Duration(seconds: 8);
  static const _webSchemes = {'http', 'https', 'about', 'data', 'javascript', 'blob'};

  late final WebViewController _controller;
  late final GatewayReturnDetector _detector = GatewayReturnDetector(paymentUrl: widget.paymentUrl);
  int _progress = 0;
  String? _loadError;

  /// The return page was reached; closing once it has loaded.
  bool _returning = false;
  bool _closed = false;
  GatewayOutcome _outcome = GatewayOutcome.unknown;
  Map<String, String> _params = const {};
  Timer? _returnTimer;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) => mounted ? setState(() => _progress = value) : null,
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            // Bank / wallet apps (bkash://, intent://, upi://…) open outside.
            if (uri != null && uri.scheme.isNotEmpty && !_webSchemes.contains(uri.scheme.toLowerCase())) {
              _openExternal(request.url);
              return NavigationDecision.prevent;
            }
            _handleUrl(request.url);
            // Never block the return page: the backend must receive it.
            return NavigationDecision.navigate;
          },
          // Also sees form POSTs (Android does not report those above).
          onPageStarted: _handleUrl,
          onPageFinished: (_) {
            if (_returning) _close();
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame != true || !mounted) return;
            if (_returning) {
              _close(); // The request reached the backend; its page just failed.
              return;
            }
            // A redirect to an app scheme is handled by _openExternal.
            if (error.description.contains('ERR_UNKNOWN_URL_SCHEME')) return;
            setState(() => _loadError = error.description);
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  @override
  void dispose() {
    _returnTimer?.cancel();
    super.dispose();
  }

  void _handleUrl(String url) {
    if (_returning || _closed) return;
    final outcome = _detector.check(url);
    if (outcome == null) return;
    _outcome = outcome;
    _params = Uri.tryParse(url)?.queryParameters ?? const {};
    _returnTimer = Timer(_returnTimeout, _close);
    if (mounted) setState(() => _returning = true);
  }

  void _close([GatewayOutcome? outcome]) {
    if (_closed || !mounted) return;
    _closed = true;
    _returnTimer?.cancel();
    Navigator.pop(context, GatewayResult(outcome ?? _outcome, _params));
  }

  /// Opens an app link. Android `intent://` links are turned into the app's
  /// own scheme, else their web fallback, else the app's store page.
  Future<void> _openExternal(String raw) async {
    Future<bool> tryLaunch(Uri? uri) async {
      if (uri == null) return false;
      try {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        return false;
      }
    }

    var opened = false;
    if (raw.toLowerCase().startsWith('intent:')) {
      final marker = raw.indexOf('#Intent;');
      final params = <String, String>{};
      if (marker >= 0) {
        for (final part in raw.substring(marker + 8).split(';')) {
          final eq = part.indexOf('=');
          if (eq > 0) params[part.substring(0, eq)] = part.substring(eq + 1);
        }
      }
      final body = raw.substring('intent:'.length, marker >= 0 ? marker : raw.length);
      final scheme = params['scheme'];
      if (scheme != null && scheme.isNotEmpty) opened = await tryLaunch(Uri.tryParse('$scheme:$body'));
      final fallback = params['S.browser_fallback_url'];
      if (!opened && fallback != null) {
        final uri = Uri.tryParse(Uri.decodeComponent(fallback));
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          await _controller.loadRequest(uri);
          opened = true;
        }
      }
      final package = params['package'];
      if (!opened && package != null && package.isNotEmpty) {
        opened =
            await tryLaunch(Uri.parse('market://details?id=$package')) ||
            await tryLaunch(Uri.parse('https://play.google.com/store/apps/details?id=$package'));
      }
    } else {
      opened = await tryLaunch(Uri.tryParse(raw));
    }

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('Could not open the app. Please choose another payment method.'.tr),
        ),
      );
    }
  }

  /// System back: step back through the gateway pages first, then ask.
  Future<void> _handleBack() async {
    if (_returning || _closed) return;
    if (_loadError == null && await _controller.canGoBack()) {
      await _controller.goBack();
      return;
    }
    await _confirmClose();
  }

  Future<void> _confirmClose() async {
    if (_returning || _closed) return;
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsTheme.cardBg(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18.r)),
        title: Text(
          'Leave payment?'.tr,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColorsTheme.textMainColor(context)),
        ),
        content: Text(
          'If you already paid, we will still confirm it on the next screen.'.tr,
          style: TextStyle(fontSize: 13.sp, height: 1.4, color: AppColorsTheme.textMutedColor(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Stay'.tr, style: TextStyle(color: AppColorsTheme.textMainColor(context))),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: Text('Leave'.tr, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
    if (leave == true) _close(GatewayOutcome.unknown);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Scaffold(
          backgroundColor: AppColorsTheme.background(context),
          body: Column(
            children: [
              HeroPageHeader(
                title: 'Secure Payment'.tr,
                subtitle: 'Powered by SSLCommerz'.tr,
                onBack: _confirmClose,
                trailing: HeroIconButton(
                  icon: Icons.refresh_rounded,
                  onTap: () {
                    if (_returning) return;
                    setState(() => _loadError = null);
                    _controller.reload();
                  },
                ),
              ),
              if (_progress < 100 && !_returning)
                LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 3,
                  color: primaryOrange,
                  backgroundColor: primaryOrange.withValues(alpha: 0.15),
                ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _loadError == null
                          ? WebViewWidget(controller: _controller)
                          : _LoadError(
                              message: _loadError!,
                              onRetry: () {
                                setState(() => _loadError = null);
                                _controller.loadRequest(Uri.parse(widget.paymentUrl));
                              },
                            ),
                    ),
                    // Hides the shop's return page while the app takes over.
                    if (_returning) const Positioned.fill(child: _ReturningOverlay()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReturningOverlay extends StatelessWidget {
  const _ReturningOverlay();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColorsTheme.background(context),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: 34.sp,
              child: const CircularProgressIndicator(strokeWidth: 3, color: primaryOrange),
            ),
            UIHelper.verticalSpace(14.h),
            Text(
              'Returning to the app…'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 40.sp, color: primaryOrange),
            UIHelper.verticalSpace(12.h),
            Text(
              'Could not load the payment page'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: AppColorsTheme.textMainColor(context),
              ),
            ),
            UIHelper.verticalSpace(6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.sp, color: AppColorsTheme.textMutedColor(context)),
            ),
            UIHelper.verticalSpace(14.h),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text('Try again'.tr),
              style: TextButton.styleFrom(foregroundColor: primaryOrange),
            ),
          ],
        ),
      ),
    );
  }
}
