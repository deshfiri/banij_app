import 'package:flutter/material.dart';

class SupplierDashboardProvider extends ChangeNotifier {
  String _activeDrawerItem = 'Application & KYC';
  int _currentIndex = 0;

  String get activeDrawerItem => _activeDrawerItem;
  int get currentIndex => _currentIndex;

  void setActiveDrawerItem(String item) {
    _activeDrawerItem = item;
    notifyListeners();
  }

  void setBottomNavIndex(int index) {
    if (index == 2) return; // Quick Action (+) button handled separately
    _currentIndex = index;
    notifyListeners();
  }
}
