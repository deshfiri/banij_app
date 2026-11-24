import 'package:flutter/material.dart';

import '../feature/notification/model/notification_model.dart';
import '../helpers/error_message.dart';
import '../networks/api_access.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  bool isRead;
  final IconData iconData;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.isRead = false,
    required this.iconData,
  });
}

class NotificationProvider extends ChangeNotifier {
  List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchNotifications() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final NotificationResponseModel res = await notificationRxObj
          .fetchNotifications();
      if (res.success == false) {
        throw Exception(res.message ?? 'Failed to load notifications');
      }

      _notifications = (res.data ?? const []).map((item) {
        return NotificationItem(
          id: item.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: item.title ?? 'Notification',
          message: item.description ?? item.message ?? '',
          time: item.createdAtHuman ?? item.time ?? '',
          isRead: item.isRead ?? false,
          iconData: Icons.notifications_active_outlined,
        );
      }).toList();
    } catch (error) {
      _error = error.apiErrorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }
}
