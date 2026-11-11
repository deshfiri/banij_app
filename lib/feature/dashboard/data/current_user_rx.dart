import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/current_user_model.dart';
import 'current_user_api.dart';

final class CurrentUserRx extends RxResponseInt<CurrentUserModel> {
  final CurrentUserApi _api = CurrentUserApi.instance;

  CurrentUserRx()
      : super(
          empty: CurrentUserModel(),
          dataFetcher: BehaviorSubject<CurrentUserModel>(),
        );

  ValueStream get getCurrentUserData => dataFetcher.stream;

  Future<CurrentUserModel> fetchCurrentUser() async {
    try {
      CurrentUserModel data = await _api.getCurrentUser();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
