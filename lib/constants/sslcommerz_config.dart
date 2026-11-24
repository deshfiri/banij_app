/// SSLCommerz settings.
///
/// The app normally pays the `redirect_url` the backend returns (the backend
/// owns the store credentials). [directSandboxEnabled] lets the app create
/// the SSLCommerz session itself when the backend returns no payment link —
/// **for sandbox testing only**.
///
/// SECURITY: never put LIVE store credentials in the app — anyone can read
/// them from the APK/IPA. For production, turn [directSandboxEnabled] off
/// and let the backend create the session and receive the IPN.
abstract final class SslCommerzConfig {
  /// Create the session from the app when the backend sends no payment link.
  static const bool directSandboxEnabled = true;

  /// Sandbox store. Replace with the store from your SSLCommerz sandbox
  /// registration (https://developer.sslcommerz.com/registration/).
  static const String storeId = 'testbox';
  static const String storePassword = 'qwerty';

  static const String _sandboxHost = 'https://sandbox.sslcommerz.com';

  /// Creates a payment session; answers with `GatewayPageURL`.
  static const String sessionUrl = '$_sandboxHost/gwprocess/v4/api.php';

  /// Looks a transaction up by our `tran_id`.
  static const String transactionQueryUrl = '$_sandboxHost/validator/api/merchantTransIDvalidationAPI.php';

  /// Return URLs. They only need to be on our own domain: the in-app web
  /// view recognises them and closes before they load.
  static const String _returnBase = 'https://staging.deshfiri.com/payment/sslcommerz';
  static const String successUrl = '$_returnBase/success';
  static const String failUrl = '$_returnBase/fail';
  static const String cancelUrl = '$_returnBase/cancel';

  /// Optional backend IPN listener so the server also learns about the
  /// payment. Leave empty if the backend has none yet.
  static const String ipnUrl = '';
}
