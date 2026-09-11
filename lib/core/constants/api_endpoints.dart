class ApiEndpoints {
  // 🔥 ضع IP جهاز اللابتوب الخاص بك هنا
  static const String baseUrl = 'http://192.168.43.194:45463/api';

  static const String login = "$baseUrl/Account/Login";
  static const String restaurants = "$baseUrl/Restaurants";

  static String restaurantFoods(int id) =>
      "$baseUrl/FoodDonations/MyRestaurant/$id";
  static const String availableFoods = "$baseUrl/FoodDonations/Available";
  static const String createPickup = "$baseUrl/PickupRequests";

  // مسار الطلبات
  static const String myRequests = "$baseUrl/PickupRequests/Beneficiary";
}
