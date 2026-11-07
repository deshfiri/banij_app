import 'dart:convert';

class LoginResponse {
  final bool? success;
  final String? message;
  final String? token;
  final Map<String, dynamic>? data;

  LoginResponse({
    this.success,
    this.message,
    this.token,
    this.data,
  });

  factory LoginResponse.fromRawJson(String str) =>
      LoginResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
        success: json["success"],
        message: json["message"],
        token: json["token"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "token": token,
        "data": data,
      };
}

class RegisterResponse {
  final bool? success;
  final String? message;
  final String? token;
  final Map<String, dynamic>? data;

  RegisterResponse({
    this.success,
    this.message,
    this.token,
    this.data,
  });

  factory RegisterResponse.fromRawJson(String str) =>
      RegisterResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RegisterResponse.fromJson(Map<String, dynamic> json) => RegisterResponse(
        success: json["success"],
        message: json["message"],
        token: json["token"],
        data: json["data"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "token": token,
        "data": data,
      };
}
