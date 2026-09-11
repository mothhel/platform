class RestaurantModel {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final bool isActive;

  RestaurantModel({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    required this.isActive,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      // التقاط المعرف بجميع الصيغ المحتملة من .NET
      id:
          json['restaurantId'] ??
          json['RestaurantId'] ??
          json['id'] ??
          json['Id'] ??
          0,
      name:
          json['name'] ??
          json['Name'] ??
          json['restaurantName'] ??
          json['RestaurantName'] ??
          'مطعم غير معروف',
      address:
          json['location'] ??
          json['Location'] ??
          json['address'] ??
          json['Address'] ??
          'الموقع العام',
      phone:
          json['contactNumber'] ??
          json['ContactNumber'] ??
          json['phone'] ??
          json['Phone'] ??
          '',
      isActive: json['isActive'] ?? json['IsActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'RestaurantId': id,
      'Name': name,
      'Location': address,
      'ContactNumber': phone,
      'IsActive': isActive,
    };
  }
}
