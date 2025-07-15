import '../models/product.dart';

class ProductService {
  static List<Product> getAllProducts() {
    
    return [
      // Fitness Equipment
      const Product(
        id: '1',
        name: 'Adjustable Dumbbells Set',
        description: 'Professional grade adjustable dumbbells with quick-lock system. Perfect for home workouts.',
        price: 29999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/61jau6tusOL._AC_SL1500_.jpg',
        category: 'equipment',
        rating: 4.8,
        reviewCount: 156,
        features: ['5-50 lbs per dumbbell', 'Quick-lock system', 'Space-saving design'],
      ),
      const Product(
        id: '2',
        name: 'Premium Yoga Mat',
        description: 'Non-slip premium yoga mat with excellent cushioning and grip.',
        price: 1000,
        imageUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-vvuIDXLE5cIYhKsT9YaUjnv_9tszDq4jRw&s'  ,
        category: 'equipment',
        rating: 4.6,
        reviewCount: 89,
        features: ['Non-slip surface', '6mm thickness', 'Eco-friendly material'],
      ),
      const Product(
        id: '3',
        name: 'Resistance Bands Set',
        description: 'Complete resistance bands set with multiple resistance levels.',
        price: 990,
        imageUrl: 'https://i5.walmartimages.com/seo/New-11-Piece-Resistance-Band-Set-Heavy-Duty-Yoga-Pilates-Abs-Exercise-Fitness-Workout-Bands_0371214a-7d43-4f19-ba27-ea3bd752f072.b81b750f2724c81c0989fdf12b0009a6.jpeg',
        category: 'equipment',
        rating: 4.7,
        reviewCount: 203,
        features: ['5 resistance levels', 'Door anchor included', 'Carrying bag'],
      ),
      const Product(
        id: '4',
        name: 'Kettlebell 20kg',
        description: 'Cast iron kettlebell with comfortable grip for strength training.',
        price: 9000,
        imageUrl: 'https://cdn11.bigcommerce.com/s-qp20v/images/stencil/1280x1280/products/164/5327/SS-SS000312__91074.1710098534.jpg?c=2',
        category: 'equipment',
        rating: 4.9,
        reviewCount: 78,
        features: ['Cast iron construction', 'Wide handle', 'Flat bottom'],
      ),

      // Supplements
      const Product(
        id: '5',
        name: 'Whey Protein Powder',
        description: 'Premium whey protein isolate for muscle building and recovery.',
        price: 5999,
        imageUrl: 'https://cloudinary.images-iherb.com/image/upload/f_auto,q_auto:eco/images/msc/msc70329/g/65.jpg',
        category: 'supplements',
        rating: 4.5,
        reviewCount: 324,
        features: ['25g protein per serving', '30 servings', 'Vanilla flavor'],
      ),
      const Product(
        id: '6',
        name: 'Creatine Monohydrate',
        description: 'Pure creatine monohydrate for increased strength and power.',
        price: 3000,
        imageUrl: 'https://m.media-amazon.com/images/I/61-ZckiwQJL._AC_SL1396_.jpg',
        category: 'supplements',
        rating: 4.7,
        reviewCount: 189,
        features: ['100% pure', '60 servings', 'Unflavored'],
      ),
      const Product(
        id: '7',
        name: 'Pre-Workout Energy',
        description: 'High-energy pre-workout supplement with caffeine and amino acids.',
        price: 3999,
        imageUrl: 'https://digitalcontent.api.tesco.com/v2/media/ghs/d5a877fd-2e07-4c30-a08e-97cdc7fa1c81/08913905-ee19-402c-b609-a2cc80acf06e_1086765343.jpeg?h=960&w=960',
        category: 'supplements',
        rating: 4.3,
        reviewCount: 156,
        features: ['200mg caffeine', 'Beta-alanine', 'Fruit punch flavor'],
      ),
      const Product(
        id: '8',
        name: 'BCAA ',
        description: 'Branched-chain amino acids for muscle recovery and growth.',
        price: 3499,
        imageUrl: 'https://m.media-amazon.com/images/I/71IbRBLz6yL._AC_SL1500_.jpg',
        category: 'supplements',
        rating: 4.4,
        reviewCount: 112,
        features: ['2:1:1 ratio', '40 servings', 'Lemon lime flavor'],
      ),

      const Product(
        id: '9',
        name: 'Water Bottle 1L',
        description: 'Insulated stainless steel water bottle with time markers.',
        price: 1999,
        imageUrl: 'https://www.ion8.co.uk/cdn/shop/files/B0BS6TXP6G.MAIN_f37c4228-0912-4e99-bc09-fc1e7b1b1805.jpg?v=1750935426&width=990',
        category: 'accessories',
        rating: 4.6,
        reviewCount: 267,
        features: ['1L capacity', 'Pink', 'BPA-free'],
      ),
      const Product(
        id: '10',
        name: 'Gym Towel Set',
        description: 'Quick-dry microfiber towels perfect for gym workouts.',
        price: 1599,
        imageUrl: 'https://m.media-amazon.com/images/I/81SKTletWUL._AC_SL1500_.jpg',
        category: 'accessories',
        rating: 4.2,
        reviewCount: 89,
        features: ['Microfiber material', 'Quick-dry', 'Set of 2'],
      ),
    ];
  }

  static List<Product> getProductsByCategory(String category) {
    return getAllProducts().where((product) => product.category == category).toList();
  }

  static List<Product> getFeaturedProducts() {
    return getAllProducts().where((product) => product.rating >= 4.5).take(4).toList();
  }

  static List<String> getCategories() {
    return ['equipment', 'supplements', 'accessories', 'clothing'];
  }
}
