import 'dart:convert';

import 'package:crud_operations/source/remote/networking.dart';
import 'package:crud_operations/source/remote/url_constants.dart';
import 'package:crud_operations/ui/utils/api_response.dart';

class AuthRepo {
  static Future<ApiResponse> login(Map<String, dynamic> body) async {
    try {
      final response = await Networking.post(EndPoints.loginUrl, body);
      final res = await Networking.checkStatusCode(response);
      final result = jsonDecode(response.body);

      if (res == '') {
        return ApiResponse(
          message: result['message'],
          data: null,
          isSuccessful: false,
          inValidUser: false,
        );
      }
      return ApiResponse.fromJson(result);
    } catch (e) {
      return ApiResponse(
        message: e.toString(),
        data: null,
        isSuccessful: false,
        inValidUser: false,
      );
    }
  }
}
