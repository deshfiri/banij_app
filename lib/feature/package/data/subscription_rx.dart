import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/subscription_model.dart';
import 'subscription_api.dart';

final class SubscriptionRx extends RxResponseInt<SubscriptionResponseModel> {
  final SubscriptionApi _api = SubscriptionApi.instance;

  SubscriptionRx()
      : super(
          empty: const SubscriptionResponseModel(),
          dataFetcher: BehaviorSubject<SubscriptionResponseModel>(),
        );

  ValueStream<SubscriptionResponseModel> get getSubscriptionData => dataFetcher.stream;

  Future<SubscriptionResponseModel> fetchSubscription([String? endpoint]) async {
    try {
      SubscriptionResponseModel data = await _api.getSubscription(endpoint);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }

  Future<void> cancelSubscription() => _api.cancelSubscription();

  Future<bool> changeSubscription(String slug) async {
    return await _api.changeSubscription(slug);
  }

  Future<void> renewSubscription() => _api.renewSubscription();
}
