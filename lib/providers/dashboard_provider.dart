import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentIndex = 0;
  final int _currentStep = 3; // KYC step is step 3
  bool _isKycSubmitted = false;

  int get currentIndex => _currentIndex;
  int get currentStep => _currentStep;
  bool get isKycSubmitted => _isKycSubmitted;

  void setBottomNavIndex(int index) {
    if (index == 2) return; // Quick Action (+) handled separately
    _currentIndex = index;
    notifyListeners();
  }

  void submitKYC() {
    _isKycSubmitted = true;
    notifyListeners();
  }
}
