// ignore_for_file: constant_identifier_names

// const String url = String.fromEnvironment("BASE_URL");
// const String url = "http://192.168.40.77:8000";
// const String url = "https://henock.softvencefsd.xyz";
// import 'package:colten_app/constants/app_constants.dart';

const String url = "https://cargoaim.net/app_api";

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
  static String login() => "/auth/login.php";

  static String signup() => "/register";
  static String requestRevierw() => "/finance/finance_requisition_list.php";
  static String AllRequestReview() =>
      "/finance/finance_requisition_crn_list.php";
  static String ReviewAccept() => "/finance/finance_requisition_approve.php";
  static String AllReviewAccept() =>
      "/finance/finance_requisition_crn_approve_cancel.php";
  static String editAmount() =>
      "/finance/finance_requisition_update_crn_amount.php";

  static String taskAccept(int id) => "/finance/finance_requisition_list.php";
  static String requistioanlCanel() =>
      "/finance/finance_requisition_cancel.php";

  static String forgetPass() => "/forget-password";
  static String otpVerify() => "/verify-otp";
  static String resendOtp() => "/resend-otp";
  static String resetPassword() => "/reset-password";
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
  static String specialDay() => "/partner/special-days/26";
  static String logout() => "/auth/logout.php";
  static String deletePartner() => "/partner/remove";
  static String deleteAccount() => "/delete-profile";
  static String changePassword() => "/update-password";
}
