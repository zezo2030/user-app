// Booking Remote DataSource - Data Layer
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/booking_model.dart';
import '../models/booking_request_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(BookingRequestModel request);
}

class BookingRemoteDataSourceImpl implements BookingRemoteDataSource {
  final Dio dio;

  BookingRemoteDataSourceImpl({required this.dio});

  @override
  Future<BookingModel> createBooking(BookingRequestModel request) async {
    try {
      print('🔍 BookingDataSource: Making request to create booking');
      final response = await dio.post(
        '${ApiConstants.baseUrl}/bookings',
        data: request.toJson(),
      );

      print('🔍 BookingDataSource: Booking response received');
      print('🔍 BookingDataSource: Response status: ${response.statusCode}');
      print('🔍 BookingDataSource: Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Booking response data is null');
      }

      return BookingModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ BookingDataSource: DioException occurred: ${e.toString()}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ BookingDataSource: Unexpected error: ${e.toString()}');
      throw Exception('Unexpected error: $e');
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        switch (statusCode) {
          case 400:
            return Exception('Bad request. Please check your booking details.');
          case 401:
            return Exception('Unauthorized. Please login again.');
          case 403:
            return Exception('Forbidden. You don\'t have permission to create bookings.');
          case 404:
            return Exception('Hall or branch not found.');
          case 409:
            return Exception('Hall is not available for the selected time.');
          case 500:
            return Exception('Server error. Please try again later.');
          default:
            return Exception('Server error with status code: $statusCode');
        }
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.connectionError:
        return Exception('No internet connection. Please check your network.');
      default:
        return Exception('Network error: ${e.message}');
    }
  }
}
