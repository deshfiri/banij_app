import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/location_division_model.dart';
import 'location_child_api.dart';

final class LocationChildRx extends RxResponseInt<LocationDivisionModel> {
  final LocationChildApi _api = LocationChildApi.instance;

  LocationChildRx()
      : super(
          empty: LocationDivisionModel(),
          dataFetcher: BehaviorSubject<LocationDivisionModel>(),
        );

  ValueStream get getLocationChildData => dataFetcher.stream;

  Future<LocationDivisionModel> fetchChildren(String type, String sourceId) async {
    try {
      LocationDivisionModel data = await _api.getLocationChildren(type, sourceId);
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
