class UserModel {
  final String token;
  final String username;
  final String role;
  final int? beneficiaryId; // 🔥 تم إضافة معرف الجمعية هنا
  final String beneficiaryName;
  final int? restaurantId; // 🔥 أضف هذا الحقل هنا
  final String? restaurantName; // 🔥 اسم المطعم الخاص بالمستخدم

  UserModel({
    required this.token,
    required this.username,
    required this.role,
    this.beneficiaryId,
    required this.beneficiaryName,
    this.restaurantId,
    this.restaurantName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['token'] ?? json['Token'] ?? '',
      username: json['username'] ?? json['Username'] ?? '',
      role: json['role'] ?? json['Role'] ?? '',
      // التقاط معرف الجمعية من استجابة تسجيل الدخول
      beneficiaryId: json['beneficiaryId'] ?? json['BeneficiaryId'],
      beneficiaryName:
          json['beneficiaryName'] ?? json['BeneficiaryName'] ?? 'جمعية',
      restaurantId: json['restaurantId'] ?? json['RestaurantId'],
      restaurantName:
          json['restaurantName'] ?? json['RestaurantName'] ?? 'مطعم',
    );
  }
}
