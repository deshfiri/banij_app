import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/language_locale_model.dart';
import 'language_locale_api.dart';

final class LanguageLocaleRx extends RxResponseInt<LanguageLocaleResponseModel> {
  static final LanguageLocaleRx _singleton = LanguageLocaleRx._internal();
  final LanguageLocaleApi _api = LanguageLocaleApi.instance;

  LanguageLocaleRx._internal()
      : super(
          empty: LanguageLocaleResponseModel(),
          dataFetcher: BehaviorSubject<LanguageLocaleResponseModel>(),
        );
  static LanguageLocaleRx get instance => _singleton;

  ValueStream get getLanguageLocaleData => dataFetcher.stream;

  Future<LanguageLocaleResponseModel> fetchLanguageLocale() async {
    try {
      LanguageLocaleResponseModel data = await _api.getLanguageLocale();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<LanguageLocaleResponseModel> updateLanguageLocale(Map<String, dynamic> body) async {
    try {
      LanguageLocaleResponseModel data = await _api.updateLanguageLocale(body);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
