// Booking Remote DataSource - Data Layer
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/booking_model.dart';
import '../models/booking_request_model.dart';
import '../models/quote_model.dart';
import '../models/quote_request_model.dart';
import '../models/hall_slots_model.dart';

abstract class BookingRemoteDataSource {
  Future<BookingModel> createBooking(BookingRequestModel request);
  Future<QuoteModel> getQuote(QuoteRequestModel request);
  Future<HallSlotsModel> getHallSlots({
    required String hallId,
    required String date,
    required int durationHours,
    int? slotMinutes,
    int? persons,
  });
  Future<bool> checkAvailability(
    String hallId,
    String startTime,
    int durationHours,
  );
  Future<bool> checkServerHealth();
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

  @override
  Future<QuoteModel> getQuote(QuoteRequestModel request) async {
    int retryCount = 0;
    const maxRetries = 3;

    while (retryCount < maxRetries) {
      try {
        print(
          '🔍 BookingDataSource: Making request to get quote (attempt ${retryCount + 1})',
        );
        final response = await dio.post(
          '${ApiConstants.baseUrl}/bookings/quote',
          data: request.toJson(),
        );

        print('🔍 BookingDataSource: Quote response received');
        print('🔍 BookingDataSource: Response status: ${response.statusCode}');
        print('🔍 BookingDataSource: Response data: ${response.data}');

        if (response.data == null) {
          throw Exception('Quote response data is null');
        }

        return QuoteModel.fromJson(response.data);
      } on DioException catch (e) {
        retryCount++;
        print(
          '❌ BookingDataSource: DioException occurred (attempt $retryCount): ${e.toString()}',
        );

        // إذا كان الخطأ 500 أو مشكلة في الشبكة، نحاول مرة أخرى
        if (e.response?.statusCode == 500 ||
            e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.connectionError) {
          if (retryCount >= maxRetries) {
            throw _handleDioException(e);
          }

          // انتظار قبل المحاولة مرة أخرى (exponential backoff)
          final delaySeconds = retryCount * 2;
          print('⏳ BookingDataSource: Retrying in $delaySeconds seconds...');
          await Future.delayed(Duration(seconds: delaySeconds));
          continue;
        } else {
          // للأخطاء الأخرى، لا نحاول مرة أخرى
          throw _handleDioException(e);
        }
      } catch (e) {
        print('❌ BookingDataSource: Unexpected error: ${e.toString()}');
        throw Exception('خطأ غير متوقع: $e');
      }
    }

    throw Exception('فشل في الحصول على عرض السعر بعد $maxRetries محاولات');
  }

  @override
  Future<HallSlotsModel> getHallSlots({
    required String hallId,
    required String date,
    required int durationHours,
    int? slotMinutes,
    int? persons,
  }) async {
    try {
      print('🔍 BookingDataSource: Fetching slots for hall $hallId on $date');
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.hallsEndpoint}/$hallId/slots',
        queryParameters: {
          'date': date,
          'durationHours': durationHours,
          if (slotMinutes != null) 'slotMinutes': slotMinutes,
          if (persons != null) 'persons': persons,
        },
      );

      print('🔍 BookingDataSource: Slots response status: ${response.statusCode}');
      print('🔍 BookingDataSource: Slots response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Slots response data is null');
      }

      return HallSlotsModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ BookingDataSource: DioException occurred while fetching slots: ${e.toString()}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ BookingDataSource: Unexpected error fetching slots: ${e.toString()}');
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<bool> checkAvailability(
    String hallId,
    String startTime,
    int durationHours,
  ) async {
    try {
      print('🔍 BookingDataSource: Making request to check availability');
      final response = await dio.get(
        '${ApiConstants.baseUrl}/content/halls/$hallId/availability',
        queryParameters: {
          'startTime': startTime,
          'durationHours': durationHours,
        },
      );

      print('🔍 BookingDataSource: Availability response received');
      print('🔍 BookingDataSource: Response status: ${response.statusCode}');
      print('🔍 BookingDataSource: Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Availability response data is null');
      }

      return response.data['available'] as bool;
    } on DioException catch (e) {
      print('❌ BookingDataSource: DioException occurred: ${e.toString()}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ BookingDataSource: Unexpected error: ${e.toString()}');
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<bool> checkServerHealth() async {
    try {
      print('🔍 BookingDataSource: Checking server health...');
      final response = await dio.get('${ApiConstants.baseUrl}/health');
      final isHealthy = response.statusCode == 200;
      print('🔍 BookingDataSource: Server health check result: $isHealthy');
      return isHealthy;
    } catch (e) {
      print('❌ BookingDataSource: Server health check failed: $e');
      return false;
    }
  }

  Exception _handleDioException(DioException e) {
    print(
      '❌ BookingDataSource: Handling DioException - Type: ${e.type}, Status: ${e.response?.statusCode}',
    );

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('انتهت مهلة الاتصال. يرجى التحقق من اتصال الإنترنت.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        print('❌ Response Status: $statusCode');
        print('❌ Response Data: $responseData');

        switch (statusCode) {
          case 400:
            return Exception(
              'طلب غير صحيح. يرجى التحقق من بيانات الحجز المرسلة.',
            );
          case 401:
            return Exception(
              'غير مصرح لك بالوصول. يرجى تسجيل الدخول مرة أخرى.',
            );
          case 403:
            return Exception('غير مسموح لك بإنشاء حجوزات.');
          case 404:
            return Exception('القاعة أو الفرع غير موجود.');
          case 409:
            return Exception('القاعة غير متاحة في الوقت المحدد.');
          case 500:
            return Exception(
              'خطأ في السيرفر. يرجى المحاولة لاحقاً أو التواصل مع الدعم الفني.',
            );
          default:
            return Exception('خطأ في السيرفر برمز الحالة: $statusCode');
        }
      case DioExceptionType.cancel:
        return Exception('تم إلغاء الطلب.');
      case DioExceptionType.connectionError:
        return Exception('لا يوجد اتصال بالإنترنت. يرجى التحقق من الشبكة.');
      default:
        return Exception('خطأ في الشبكة: ${e.message}');
    }
  }
}
