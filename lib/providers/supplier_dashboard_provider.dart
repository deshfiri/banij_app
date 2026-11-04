import 'package:flutter/material.dart';

class SupplierDashboardProvider extends ChangeNotifier {
  String _activeDrawerItem = 'Application & KYC';

  String get activeDrawerItem => _activeDrawerItem;

  void setActiveDrawerItem(String item) {
    _activeDrawerItem = item;
    notifyListeners();
  }
}
