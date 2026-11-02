import 'package:flutter/material.dart';

class OtpVerifyProvider extends ChangeNotifier {
  bool isOtpValid = false;

  void validateOtp(String value) {
    isOtpValid = value.length == 4; 
    notifyListeners();
  }

  void resendOtp() {
    debugPrint("Resend OTP requested");
  }
}