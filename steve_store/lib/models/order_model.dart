class OrderModel {
  int? id;
  int userId;
  int productId;
  int quantity;
  String status;
  String orderDate;
  String? productTitle;
  double? productPrice;
  String? userName;

  OrderModel({
    this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.status,
    required this.orderDate,
    this.productTitle,
    this.productPrice,
    this.userName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
      'status': status,
      'orderDate': orderDate,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'],
      userId: map['userId'],
      productId: map['productId'],
      quantity: map['quantity'],
      status: map['status'],
      orderDate: map['orderDate'],
      productTitle: map['productTitle'],
      productPrice: map['productPrice'],
      userName: map['fullName'],
    );
  }
}
