class RequestItemModel {
  final int id;
  final int? foodDonationId;
  final String restaurantName;
  final String foodName;
  final int quantity;
  final String? receiverName;
  final String? beneficiaryName;
  final DateTime requestTime;
  final DateTime? deliveredTime;
  final DateTime? expiryTime;
  final String status;

  RequestItemModel({
    required this.id,
    this.foodDonationId,
    required this.restaurantName,
    required this.foodName,
    required this.quantity,
    this.receiverName,
    this.beneficiaryName,
    required this.requestTime,
    this.deliveredTime,
    this.expiryTime,
    required this.status,
  });

  factory RequestItemModel.fromJson(Map<String, dynamic> json) {
    final reqTimeRaw = json['requestTime'] ?? json['RequestTime'];
    final delTimeRaw = json['deliveredTime'] ?? json['DeliveredTime'];
    final expTimeRaw = json['expiryTime'] ?? json['ExpiryTime'];

    return RequestItemModel(
      id:
          json['id'] ??
          json['Id'] ??
          json['requestId'] ??
          json['RequestId'] ??
          0,
      foodDonationId: json['foodDonationId'] ?? json['FoodDonationId'],
      restaurantName:
          json['restaurantName'] ?? json['RestaurantName'] ?? 'مطعم',
      foodName: json['foodName'] ?? json['FoodName'] ?? 'وجبة',
      quantity: json['quantity'] ?? json['Quantity'] ?? 0,
      receiverName: json['receiverName'] ?? json['ReceiverName'],
      beneficiaryName:
          json['beneficiaryName'] ?? json['BeneficiaryName'] ?? 'جمعية خيرية',
      requestTime:
          reqTimeRaw != null
              ? (DateTime.tryParse(reqTimeRaw.toString()) ?? DateTime.now())
              : DateTime.now(),
      deliveredTime:
          delTimeRaw != null ? DateTime.tryParse(delTimeRaw.toString()) : null,
      expiryTime:
          expTimeRaw != null ? DateTime.tryParse(expTimeRaw.toString()) : null,
      status: json['status'] ?? json['Status'] ?? 'قيد الانتظار',
    );
  }
}
