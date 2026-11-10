import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';

final class KycApi {
  static final KycApi _singleton = KycApi._internal();
  KycApi._internal();
  static KycApi get instance => _singleton;

  Future<Response> submitDocument({
    required String documentType,
    dynamic fileBytesOrPath,
    String? fileName,
    String? value,
  }) async {
    try {
      Map<String, dynamic> mapData = {
        "document_type": documentType,
        if (value != null && value.isNotEmpty) "value": value,
      };

      if (fileBytesOrPath != null) {
        if (fileBytesOrPath is String && fileBytesOrPath.isNotEmpty) {
          mapData["file"] = await MultipartFile.fromFile(
            fileBytesOrPath,
            filename: fileName ?? 'document.png',
          );
        } else if (fileBytesOrPath is List<int>) {
          mapData["file"] = MultipartFile.fromBytes(
            fileBytesOrPath,
            filename: fileName ?? 'document.png',
          );
        }
      }

      FormData formData = FormData.fromMap(mapData);

      Response response = await postHttp(EndPoints.submitDocKyc(), formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return response;
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } on DioException catch (dioError) {
      if (dioError.response?.data != null) {
        final data = dioError.response?.data;
        if (data is Map && data.containsKey('message')) {
          throw Exception(data['message'].toString());
        } else if (data is Map && data.containsKey('error')) {
          throw Exception(data['error'].toString());
        }
      }
      rethrow;
    } catch (error) {
      rethrow;
    }
  }
}
