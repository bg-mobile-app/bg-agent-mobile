import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'api_exception.dart';

// Abstract class for cookie storage, to be implemented with your preferred storage
abstract class TokenStorage {
  Future<String?> getCookies();
  Future<void> saveCookies(String cookies);
  Future<void> clearCookies();
  Future<String?> getApiKey();
}

// Basic in-memory storage for demonstration. Replace with actual secure storage!
class InMemoryTokenStorage implements TokenStorage {
  String? _cookies;
  final String _apiKey = 'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK'; // Default API Key

  @override
  Future<String?> getCookies() async => _cookies;

  @override
  Future<void> saveCookies(String cookies) async {
    _cookies = cookies;
  }

  @override
  Future<void> clearCookies() async {
    _cookies = null;
  }

  @override
  Future<String?> getApiKey() async => _apiKey;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;
  late TokenStorage tokenStorage;
  final String baseUrl = 'https://demoapi.bideshgami.com/api/r'; // Replace with your base URL

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    tokenStorage = InMemoryTokenStorage(); // Use real storage implementation here
    
    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': 'https://demoapi.bideshgami.com',
        'Referer': 'https://demoapi.bideshgami.com/',
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
      },
    );

    _dio = Dio(options);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // 1. Add X-API-KEY
          final apiKey = await tokenStorage.getApiKey();
          if (apiKey != null) {
            options.headers['X-API-KEY'] = apiKey;
          }

          // 2. Attach cookies if they exist
          final cookies = await tokenStorage.getCookies();
          if (cookies != null && cookies.isNotEmpty) {
            options.headers['Cookie'] = cookies;
          }

          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Check for 401 Unauthorized
          if (e.response?.statusCode == 401) {
            debugPrint("401 Unauthorized caught. Attempting to refresh token...");
            final success = await _refreshToken();
            if (success) {
              try {
                // Retry the failed request with the new cookies
                final newCookies = await tokenStorage.getCookies();
                if (newCookies != null) {
                  e.requestOptions.headers['Cookie'] = newCookies;
                }
                
                // create a new dio instance to avoid interceptor infinite loops
                final retryDio = Dio(BaseOptions(baseUrl: baseUrl));
                final response = await retryDio.fetch(e.requestOptions);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            } else {
               debugPrint("Token refresh failed. User needs to login again.");
               await tokenStorage.clearCookies();
               // Here you might want to dispatch an event or use a global key to navigate to login screen
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshDio = Dio(BaseOptions(baseUrl: baseUrl));
      
      // Get current cookies to send with refresh request
      final currentCookies = await tokenStorage.getCookies();
      final apiKey = await tokenStorage.getApiKey();
      
      final headers = <String, dynamic>{
        'Content-Type': 'application/json',
      };
      if (currentCookies != null) headers['Cookie'] = currentCookies;
      if (apiKey != null) headers['X-API-KEY'] = apiKey;

      final response = await refreshDio.post(
        '/auth/token/refresh/',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // Extract new set-cookie header
        final setCookieHeaders = response.headers.map['set-cookie'];
        if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
           final cookies = setCookieHeaders.join('; ');
           await tokenStorage.saveCookies(cookies);
        }
        return true;
      }
      return false;
    } catch (e) {
       debugPrint("Exception during token refresh: $e");
       return false;
    }
  }

  // Extracts cookies from a response and saves them
  Future<void> saveCookiesFromResponse(Response response) async {
    final setCookieHeaders = response.headers.map['set-cookie'];
    if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
      // Combine multiple cookies into a single string for storage
      final cookieString = setCookieHeaders.join('; ');
      await tokenStorage.saveCookies(cookieString);
      debugPrint("Cookies saved successfully.");
    }
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.response != null) {
      return ApiException(
        message: e.response?.data?['message'] ?? e.message ?? 'Unknown error occurred',
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } else {
      return ApiException(
        message: e.message ?? 'Connection error',
      );
    }
  }
}
