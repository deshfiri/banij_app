import 'package:flutter/material.dart';

import '../feature/package/model/package_model.dart';
import '../helpers/error_message.dart';
import '../networks/api_access.dart';

/// State for the Packages screen: loads `GET /packages` and switches plans
/// with `POST /packages/{slug}/select`.
class PackagesProvider extends ChangeNotifier {
  PackageResponseModel? packages;
  String? error;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Slug of the plan currently being selected (null when idle).
  String? _selectingSlug;
  String? get selectingSlug => _selectingSlug;
  bool get isSelecting => _selectingSlug != null;

  Future<void> fetchPackages({bool force = false}) async {
    if (_isLoading || (packages != null && !force)) return;
    _isLoading = true;
    error = null;
    notifyListeners();
    try {
      packages = await packageRxObj.fetchPackages();
    } catch (e) {
      error = _message(e, 'Failed to load packages');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Result of the last successful selection (`selected_slug`, `next`).
  PackageSelectResultModel? lastSelection;

  /// Selects [slug]. Returns `(success, errorMessage)`; on success the list
  /// is reloaded so badges and the current plan update.
  Future<(bool, String?)> selectPackage(String slug) async {
    if (isSelecting) return (false, null);
    _selectingSlug = slug;
    notifyListeners();
    try {
      lastSelection = await packageRxObj.selectPackage(slug);
      _selectingSlug = null;
      await fetchPackages(force: true);
      return (true, null);
    } catch (e) {
      return (false, _message(e, 'Could not choose this plan'));
    } finally {
      _selectingSlug = null;
      notifyListeners();
    }
  }

  String _message(Object error, String fallback) {
    final message = error.apiErrorMessage;
    return message.isEmpty ? fallback : message;
  }
}
