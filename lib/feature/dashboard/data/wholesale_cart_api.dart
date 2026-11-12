import 'dart:convert';
import 'package:dio/dio.dart';

import '../../../networks/dio/dio.dart';
import '../../../networks/endpoints.dart';
import '../../../networks/exception_handler/data_source.dart';
import '../model/wholesale_cart_model.dart';

final class WholesaleCartApi {
  static final WholesaleCartApi _singleton = WholesaleCartApi._internal();
  WholesaleCartApi._internal();
  static WholesaleCartApi get instance => _singleton;

  Future<WholesaleCartModel> getCart() async {
    try {
      Response response = await getHttp(EndPoints.wholesaleCart());

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return WholesaleCartModel.fromJson(response.data);
        } else if (response.data is String) {
          return WholesaleCartModel.fromRawJson(response.data);
        } else {
          return WholesaleCartModel.fromRawJson(json.encode(response.data));
        }
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

  Future<WholesaleCartModel> addCartItem(Map<String, dynamic> body) async {
    try {
      Response response = await postHttp(EndPoints.wholesaleCartItems(), body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return WholesaleCartModel.fromJson(response.data);
        } else if (response.data is String) {
          return WholesaleCartModel.fromRawJson(response.data);
        } else {
          return WholesaleCartModel.fromRawJson(json.encode(response.data));
        }
      } else {
        throw DataSource.DEFAULT.getFailure();
      }
    } on DioException catch (dioError) {
      if (dioError.response?.data != null) {
        final data = dioError.response?.data;
        if (data is Map) {
          if (data.containsKey('message')) {
            throw Exception(data['message'].toString());
          } else if (data.containsKey('error')) {
            throw Exception(data['error'].toString());
          }
        }
      }
      rethrow;
    } catch (error) {
      rethrow;
    }
  }

  Future<WholesaleCartModel> updateCartItemQuantity(String item, Map<String, dynamic> body) async {
    try {
      Response response = await patchHttp(EndPoints.wholesaleCartItemDetail(item), body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return WholesaleCartModel.fromJson(response.data);
        } else if (response.data is String) {
          return WholesaleCartModel.fromRawJson(response.data);
        } else {
          return WholesaleCartModel.fromRawJson(json.encode(response.data));
        }
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

  Future<WholesaleCartModel> deleteCartItem(String item) async {
    try {
      Response response = await deleteHttp(EndPoints.wholesaleCartItemDetail(item));

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        if (response.data != null && response.data is Map<String, dynamic>) {
          return WholesaleCartModel.fromJson(response.data);
        } else if (response.data is String) {
          return WholesaleCartModel.fromRawJson(response.data);
        } else {
          return await getCart();
        }
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

  Future<WholesaleCartModel> acceptCartPrices() async {
    try {
      Response response = await postHttp(EndPoints.wholesaleCartPrices(), {});

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data is Map<String, dynamic>) {
          return WholesaleCartModel.fromJson(response.data);
        } else if (response.data is String) {
          return WholesaleCartModel.fromRawJson(response.data);
        } else {
          return WholesaleCartModel.fromRawJson(json.encode(response.data));
        }
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
