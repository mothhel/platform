import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/constants/api_endpoints.dart';
import '../models/food_donation_model.dart';

class FoodProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  List<FoodDonationModel> _availableFoods = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<String> _restaurantMenuNames = [];
  bool _isMenuLoading = false;

  List<FoodDonationModel> get availableFoods => _availableFoods;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<String> get restaurantMenuNames => _restaurantMenuNames;
  bool get isMenuLoading => _isMenuLoading;

  int get totalAvailableFoods =>
      _availableFoods.fold(0, (sum, item) => sum + item.quantity);

  Map<String, List<FoodDonationModel>> get groupedFoods {
    Map<String, List<FoodDonationModel>> map = {};
    for (var food in _availableFoods) {
      if (!map.containsKey(food.restaurantName)) map[food.restaurantName] = [];
      map[food.restaurantName]!.add(food);
    }
    return map;
  }

  Future<void> fetchAvailableFoods() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.availableFoods);
      var responseData = response.data;
      List list = [];

      if (responseData is List) {
        list = responseData;
      } else if (responseData is Map) {
        list = responseData['\$values'] ?? responseData['data'] ?? [];
      }
      _availableFoods =
          list
              .map(
                (item) =>
                    FoodDonationModel.fromJson(item as Map<String, dynamic>),
              )
              .toList();
    } catch (e) {
      _errorMessage = "تعذر الاتصال بالسيرفر";
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> requestPickup({
    required int foodId,
    required int beneficiaryId,
    required int quantity,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.createPickup,
        data: {
          'foodDonationId': foodId,
          'beneficiaryId': beneficiaryId,
          'quantityRequested': quantity,
        },
      );
      await fetchAvailableFoods();
      return true;
    } on DioException catch (e) {
      throw Exception(e.error.toString()); // رمي الخطأ للواجهة
    } catch (e) {
      throw Exception("حدث خطأ أثناء الحجز.");
    }
  }

  Future<bool> addFoodDonation({
    required String foodName,
    required int quantity,
    required DateTime expiryTime,
    required int restaurantId,
    required String restaurantName,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final adjustedExpiry = DateTime(
        expiryTime.year,
        expiryTime.month,
        expiryTime.day,
        23,
        59,
        59,
      );
      final response = await _apiClient.dio.post(
        "/FoodDonations",
        data: {
          "FoodName": foodName,
          "Quantity": quantity,
          "ExpiryTime": adjustedExpiry.toIso8601String(),
          "RestaurantId": restaurantId,
          "RestaurantName": restaurantName,
        },
      );
      await fetchAvailableFoods();
      _isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception(e.error.toString()); // رمي الخطأ للواجهة
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception("حدث خطأ أثناء إضافة الوجبة.");
    }
  }

  Future<void> fetchRestaurantMenu({int? restaurantId}) async {
    _isMenuLoading = true;
    notifyListeners();
    try {
      final int restId = restaurantId ?? 1;
      final response = await _apiClient.dio.get(
        "/FoodCodes/Restaurant/$restId",
      );
      final data = response.data;
      List rawList =
          data is List
              ? data
              : (data is Map ? data['\$values'] ?? data['data'] ?? [] : []);
      _restaurantMenuNames =
          rawList
              .map((item) {
                if (item is Map)
                  return item['name']?.toString() ??
                      item['Name']?.toString() ??
                      item['foodName']?.toString() ??
                      item['FoodName']?.toString() ??
                      '';
                return item.toString();
              })
              .where((name) => name.isNotEmpty)
              .toList();
    } catch (e) {
      debugPrint("❌ Menu Error: $e");
    }
    _isMenuLoading = false;
    notifyListeners();
  }
}
