class FoodDonationModel {
  final int id;
  final String foodName;
  final int quantity;
  final DateTime? expiryTime;
  final int restaurantId;
  final String restaurantName;

  FoodDonationModel({
    required this.id,
    required this.foodName,
    required this.quantity,
    this.expiryTime,
    required this.restaurantId,
    required this.restaurantName,
  });

  factory FoodDonationModel.fromJson(Map<String, dynamic> json) {
    final rawExpiry = json['expiryTime'] ?? json['ExpiryTime'];
    DateTime? parsedExpiry;
    if (rawExpiry != null) {
      parsedExpiry = DateTime.tryParse(rawExpiry.toString());
    }

    return FoodDonationModel(
      id:
          json['foodDonationId'] ??
          json['FoodDonationId'] ??
          json['id'] ??
          json['Id'] ??
          0,
      foodName: json['foodName'] ?? json['FoodName'] ?? 'وجبة',
      quantity: json['quantity'] ?? json['Quantity'] ?? 0,
      expiryTime: parsedExpiry,
      restaurantId:
          json['restaurantId'] ??
          json['RestaurantId'] ??
          json['restaurant_id'] ??
          0,
      restaurantName:
          json['restaurantName'] ??
          json['RestaurantName'] ??
          json['restaurant']?['name'] ??
          'مطعم مشارك',
    );
  }
}
