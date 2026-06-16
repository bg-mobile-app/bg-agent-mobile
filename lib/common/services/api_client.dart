import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  final String _apiKey =
      'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK'; // Default API Key

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

// Persistent cookie storage implementation using SharedPreferences
class SharedPreferencesTokenStorage implements TokenStorage {
  static const String _cookieKey = 'auth_cookies';
  final String _apiKey =
      'eef0787fa713f76_mobile_app_key_2026 xsmtpsib-206808a735e9f7cdbff5b-cMceaL6wYHHzIFkK';

  @override
  Future<String?> getCookies() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cookieKey);
  }

  @override
  Future<void> saveCookies(String cookies) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cookieKey, cookies);
  }

  @override
  Future<void> clearCookies() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cookieKey);
  }

  @override
  Future<String?> getApiKey() async => _apiKey;
}

class _ResponseCacheEntry {
  _ResponseCacheEntry({required this.response, required this.expiresAt});

  final Response response;
  final DateTime expiresAt;

  bool get isFresh => DateTime.now().isBefore(expiresAt);
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;
  late TokenStorage tokenStorage;
  final String baseUrl =
      'https://demoapi.bideshgami.com/api/r'; // Replace with your base URL
  final Map<String, _ResponseCacheEntry> _responseCache = {};
  final Duration defaultCacheDuration = const Duration(minutes: 2);

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    tokenStorage =
        SharedPreferencesTokenStorage(); // Use real storage implementation here

    BaseOptions options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': 'https://demoapi.bideshgami.com',
        'Referer': 'https://demoapi.bideshgami.com/',
        'User-Agent':
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
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

