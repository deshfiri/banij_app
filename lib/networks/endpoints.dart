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
  static String logout()=>"/auth/logout";

  static String signup() => "/register";
  static String profile()=>"/profile";
  static String package()=>"/packages";
  static String dashborad()=>"/dashboard";
  static String currentUser()=>"/auth/me";
  static String submitDocKyc()=>"/kyc/documents";
  static String notification()=>"/notifications";
  static String locationDivisions()=>"/locations/divisions";
  static String bankList()=>"/banks";
  static String walletBalnce()=>"/wallet";
  static String walletList()=>"/wallet/transactions";
  static String accountDelete()=>"/account-deletion";
  static String locationChild(String type,String sourceId)=>"/locations/$type/$sourceId/children";
  static String myProduct()=>"/my-products";
  static String websites() => "/websites";
  static String payments() => "/payout-methods";
  static String address()=>"/addresses";
  static String verificationHistory()=>"/kyc/history";
  static String order()=>"/orders";
  static String productCatalog()=>"/catalog";
  static String catalog() => "/catalog";
  static String catalogWholesale() => "/catalog/wholesale";
  static String catalogDropshipping() => "/catalog/dropshipping";
  static String wholesaleCart() => "/wholesale/cart";
  static String wholesaleCartItems() => "/wholesale/cart/items";
  static String wholesaleCartItemDetail(String item) => "/wholesale/cart/items/$item";
  static String wholesaleCartPrices() => "/wholesale/cart/prices";
  static String checkout() => "/checkout";
  static String checkoutCoupon() => "/checkout/coupon";
  static String checkoutPayment() => "/checkout/payment";
  static String checkoutPaymentVerify() => "/checkout/payment/verify";
  static String allocatedStock() => "/allocated-stock";
  static String requestRevierw() => "/finance/finance_requisition_list.php";
  static String allRequestReview() =>
      "/finance/finance_requisition_crn_list.php";
  static String reviewAccept() => "/finance/finance_requisition_approve.php";
  static String allReviewAccept() =>
      "/finance/finance_requisition_crn_approve_cancel.php";
  static String editAmount() =>
      "/finance/finance_requisition_update_crn_amount.php";

  static String taskAccept(int id) => "/finance/finance_requisition_list.php";
  static String requistioanlCanel() =>
      "/finance/finance_requisition_cancel.php";
  static String securityRules()=>"/security";

  static String forgetPass() => "/password/forgot";
  static String otpVerify() => "/verify-otp";
  static String resendOtp() => "/resend-otp";
  static String resetPassword() => "/password/reset";
  static String changepassword()=>"/security/password";
  static String userProfile() => "/profile";
  static String editProfile() => "/update-profile";
  static String updateProfile() => "/update-profile";
  static String history() => "/appointments-history";
  static String special() => "/partner-information/special-days";
  static String partnerInformation() => "/partner-information";
  static String profileInfo() => "/me";
  static String favouriteThingsGet() => "/partner-information/favourite-things";
  static String archives() => "/archives";
  static String upcomingEvents() => "/upcoming_events";
  // static String updatePartnerInfo() => "/update-partner/$KkID";
  static String storePartner() => "/partner-information/store";
  static String invoicesList() => "/finance/invoices.php";
  static String receiptsList() => "/finance/receipts.php";
  static String invoiceDetail(String id) => "/finance/invoice_detail.php?id=$id";
  static String receiptDetail(String id) => "/finance/receipt_detail.php?id=$id";
  static String specialDay() => "/partner/special-days/26";
  static String deletePartner() => "/partner/remove";
  static String deleteAccount() => "/delete-profile";
}
