// ignore_for_file: constant_identifier_names

// const String url = String.fromEnvironment("BASE_URL");
// const String url = "http://192.168.40.77:8000";
// const String url = "https://henock.softvencefsd.xyz";
// import 'package:colten_app/constants/app_constants.dart';

const String url = "https://staging.deshfiri.com/api/mobile/v1";

final class NetworkConstants {
  NetworkConstants._();
  static const ACCEPT = "Accept";
  static const APP_KEY = "App-Key";
  static const ACCEPT_LANGUAGE = "Accept-Language";
  static const ACCEPT_LANGUAGE_VALUE = "pt";
  static const APP_KEY_VALUE = String.fromEnvironment("APP_KEY_VALUE");
  static const ACCEPT_TYPE = "application/json";
  static const AUTHORIZATION = "Authorization";
  static const CONTENT_TYPE = "content-Type";
}

final class EndPoints {
  EndPoints._();
  static String login() => "/auth/login";
  static String twoFactorChallenge() => "/auth/two-factor-challenge";
  static String logout() => "/auth/logout";

  static String signup() => "/register";
  static String profile() => "/profile";
  static String package() => "/packages";
  static String selectPackage(String slug) => "/packages/$slug/select";
  static String subscription() => "/subscription";
  static String onboradingActive() => "/onboarding";
  static String subscriptionCancel() => "/subscription/cancel";
  static String subscriptionChange() => "/subscription/change";
  static String subscriptionRenew() => "/subscription/renew";
  static String addressList() => "/addresses";
  static String referrals() => "/referrals";
  static String dashborad() => "/dashboard";
  static String currentUser() => "/auth/me";
  static String submitDocKyc() => "/kyc/documents";
  static String notification() => "/notifications";
  static String withdrawals() => "/withdrawals";
  static String locationDivisions() => "/locations/divisions";
  static String bankList() => "/banks";
  static String bankBranches(String bankCode) => "/banks/$bankCode/branches";
  static String walletBalnce() => "/wallet";
  static String topWallet() => "/wallet/top-up";
  static String walletList() => "/wallet/transactions";
  static String accountDelete() => "/account-deletion";
  static String locationChild(String type, String sourceId) =>
      "/locations/$type/$sourceId/children";
  static String myProduct() => "/my-products";
  static String websites() => "/websites";
  static String payments() => "/payout-methods";
  static String address() => "/addresses";
  static String verificationHistory() => "/kyc/history";
  static String order() => "/orders";
  static String catalog() => "/catalog";
  static String catalogWholesale() => "/catalog/wholesale";
  static String catalogDropshipping() => "/catalog/dropshipping";
  static String withdrawaloption() => "/withdrawals/options";
  static String wholesaleCart() => "/wholesale/cart";
  static String wholesaleCartItems() => "/wholesale/cart/items";
  static String wholesaleCartItemDetail(String item) =>
      "/wholesale/cart/items/$item";
  static String wholesaleCartPrices() => "/wholesale/cart/prices";
  static String wholesaleCheckout() => "/wholesale/checkout";
  static String wholesaleCheckoutCoupon() => "/wholesale/checkout/coupon";
  static String wholesaleCheckoutAddress() => "/wholesale/checkout/address";
  static String wholesaleCheckoutAddresses(String type) =>
      "/wholesale/checkout/addresses/$type";
  static String wholesaleCheckoutConfirmation() =>
      "/wholesale/checkout/confirmation";
  static String checkout() => "/checkout";
  static String checkoutCoupon() => "/checkout/coupon";
  static String checkoutPayment() => "/checkout/payment";
  static String checkoutPaymentVerify() => "/checkout/payment/verify";
  static String allocatedStock() => "/allocated-stock";
  static String securityRules() => "/security";

  static String forgetPass() => "/password/forgot";
  static String otpVerify() => "/verify-otp";
  static String resendOtp() => "/resend-otp";
  static String resetPassword() => "/password/reset";
  static String changepassword() => "/security/password";
  static String partnerInformation() => "/partner-information";
  static String language() => "/locale";
  static String storePartner() => "/partner-information/store";
  // Used by ReceiptApi. NOTE: legacy PHP path, unlike every other REST
  // endpoint here (e.g. /invoices) — confirm with the backend.
  static String receiptsList() => "/finance/receipts.php";
  static String invoice() => "/invoices";
  static String invoiceDetails(String id) => "/invoices/$id";
}
