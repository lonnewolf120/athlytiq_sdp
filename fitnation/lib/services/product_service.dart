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
        imageUrl: 'https://m.media-amazon.com/images/I/619B8uw9JnL._AC_SX679_.jpg',
         images: [
          'https://m.media-amazon.com/images/I/619B8uw9JnL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/51q2dzseMZL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/61x4+UH+WYL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/71REsLz0q2L._AC_SY879_.jpg',
        ],
        category: 'equipment',
        rating: 4.8,
        reviewCount: 156,
        features: ['5-50 lbs per dumbbell', 'Quick-lock system', 'Space-saving design'],
      ),
      
    
      const Product(
        id: '12',
        name: 'Pull-up Bar Doorway',
        description: 'No-screw doorway pull-up bar with multiple grip positions for upper body workouts.',
        price: 3499.99,
        imageUrl: 'https://m.media-amazon.com/images/I/619ozwh22nS._AC_SX679_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/619ozwh22nS._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/717IBYDxd2L._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/71CznFDwWYL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/71Cd-CeFKpL._AC_SL1500_.jpg',
        ],
        category: 'equipment',
        rating: 4.6,
        reviewCount: 328,
        features: ['No screws required', 'Multiple grip positions', '300lb capacity', 'Easy installation'],
      ),
      const Product(
        id: '13',
        name: 'Foam Roller',
        description: 'High-density foam roller for muscle recovery and myofascial release.',
        price: 1999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/811sxiolfES._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/811sxiolfES._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71KjwooxpmL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/812r+Dqc2RL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/81jF-rjH76L._AC_SX425_.jpg',
        ],
        category: 'equipment',
        rating: 4.7,
        reviewCount: 256,
        features: ['High-density foam', '18-inch length', 'Textured surface', 'Lightweight'],
      ),
      const Product(
        id: '14',
        name: 'Battle Ropes 30ft',
        description: 'Heavy-duty battle ropes for high-intensity cardio and strength training.',
        price: 8999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/61md9mYBQKL._AC_SX425_.jpg',
        images: [
           'https://m.media-amazon.com/images/I/61md9mYBQKL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/81VsHjYuWuL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71v-PYJRipL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71u-IjdWlwL._AC_SX425_.jpg',
        ],
        category: 'equipment',
        rating: 4.5,
        reviewCount: 89,
        features: ['30ft length', '2-inch diameter', 'Poly dacron material', 'Anchor kit included'],
      ),
      const Product(
        id: '15',
        name: 'Medicine Ball 20lb',
        description: 'Textured rubber medicine ball for functional training and core workouts.',
        price: 4999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/41P66IHhjuL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/41P66IHhjuL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/41P66IHhjuL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/91N7p51RRRL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/81-kA3jTF8L._AC_SX679_.jpg',
        ],
        category: 'equipment',
        rating: 4.6,
        reviewCount: 167,
        features: ['20lb weight', 'Textured grip', 'Dead bounce design', 'Durable rubber'],
      ),
      const Product(
        id: '16',
        name: 'Rowing Machine',
        description: 'Magnetic resistance rowing machine with LCD display and comfortable seat.',
        price: 39999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/61wnRsm+mLL._AC_SX300_SY300_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61wnRsm+mLL._AC_SX300_SY300_.jpg',
          'https://m.media-amazon.com/images/I/81ggsYPTBiL._AC_SY450_.jpg',
          'https://m.media-amazon.com/images/I/81SNe1qSlKL._AC_SY450_.jpg',
          'https://m.media-amazon.com/images/I/818vL20BAqL._AC_SY450_.jpg',
        ],
        category: 'equipment',
        rating: 4.4,
        reviewCount: 245,
        features: ['Magnetic resistance', 'LCD display', 'Foldable design', '8 resistance levels'],
      ),
      const Product(
        id: '17',
        name: 'Weight Plates Set 50lb',
        description: 'Standard weight plates set with multiple denominations for barbell training.',
        price: 14999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/81ka00l+QmL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/81ka00l+QmL._AC_SX425_.jpg',
          
          'https://m.media-amazon.com/images/I/91+wWYYatDL._AC_SY300_SX300_.jpg',
        ],
        category: 'equipment',
        rating: 4.7,
        reviewCount: 198,
        features: ['50lb total weight', 'Cast iron construction', 'Standard 1-inch hole', 'Multiple plates'],
      ),
      const Product(
        id: '18',
        name: 'Jump Rope Speed Rope',
        description: 'High-speed ball bearing jump rope with adjustable cable for cardio workouts.',
        price: 1499.99,
        imageUrl: 'https://m.media-amazon.com/images/I/71k3hT3rqoL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71k3hT3rqoL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/813IwMk2J7L._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/814k55cNdhL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/713aOduJAPL._AC_SX425_.jpg',
        ],
        category: 'equipment',
        rating: 4.5,
        reviewCount: 412,
        features: ['Ball bearing system', 'Adjustable cable', 'Comfortable handles', 'Anti-slip grip'],
      ),
      
      const Product(
        id: '20',
        name: 'Adjustable Bench',
        description: 'Heavy-duty adjustable weight bench with multiple incline positions.',
        price: 16999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/719zG2ZrQzL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/719zG2ZrQzL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71nxTfcbsYL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71zRai-i+sL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71Ops8j8xwL._AC_SX425_.jpg',
        ],
        category: 'equipment',
        rating: 4.6,
        reviewCount: 289,
        features: ['7 back positions', '3 seat positions', '600lb capacity', 'Foldable design'],
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
        id: '11',
        name: 'Olympic Barbell 45lb',
        description: 'Premium Olympic barbell with knurled grip and rotating sleeves for serious lifting.',
        price: 24999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/41vhteoZJYL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/41vhteoZJYL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
          'https://m.media-amazon.com/images/I/41vhteoZJYL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
          'https://m.media-amazon.com/images/I/61GVUZ1T6NL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/51KJZfgsM2L._AC_SX679_.jpg',
        ],
        category: 'equipment',
        rating: 4.8,
        reviewCount: 142,
        features: ['45lb standard weight', 'Knurled grip', 'Rotating sleeves', '7ft length'],
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

      // Clothing
      const Product(
        id: '21',
        name: 'Men\'s Athletic T-Shirt',
        description: 'Moisture-wicking performance t-shirt with anti-odor technology for intense workouts.',
        price: 2499.99,
        imageUrl: 'https://m.media-amazon.com/images/I/61omzEIOW5L._AC_SX385_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71YGXLKK4OL._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/71CF66zu9+L._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/71yfJwYAUBL._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/71nxTfcbsYL._AC_SX425_.jpg',
        ],
        category: 'clothing',
        rating: 4.7,
        reviewCount: 834,
        features: ['Moisture-wicking fabric', 'Anti-odor technology', 'Comfortable fit', 'Multiple colors'],
      ),
      const Product(
        id: '22',
        name: 'Women\'s Leggings High Waist',
        description: 'High-waisted workout leggings with compression fit and side pockets.',
        price: 3299.99,
        imageUrl: 'https://m.media-amazon.com/images/I/61M8Xaz49FL._AC_SX342_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61M8Xaz49FL._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/61hBReXUJCL._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/51quFHl9IPL._AC_SX342_.jpg',
        ],
        category: 'clothing',
        rating: 4.6,
        reviewCount: 1247,
        features: ['High-waisted design', 'Side pockets', 'Compression fit', 'Squat-proof fabric'],
      ),

      const Product(
        id: '222',
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
        id: '333',
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
        id: '444',
        name: 'Kettlebell 20kg',
        description: 'Cast iron kettlebell with comfortable grip for strength training.',
        price: 9000,
        imageUrl: 'https://cdn11.bigcommerce.com/s-qp20v/images/stencil/1280x1280/products/164/5327/SS-SS000312__91074.1710098534.jpg?c=2',
        category: 'equipment',
        rating: 4.9,
        reviewCount: 78,
        features: ['Cast iron construction', 'Wide handle', 'Flat bottom'],
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
