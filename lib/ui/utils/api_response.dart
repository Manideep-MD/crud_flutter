import 'package:flutter/foundation.dart';

class ApiResponse {
  final String message;
  final dynamic data;
  final bool isSuccessful;
  final bool inValidUser;

  ApiResponse({
    required this.message,
    required this.data,
    required this.isSuccessful,
    required this.inValidUser,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      message: json['message'],
      data: json['data'],
      isSuccessful:
          (json['statusCode'] == 200 ||
              json['statusCode'] == 201 ||
              json['statusCode'] == 202)
          ? true
          : false,
      inValidUser: json['statusCode'] == 401 ? true : false,
    );
  }
}
