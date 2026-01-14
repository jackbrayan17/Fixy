class CartItem {
  int? id;
  int productId;
  int quantity;
  String? productTitle;
  double? productPrice;
  String? productImage;

  CartItem({
    this.id,
    required this.productId,
    this.quantity = 1,
    this.productTitle,
    this.productPrice,
    this.productImage,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      id: map['id'],
      productId: map['productId'],
      quantity: map['quantity'],
      productTitle: map['title'],
      productPrice: map['price'],
      productImage: map['imagePath'],
    );
  }
}
