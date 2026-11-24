import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../common_widget/hero_page_header.dart';
import '../../../constants/color.dart';
import '../../../helpers/ui_helpers.dart';

/// How the gateway page ended.
enum GatewayOutcome { success, failed, cancelled, unknown }

/// Result of [SslCommerzPaymentScreen]: the outcome plus the query values the
/// gateway sent back (e.g. `tran_id`, `val_id`, `status`), which are passed
/// on to `POST /checkout/payment/verify`.
class GatewayResult {
  final GatewayOutcome outcome;
  final Map<String, String> params;

  const GatewayResult(this.outcome, [this.params = const {}]);
}

/// Opens the SSLCommerz page (the `redirect_url` from `POST /checkout`) in an
/// in-app web view and closes itself when SSLCommerz redirects back to the
/// shop's success / fail / cancel URL.
///
/// No store credentials live in the app: the backend creates the SSLCommerz
/// session and settles it from the gateway's IPN.
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
  late final WebViewController _controller;
  int _progress = 0;
  bool _finished = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (value) => mounted ? setState(() => _progress = value) : null,
          onPageStarted: (url) => _inspect(url),
          onNavigationRequest: (request) {
            if (_inspect(request.url)) return NavigationDecision.prevent;
            // Bank / wallet apps (bkash://, intent://, upi://…) open outside.
            final uri = Uri.tryParse(request.url);
            if (uri != null && !const {'http', 'https', 'about', 'data', 'javascript'}.contains(uri.scheme)) {
              launchUrl(uri, mode: LaunchMode.externalApplication).catchError((_) => false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() => _loadError = error.description);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Returns true (and closes) when [url] is the gateway's return URL.
  bool _inspect(String url) {
    if (_finished) return true;
    final outcome = _outcomeFor(url);
    if (outcome == null) return false;
    _finished = true;
    final uri = Uri.tryParse(url);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, GatewayResult(outcome, uri?.queryParameters ?? const {}));
    });
    return true;
  }

  /// Detects the return to the shop after SSLCommerz. While still on the
  /// SSLCommerz domain (or a bank page) nothing is matched.
  static GatewayOutcome? _outcomeFor(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();
    if (host.isEmpty || host.contains('sslcommerz')) return null;

    final text = '${uri.path} ${uri.query}'.toLowerCase();
    if (RegExp(r'cancel').hasMatch(text)) return GatewayOutcome.cancelled;
    if (RegExp(r'fail|declin|error').hasMatch(text)) return GatewayOutcome.failed;
    if (RegExp(r'success|succeed|paid|complete|thank').hasMatch(text)) return GatewayOutcome.success;
    if (RegExp(r'checkout|payment|callback|return|ipn').hasMatch(text)) return GatewayOutcome.unknown;
    return null;
  }

  Future<void> _confirmClose() async {
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
    if (leave == true && mounted) {
      _finished = true;
      Navigator.pop(context, const GatewayResult(GatewayOutcome.unknown));
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmClose();
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
                    setState(() => _loadError = null);
                    _controller.reload();
                  },
                ),
              ),
              if (_progress < 100)
                LinearProgressIndicator(
                  value: _progress / 100,
                  minHeight: 3,
                  color: primaryOrange,
                  backgroundColor: primaryOrange.withValues(alpha: 0.15),
                ),
              Expanded(
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
            ],
          ),
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
