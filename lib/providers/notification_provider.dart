import 'package:flutter/material.dart';

import '../feature/notification/model/notification_category.dart';
import '../feature/notification/model/notification_model.dart';
import '../helpers/error_message.dart';
import '../networks/api_access.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;

  /// Human-readable time from the API ("2 hours ago").
  final String time;

  /// Parsed `created_at` in local time, used for Today/Yesterday grouping.
  /// Null when the API sends no parseable timestamp.
  final DateTime? createdAt;
  final NotificationCategory category;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.createdAt,
    this.isRead = false,
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

      final items = res.data ?? const <NotificationItemModel>[];
      _notifications = [
        for (var i = 0; i < items.length; i++) _toItem(items[i], i),
      ];
    } catch (error) {
      _error = error.apiErrorMessage;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  static NotificationItem _toItem(NotificationItemModel item, int index) {
    final title = item.title ?? 'Notification';
    final message = item.description ?? item.message ?? '';
    return NotificationItem(
      // Index fallback keeps ids unique so markAsRead hits the right item.
      id: item.id ?? 'local-$index',
      title: title,
      message: message,
      time: item.createdAtHuman ?? item.time ?? '',
      createdAt: DateTime.tryParse(item.createdAt ?? '')?.toLocal(),
      category: NotificationCategory.resolve(type: item.type, title: title, message: message),
      isRead: item.isRead ?? false,
    );
  }

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  /// Categories present in the current list, in [NotificationCategory] order.
  List<NotificationCategory> get categories {
    final present = _notifications.map((n) => n.category).toSet();
    return NotificationCategory.values.where(present.contains).toList();
  }

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
