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

      // Running Gear
      const Product(
        id: '500',
        name: 'Men\'s Running Shoes',
        description: 'Lightweight running shoes with superior cushioning and breathable mesh upper.',
        price: 12999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/71vqccKqizL._AC_SX575_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71vqccKqizL._AC_SX575_.jpg',
          'https://m.media-amazon.com/images/I/71tNwiY0iFL._AC_SX575_.jpg',
          'https://m.media-amazon.com/images/I/71hbCUwvGIL._AC_SY695_.jpg',
        ],
        category: 'footwear',
        rating: 4.8,
        reviewCount: 2456,
        features: ['Responsive foam cushioning', 'Breathable mesh', 'Lightweight design', 'All-day comfort'],
      ),
      const Product(
        id: '501',
        name: 'Women\'s Running Shoes',
        description: 'Performance running shoes designed for women with adaptive fit and energy return.',
        price: 11999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/71RipFkA7yL._AC_SY575_.jpg',
        images: [
         'https://m.media-amazon.com/images/I/71RipFkA7yL._AC_SY575_.jpg',
        ],
        category: 'footwear',
        rating: 4.7,
        reviewCount: 1834,
        features: ['Adaptive fit technology', 'Energy return foam', 'Women-specific design', 'Reflective details'],
      ),
      const Product(
        id: '502',
        name: 'GPS Running Watch',
        description: 'Advanced GPS running watch with heart rate monitoring and training analytics.',
        price: 24999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/61m+fKy7wzL._AC_SY300_SX300_.jpg',
        category: 'accessories',
        rating: 4.6,
        reviewCount: 892,
        features: ['Built-in GPS', 'Heart rate monitor', '7-day battery', 'Water resistant'],
      ),
      const Product(
        id: '503',
        name: 'Running Hydration Belt',
        description: 'Comfortable hydration belt with multiple pockets and bounce-free design.',
        price: 3999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/71acFE0O5YL._AC_SX679_.jpg',
        category: 'accessories',
        rating: 4.5,
        reviewCount: 456,
        features: ['Bounce-free design', '2 water bottles', 'Multiple pockets', 'Adjustable fit'],
      ),

      // Cycling Gear
      const Product(
        id: '600',
        name: 'Road Bike Helmet',
        description: 'Lightweight aerodynamic cycling helmet with superior ventilation.',
        price: 8999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/61XqNkn9DaL._AC_SX466_.jpg',
        category: 'accessories',
        rating: 4.7,
        reviewCount: 678,
        features: ['Aerodynamic design', '22 vents', 'Lightweight', 'MIPS protection'],
      ),
      const Product(
        id: '601',
        name: 'Cycling Shoes',
        description: 'Performance cycling shoes with stiff sole and secure closure system.',
        price: 15999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/61v5S25noiL._AC_SY575_.jpg',
        category: 'footwear',
        rating: 4.6,
        reviewCount: 234,
        features: ['Carbon fiber sole', 'BOA closure', 'Breathable upper', 'Professional fit'],
      ),
      const Product(
        id: '602',
        name: 'Bike Computer',
        description: 'Advanced bike computer with GPS navigation and performance metrics.',
        price: 29999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/61QaZ-QlNHL._AC_SX679_.jpg',
        category: 'accessories',
        rating: 4.8,
        reviewCount: 345,
        features: ['GPS navigation', 'Performance tracking', 'Long battery life', 'ANT+ connectivity'],
      ),

      // Swimming Gear
      const Product(
        id: '700',
        name: 'Swim Goggles Pro',
        description: 'Professional swimming goggles with anti-fog and UV protection.',
        price: 2999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/71Y+spVpwuL._AC_SY300_SX300_.jpg',
        category: 'accessories',
        rating: 4.6,
        reviewCount: 1234,
        features: ['Anti-fog coating', 'UV protection', 'Comfortable seal', 'Adjustable strap'],
      ),
      const Product(
        id: '701',
        name: 'Swim Cap Silicone',
        description: 'High-quality silicone swim cap for competitive and recreational swimming.',
        price: 1299.99,
        imageUrl: 'https://m.media-amazon.com/images/I/510YGPJDS+L._AC_SY300_SX300_.jpg',
        category: 'accessories',
        rating: 4.4,
        reviewCount: 567,
        features: ['100% silicone', 'Tear-resistant', 'Comfortable fit', 'Multiple colors'],
      ),
      const Product(
        id: '702',
        name: 'Waterproof Fitness Tracker',
        description: 'Advanced fitness tracker designed for swimming and water sports.',
        price: 18999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/51CtR+quteL._AC_SY300_SX300_.jpg',
        category: 'accessories',
        rating: 4.5,
        reviewCount: 789,
        features: ['50m water resistance', 'Swim stroke detection', 'Heart rate monitor', '14-day battery'],
      ),

      // Hiking Gear
      const Product(
        id: '800',
        name: 'Hiking Boots',
        description: 'Durable waterproof hiking boots with excellent traction and support.',
        price: 16999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/710OLYAZw5L._AC_SY575_.jpg',
        category: 'footwear',
        rating: 4.7,
        reviewCount: 1456,
        features: ['Waterproof membrane', 'Vibram sole', 'Ankle support', 'Breathable lining'],
      ),
      const Product(
        id: '801',
        name: 'Hiking Backpack 40L',
        description: 'Lightweight hiking backpack with hydration system and multiple compartments.',
        price: 12999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/81siwI2UxEL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
        category: 'accessories',
        rating: 4.6,
        reviewCount: 678,
        features: ['40L capacity', 'Hydration compatible', 'Adjustable fit', 'Rain cover included'],
      ),
      const Product(
        id: '802',
        name: 'Hiking Poles',
        description: 'Adjustable trekking poles with shock absorption and comfortable grips.',
        price: 6999.99,
        imageUrl: 'https://m.media-amazon.com/images/I/71TJLm0G1HL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
        category: 'accessories',
        rating: 4.5,
        reviewCount: 892,
        features: ['Adjustable length', 'Shock absorption', 'Tungsten tips', 'Lightweight carbon'],
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
    return ['equipment', 'supplements', 'accessories', 'clothing', 'footwear'];
  }

  static List<Product> getSuggestedProductsForActivity(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'run':
        return getAllProducts().where((product) => 
          product.id == '500' || // Men's Running Shoes
          product.id == '501' || // Women's Running Shoes
          product.id == '502' || // GPS Running Watch
          product.id == '503'    // Running Hydration Belt
        ).toList();
      case 'ride':
        return getAllProducts().where((product) => 
          product.id == '600' || // Road Bike Helmet
          product.id == '601' || // Cycling Shoes
          product.id == '602'    // Bike Computer
        ).toList();
      case 'swim':
        return getAllProducts().where((product) => 
          product.id == '700' || // Swim Goggles Pro
          product.id == '701' || // Swim Cap Silicone
          product.id == '702'    // Waterproof Fitness Tracker
        ).toList();
      case 'hike':
        return getAllProducts().where((product) => 
          product.id == '800' || // Hiking Boots
          product.id == '801' || // Hiking Backpack 40L
          product.id == '802'    // Hiking Poles
        ).toList();
      default:
        // Return general fitness equipment for other activities
        return getAllProducts().where((product) => 
          product.category == 'equipment' && product.rating >= 4.5
        ).take(4).toList();
    }
  }
}
