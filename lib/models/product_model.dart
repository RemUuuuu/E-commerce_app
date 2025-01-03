class ProductModel {
  int? id;
  String name;
  String description;
  double price;
  int stock;
  String? image;

  ProductModel({
    this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    this.image,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'image': image,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      price: map['price'],
      stock: map['stock'],
      image: map['image'],
    );
  }
}
