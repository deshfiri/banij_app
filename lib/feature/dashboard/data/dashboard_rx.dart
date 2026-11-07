import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/dashboard_model.dart';
import 'dashboard_api.dart';

final class DashboardRx extends RxResponseInt<DashboardModel> {
  final DashboardApi _api = DashboardApi.instance;

  DashboardRx()
      : super(
          empty: DashboardModel(success: false, message: ''),
          dataFetcher: BehaviorSubject<DashboardModel>(),
        );

  ValueStream get getDashboardData => dataFetcher.stream;

  Future<DashboardModel> fetchDashboardStats() async {
    try {
      DashboardModel data = await _api.getDashboardStats();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
