import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'https://demoapi.bideshgami.com/api/r',
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // We might not need auth if it's open, but let's test.
    },
  ));

  try {
    final response = await dio.post(
      '/chat/conversations/',
      data: {
        "participant_name": "Customer1",
        "participant_role": "CUSTOMER",
        "receiver_role": "CALL_CENTER",
        "work_permit_id": "13"
      },
    );
    print('Success: \${response.statusCode}');
    print(response.data);
  } catch (e) {
    if (e is DioException) {
      print('DioError: \${e.response?.statusCode}');
      print(e.response?.data);
    } else {
      print(e);
    }
  }
}
