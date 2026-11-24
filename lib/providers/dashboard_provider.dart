import 'package:flutter/material.dart';

import '../helpers/error_message.dart';
import '../feature/account/model/account_model.dart';
import '../feature/dashboard/model/address_model.dart';
import '../feature/dashboard/model/catalog_model.dart';
import '../feature/dashboard/model/checkout_model.dart';
import '../feature/dashboard/model/checkout_response_model.dart';
import '../feature/dashboard/model/dashboard_model.dart';
import '../feature/dashboard/model/my_product_model.dart';
import '../feature/dashboard/model/onboarding_model.dart';
import '../feature/dashboard/model/order_model.dart';
import '../feature/dashboard/model/payment_model.dart';
import '../feature/dashboard/model/wholesale_checkout_model.dart';
import '../feature/package/model/package_model.dart';
import '../helpers/toast.dart';
import '../networks/api_access.dart';
import '../networks/endpoints.dart';

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
  OrderItemModel? selectedOrderModel;
  bool _isLoadingOrderDetail = false;
  bool get isLoadingOrderDetail => _isLoadingOrderDetail;
  AccountModel? accountModel;
  OnboardingResponseModel? onboardingModel;

  WholesaleCheckoutResponseModel? wholesaleCheckoutModel;

  /// Message when `GET /wholesale/checkout` refused to quote (e.g. the cart
  /// needs attention). Null when the quote loaded.
  String? wholesaleCheckoutError;
  PaymentMethodResponseModel? paymentResponseModel;
  AddressResponseModel? addressResponseModel;
  AddressItemModel? selectedAddress;
  CheckoutResponseModel? checkoutResponseModel;

  bool _isLoadingCheckout = false;
  bool get isLoadingCheckout => _isLoadingCheckout;

  bool _isApplyingCoupon = false;
  bool get isApplyingCoupon => _isApplyingCoupon;

  /// Gateway value sent to `POST /checkout`. SSLCommerz by default; replaced
  /// by the first gateway `GET /checkout` offers when it lists any.
  static const String sslCommerzGateway = 'sslcommerz';
  String _selectedPaymentMethod = sslCommerzGateway;
  String get selectedPaymentMethod => _selectedPaymentMethod;

  int _orderQuantity = 1;
  int get orderQuantity => _orderQuantity;

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
    fetchOnboardingStatus();
  }

  bool _isLoadingProducts = false;
  bool get isLoadingProducts => _isLoadingProducts;

  bool _isLoadingOrders = false;
  bool get isLoadingOrders => _isLoadingOrders;

  void setSelectedPaymentMethod(String method) {
    _selectedPaymentMethod = method;
    notifyListeners();
  }

  void incrementOrderQuantity() {
    _orderQuantity++;
    notifyListeners();
  }

  void decrementOrderQuantity() {
    if (_orderQuantity > 1) {
      _orderQuantity--;
      notifyListeners();
    }
  }

  Future<void> fetchCheckoutState() async {
    _isLoadingCheckout = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        wholesaleCheckoutRxObj.fetchCheckout().then((value) {
          wholesaleCheckoutError = null;
          return value;
        }).catchError((Object e) {
          // e.g. 409 cart_not_ready: "Your cart needs attention before checkout."
          wholesaleCheckoutError = e.apiErrorMessage;
          return WholesaleCheckoutResponseModel();
        }),
        paymentRxObj.fetchPaymentMethods().catchError((_) => PaymentMethodResponseModel(data: [])),
        addressRxObj.fetchAddresses().catchError((_) => AddressResponseModel(data: [])),
        checkoutRxObj
            .fetchCheckoutDetails(coupon: _checkoutCouponCode)
            .catchError((_) => CheckoutResponseModel()),
      ]);

      if (results[0] is WholesaleCheckoutResponseModel) {
        wholesaleCheckoutModel = results[0] as WholesaleCheckoutResponseModel;
      }
      // Wholesale order: preselect an accepted payment method.
      final wholesaleMethods = wholesalePaymentMethods;
      if (wholesaleMethods.isNotEmpty && !wholesaleMethods.any((m) => m.value == _selectedPaymentMethod)) {
        _selectedPaymentMethod = _preferredMethod(wholesaleMethods).value;
      }
      if (results[1] is PaymentMethodResponseModel) {
        paymentResponseModel = results[1] as PaymentMethodResponseModel;
      }
      if (results[2] is AddressResponseModel) {
        addressResponseModel = results[2] as AddressResponseModel;
        final addresses = addressResponseModel?.data ?? [];
        if (addresses.isNotEmpty) {
          selectedAddress = addresses.firstWhere(
            (a) => a.isDefault == true,
            orElse: () => addresses.first,
          );
        }
      }
      if (results[3] is CheckoutResponseModel) {
        checkoutResponseModel = results[3] as CheckoutResponseModel;
        // Default to the first available gateway offered by /checkout.
        final available = checkoutGateways.where((g) => g.isAvailable).toList();
        if (available.isNotEmpty && !available.any((g) => g.value == _selectedPaymentMethod)) {
          _selectedPaymentMethod = available.first.value;
        }
      }
    } catch (_) {
    } finally {
      _isLoadingCheckout = false;
      notifyListeners();
    }
  }

  Future<void> applyWholesaleCoupon(String couponCode) async {
    if (couponCode.trim().isEmpty) return;
    _isApplyingCoupon = true;
    notifyListeners();
    try {
      wholesaleCheckoutModel = await wholesaleCheckoutRxObj.applyCoupon(couponCode);
      ToastUtil.showSuccessMessage('Coupon applied successfully');
    } catch (e) {
      String err = e.apiErrorMessage;
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to apply coupon');
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  Future<void> removeWholesaleCoupon() async {
    _isApplyingCoupon = true;
    notifyListeners();
    try {
      wholesaleCheckoutModel = await wholesaleCheckoutRxObj.removeCoupon();
      ToastUtil.showSuccessMessage('Coupon removed');
    } catch (_) {
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  Future<void> selectWholesaleAddress(AddressItemModel address) async {
    selectedAddress = address;
    notifyListeners();
    if (address.id != null) {
      try {
        wholesaleCheckoutModel = await wholesaleCheckoutRxObj.selectAddress(address.id.toString());
        ToastUtil.showSuccessMessage('Address updated for checkout');
      } catch (_) {}
    }
  }

  /// Payment methods the wholesale checkout accepts (from `GET /wholesale/checkout`).
  List<CheckoutGateway> get wholesalePaymentMethods =>
      (wholesaleCheckoutModel?.paymentMethods ?? const <CheckoutGateway>[]).where((m) => m.isAvailable).toList();

  /// `payment_method` to send: the selected one when the checkout accepts it,
  /// otherwise the SSLCommerz-like method, otherwise the first accepted one.
  String get _wholesalePaymentMethod {
    final methods = wholesalePaymentMethods;
    if (methods.isEmpty || methods.any((m) => m.value == _selectedPaymentMethod)) return _selectedPaymentMethod;
    return _preferredMethod(methods).value;
  }

  /// SSLCommerz (or any online gateway) first, else the first method.
  static CheckoutGateway _preferredMethod(List<CheckoutGateway> methods) => methods.firstWhere(
        (m) => m.value.toLowerCase().contains('ssl') || m.label.toLowerCase().contains('ssl'),
        orElse: () => methods.first,
      );

  /// SSLCommerz page to open after confirming a wholesale order, when the
  /// order must be paid online. Null for pay-later methods.
  String? get wholesalePaymentUrl => wholesaleCheckoutModel?.redirectUrl;

  Future<bool> confirmWholesaleOrder() async {
    _isLoadingCheckout = true;
    notifyListeners();
    try {
      // The fingerprint pins the quote being confirmed; reload it if missing.
      var fingerprint = wholesaleCheckoutModel?.fingerprint;
      if (fingerprint == null) {
        wholesaleCheckoutModel = await wholesaleCheckoutRxObj.fetchCheckout();
        fingerprint = wholesaleCheckoutModel?.fingerprint;
      }
      if (fingerprint == null) {
        ToastUtil.showErrorMessage('Checkout details are out of date. Please refresh and try again.');
        return false;
      }
      wholesaleCheckoutModel = await wholesaleCheckoutRxObj.confirmOrder(
        paymentMethod: _wholesalePaymentMethod,
        fingerprint: fingerprint,
      );
      if (wholesalePaymentUrl == null) ToastUtil.showSuccessMessage('Order confirmed successfully!');
      return true;
    } catch (e) {
      String err = e.apiErrorMessage;
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Order confirmation failed');
      return false;
    } finally {
      _isLoadingCheckout = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Package checkout payment (POST /checkout → gateway → GET /checkout/payment)
  // ---------------------------------------------------------------------------

  bool _isPaying = false;
  bool get isPaying => _isPaying;

  /// Gateways offered by `GET /checkout`.
  List<CheckoutGateway> get checkoutGateways => checkoutResponseModel?.data?.gatewayList ?? const [];

  /// True when `GET /checkout` returned a package to pay for, so "Place
  /// Order" must go through the payment gateway.
  bool get isPackageCheckout => checkoutResponseModel?.data?.package != null;

  /// `POST /checkout` with the selected gateway (and coupon, if any).
  /// Returns the gateway `redirect_url`, or null after showing the error.
  Future<String?> startCheckoutPayment({String? coupon}) async {
    if (_isPaying) return null;
    _isPaying = true;
    notifyListeners();
    try {
      final body = <String, dynamic>{
        'gateway': _selectedPaymentMethod,
        if (coupon != null && coupon.trim().isNotEmpty) 'coupon': coupon.trim(),
      };
      final result = await checkoutRxObj.pay(body);
      final url = result.redirectUrl;
      if (url == null || url.isEmpty) {
        // Nothing to open: either already settled or the API did not send a URL.
        if (result.isPaid) return '';
        ToastUtil.showErrorMessage(result.message ?? 'Payment page is not available. Please try again.');
        return null;
      }
      return url;
    } catch (e) {
      final err = e.apiErrorMessage;
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Could not start the payment');
      return null;
    } finally {
      _isPaying = false;
      notifyListeners();
    }
  }

  /// `GET /checkout/payment`. Returns null when the request itself failed.
  Future<CheckoutModel?> fetchCheckoutPaymentStatus() async {
    try {
      return await checkoutRxObj.paymentStatus();
    } catch (_) {
      return null;
    }
  }

  /// `POST /checkout/payment/verify` (no body) — asks the gateway right away,
  /// by the backend's own reference, whether the open payment went through.
  /// Answers like `GET /checkout/payment`. Null when the request failed.
  Future<CheckoutModel?> verifyCheckoutPayment() async {
    try {
      return await checkoutRxObj.verify();
    } catch (_) {
      return null;
    }
  }

  // ---- Package checkout coupon ----
  // The coupon is not stored server-side: `GET /checkout?coupon=` previews the
  // total with it, and `POST /checkout` receives it again when paying.

  String? _checkoutCouponCode;

  /// Coupon applied to the package checkout (kept in the app).
  String? get checkoutCoupon {
    final coupon = _checkoutCouponCode ?? checkoutResponseModel?.data?.coupon;
    return coupon == null || coupon.isEmpty || coupon == 'null' ? null : coupon;
  }

  /// Previews [code] with `GET /checkout?coupon=`; keeps it when accepted.
  Future<void> applyCheckoutCoupon(String code) async {
    if (code.trim().isEmpty || _isApplyingCoupon) return;
    _isApplyingCoupon = true;
    notifyListeners();
    try {
      checkoutResponseModel = await checkoutRxObj.fetchCheckoutDetails(coupon: code.trim());
      _checkoutCouponCode = code.trim();
      ToastUtil.showSuccessMessage('Coupon applied successfully');
    } catch (e) {
      final err = e.apiErrorMessage;
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Failed to apply coupon');
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

  /// Drops the coupon and reloads the quote without it.
  Future<void> removeCheckoutCoupon() async {
    if (_isApplyingCoupon) return;
    _isApplyingCoupon = true;
    _checkoutCouponCode = null;
    notifyListeners();
    try {
      checkoutResponseModel = await checkoutRxObj.fetchCheckoutDetails();
      ToastUtil.showSuccessMessage('Coupon removed');
    } catch (e) {
      final err = e.apiErrorMessage;
      ToastUtil.showErrorMessage(err.isNotEmpty ? err : 'Could not remove the coupon');
    } finally {
      _isApplyingCoupon = false;
      notifyListeners();
    }
  }

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
      String err = e.apiErrorMessage;
      if (err.isNotEmpty) {
        ToastUtil.showErrorMessage(err);
      }
    } finally {
      _isLoadingOrders = false;
      notifyListeners();
    }
  }

  Future<void> fetchOrderDetail(String orderId) async {
    _isLoadingOrderDetail = true;
    notifyListeners();
    try {
      selectedOrderModel = await orderRxObj.fetchOrderDetail(orderId);
    } catch (e) {
      String err = e.apiErrorMessage;
      if (err.isNotEmpty) {
        ToastUtil.showErrorMessage(err);
      }
    } finally {
      _isLoadingOrderDetail = false;
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
      String err = e.apiErrorMessage;
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
      String err = e.apiErrorMessage;
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
      String err = e.apiErrorMessage;
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
          _isKycSubmitted = true;
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

  Future<void> fetchOnboardingStatus() async {
    try {
      onboardingModel = await onboardingRxObj.fetchOnboardingStatus();
      if (onboardingModel?.data != null) {
        final data = onboardingModel!.data!;
        if (data.currentStep == 'approval' || data.isApproved) {
          _currentStep = 5;
        } else if (data.currentStep == 'package' || data.currentStep == 'payment') {
          _currentStep = 4;
        } else if (data.currentStep == 'kyc') {
          _currentStep = 3;
        }
      }
      notifyListeners();
    } catch (_) {}
  }
}
