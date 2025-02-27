// lib/core/network/api_client.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_endpoints.dart';
import '../errors/exceptions.dart';
import '../services/storage_service.dart';
import 'response_handler.dart';

class ApiClient {
  late Dio _dio;
  final StorageService _storageService;

  ApiClient(this._storageService) {
    _dio = _createDio();
    _addInterceptors();
  }

  Dio _createDio() {
    return Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(milliseconds: 30000),
        receiveTimeout: const Duration(milliseconds: 30000),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  void _addInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expired, logout and request login again
            await _storageService.deleteToken();
            // Navigate to login screen will be handled in the UI layer
            return handler.reject(error);
          }

          if (error.response?.statusCode == 403) {
            // Forbidden access
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'У вас нет доступа к этому ресурсу',
                type: DioExceptionType.badResponse,
                response: error.response,
              ),
            );
          }

          if (error.response?.statusCode == 422) {
            // Validation error
            final data = error.response?.data;
            String errorMessage = 'Ошибка валидации данных';

            if (data != null && data is Map && data.containsKey('errors')) {
              final errors = data['errors'];
              if (errors is Map) {
                final firstError = errors.entries.first;
                final errorList = firstError.value;
                if (errorList is List && errorList.isNotEmpty) {
                  errorMessage = errorList.first.toString();
                }
              }
            }

            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: errorMessage,
                type: DioExceptionType.badResponse,
                response: error.response,
              ),
            );
          }

          // Network errors
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              (error.error is SocketException)) {
            return handler.reject(
              DioException(
                requestOptions: error.requestOptions,
                error: 'Проверьте подключение к интернету',
                type: error.type,
                response: error.response,
              ),
            );
          }

          return handler.next(error);
        },
      ),
    );

    // Logging interceptor for debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
      ));
    }
  }

  // GET request
  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ResponseHandler.handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // POST request
  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
      return ResponseHandler.handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // PUT request
  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return ResponseHandler.handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // DELETE request
  Future<dynamic> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return ResponseHandler.handleResponse(response);
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  // Login request
  Future<dynamic> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {
          'username': username,
          'password': password,
          'grant_type': 'password',
          'client_id': 'mis-backend',
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );

      final data = ResponseHandler.handleResponse(response);

      if (data != null && data['access_token'] != null) {
        await _storageService.saveToken(data['access_token']);
      }

      return data;
    } on DioException catch (e) {
      _handleDioError(e);
    }
  }

  void _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        (e.error is SocketException)) {
      throw NetworkException('Проверьте подключение к интернету');
    }

    if (e.response != null) {
      if (e.response!.statusCode == 401) {
        throw AuthException('Неверный логин или пароль');
      } else if (e.response!.statusCode == 403) {
        throw AuthException('Доступ запрещен');
      } else {
        final errorMessage = e.error != null ? e.error.toString() : 'Произошла ошибка';
        throw ServerException(errorMessage);
      }
    } else {
      throw ServerException('Произошла неизвестная ошибка');
    }
  }
}