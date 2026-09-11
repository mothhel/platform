import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/request_item_model.dart';

class RequestProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  List<RequestItemModel> _allRequests = [];
  List<RequestItemModel> _pendingRequests = [];
  List<RequestItemModel> _deliveredRequests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RequestItemModel> get allRequests => _allRequests;
  List<RequestItemModel> get pendingRequests => _pendingRequests;
  List<RequestItemModel> get deliveredRequests => _deliveredRequests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchMyRequests(int id, {bool isRestaurant = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final String endpoint =
          isRestaurant
              ? "/RestaurantDashboard/GetMyRequests/$id"
              : "/BeneficiaryDashboard/GetMyRequests/$id";
      final response = await _apiClient.dio.get(endpoint);
      var data = response.data;
      List list =
          data is List
              ? data
              : (data is Map ? data['\$values'] ?? data['data'] ?? [] : []);
      _allRequests =
          list
              .map(
                (item) =>
                    RequestItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      String normalize(String st) => st
          .toString()
          .trim()
          .toLowerCase()
          .replaceAll('أ', 'ا')
          .replaceAll('إ', 'ا')
          .replaceAll('آ', 'ا');
      _pendingRequests =
          _allRequests.where((r) {
            final st = normalize(r.status);
            return st == "pending" ||
                st == "قيد الانتظار" ||
                st == "0" ||
                st == "انتظار";
          }).toList();
      _deliveredRequests =
          _allRequests.where((r) {
            final st = normalize(r.status);
            return st == "delivered" ||
                st == "مستلمة" ||
                st == "مكتملة" ||
                st == "1" ||
                st == "تم التسليم";
          }).toList();
    } catch (e) {
      _errorMessage = "تعذر جلب الطلبات.";
    }
    _isLoading = false;
    notifyListeners();
  }

  // 🔥 دالة تأكيد التسليم محمية
  Future<bool> confirmDelivery({
    required int requestId,
    required String receiverName,
    required int restaurantId,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        "/RestaurantDashboard/ConfirmDelivery",
        data: {"requestId": requestId, "receiverName": receiverName},
      );
      await fetchMyRequests(restaurantId, isRestaurant: true);
      return true;
    } on DioException catch (e) {
      throw Exception(e.error.toString()); // رمي الخطأ للشاشة
    } catch (e) {
      throw Exception("حدث خطأ أثناء التأكيد.");
    }
  }
}
