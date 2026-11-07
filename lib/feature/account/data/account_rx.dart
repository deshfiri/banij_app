import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/account_model.dart';
import 'account_api.dart';

final class AccountRx extends RxResponseInt<AccountModel> {
  final AccountApi _api = AccountApi.instance;

  AccountRx()
      : super(
          empty: AccountModel(success: false, message: ''),
          dataFetcher: BehaviorSubject<AccountModel>(),
        );

  ValueStream get getAccountData => dataFetcher.stream;

  Future<AccountModel> fetchProfile() async {
    try {
      AccountModel data = await _api.getProfile();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<AccountModel> saveProfile(Map<String, dynamic> updateData) async {
    try {
      AccountModel data = await _api.updateProfile(updateData);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
