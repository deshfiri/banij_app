import 'package:flutter/material.dart';

import '../feature/package/model/subscription_model.dart';
import '../helpers/error_message.dart';
import '../networks/api_access.dart';

/// State for the Subscription screen: loads `GET /subscription` and runs the
/// cancel / renew actions, refreshing the data afterwards.
class SubscriptionProvider extends ChangeNotifier {
  SubscriptionResponseModel? subscription;
  String? error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCancelling = false;
  bool get isCancelling => _isCancelling;

  bool _isRenewing = false;
  bool get isRenewing => _isRenewing;

  bool get isBusy => _isCancelling || _isRenewing;

  Future<void> fetchSubscription({bool force = false}) async {
    if (_isLoading || (subscription != null && !force)) return;
    _isLoading = true;
    error = null;
    notifyListeners();
    try {
      subscription = await subscriptionRxObj.fetchSubscription();
    } catch (e) {
      error = _message(e, 'Failed to load your subscription');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns null on success, otherwise the error message.
  Future<String?> cancelSubscription() async {
    if (isBusy) return null;
    _isCancelling = true;
    notifyListeners();
    try {
      await subscriptionRxObj.cancelSubscription();
      await fetchSubscription(force: true);
      return null;
    } catch (e) {
      return _message(e, 'Could not cancel the package');
    } finally {
      _isCancelling = false;
      notifyListeners();
    }
  }

  /// Returns null on success, otherwise the error message.
  Future<String?> renewSubscription() async {
    if (isBusy) return null;
    _isRenewing = true;
    notifyListeners();
    try {
      await subscriptionRxObj.renewSubscription();
      await fetchSubscription(force: true);
      return null;
    } catch (e) {
      return _message(e, 'Could not renew the package');
    } finally {
      _isRenewing = false;
      notifyListeners();
    }
  }

  void clear() {
    subscription = null;
    error = null;
    notifyListeners();
  }

  String _message(Object error, String fallback) {
    final message = error.apiErrorMessage;
    return message.isEmpty ? fallback : message;
  }
}
