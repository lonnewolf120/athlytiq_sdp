class Product {
  final String id;
  final String name;
  final String description;

  final double price;
  final String imageUrl;
  final List<String> images;

  final String category;
  final String? subCategory;
  final String? categoryIcon;
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
    this.subCategory,
    this.categoryIcon,
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
  footwear,
  treadmill,
  kettlebell,
  barbell,
  dumbbells,
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
      case ProductCategory.footwear:
        return 'Footwear';
      case ProductCategory.treadmill:
        return 'Treadmill';
      case ProductCategory.kettlebell:
        return 'Kettlebell';
      case ProductCategory.barbell:
        return 'Barbell';
      case ProductCategory.dumbbells:
        return 'Dumbbells';
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
      case ProductCategory.footwear:
        return '👟';
      case ProductCategory.treadmill:
        return '🏃';
      case ProductCategory.kettlebell:
        return '🏋️';
      case ProductCategory.barbell:
        return '🏋️';
      case ProductCategory.dumbbells:
        return '🏋️';
    }
  }
}
