import 'package:bbnij/feature/notification/model/notification_category.dart';
import 'package:bbnij/feature/notification/model/notification_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  NotificationCategory resolve(String title, [String message = '', String? type]) =>
      NotificationCategory.resolve(type: type, title: title, message: message);

  test('API type wins over the text', () {
    expect(resolve('Hello', 'Your parcel is on the way', 'App\\Notifications\\PaymentReceived'), NotificationCategory.payment);
    expect(resolve('Hello', '', 'order_shipped'), NotificationCategory.order);
  });

  test('unknown type falls back to keywords in title and message', () {
    expect(resolve('New Order Dispatched', 'Order #ORD-1 picked up', 'App\\Notifications\\GeneralNotice'),
        NotificationCategory.order);
  });

  test('keyword categories', () {
    expect(resolve('KYC Verification Submitted'), NotificationCategory.verification);
    expect(resolve('Subscription Package Renewed'), NotificationCategory.subscription);
    expect(resolve('Security Alert: Password Updated'), NotificationCategory.security);
    expect(resolve('Payment received for order #12'), NotificationCategory.payment);
    expect(resolve('Withdrawal approved'), NotificationCategory.payment);
    expect(resolve('Low stock', 'Product X is running out'), NotificationCategory.product);
    expect(resolve('Eid offer', '20% discount this week'), NotificationCategory.promotion);
    expect(resolve('অর্ডার নিশ্চিত হয়েছে'), NotificationCategory.order);
  });

  test('wholesale is not a promotion', () {
    expect(resolve('Wholesale checkout confirmed'), NotificationCategory.general);
  });

  test('nothing recognisable is general', () {
    expect(resolve('Welcome to Banij'), NotificationCategory.general);
    expect(resolve(''), NotificationCategory.general);
  });

  test('model reads type and text from a nested Laravel data map', () {
    final item = NotificationItemModel.fromJson({
      'id': 'abc',
      'type': 'App\\Notifications\\OrderShipped',
      'data': {'title': 'Order shipped', 'message': 'On the way'},
      'created_at': '2026-11-27T10:00:00.000000Z',
      'read_at': null,
    });
    expect(item.type, 'App\\Notifications\\OrderShipped');
    expect(item.title, 'Order shipped');
    expect(item.description, 'On the way');
    expect(item.isRead, false);
  });
}
