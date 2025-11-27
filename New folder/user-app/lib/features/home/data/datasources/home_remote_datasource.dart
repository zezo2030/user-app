import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/home_response_model.dart';
import '../models/branch_model.dart';
import '../models/hall_model.dart';

abstract class HomeRemoteDataSource {
  Future<HomeResponseModel> getHomeData();
  Future<BranchModel> getBranchDetails(String branchId);
  Future<List<HallModel>> getHallsByBranch(String branchId);
  Future<HallModel> getHallDetails(String hallId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<HomeResponseModel> getHomeData() async {
    try {
      print('🔍 HomeDataSource: Making request to home endpoint');
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.homeEndpoint}',
      );

      print('🔍 HomeDataSource: Response received');
      print('🔍 HomeDataSource: Response status: ${response.statusCode}');
      print('🔍 HomeDataSource: Response data: ${response.data}');
      
      // Log branches data specifically
      if (response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;
        if (data['featuredBranches'] != null) {
          print('🔍 HomeDataSource: Featured branches data: ${data['featuredBranches']}');
          if (data['featuredBranches'] is List) {
            final branches = data['featuredBranches'] as List;
            for (int i = 0; i < branches.length; i++) {
              if (branches[i] is Map<String, dynamic>) {
                final branch = branches[i] as Map<String, dynamic>;
                print('🔍 HomeDataSource: Branch $i capacity: ${branch['capacity']} (type: ${branch['capacity'].runtimeType})');
              }
            }
          }
        }
      }

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      return HomeResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ HomeDataSource: DioException occurred: ${e.toString()}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ HomeDataSource: Unexpected error: ${e.toString()}');
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<BranchModel> getBranchDetails(String branchId) async {
    try {
      print('🔍 HomeDataSource: Making request to branch details endpoint for ID: $branchId');
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.branchDetailsEndpoint}/$branchId',
      );

      print('🔍 HomeDataSource: Branch details response received');
      print('🔍 HomeDataSource: Response status: ${response.statusCode}');
      print('🔍 HomeDataSource: Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Branch details response data is null');
      }

      return BranchModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ HomeDataSource: DioException occurred for branch details: ${e.toString()}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ HomeDataSource: Unexpected error for branch details: ${e.toString()}');
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<List<HallModel>> getHallsByBranch(String branchId) async {
    try {
      print('🔍 HomeDataSource: Making request to halls endpoint for branch: $branchId');
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.hallsEndpoint}',
        queryParameters: {'branchId': branchId},
      );

      print('🔍 HomeDataSource: Halls response received');
      print('🔍 HomeDataSource: Response status: ${response.statusCode}');
      print('🔍 HomeDataSource: Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      final List<dynamic> hallsData = response.data is List 
          ? response.data as List<dynamic>
          : [];
      
      return hallsData.map((hallJson) => HallModel.fromJson(hallJson)).toList();
    } on DioException catch (e) {
      print('❌ HomeDataSource: DioException occurred for halls: ${e.toString()}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ HomeDataSource: Unexpected error for halls: ${e.toString()}');
      throw Exception('Unexpected error: $e');
    }
  }

  @override
  Future<HallModel> getHallDetails(String hallId) async {
    try {
      print('🔍 HomeDataSource: Making request to hall details endpoint: $hallId');
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.hallsEndpoint}/$hallId',
      );

      print('🔍 HomeDataSource: Hall details response received');
      print('🔍 HomeDataSource: Response status: ${response.statusCode}');
      print('🔍 HomeDataSource: Response data: ${response.data}');

      if (response.data == null) {
        throw Exception('Response data is null');
      }

      return HallModel.fromJson(response.data);
    } on DioException catch (e) {
      print('❌ HomeDataSource: DioException occurred for hall details: ${e.toString()}');
      throw _handleDioException(e);
    } catch (e) {
      print('❌ HomeDataSource: Unexpected error for hall details: ${e.toString()}');
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
            return Exception('Bad request. Please try again.');
          case 401:
            return Exception('Unauthorized. Please login again.');
          case 403:
            return Exception('Forbidden. You don\'t have permission to access this resource.');
          case 404:
            return Exception('Resource not found.');
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