            // Extract csrftoken and set it as X-CSRFToken header
            final cookiesMap = _parseCookieString(cookies);
            final csrfToken = cookiesMap['csrftoken'];
            if (csrfToken != null) {
              options.headers['X-CSRFToken'] = csrfToken;
            }
          }

          return handler.next(options);
        },
        onResponse: (response, handler) async {
          final setCookieHeaders = response.headers['set-cookie'];
          if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
            await _updateAndSaveCookies(setCookieHeaders);
          }
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          // Check for 401 Unauthorized
          if (e.response?.statusCode == 401) {
            debugPrint(
              "401 Unauthorized caught. Attempting to refresh token...",
            );
            final success = await _refreshToken();
            if (success) {
              try {
                // Retry the failed request with the new cookies
                final newCookies = await tokenStorage.getCookies();
                if (newCookies != null) {
                  e.requestOptions.headers['Cookie'] = newCookies;

                  // Also extract and update CSRF Token header for the retried request
                  final cookiesMap = _parseCookieString(newCookies);
                  final csrfToken = cookiesMap['csrftoken'];
                  if (csrfToken != null) {
                    e.requestOptions.headers['X-CSRFToken'] = csrfToken;
                  }
                }

                // create a new dio instance to avoid interceptor infinite loops
                final retryDio = Dio(
                  BaseOptions(
                    baseUrl: baseUrl,
                    connectTimeout: const Duration(seconds: 30),
                    receiveTimeout: const Duration(seconds: 30),
                    headers: {
                      'Content-Type': 'application/json',
                      'Accept': 'application/json',
                      'Origin': 'https://demoapi.bideshgami.com',
                      'Referer': 'https://demoapi.bideshgami.com/',
                      'User-Agent':
                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
                    },
                  ),
                );
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
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Origin': 'https://demoapi.bideshgami.com',
            'Referer': 'https://demoapi.bideshgami.com/',
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          },
        ),
      );

      // Get current cookies to send with refresh request
      final currentCookies = await tokenStorage.getCookies();
      final apiKey = await tokenStorage.getApiKey();

      final headers = <String, dynamic>{};
      if (currentCookies != null) {
        headers['Cookie'] = currentCookies;
        final cookiesMap = _parseCookieString(currentCookies);
        final csrfToken = cookiesMap['csrftoken'];
        if (csrfToken != null) {
          headers['X-CSRFToken'] = csrfToken;
        }
      }
      if (apiKey != null) headers['X-API-KEY'] = apiKey;

      final response = await refreshDio.post(
        '$baseUrl/auth/token/refresh/',
        options: Options(headers: headers),
      );

      if (response.statusCode == 200) {
        // Extract new set-cookie header case-insensitively
        final setCookieHeaders = response.headers['set-cookie'];
        if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
          await _updateAndSaveCookies(setCookieHeaders);
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
    final setCookieHeaders = response.headers['set-cookie'];
    if (setCookieHeaders != null && setCookieHeaders.isNotEmpty) {
      await _updateAndSaveCookies(setCookieHeaders);
      return;
    }

    debugPrint(
      'saveCookiesFromResponse: no set-cookie headers found on response for '
      '${response.requestOptions.path}. This may mean the backend is not returning cookie-based auth.',
    );
  }

  Map<String, String> _parseCookieString(String cookieString) {
    final Map<String, String> cookies = {};
    final pairs = cookieString.split(';');
    for (var pair in pairs) {
      final trimmed = pair.trim();
      if (trimmed.isEmpty) continue;
      final eqIndex = trimmed.indexOf('=');
      if (eqIndex != -1) {
        final key = trimmed.substring(0, eqIndex).trim();
        final value = trimmed.substring(eqIndex + 1).trim();
        if (key.isNotEmpty) {
          cookies[key] = value;
        }
      }
    }
    return cookies;
  }

  String _serializeCookies(Map<String, String> cookies) {
    return cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
  }

  Future<void> _updateAndSaveCookies(List<String> setCookieHeaders) async {
    final existingCookieStr = await tokenStorage.getCookies() ?? '';
    final cookiesMap = _parseCookieString(existingCookieStr);

    for (var header in setCookieHeaders) {
      if (header.trim().isEmpty) continue;
      final parts = header.split(';');
      if (parts.isNotEmpty) {
        final pair = parts[0].trim();
        final eqIndex = pair.indexOf('=');
        if (eqIndex != -1) {
          final key = pair.substring(0, eqIndex).trim();
          final value = pair.substring(eqIndex + 1).trim();
          if (key.isNotEmpty) {
            // Check for cookie deletion instructions from the server
            final isExpired =
                value.isEmpty ||
                value.toLowerCase() == 'deleted' ||
                header.contains('Max-Age=0') ||
                header.contains('expires=Thu, 01 Jan 1970');
            if (isExpired) {
              cookiesMap.remove(key);
            } else {
              cookiesMap[key] = value;
            }
          }
        }
      }
    }

    final mergedCookieStr = _serializeCookies(cookiesMap);
    await tokenStorage.saveCookies(mergedCookieStr);
    clearResponseCache();
    debugPrint("Cookie jar updated persistent storage: $mergedCookieStr");
  }

  Dio get dio => _dio;

  void clearResponseCache() {
    _responseCache.clear();
  }

  Future<String> _cacheKey(
    String path,
    Map<String, dynamic>? queryParameters,
  ) async {
    final cookies = await tokenStorage.getCookies() ?? '';
    final buffer = StringBuffer('${cookies.hashCode}:$path');
    if (queryParameters != null && queryParameters.isNotEmpty) {
      final keys = queryParameters.keys.map((key) => key.toString()).toList()
        ..sort();
      final encodedQuery = keys
          .map((key) {
            final value = queryParameters[key];
            return '${Uri.encodeQueryComponent(key)}='
                '${Uri.encodeQueryComponent(value?.toString() ?? '')}';
          })
          .join('&');
      buffer.write('?');
      buffer.write(encodedQuery);
    }
    return buffer.toString();
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useCache = true,
    bool forceRefresh = false,
    Duration? cacheDuration,
  }) async {
    final key = await _cacheKey(path, queryParameters);
    if (useCache && !forceRefresh) {
      final cached = _responseCache[key];
      if (cached != null && cached.isFresh) {
        return cached.response;
      }
    }

    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      if (useCache &&
          response.statusCode != null &&
          response.statusCode! < 400) {
        _responseCache[key] = _ResponseCacheEntry(
          response: response,
          expiresAt: DateTime.now().add(cacheDuration ?? defaultCacheDuration),
        );
      }
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      clearResponseCache();
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      clearResponseCache();
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      clearResponseCache();
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      clearResponseCache();
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.response != null) {
      return ApiException(
        message: _extractErrorMessage(e.response?.data, e.message),
        statusCode: e.response?.statusCode,
        data: e.response?.data,
      );
    } else {
      return ApiException(message: e.message ?? 'Connection error');
    }
  }

  String _extractErrorMessage(dynamic data, String? fallback) {
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final messages = <String>[];
        for (final entry in errors.entries) {
          final field = entry.key.toString();
          final value = entry.value;
          if (value is List) {
            messages.add('$field: ${value.join(', ')}');
          } else {
            messages.add('$field: $value');
          }
        }
        return messages.join('\n');
      }

      final message = data['message'];
      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    if (data is String && data.trim().isNotEmpty) return data;
    return fallback ?? 'Unknown error occurred';
  }
}
