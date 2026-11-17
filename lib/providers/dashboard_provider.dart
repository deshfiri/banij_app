import 'package:flutter/material.dart';

import '../feature/account/model/account_model.dart';
import '../feature/dashboard/model/dashboard_model.dart';
import '../feature/dashboard/model/my_product_model.dart';
import '../feature/dashboard/model/order_model.dart';
import '../feature/package/model/package_model.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';
import '../networks/endpoints.dart';

import '../feature/dashboard/model/catalog_model.dart';

class DashboardProvider extends ChangeNotifier {
  int _currentIndex = 0;
  int _currentStep = 3; // Step 3: KYC, Step 4: Package, Step 5: Approval
  bool _isKycSubmitted = false;
  int _selectedPackageIndex = 0;
  DashboardModel? _dashboardModel;
  PackageResponseModel? packageResponse;
  MyProductResponseModel? myProductResponse;
  MyProductResponseModel? catalogProductResponse;
  CatalogResponseModel? catalogResponseModel;
  OrderResponseModel? orderResponse;
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

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  Future<void> fetchOrders({
    String? type,
    String? search,
    String? source,
    String? store,
    String? status,
    String? payment,
    String? from,
    String? to,
    String? sort,
    String? direction,
    int? perPage,
    int? page,
  }) async {
    _isLoadingOrders = true;
    notifyListeners();

    try {
      String endpoint = EndPoints.order();
      if (type == 'store') {
        endpoint = '/orders/store-orders';
      } else if (type == 'stores') {
        endpoint = '/orders/stores';
      }

      final Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (source != null && source.isNotEmpty) queryParams['source'] = source;
      if (store != null && store.isNotEmpty) queryParams['store'] = store;
      if (status != null && status.isNotEmpty) queryParams['status'] = status;
      if (payment != null && payment.isNotEmpty) queryParams['payment'] = payment;
      if (from != null && from.isNotEmpty) queryParams['from'] = from;
      if (to != null && to.isNotEmpty) queryParams['to'] = to;
      if (sort != null && sort.isNotEmpty) queryParams['sort'] = sort;
      if (direction != null && direction.isNotEmpty) queryParams['direction'] = direction;
      if (perPage != null) queryParams['per_page'] = perPage;
      if (page != null) queryParams['page'] = page;

      orderResponse = await orderRxObj.fetchOrders(
        endpoint,
        queryParams.isNotEmpty ? queryParams : null,
      );
    } catch (e) {
      orderResponse = OrderResponseModel(data: []);
      String err = e.toString().replaceAll('Exception: ', '');
      if (err.isNotEmpty) {
        ToastUtil.showErrorMessage(err);
      }
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<bool> cancelStoreOrder(String orderId, {String? reason}) async {
    try {
      final success = await orderRxObj.cancelStoreOrder(orderId, reason: reason);
      if (success) {
        ToastUtil.showSuccessMessage('Order cancelled successfully');
        fetchOrders(type: 'store');
      } else {
        ToastUtil.showErrorMessage('Failed to cancel order');
      }
      return success;
    } catch (e) {
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to cancel order');
      return false;
    }
  }

  Future<bool> exportOrders() async {
    try {
      final success = await orderRxObj.exportOrders();
      if (success) {
        ToastUtil.showSuccessMessage('Orders exported successfully!');
      } else {
        ToastUtil.showSuccessMessage('Export request sent successfully!');
      }
      return true;
    } catch (_) {
      ToastUtil.showSuccessMessage('Export request sent successfully!');
      return true;
    }
  }

  Future<void> fetchMyProducts() async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      myProductResponse = await myProductRxObj.fetchProducts(EndPoints.myProduct());
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

  Future<void> fetchCatalogProducts({
    String? type,
    String? search,
    String? category,
    String? brand,
    String? stock,
    String? priceMin,
    String? priceMax,
    String? scope,
    int? page,
  }) async {
    _isLoadingProducts = true;
    notifyListeners();

    try {
      String endpoint = EndPoints.catalog();
      if (type == 'wholesale') {
        endpoint = EndPoints.catalogWholesale();
      } else if (type == 'dropshipping') {
        endpoint = EndPoints.catalogDropshipping();
      }

      final Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category.isNotEmpty && category != 'All') queryParams['category'] = category;
      if (brand != null && brand.isNotEmpty && brand != 'All') queryParams['brand'] = brand;
      if (stock != null && stock.isNotEmpty) queryParams['stock'] = stock;
      if (priceMin != null && priceMin.isNotEmpty) queryParams['price_min'] = priceMin;
      if (priceMax != null && priceMax.isNotEmpty) queryParams['price_max'] = priceMax;
      if (scope != null && scope.isNotEmpty) queryParams['scope'] = scope;
      if (page != null) queryParams['page'] = page;

      catalogResponseModel = await catalogRxObj.fetchCatalogProducts(
        endpoint,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
    } catch (e) {
      String err = e.toString().replaceAll('Exception: ', '');
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to fetch filtered products');
      catalogResponseModel = CatalogResponseModel(data: []);
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
