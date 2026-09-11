import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/restaurant_model.dart';
import '../models/food_donation_model.dart';

class RestaurantProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<RestaurantModel> _restaurants = [];
  List<FoodDonationModel> _selectedRestaurantFoods = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RestaurantModel> get restaurants => _restaurants;
  List<FoodDonationModel> get selectedRestaurantFoods =>
      _selectedRestaurantFoods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiClient.dio.get(ApiEndpoints.restaurants);

      if (response.statusCode == 200) {
        var responseData = response.data;
        List list = [];

        if (responseData is List) {
          list = responseData;
        } else if (responseData is Map) {
          list = responseData['\$values'] ?? responseData['data'] ?? [];
        }

        _restaurants =
            list
                .map(
                  (item) =>
                      RestaurantModel.fromJson(item as Map<String, dynamic>),
                )
                .toList();
      }
    } on DioException catch (e) {
      _errorMessage =
          e.error?.toString() ?? "تعذر جلب المطاعم بسبب توقف الخدمة.";
      debugPrint("❌ Error fetching restaurants (DioException): $e");
    } catch (e) {
      _errorMessage = "تعذر جلب المطاعم: حدث خطأ غير متوقع.";
      debugPrint("❌ Error fetching restaurants: $e");
    }

    _isLoading = false;
    notifyListeners();
  }
}
