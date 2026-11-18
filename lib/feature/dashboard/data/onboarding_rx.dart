import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/onboarding_model.dart';
import 'onboarding_api.dart';

final class OnboardingRx extends RxResponseInt<OnboardingResponseModel> {
  final OnboardingApi _api = OnboardingApi.instance;

  OnboardingRx()
      : super(
          empty: OnboardingResponseModel(),
          dataFetcher: BehaviorSubject<OnboardingResponseModel>(),
        );

  ValueStream<OnboardingResponseModel> get getOnboardingData => dataFetcher.stream;

  Future<OnboardingResponseModel> fetchOnboardingStatus() async {
    try {
      OnboardingResponseModel data = await _api.getOnboardingStatus();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
