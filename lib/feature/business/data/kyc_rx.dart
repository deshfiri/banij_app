import 'package:dio/dio.dart';
import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import 'kyc_api.dart';

final class KycRx extends RxResponseInt<Response> {
  final KycApi _api = KycApi.instance;

  KycRx()
      : super(
          empty: Response(requestOptions: RequestOptions(path: '')),
          dataFetcher: BehaviorSubject<Response>(),
        );

  ValueStream get getKycData => dataFetcher.stream;

  Future<Response> submitDoc({
    required String documentType,
    dynamic fileBytesOrPath,
    String? fileName,
    String? value,
  }) async {
    try {
      Response data = await _api.submitDocument(
        documentType: documentType,
        fileBytesOrPath: fileBytesOrPath,
        fileName: fileName,
        value: value,
      );
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
