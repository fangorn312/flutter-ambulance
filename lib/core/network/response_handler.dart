import 'dart:convert';
import 'package:dio/dio.dart';
import '../errors/exceptions.dart';

class ResponseHandler {
  static dynamic handleResponse(Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return response.data;
      case 400:
        throw ServerException('Bad request: ${_extractErrorMessage(response)}');
      case 401:
        throw AuthException('Unauthorized: ${_extractErrorMessage(response)}');
      case 403:
        throw ServerException('Forbidden: ${_extractErrorMessage(response)}');
      case 404:
        throw ServerException('Not found: ${_extractErrorMessage(response)}');
      case 500:
      default:
        throw ServerException('Server error: ${_extractErrorMessage(response)}');
    }
  }

  static String _extractErrorMessage(Response response) {
    try {
      if (response.data is String) {
        return response.data;
      } else if (response.data is Map) {
        return response.data['message'] ?? 'Unknown error';
      } else {
        return 'Unknown error';
      }
    } catch (e) {
      return 'Error parsing error message';
    }
  }
} 
