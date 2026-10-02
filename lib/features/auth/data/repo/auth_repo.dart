import 'package:dio/dio.dart';

import '../../../../core/network/api_helper.dart';
import '../../../../core/network/end_points.dart';

class AuthRepo {
  final ApiHelper _apiHelper;

  AuthRepo([ApiHelper? apiHelper]) : _apiHelper = apiHelper ?? ApiHelper();

  Future<Response> register({
    required String username,
    required String password,
    String? imagePath,
  }) async {
    try {
      final imageData = imagePath != null ? await _apiHelper.getImageData(imagePath) : '';
      final Map<String, dynamic> data = {
        'username': username,
        'password': password,
        'image': imageData,
      };

      final response = await _apiHelper.postRequest(
        endPoint: EndPoints.register,
        data: data,
        isFormData: true,
      );

      _extractAndSaveToken(response.data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _apiHelper.postRequest(
        endPoint: EndPoints.login,
        data: {
          'username': username,
          'password': password,
        },
        isFormData: true,
      );

      _extractAndSaveToken(response.data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  void _extractAndSaveToken(dynamic responseData) {
    if (responseData is Map) {
      final data = responseData;
      String? token = data['token']?.toString() ??
          data['access_token']?.toString() ??
          data['accessToken']?.toString();

      if (token == null && data['data'] != null) {
        if (data['data'] is Map) {
          final nestedData = data['data'] as Map;
          token = nestedData['token']?.toString() ??
              nestedData['access_token']?.toString() ??
              nestedData['accessToken']?.toString();
        } else if (data['data'] is String) {
          token = data['data'].toString();
        }
      }

      if (token == null && data['authorisation'] is Map) {
        token = data['authorisation']['token']?.toString();
      }

      if (token == null && data['user'] is Map) {
        token = data['user']['token']?.toString();
      }

      if (token != null && token.isNotEmpty) {
        _apiHelper.accessToken = token;
      }
    }
  }

  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      return await _apiHelper.postRequest(
        endPoint: EndPoints.changePassword,
        data: {
          'old_password': currentPassword,
          'new_password': newPassword,
        },
        isFormData: true,
        isPrivate: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> refreshToken({String? token}) async {
    try {
      final tokenToUse = token ?? _apiHelper.refreshToken;
      final response = await _apiHelper.postRequest(
        endPoint: EndPoints.refreshToken,
        data: {
          'refresh_token': tokenToUse,
        },
        isFormData: true,
        isPrivate: true,
      );

      _extractAndSaveToken(response.data);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> updateProfile({
    required String username,
    String? imagePath,
  }) async {
    try {
      final imageData = imagePath != null ? await _apiHelper.getImageData(imagePath) : '';
      final Map<String, dynamic> data = {
        'username': username,
        'image': imageData,
      };

      return await _apiHelper.putRequest(
        endPoint: EndPoints.updateProfile,
        data: data,
        isFormData: true,
        isPrivate: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> getUserData() async {
    try {
      return await _apiHelper.getRequest(
        endPoint: EndPoints.getUserData,
        isPrivate: true,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> deleteUser() async {
    try {
      return await _apiHelper.deleteRequest(
        endPoint: EndPoints.deleteUser,
        isPrivate: true,
      );
    } catch (e) {
      rethrow;
    }
  }
}
