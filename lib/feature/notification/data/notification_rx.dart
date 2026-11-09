import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/notification_model.dart';
import 'notification_api.dart';

final class NotificationRx extends RxResponseInt<NotificationResponseModel> {
  final NotificationApi _api = NotificationApi.instance;

  NotificationRx()
      : super(
          empty: NotificationResponseModel(success: false, message: ''),
          dataFetcher: BehaviorSubject<NotificationResponseModel>(),
        );

  ValueStream get getNotificationData => dataFetcher.stream;

  Future<NotificationResponseModel> fetchNotifications() async {
    try {
      NotificationResponseModel data = await _api.getNotifications();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
