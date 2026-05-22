import 'dart:convert';
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://demoapi.bideshgami.com/api/r',
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-API-KEY': 'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK',
    },
  ));

  try {
    // Try sending a list
    print('Sending a List...');
    final listResponse = await dio.post('/booking/wp/', data: [
      {
        'workPermit': 'test-slug',
        'name': 'Test',
      }
    ]);
    print('List Success: ${listResponse.data}');
  } on DioException catch (e) {
    print('List Error: ${e.response?.statusCode}');
    print('List Error Data: ${e.response?.data}');
  }

  try {
    // Try sending an object
    print('\nSending an Object...');
    final objResponse = await dio.post('/booking/wp/', data: {
        'workPermit': 'test-slug',
        'name': 'Test',
    });
    print('Object Success: ${objResponse.data}');
  } on DioException catch (e) {
    print('Object Error: ${e.response?.statusCode}');
    print('Object Error Data: ${e.response?.data}');
  }
}
