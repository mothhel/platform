import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _currentUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;

  Future<UserModel?> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );

      final user = UserModel.fromJson(response.data as Map<String, dynamic>);
      _currentUser = user;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', user.token);
      await prefs.setString('user_role', user.role);

      _isLoading = false;
      notifyListeners();
      return user;
    } on DioException catch (e) {
      _errorMessage = e.error?.toString() ?? "بيانات الدخول غير صحيحة.";
    } catch (e) {
      _errorMessage = "حدث خطأ غير متوقع أثناء تسجيل الدخول.";
    }
    _isLoading = false;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
    _currentUser = null;
    notifyListeners();
  }
}
