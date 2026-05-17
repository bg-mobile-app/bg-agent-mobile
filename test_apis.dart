import 'dart:convert';
import 'dart:io';

void main() async {
  final client = HttpClient();
  client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  
  var request = await client.getUrl(Uri.parse('https://demoapi.bideshgami.com/api/r/work-permits/home-permits/'));
  request.headers.set('X-API-KEY', 'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK');
  request.headers.set('Origin', 'https://demoapi.bideshgami.com');
  request.headers.set('Referer', 'https://demoapi.bideshgami.com/');
  request.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
  
  var response = await request.close();
  var responseBody = await response.transform(utf8.decoder).join();
  print('List Status: ${response.statusCode}');
  
  try {
    final List results = jsonDecode(responseBody);
    if (results.isNotEmpty) {
      final slug = results.first['slug'];
      print('Found slug: $slug');
      
      request = await client.getUrl(Uri.parse('https://demoapi.bideshgami.com/api/r/work-permits/$slug/'));
      request.headers.set('X-API-KEY', 'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK');
      request.headers.set('Origin', 'https://demoapi.bideshgami.com');
      request.headers.set('Referer', 'https://demoapi.bideshgami.com/');
      request.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
      
      response = await request.close();
      responseBody = await response.transform(utf8.decoder).join();
      print('Details Status: ${response.statusCode}');
      
      request = await client.getUrl(Uri.parse('https://demoapi.bideshgami.com/api/r/work-permits/$slug/related-permits/'));
      request.headers.set('X-API-KEY', 'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK');
      request.headers.set('Origin', 'https://demoapi.bideshgami.com');
      request.headers.set('Referer', 'https://demoapi.bideshgami.com/');
      request.headers.set('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36');
      
      response = await request.close();
      responseBody = await response.transform(utf8.decoder).join();
      print('Similar Status: ${response.statusCode}');
    }
  } catch (e) {
    print(e);
  }
}
