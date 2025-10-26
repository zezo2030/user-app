import 'package:dio/dio.dart';
import '../errors/failures.dart';

// String extensions
extension StringExtensions on String {
  // Check if string is a valid email
  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  // Check if string is a valid phone number
  bool get isValidPhone {
    final cleaned = replaceAll(RegExp(r'[^\d+]'), '');
    return cleaned.startsWith('+') && cleaned.length >= 11;
  }

  // Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  // Remove all whitespace
  String get removeWhitespace {
    return replaceAll(RegExp(r'\s+'), '');
  }
}

// DioException to Failure conversion
extension DioExceptionToFailure on DioException {
  Failure toFailure() {
    print('🔍 DioException type: ${type}');
    print('🔍 DioException message: ${message}');
    print('🔍 DioException response: ${response?.data}');
    print('🔍 DioException statusCode: ${response?.statusCode}');

    switch (type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure(
          message: 'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        final statusCode = response?.statusCode;
        final message = _getErrorMessage(statusCode);

        if (statusCode == 401) {
          return AuthenticationFailure(
            message: message,
            statusCode: statusCode,
          );
        } else if (statusCode == 400) {
          return ValidationFailure(message: message);
        } else {
          return ServerFailure(message: message, statusCode: statusCode);
        }

      case DioExceptionType.cancel:
        return const NetworkFailure(
          message: 'Request was cancelled.',
        );

      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message:
              'Unable to connect to server. Please check your internet connection.',
        );

      default:
        return UnknownFailure(message: message ?? 'An unknown error occurred.');
    }
  }

  String _getErrorMessage(int? statusCode) {
    print('🔍 Getting error message for statusCode: $statusCode');

    if (response?.data is Map<String, dynamic>) {
      final data = response!.data as Map<String, dynamic>;
      print('🔍 Server response data: $data');
      final message = data['message'] ?? 'Server error occurred.';
      print('🔍 Server error message: $message');
      return message;
    }

    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Unauthorized. Please login again.';
      case 403:
        return 'Forbidden. You do not have permission.';
      case 404:
        return 'Not found. The requested resource was not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Internal server error. Please try again later.';
      default:
        return 'An unknown error occurred.';
    }
  }
}
