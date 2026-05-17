import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  
  final request = await client.postUrl(Uri.parse('https://demoapi.bideshgami.com/api/r/auth/login/'));
  request.headers.set('X-API-KEY', 'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK');
  request.headers.set('Origin', 'https://demoapi.bideshgami.com');
  request.headers.set('Referer', 'https://demoapi.bideshgami.com/');
  request.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/120.0.0.0 Safari/537.36');
  request.headers.set('Content-Type', 'application/json');
  
  request.write(jsonEncode({"username":"fake","password":"fake"}));
  
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  print('Status: ${response.statusCode}');
  print('Body: $responseBody');
}
