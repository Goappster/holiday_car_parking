import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "https://holidayscarparking.uk/api/", // Change this to your API URL
      // connectTimeout: Duration(seconds: 10),
      // receiveTimeout: Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // GET request with optional parameters
  Future<Response?> getRequest(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      Response response = await _dio.get(endpoint, queryParameters: queryParams);
      return response;
    } catch (e) {
      if (kDebugMode) {
        print("Error in GET request: $e");
      }
      return null;
    }
  }

  // POST request with parameters
  Future<Response?> postRequest(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      print("Error in POST request: $e");
      return null;
    }
  }



}
