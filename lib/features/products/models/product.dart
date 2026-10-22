class Product {
  const Product({
    required this.id,
    required this.name,
    this.nameAr,
    required this.description,
    this.descriptionAr,
    required this.price,
    required this.category,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? nameAr;
  final String description;
  final String? descriptionAr;
  final double price;
  final String category;
  final String? imageUrl;

  String getName(String langCode) {
    if (langCode == 'ar' && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  String getDescription(String langCode) {
    if (langCode == 'ar' && descriptionAr != null && descriptionAr!.isNotEmpty) {
      return descriptionAr!;
    }
    return description;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['nameAr'] as String?,
      description: json['description'] as String,
      descriptionAr: json['descriptionAr'] as String?,
      price: (json['price'] as num).toDouble(),
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}