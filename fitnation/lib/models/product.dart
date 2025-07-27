class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String> images; 

  final String category;
  final double rating;
  final int reviewCount;
  final bool isInStock;
  final List<String> features;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.images = const [],
    
    required this.category,
    required this.rating,
    required this.reviewCount,
    this.isInStock = true,
    this.features = const [],
  });
}

enum ProductCategory {
  equipment,
  supplements,
  accessories,
  clothing,
}

extension ProductCategoryExtension on ProductCategory {
  String get displayName {
    switch (this) {
      case ProductCategory.equipment:
        return 'Equipment';
      case ProductCategory.supplements:
        return 'Supplements';
      case ProductCategory.accessories:
        return 'Accessories';
      case ProductCategory.clothing:
        return 'Clothing';
    }
  }

  String get icon {
    switch (this) {
      case ProductCategory.equipment:
        return '🏋️';
      case ProductCategory.supplements:
        return '💊';
      case ProductCategory.accessories:
        return '🎒';
      case ProductCategory.clothing:
        return '👕';
    }
  }
}
