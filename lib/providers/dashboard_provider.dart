import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _currentStep = 3; // Step 3: KYC, Step 4: Package, Step 5: Approval
  bool _isKycSubmitted = false;
  int _selectedPackageIndex = 1; // Default to 1 (Professional / Popular)

  int get currentIndex => _currentIndex;
  int get currentStep => _currentStep;
  bool get isKycSubmitted => _isKycSubmitted;
  int get selectedPackageIndex => _selectedPackageIndex;

  void setBottomNavIndex(int index) {
    if (index == 2) return; // Quick Action (+) handled separately
    _currentIndex = index;
    notifyListeners();
  }

  void setStep(int step) {
    _currentStep = step;
    notifyListeners();
  }

  void setSelectedPackage(int index) {
    _selectedPackageIndex = index;
    notifyListeners();
  }

  void submitKYC() {
    _currentStep = 4; // Advance to Package selection (Step 4)
    notifyListeners();
  }

  void completePackageSelection() {
    _currentStep = 5; // Advance to Approval (Step 5)
    notifyListeners();
  }

  void unlockDashboard() {
    _isKycSubmitted = true;
    notifyListeners();
  }
}
