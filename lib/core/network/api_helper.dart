import 'dart:io';
import 'package:dio/dio.dart';
import 'cache_helper.dart';
import 'end_points.dart';

class ApiHelper {
  static final ApiHelper _instance = ApiHelper._internal();
  factory ApiHelper() => _instance;
  ApiHelper._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: EndPoints.baseUrl,
  ));

  String? _accessToken;
  String? refreshToken;

  String? get accessToken {
    _accessToken ??= CacheHelper.getString(key: 'token');
    return _accessToken;
  }

  set accessToken(String? token) {
    _accessToken = token;
    if (token != null && token.isNotEmpty) {
      CacheHelper.saveData(key: 'token', value: token);
    } else {
      CacheHelper.removeData(key: 'token');
    }
  }

  Future<void> clearSession() async {
    _accessToken = null;
    refreshToken = null;
    await CacheHelper.removeData(key: 'token');
    await CacheHelper.removeData(key: 'username');
  }

  Future<dynamic> getImageData(String image) async {
    if (image.isEmpty) return '';
    if (File(image).existsSync()) {
      return await MultipartFile.fromFile(image);
    }
    return image;
  }

  Future<Response> postRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = true,
    bool isPrivate = false,
  }) async {
    return _dio.post(
      endPoint,
      data: data != null
          ? (isFormData ? FormData.fromMap(data) : data)
          : null,
      options: Options(
        headers: {
          if (isPrivate && accessToken != null)
            'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

  Future<Response> getRequest({
    required String endPoint,
    Map<String, dynamic>? queryParams,
    bool isPrivate = false,
  }) async {
    return _dio.get(
      endPoint,
      queryParameters: queryParams,
      options: Options(
        headers: {
          if (isPrivate && accessToken != null)
            'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

  Future<Response> putRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isFormData = true,
    bool isPrivate = false,
  }) async {
    return _dio.put(
      endPoint,
      data: data != null
          ? (isFormData ? FormData.fromMap(data) : data)
          : null,
      options: Options(
        headers: {
          if (isPrivate && accessToken != null)
            'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

  Future<Response> deleteRequest({
    required String endPoint,
    Map<String, dynamic>? data,
    bool isPrivate = false,
  }) async {
    return _dio.delete(
      endPoint,
      data: data,
      options: Options(
        headers: {
          if (isPrivate && accessToken != null)
            'Authorization': 'Bearer $accessToken',
        },
      ),
    );
  }

  String handleException(Object e) {
    String errorMsg = 'Invalid username or password.';
    if (e is DioException) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 400) {
        return 'Invalid username or password.';
      } else if (e.response?.data != null) {
        if (e.response?.data is Map<String, dynamic>) {
          var errorResponse = e.response?.data as Map<String, dynamic>;
          errorMsg = errorResponse['message'] ??
              errorResponse['error'] ??
              errorResponse['detail'] ??
              'Invalid username or password.';
        } else if (e.response?.data is String) {
          errorMsg = e.response?.data as String;
        }
      } else {
        errorMsg = 'Network error, please check your connection.';
      }
    }
    return errorMsg;
  }
}
