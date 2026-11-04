import 'package:flutter/material.dart';

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
  final List<NotificationItem> _notifications = [
    NotificationItem(
      id: '1',
      title: 'KYC Verification Submitted',
      message: 'Your KYC documents have been successfully submitted for review.',
      time: '10 mins ago',
      isRead: false,
      iconData: Icons.verified_user_outlined,
    ),
    NotificationItem(
      id: '2',
      title: 'New Order Dispatched',
      message: 'Order #ORD-2026-892 has been picked up by the delivery partner.',
      time: '2 hours ago',
      isRead: false,
      iconData: Icons.local_shipping_outlined,
    ),
    NotificationItem(
      id: '3',
      title: 'Subscription Package Renewed',
      message: 'Your Standard Business package was successfully renewed for 1 year.',
      time: '1 day ago',
      isRead: true,
      iconData: Icons.card_membership_outlined,
    ),
    NotificationItem(
      id: '4',
      title: 'Security Alert: Password Updated',
      message: 'Your account password was successfully updated from a trusted session.',
      time: '3 days ago',
      isRead: true,
      iconData: Icons.lock_outline_rounded,
    ),
  ];

  List<NotificationItem> get notifications => _notifications;

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
