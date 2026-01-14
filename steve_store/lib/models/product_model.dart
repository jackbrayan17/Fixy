class Product {
  int? id;
  String title;
  String description;
  double price;
  String category;
  List<String> images;

  Product({
    this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    this.images = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'category': category,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map, List<String> images) {
    return Product(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      price: map['price'],
      category: map['category'],
      images: images,
    );
  }
}
