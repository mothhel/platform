import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_endpoints.dart'; // 🔥 استدعاء ملف الروابط

class ApiClient {
  late Dio dio;

  // تطبيق نمط Singleton لمنع تكرار الاتصالات
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  ApiClient._internal() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        validateStatus: (status) => true, // استلام كل الحالات لمعالجتها يدوياً
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('auth_token');
            if (token != null) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          } catch (e) {
            debugPrint("Error reading token: $e");
          }
          options.headers['Content-Type'] = 'application/json';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final statusCode = response.statusCode ?? 500;
          final data = response.data;

          // اكتشاف توقف الكنترولر (إرجاع صفحة HTML)
          if (data is String && data.trim().startsWith("<!DOCTYPE")) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error:
                    "عذراً، الخدمة غير موجودة أو الكنترولر متوقف من السيرفر (404).",
                type: DioExceptionType.badResponse,
              ),
            );
          }

          if (statusCode == 404) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: "عذراً، مسار الخدمة متوقف من السيرفر حالياً (404).",
                type: DioExceptionType.badResponse,
              ),
            );
          }

          if (statusCode >= 500) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: "عذراً، يوجد خطأ داخلي في السيرفر (500).",
                type: DioExceptionType.badResponse,
              ),
            );
          }

          if (statusCode >= 400 && statusCode < 500) {
            String msg = "بيانات غير صالحة ($statusCode).";
            if (data is Map && data.containsKey('message')) {
              msg = data['message'];
            }
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                error: msg,
                type: DioExceptionType.badResponse,
              ),
            );
          }

          return handler.next(response);
        },
        onError: (DioException e, handler) {
          String errorMsg = "تعذر الاتصال بالسيرفر. يرجى التحقق من تشغيله.";
          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout) {
            errorMsg = "انتهى وقت الاتصال بالسيرفر.";
          } else if (e.error != null) {
            errorMsg = e.error.toString();
          }
          return handler.reject(
            DioException(
              requestOptions: e.requestOptions,
              error: errorMsg,
              type: e.type,
            ),
          );
        },
      ),
    );
  }
}
