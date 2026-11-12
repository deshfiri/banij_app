import 'package:rxdart/rxdart.dart';

import '../../../networks/rx_base.dart';
import '../model/location_division_model.dart';
import 'location_division_api.dart';

final class LocationDivisionRx extends RxResponseInt<LocationDivisionModel> {
  final LocationDivisionApi _api = LocationDivisionApi.instance;

  LocationDivisionRx()
      : super(
          empty: LocationDivisionModel(),
          dataFetcher: BehaviorSubject<LocationDivisionModel>(),
        );

  ValueStream get getLocationDivisionData => dataFetcher.stream;

  Future<LocationDivisionModel> fetchDivisions() async {
    try {
      LocationDivisionModel data = await _api.getDivisions();
      return handleSuccessWithReturn(data);
    } catch (error) {
      return handleErrorWithReturn(error);
    }
  }
}
