import 'package:flutter/material.dart';

import '../feature/account/model/account_model.dart';
import '../feature/dashboard/model/dashboard_model.dart';
import '../feature/dashboard/model/my_product_model.dart';
import '../feature/package/model/package_model.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _currentStep = 3; // Step 3: KYC, Step 4: Package, Step 5: Approval
  bool _isKycSubmitted = false;
  int _selectedPackageIndex = 0;
  DashboardModel? _dashboardModel;
  PackageResponseModel? packageResponse;
  MyProductResponseModel? myProductResponse;
  AccountModel? accountModel;

  int get currentIndex => _currentIndex;
  int get currentStep => _currentStep;
  bool get isKycSubmitted => _isKycSubmitted;
  int get selectedPackageIndex => _selectedPackageIndex;
  DashboardModel? get dashboardModel => _dashboardModel;

  bool get isAccountSetupCompleted {
    if (_dashboardModel?.data?.standing != null) {
      final standing = _dashboardModel!.data!.standing!;
      if (standing.needsAttention == false ||
          standing.status?.toLowerCase() == 'active' ||
          standing.status?.toLowerCase() == 'approved') {
        return true;
      }
    }
    return _isKycSubmitted;
  }

  DashboardProvider() {
    fetchDashboard();
    fetchPackages();
    fetchProfile();
    fetchMyProducts();
  }

  bool _isLoadingProducts = false;
  bool get isLoadingProducts => _isLoadingProducts;

  Future<void> fetchMyProducts() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      myProductResponse = await myProductRxObj.fetchProducts();
    } catch (e) {
      myProductResponse = MyProductResponseModel(data: []);
      String err = e.toString().replaceAll('Exception: ', '');
      if (err.contains('account_not_activated') || err.contains('Finish setting up')) {
        ToastUtil.showErrorMessage(err);
      }
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboard() async {
    try {
      _dashboardModel = await dashboardRxObj.fetchDashboardStats();
      if (_dashboardModel?.data?.standing?.status != null) {
        final status = _dashboardModel!.data!.standing!.status!.toLowerCase();
        if (status.contains('kyc')) {
          _currentStep = 3;
        } else if (status.contains('package')) {
          _currentStep = 4;
        } else if (status.contains('approval') ||
            status.contains('approved') ||
            status.contains('active')) {
          _currentStep = 5;
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchPackages() async {
    try {
      packageResponse = await packageRxObj.fetchPackages();
      if (packageResponse?.selectedSlug != null &&
          packageResponse?.data != null) {
        final idx = packageResponse!.data!
            .indexWhere((p) => p.slug == packageResponse!.selectedSlug);
        if (idx != -1) {
          _selectedPackageIndex = idx;
        }
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchProfile() async {
    try {
      accountModel = await accountRxObj.fetchProfile();
      if (accountModel?.data != null) {
        if (accountModel!.data!.emailVerified == true &&
            accountModel!.data!.mobileVerified == true) {
          if (_currentStep < 3) _currentStep = 3;
        }
      }
      notifyListeners();
    } catch (_) {}
  }

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
