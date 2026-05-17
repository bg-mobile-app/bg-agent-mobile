import 'dart:convert';
import 'dart:io';

import 'lib/features/search/models/work_permit_details.dart';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  
  var request = await client.getUrl(Uri.parse('https://demoapi.bideshgami.com/api/r/work-permits/home-permits/'));
  request.headers.set('X-API-KEY', 'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK');
  request.headers.set('Origin', 'https://demoapi.bideshgami.com');
  request.headers.set('Referer', 'https://demoapi.bideshgami.com/');
  request.headers.set('User-Agent', 'Mozilla/5.0');
  
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  
  try {
    final List results = jsonDecode(responseBody);
    if (results.isNotEmpty) {
      final slug = results.first['slug'];
      print('Testing slug: $slug');
      
      request = await client.getUrl(Uri.parse('https://demoapi.bideshgami.com/api/r/work-permits/$slug/'));
      request.headers.set('X-API-KEY', 'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK');
      request.headers.set('Origin', 'https://demoapi.bideshgami.com');
      request.headers.set('Referer', 'https://demoapi.bideshgami.com/');
      request.headers.set('User-Agent', 'Mozilla/5.0');
      
      response = await request.close();
      responseBody = await response.transform(utf8.decoder).join();
      
      try {
        final Map<String, dynamic> data = jsonDecode(responseBody);
        final details = WorkPermitDetails.fromJson(data);
        print('Successfully parsed details for: ${details.title}');
      } catch (e, stacktrace) {
        print('Error parsing details: $e');
        print(stacktrace);
      }
    }
  } catch (e) {
    print('Failed to fetch/parse home-permits: $e');
  }
}
