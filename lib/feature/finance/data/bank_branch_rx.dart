import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/bank_branch_model.dart';
import 'bank_branch_api.dart';

final class BankBranchRx extends RxResponseInt<BankBranchResponseModel> {
  static final BankBranchRx _singleton = BankBranchRx._internal();
  final BankBranchApi _api = BankBranchApi.instance;

  BankBranchRx._internal()
      : super(
          empty: BankBranchResponseModel(),
          dataFetcher: BehaviorSubject<BankBranchResponseModel>(),
        );
  static BankBranchRx get instance => _singleton;

  ValueStream get getBranchData => dataFetcher.stream;

  Future<BankBranchResponseModel> fetchBranches(String bankCode, {String? districtId}) async {
    try {
      BankBranchResponseModel data = await _api.getBranches(bankCode, districtId: districtId);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
