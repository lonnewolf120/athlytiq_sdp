// fitnation/lib/services/product_service.dart
import '../models/product.dart';

class ProductService {
  static List<Product> getAllProducts() {
    return [
      // CATEGORY: EQUIPMENT
      const Product(
        id: 'eq1_dumbbells',
        name: 'Adjustable Dumbbells Set (5-50lb)',
        description:
            'Professional grade adjustable dumbbells with quick-lock system. Perfect for home workouts, saving space and offering versatile weight options.',
        price: 29999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/619B8uw9JnL._AC_SX679_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/619B8uw9JnL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/51q2dzseMZL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/61x4+UH+WYL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/71REsLz0q2L._AC_SY879_.jpg',
        ],
        category: 'equipment',
        subCategory: 'dumbbells',
        categoryIcon: '🏋️',
        rating: 4.8,
        reviewCount: 156,
        features: [
          'Adjustable from 5 to 50 lbs per dumbbell',
          'Fast and secure quick-lock mechanism',
          'Compact, space-saving design',
          'Comfortable grip handles',
        ],
      ),
      const Product(
        id: 'eq2_barbell',
        name: 'Olympic Barbell (7ft, 45lb)',
        description:
            'Premium Olympic barbell with knurled grip and smooth rotating sleeves, designed for serious powerlifting and weight training.',
        price: 24999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/41vhteoZJYL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/41vhteoZJYL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
          'https://m.media-amazon.com/images/I/61GVUZ1T6NL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/51KJZfgsM2L._AC_SX679_.jpg',
        ],
        category: 'equipment',
        subCategory: 'barbells',
        categoryIcon: '🏋️',
        rating: 4.8,
        reviewCount: 142,
        features: [
          'Standard 7ft length, 45lb weight',
          'Precision knurling for secure grip',
          'Smooth rotating sleeves reduce wrist torque',
          'High-strength steel construction',
        ],
      ),
      const Product(
        id: 'eq3_kettlebell',
        name: 'Cast Iron Kettlebell (20kg)',
        description:
            'Durable cast iron kettlebell, ideal for strength, cardio, and flexibility workouts. Features a smooth finish and comfortable handle.',
        price: 9000.00,
        imageUrl:
            'https://cdn11.bigcommerce.com/s-qp20v/images/stencil/1280x1280/products/164/5327/SS-SS000312__91074.1710098534.jpg?c=2',
        images: [
          'https://cdn11.bigcommerce.com/s-qp20v/images/stencil/1280x1280/products/164/5327/SS-SS000312__91074.1710098534.jpg?c=2',
          'https://m.media-amazon.com/images/I/61b1bL71pVL._AC_SY355_.jpg',
          'https://m.media-amazon.com/images/I/61lqgS92vPL._AC_SY355_.jpg',
        ],
        category: 'equipment',
        subCategory: 'kettlebells',
        categoryIcon: '🏋️',
        rating: 4.9,
        reviewCount: 78,
        features: [
          '20kg (44lb) weight',
          'Solid cast iron construction',
          'Wide, ergonomic handle for two-hand grips',
          'Flat bottom for stability',
        ],
      ),
      const Product(
        id: 'eq4_treadmill',
        name: 'Folding Electric Treadmill',
        description:
            'Compact and powerful electric treadmill with multiple workout programs and a clear LCD display. Perfect for home cardio.',
        price: 49999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/31chdUGXSAL._AC_.jpg', 
        images: [
          'https://m.media-amazon.com/images/I/31chdUGXSAL._AC_.jpg',
          'https://m.media-amazon.com/images/I/712dpGAqHuL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/71JnGGtcV0L._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/61x-G1r5bmL._AC_SX679_.jpg',
        ],
        category: 'equipment',
        subCategory: 'treadmills',
        categoryIcon: '🏃',
        rating: 4.5,
        reviewCount: 210,
        features: [
          'Foldable design for easy storage',
          'Adjustable speed and incline',
          'Built-in workout programs',
          'Heart rate monitor',
        ],
      ),
      const Product(
        id: 'eq5_resistance_bands',
        name: 'Resistance Bands Set (5-Pack)',
        description:
            'Versatile set of 5 resistance loop bands for full-body workouts, stretching, and rehabilitation.',
        price: 990.00,
        imageUrl:
            'https://i5.walmartimages.com/seo/New-11-Piece-Resistance-Band-Set-Heavy-Duty-Yoga-Pilates-Abs-Exercise-Fitness-Workout-Bands_0371214a-7d43-4f19-ba27-ea3bd752f072.b81b750f2724c81c0989fdf12b0009a6.jpeg',
        images: [
          'https://i5.walmartimages.com/seo/New-11-Piece-Resistance-Band-Set-Heavy-Duty-Yoga-Pilates-Abs-Exercise-Fitness-Workout-Bands_0371214a-7d43-4f19-ba27-ea3bd752f072.b81b750f2724c81c0989fdf12b0009a6.jpeg',
          'https://m.media-amazon.com/images/I/713v9-PjJzL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71k42T9eJBL._AC_SX425_.jpg',
        ],
        category: 'equipment',
        subCategory: 'resistance bands',
        categoryIcon: '💪',
        rating: 4.7,
        reviewCount: 203,
        features: [
          '5 varying resistance levels',
          'Durable natural latex',
          'Includes carrying bag',
          'Ideal for home, gym, travel',
        ],
      ),
      const Product(
        id: 'eq6_pullup_bar',
        name: 'Doorway Pull-up Bar (Multi-Grip)',
        description:
            'Easy-to-install, no-screw doorway pull-up bar with multiple grip positions for comprehensive upper body workouts.',
        price: 3499.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/619ozwh22nS._AC_SX679_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/619ozwh22nS._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/717IBYDxd2L._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/71CznFDwWYL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/71Cd-CeFKpL._AC_SL1500_.jpg',
        ],
        category: 'equipment',
        subCategory: 'pull-up bars',
        categoryIcon: '🤸',
        rating: 4.6,
        reviewCount: 328,
        features: [
          'Installs in doorways without screws',
          'Comfortable multi-grip positions',
          'Heavy-duty steel construction (holds up to 300lb)',
          'Quick assembly and portability',
        ],
      ),
      const Product(
        id: 'eq7_foam_roller',
        name: 'High-Density Foam Roller (18-inch)',
        description:
            'Essential tool for muscle recovery, deep tissue massage, and myofascial release. Aids in flexibility and reduces soreness.',
        price: 1999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/811sxiolfES._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/811sxiolfES._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71KjwooxpmL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/812r+Dqc2RL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/81jF-rjH76L._AC_SX425_.jpg',
        ],
        category: 'equipment',
        subCategory: 'recovery tools',
        categoryIcon: '💆',
        rating: 4.7,
        reviewCount: 256,
        features: [
          'Firm, high-density EVA foam',
          '18-inch length, 6-inch diameter',
          'Durable and lightweight',
          'Smooth surface for consistent pressure',
        ],
      ),
      const Product(
        id: 'eq8_battle_ropes',
        name: 'Battle Ropes (30ft, 2in)',
        description:
            'Heavy-duty poly dacron battle ropes for intense full-body workouts, improving strength, endurance, and power.',
        price: 8999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/61md9mYBQKL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61md9mYBQKL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/81VsHjYuWuL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71v-PYJRipL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71u-IjdWlwL._AC_SX425_.jpg',
        ],
        category: 'equipment',
        subCategory: 'cardio & power',
        categoryIcon: '💪',
        rating: 4.5,
        reviewCount: 89,
        features: [
          '30ft length, 2-inch thickness',
          'Durable poly dacron material',
          'Heat-shrink handles for secure grip',
          'Includes anchor kit',
        ],
      ),
      const Product(
        id: 'eq9_medicine_ball',
        name: 'Textured Medicine Ball (20lb)',
        description:
            'Robust, textured rubber medicine ball for functional training, core strength, and explosive power drills.',
        price: 4999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/41P66IHhjuL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/41P66IHhjuL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/91N7p51RRRL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/81-kA3jTF8L._AC_SX679_.jpg',
        ],
        category: 'equipment',
        subCategory: 'strength training',
        categoryIcon: '💪',
        rating: 4.6,
        reviewCount: 167,
        features: [
          '20lb solid rubber construction',
          'Textured surface for enhanced grip',
          'Consistent dead bounce',
          'Versatile for throws, slams, and core work',
        ],
      ),
      const Product(
        id: 'eq10_rowing_machine',
        name: 'Magnetic Rowing Machine',
        description:
            'Smooth and quiet magnetic resistance rowing machine with an intuitive LCD display for effective full-body cardio workouts.',
        price: 39999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/61wnRsm+mLL._AC_SX300_SY300_.jpg', // Reusing placeholder for now
        images: [
          'https://m.media-amazon.com/images/I/61wnRsm+mLL._AC_SX300_SY300_.jpg',
          'https://m.media-amazon.com/images/I/81ggsYPTBiL._AC_SY450_.jpg',
          'https://m.media-amazon.com/images/I/81SNe1qSlKL._AC_SY450_.jpg',
          'https://m.media-amazon.com/images/I/818vL20BAqL._AC_SY450_.jpg',
        ],
        category: 'equipment',
        subCategory: 'cardio machines',
        categoryIcon: '🚣',
        rating: 4.4,
        reviewCount: 245,
        features: [
          '8 levels of magnetic resistance',
          'Large LCD display tracks metrics',
          'Foldable design for easy storage',
          'Comfortable padded seat and non-slip pedals',
        ],
      ),
      const Product(
        id: 'eq11_weight_plates',
        name: 'Standard Weight Plates Set (50lb)',
        description:
            'Durable cast iron weight plates, perfect for barbells and plate-loaded machines. Total 50lb set with various denominations.',
        price: 14999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/81ka00l+QmL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/81ka00l+QmL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/91+wWYYatDL._AC_SY300_SX300_.jpg',
        ],
        category: 'equipment',
        subCategory: 'weight plates',
        categoryIcon: '💿',
        rating: 4.7,
        reviewCount: 198,
        features: [
          'Total 50lb set (e.g., 2x25lb or mix)',
          'Durable cast iron construction',
          'Standard 1-inch center hole',
          'Painted finish for corrosion resistance',
        ],
      ),
      const Product(
        id: 'eq12_jump_rope',
        name: 'Speed Jump Rope (Adjustable)',
        description:
            'Lightweight and fast speed rope with ball bearings for efficient cardio and agility training.',
        price: 1499.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/71k3hT3rqoL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71k3hT3rqoL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/813IwMk2J7L._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/814k55cNdhL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/713aOduJAPL._AC_SX425_.jpg',
        ],
        category: 'equipment',
        subCategory: 'cardio & agility',
        categoryIcon: '🪢',
        rating: 4.5,
        reviewCount: 412,
        features: [
          'Smooth ball bearing system',
          'Adjustable cable length',
          'Comfortable, anti-slip handles',
          'Durable PVC coated steel cable',
        ],
      ),
      const Product(
        id: 'eq13_adjustable_bench',
        name: 'Multi-Position Adjustable Bench',
        description:
            'Robust adjustable weight bench offering multiple back and seat positions for versatile strength training exercises.',
        price: 16999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/719zG2ZrQzL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/719zG2ZrQzL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71nxTfcbsYL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71zRai-i+sL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/71Ops8j8xwL._AC_SX425_.jpg',
        ],
        category: 'equipment',
        subCategory: 'benches',
        categoryIcon: '💺',
        rating: 4.6,
        reviewCount: 289,
        features: [
          '7 backrest positions, 3 seat positions',
          'Heavy-duty steel frame (600lb capacity)',
          'Thick, comfortable padding',
          'Compact and easy to fold',
        ],
      ),
      const Product(
        id: 'eq14_yoga_mat',
        name: 'Premium Non-Slip Yoga Mat (6mm)',
        description:
            'Eco-friendly yoga mat providing excellent grip and cushioning for yoga, Pilates, and floor exercises.',
        price: 1000.00,
        imageUrl:
            'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-vvuIDXLE5cIYhKsT9YaUjnv_9tszDq4jRw&s',
        images: [
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR-vvuIDXLE5cIYhKsT9YaUjnv_9tszDq4jRw&s',
          'https://m.media-amazon.com/images/I/71Q07o2-qYL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/715bXkY1u2L._AC_SX425_.jpg',
        ],
        category: 'equipment',
        subCategory: 'yoga & Pilates',
        categoryIcon: '🧘',
        rating: 4.6,
        reviewCount: 89,
        features: [
          'Superior non-slip surface',
          '6mm thickness for joint comfort',
          'Durable and tear-resistant',
          'Lightweight and portable with strap',
        ],
      ),

      // CATEGORY: SUPPLEMENTS
      const Product(
        id: 'sup1_protein_whey',
        name: 'Whey Protein Isolate (Vanilla)',
        description:
            'High-quality whey protein isolate for rapid muscle recovery and growth. Low in carbs and fat.',
        price: 5999.00,
        imageUrl:
            'https://cloudinary.images-iherb.com/image/upload/f_auto,q_auto:eco/images/msc/msc70329/g/65.jpg',
        images: [
          'https://cloudinary.images-iherb.com/image/upload/f_auto,q_auto:eco/images/msc/msc70329/g/65.jpg',
          'https://m.media-amazon.com/images/I/61+9fK-s3-L._AC_SL1500_.jpg',
          'https://m.media-amazon.com/images/I/71+q2w4uMQL._AC_SL1500_.jpg',
        ],
        category: 'supplements',
        subCategory: 'protein powder',
        categoryIcon: '🥛',
        rating: 4.5,
        reviewCount: 324,
        features: [
          '25g protein per serving',
          'Low carb, low fat',
          'Mixes easily, delicious vanilla flavor',
          '30 servings per container',
        ],
      ),
      const Product(
        id: 'sup2_creatine',
        name: 'Creatine Monohydrate (Unflavored)',
        description:
            'Pure micronized creatine monohydrate for significant increases in strength, power, and muscle mass.',
        price: 3000.00,
        imageUrl:
            'https://m.media-amazon.com/images/I/61-ZckiwQJL._AC_SL1396_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61-ZckiwQJL._AC_SL1396_.jpg',
          'https://m.media-amazon.com/images/I/61Q6S4v06QL._AC_SL1396_.jpg',
        ],
        category: 'supplements',
        subCategory: 'performance',
        categoryIcon: '💊',
        rating: 4.7,
        reviewCount: 189,
        features: [
          '100% pure micronized creatine',
          'Unflavored for easy mixing',
          'Supports muscle strength and endurance',
          '60 servings',
        ],
      ),
      const Product(
        id: 'sup3_preworkout',
        name: 'Pre-Workout Energy (Fruit Punch)',
        description:
            'Explosive pre-workout formula to boost energy, focus, and performance during intense training sessions.',
        price: 3999.00,
        imageUrl:
            'https://digitalcontent.api.tesco.com/v2/media/ghs/d5a877fd-2e07-4c30-a08e-97cdc7fa1c81/08913905-ee19-402c-b609-a2cc80acf06e_1086765343.jpeg?h=960&w=960',
        images: [
          'https://digitalcontent.api.tesco.com/v2/media/ghs/d5a877fd-2e07-4c30-a08e-97cdc7fa1c81/08913905-ee19-402c-b609-a2cc80acf06e_1086765343.jpeg?h=960&w=960',
          'https://m.media-amazon.com/images/I/71+f6-M+tBL._AC_SL1500_.jpg',
        ],
        category: 'supplements',
        subCategory: 'energy & focus',
        categoryIcon: '⚡',
        rating: 4.3,
        reviewCount: 156,
        features: [
          '200mg caffeine for sustained energy',
          'Beta-alanine for endurance',
          'Delicious fruit punch flavor',
          'Enhances mental focus and pump',
        ],
      ),
      const Product(
        id: 'sup4_bcaa',
        name: 'BCAA Powder (Lemon Lime)',
        description:
            'Branched-chain amino acids (BCAA) in a 2:1:1 ratio to support muscle recovery, reduce soreness, and prevent muscle breakdown.',
        price: 3499.00,
        imageUrl:
            'https://m.media-amazon.com/images/I/71IbRBLz6yL._AC_SL1500_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71IbRBLz6yL._AC_SL1500_.jpg',
          'https://m.media-amazon.com/images/I/717t7uJ44uL._AC_SL1500_.jpg',
        ],
        category: 'supplements',
        subCategory: 'recovery',
        categoryIcon: '🩹',
        rating: 4.4,
        reviewCount: 112,
        features: [
          'Optimal 2:1:1 BCAA ratio (Leucine:Isoleucine:Valine)',
          'Supports muscle protein synthesis',
          'Reduces exercise-induced muscle damage',
          'Refreshing lemon-lime flavor',
        ],
      ),
      

      // CATEGORY: ACCESSORIES
      const Product(
        id: 'acc1_water_bottle',
        name: 'Insulated Water Bottle (1L)',
        description:
            'Premium stainless steel water bottle with double-wall insulation to keep drinks cold for hours, featuring a convenient time marker.',
        price: 1999.00,
        imageUrl:
            'https://www.ion8.co.uk/cdn/shop/files/B0BS6TXP6G.MAIN_f37c4228-0912-4e99-bc09-fc1e7b1b1805.jpg?v=1750935426&width=990',
        images: [
          'https://www.ion8.co.uk/cdn/shop/files/B0BS6TXP6G.MAIN_f37c4228-0912-4e99-bc09-fc1e7b1b1805.jpg?v=1750935426&width=990',
          'https://m.media-amazon.com/images/I/61jC1D+zP+L._AC_SX679_.jpg',
        ],
        category: 'accessories',
        subCategory: 'hydration',
        categoryIcon: '💧',
        rating: 4.6,
        reviewCount: 267,
        features: [
          '1-liter capacity',
          'Double-wall vacuum insulation',
          'BPA-free durable stainless steel',
          'Time markers for hydration tracking',
        ],
      ),
      const Product(
        id: 'acc2_gym_towel',
        name: 'Quick-Dry Gym Towel Set',
        description:
            'Ultra-absorbent and quick-drying microfiber towels, perfect for gym workouts, sports, and travel.',
        price: 1599.00,
        imageUrl:
            'https://m.media-amazon.com/images/I/81SKTletWUL._AC_SL1500_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/81SKTletWUL._AC_SL1500_.jpg',
          'https://m.media-amazon.com/images/I/81G-l7N3HhL._AC_SL1500_.jpg',
        ],
        category: 'accessories',
        subCategory: 'gym gear',
        categoryIcon: 'タオル',
        rating: 4.2,
        reviewCount: 89,
        features: [
          'Microfiber material (set of 2)',
          'Highly absorbent and fast drying',
          'Compact and lightweight',
          'Soft and gentle on skin',
        ],
      ),
      const Product(
        id: 'acc3_gps_watch',
        name: 'GPS Running Watch (Heart Rate)',
        description:
            'Advanced GPS running watch with integrated heart rate monitoring and detailed training analytics for serious runners.',
        price: 24999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/61m+fKy7wzL._AC_SY300_SX300_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61m+fKy7wzL._AC_SY300_SX300_.jpg',
          'https://m.media-amazon.com/images/I/71z784eK8uL._AC_SY300_SX300_.jpg',
        ],
        category: 'accessories',
        subCategory: 'wearables',
        categoryIcon: '⌚',
        rating: 4.6,
        reviewCount: 892,
        features: [
          'Built-in GPS for pace, distance, routes',
          '24/7 wrist-based heart rate tracking',
          'Smart notifications and music control',
          'Up to 7-day battery life in smartwatch mode',
        ],
      ),
      const Product(
        id: 'acc4_hydration_belt',
        name: 'Running Hydration Belt (Bounce-Free)',
        description:
            'Lightweight and comfortable hydration belt with two water bottles and multiple pockets for essentials during long runs.',
        price: 3999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/71acFE0O5YL._AC_SX679_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71acFE0O5YL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/71N1p0L6kCL._AC_SX679_.jpg',
        ],
        category: 'accessories',
        subCategory: 'hydration',
        categoryIcon: '🚰',
        rating: 4.5,
        reviewCount: 456,
        features: [
          'Ergonomic, bounce-free design',
          'Includes two 10oz BPA-free bottles',
          'Zippered and mesh pockets for phone, keys, gels',
          'Adjustable waist strap for custom fit',
        ],
      ),
      const Product(
        id: 'acc5_bike_helmet',
        name: 'Aerodynamic Road Bike Helmet',
        description:
            'Lightweight and well-ventilated cycling helmet with MIPS technology for enhanced safety on the road.',
        price: 8999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/61XqNkn9DaL._AC_SX466_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61XqNkn9DaL._AC_SX466_.jpg',
          'https://m.media-amazon.com/images/I/61u9n9p2cCL._AC_SX466_.jpg',
        ],
        category: 'accessories',
        subCategory: 'cycling gear',
        categoryIcon: '🚴',
        rating: 4.7,
        reviewCount: 678,
        features: [
          'Sleek aerodynamic design',
          '22 strategic vents for airflow',
          'MIPS (Multi-directional Impact Protection System)',
          'Adjustable fit system and comfortable padding',
        ],
      ),
      const Product(
        id: 'acc6_bike_computer',
        name: 'GPS Bike Computer (Performance)',
        description:
            'Advanced GPS bike computer providing comprehensive performance metrics, navigation, and smart connectivity for serious cyclists.',
        price: 29999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/61QaZ-QlNHL._AC_SX679_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61QaZ-QlNHL._AC_SX679_.jpg',
          'https://m.media-amazon.com/images/I/71C7N1LqT+L._AC_SX679_.jpg',
        ],
        category: 'accessories',
        subCategory: 'cycling gear',
        categoryIcon: '🚲',
        rating: 4.8,
        reviewCount: 345,
        features: [
          'Detailed GPS navigation and mapping',
          'Monitors speed, distance, cadence, heart rate (with sensors)',
          'Long-lasting battery',
          'ANT+ and Bluetooth connectivity',
        ],
      ),
      const Product(
        id: 'acc7_swim_goggles',
        name: 'Anti-Fog Swim Goggles (Pro)',
        description:
            'Professional-grade swimming goggles with crystal-clear anti-fog lenses and UV protection, ensuring comfort and visibility.',
        price: 2999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/71Y+spVpwuL._AC_SY300_SX300_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71Y+spVpwuL._AC_SY300_SX300_.jpg',
          'https://m.media-amazon.com/images/I/71nO4p2d-ML._AC_SY300_SX300_.jpg',
        ],
        category: 'accessories',
        subCategory: 'swimming gear',
        categoryIcon: '🏊',
        rating: 4.6,
        reviewCount: 1234,
        features: [
          'Enhanced anti-fog coating',
          '100% UV protection',
          'Comfortable silicone seal and adjustable straps',
          'Wide field of vision',
        ],
      ),
      const Product(
        id: 'acc8_swim_cap',
        name: 'Silicone Swim Cap (Unisex)',
        description:
            'Durable and comfortable silicone swim cap, designed to protect hair from chlorine and reduce drag in the water.',
        price: 1299.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/510YGPJDS+L._AC_SY300_SX300_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/510YGPJDS+L._AC_SY300_SX300_.jpg',
          'https://m.media-amazon.com/images/I/61+o-Kq-hL._AC_SY300_SX300_.jpg',
        ],
        category: 'accessories',
        subCategory: 'swimming gear',
        categoryIcon: '🏊',
        rating: 4.4,
        reviewCount: 567,
        features: [
          '100% high-quality silicone',
          'Snug, comfortable fit',
          'Tear-resistant and durable',
          'Available in multiple colors',
        ],
      ),
      const Product(
        id: 'acc9_waterproof_tracker',
        name: 'Waterproof Fitness Tracker (Swim)',
        description:
            'Versatile fitness tracker with advanced waterproofing and swim-specific tracking features, perfect for aquatic athletes.',
        price: 18999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/51CtR+quteL._AC_SY300_SX300_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/51CtR+quteL._AC_SY300_SX300_.jpg',
          'https://m.media-amazon.com/images/I/514A-L1BvAL._AC_SY300_SX300_.jpg',
        ],
        category: 'accessories',
        subCategory: 'wearables',
        categoryIcon: '⌚',
        rating: 4.5,
        reviewCount: 789,
        features: [
          'Water resistant up to 50 meters',
          'Automatic swim stroke detection',
          '24/7 heart rate monitoring',
          'Up to 14-day battery life',
        ],
      ),
      const Product(
        id: 'acc10_hiking_backpack',
        name: 'Hiking Backpack (40L, Lightweight)',
        description:
            'Spacious and lightweight 40-liter hiking backpack with multiple compartments and hydration compatibility for day trips and overnight adventures.',
        price: 12999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/81siwI2UxEL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/81siwI2UxEL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
          'https://m.media-amazon.com/images/I/819w4v9L9BL._AC_SX300_SY300_.jpg',
        ],
        category: 'accessories',
        subCategory: 'hiking gear',
        categoryIcon: '🎒',
        rating: 4.6,
        reviewCount: 678,
        features: [
          '40-liter main capacity',
          'Dedicated hydration sleeve',
          'Adjustable torso length and padded straps',
          'Integrated rain cover included',
        ],
      ),
      const Product(
        id: 'acc11_hiking_poles',
        name: 'Adjustable Hiking Poles (Carbon Fiber)',
        description:
            'Lightweight and durable carbon fiber trekking poles with shock absorption, essential for stability and support on challenging trails.',
        price: 6999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/71TJLm0G1HL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71TJLm0G1HL.__AC_SX300_SY300_QL70_FMwebp_.jpg',
          'https://m.media-amazon.com/images/I/71k42T9eJBL._AC_SX425_.jpg',
        ],
        category: 'accessories',
        subCategory: 'hiking gear',
        categoryIcon: '🦯',
        rating: 4.5,
        reviewCount: 892,
        features: [
          'Lightweight carbon fiber construction',
          'Quick-lock adjustable length',
          'Comfortable ergonomic grips',
          'Includes various tips for different terrains',
        ],
      ),

      // CATEGORY: CLOTHING
      const Product(
        id: 'cloth1_mens_tshirt',
        name: 'Men\'s Athletic T-Shirt (Moisture-Wicking)',
        description:
            'High-performance athletic t-shirt for men, featuring moisture-wicking and anti-odor technology to keep you dry and fresh.',
        price: 2499.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/61omzEIOW5L._AC_SX385_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71YGXLKK4OL._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/71CF66zu9+L._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/71yfJwYAUBL._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/71nxTfcbsYL._AC_SX425_.jpg',
        ],
        category: 'clothing',
        subCategory: 'men\'s activewear',
        categoryIcon: '👕',
        rating: 4.7,
        reviewCount: 834,
        features: [
          'Fast-drying, moisture-wicking fabric',
          'Anti-odor technology',
          'Lightweight and breathable',
          'Athletic fit for unrestricted movement',
        ],
      ),
      const Product(
        id: 'cloth2_womens_leggings',
        name: 'Women\'s High-Waisted Leggings (Pocket)',
        description:
            'Comfortable and supportive high-waisted workout leggings with convenient side pockets, perfect for yoga, gym, or casual wear.',
        price: 3299.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/61M8Xaz49FL._AC_SX342_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61M8Xaz49FL._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/61hBReXUJCL._AC_SX342_.jpg',
          'https://m.media-amazon.com/images/I/51quFHl9IPL._AC_SX342_.jpg',
        ],
        category: 'clothing',
        subCategory: 'women\'s activewear',
        categoryIcon: '👖',
        rating: 4.6,
        reviewCount: 1247,
        features: [
          'High-rise waistband for tummy control',
          'Two side pockets for phone/essentials',
          'Squat-proof, non-see-through fabric',
          'Four-way stretch for flexibility',
        ],
      ),
      const Product(
        id: 'cloth3_mens_shorts',
        name: 'Men\'s Running Shorts (7-inch)',
        description:
            'Lightweight and breathable running shorts for men, with a 7-inch inseam and internal brief for comfort during runs.',
        price: 1999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/61+9X8Gf2xL._AC_SX425_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61+9X8Gf2xL._AC_SX425_.jpg',
          'https://m.media-amazon.com/images/I/61b1bL71pVL._AC_SY355_.jpg',
        ],
        category: 'clothing',
        subCategory: 'men\'s activewear',
        categoryIcon: '🩳',
        rating: 4.5,
        reviewCount: 520,
        features: [
          '7-inch inseam',
          'Moisture-wicking fabric',
          'Built-in brief for support',
          'Elastic waistband with drawstring',
        ],
      ),
      
      // CATEGORY: FOOTWEAR
      const Product(
        id: 'foot1_mens_running_shoes',
        name: 'Men\'s Lightweight Running Shoes',
        description:
            'Versatile running shoes for men, offering superior cushioning and a breathable mesh upper for comfortable, long-distance runs.',
        price: 12999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/71vqccKqizL._AC_SX575_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71vqccKqizL._AC_SX575_.jpg',
          'https://m.media-amazon.com/images/I/71tNwiY0iFL._AC_SX575_.jpg',
          'https://m.media-amazon.com/images/I/71hbCUwvGIL._AC_SY695_.jpg',
        ],
        category: 'footwear',
        subCategory: 'running shoes',
        categoryIcon: '👟',
        rating: 4.8,
        reviewCount: 2456,
        features: [
          'Responsive foam cushioning',
          'Lightweight and breathable mesh upper',
          'Durable rubber outsole for traction',
          'Comfortable for daily training',
        ],
      ),
      const Product(
        id: 'foot2_womens_running_shoes',
        name: 'Women\'s Performance Running Shoes',
        description:
            'Engineered for women, these running shoes provide adaptive fit and energetic responsiveness for optimal performance.',
        price: 11999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/71RipFkA7yL._AC_SY575_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/71RipFkA7yL._AC_SY575_.jpg',
          'https://m.media-amazon.com/images/I/716503c-QUL._AC_SY575_.jpg',
        ],
        category: 'footwear',
        subCategory: 'running shoes',
        categoryIcon: '👟',
        rating: 4.7,
        reviewCount: 1834,
        features: [
          'Women-specific design and fit',
          'Energy-returning midsole foam',
          'Seamless upper construction reduces irritation',
          'Excellent grip on various surfaces',
        ],
      ),
      const Product(
        id: 'foot3_cycling_shoes',
        name: 'Men\'s Cycling Shoes (SPD Cleat)',
        description:
            'Performance road cycling shoes with a stiff sole for efficient power transfer and a secure closure system.',
        price: 15999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/61v5S25noiL._AC_SY575_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/61v5S25noiL._AC_SY575_.jpg',
          'https://m.media-amazon.com/images/I/71j2p+2D2QL._AC_SY575_.jpg',
        ],
        category: 'footwear',
        subCategory: 'cycling shoes',
        categoryIcon: '🚴',
        rating: 4.6,
        reviewCount: 234,
        features: [
          'Stiff composite sole for power transfer',
          'Secure BOA dial closure system',
          'Breathable synthetic upper',
          'Compatible with 2-bolt SPD cleats',
        ],
      ),
      const Product(
        id: 'foot4_hiking_boots',
        name: 'Waterproof Hiking Boots (Men\'s)',
        description:
            'Rugged and waterproof hiking boots offering excellent ankle support and traction for diverse outdoor trails.',
        price: 16999.99,
        imageUrl:
            'https://m.media-amazon.com/images/I/710OLYAZw5L._AC_SY575_.jpg',
        images: [
          'https://m.media-amazon.com/images/I/710OLYAZw5L._AC_SY575_.jpg',
          'https://m.media-amazon.com/images/I/81Qf5Vw3yCL._AC_SY575_.jpg',
        ],
        category: 'footwear',
        subCategory: 'hiking boots',
        categoryIcon: '🥾',
        rating: 4.7,
        reviewCount: 1456,
        features: [
          'Durable waterproof membrane',
          'Aggressive multi-directional lugs for grip',
          'Cushioned midsole for comfort',
          'High-cut design for ankle support',
        ],
      ),
    ];
  }

  static List<Product> getProductsByCategory(String category) {
    return getAllProducts()
        .where(
          (product) => product.category.toLowerCase() == category.toLowerCase(),
        )
        .toList();
  }

  static List<Product> getProductsBySubCategory(String subCategory) {
    return getAllProducts()
        .where(
          (product) =>
              product.subCategory?.toLowerCase() == subCategory.toLowerCase(),
        )
        .toList();
  }

  static List<Product> getFeaturedProducts() {
    // Returns products with a high rating, prioritizing equipment first then other popular items
    return getAllProducts()
        .where((product) => product.rating >= 4.5)
        .take(6)
        .toList();
  }

  static List<String> getCategories() {
    return [
      'all',
      'equipment',
      'supplements',
      'accessories',
      'clothing',
      'footwear',
    ];
  }

  // Example of getting suggested products for a specific activity, now using new IDs and structure
  static List<Product> getSuggestedProductsForActivity(String activityType) {
    switch (activityType.toLowerCase()) {
      case 'running':
        return getAllProducts()
            .where(
              (product) =>
                  product.subCategory == 'running shoes' ||
                  product.subCategory == 'wearables' ||
                  product.subCategory == 'hydration' &&
                      product.category == 'accessories',
            )
            .take(4)
            .toList();
      case 'cycling':
        return getAllProducts()
            .where(
              (product) =>
                  product.subCategory == 'cycling shoes' ||
                  product.subCategory == 'cycling gear',
            )
            .take(4)
            .toList();
      case 'swimming':
        return getAllProducts()
            .where(
              (product) =>
                  product.subCategory == 'swimming gear' ||
                  product.id == 'acc9_waterproof_tracker', // specific tracker
            )
            .take(4)
            .toList();
      case 'hiking':
        return getAllProducts()
            .where(
              (product) =>
                  product.subCategory == 'hiking boots' ||
                  product.subCategory == 'hiking gear',
            )
            .take(4)
            .toList();
      case 'strength training': // Added for equipment heavy activities
      case 'weightlifting':
      case 'home workout':
        return getAllProducts()
            .where(
              (product) =>
                  product.category == 'equipment' &&
                  (product.subCategory == 'dumbbells' ||
                      product.subCategory == 'barbells' ||
                      product.subCategory == 'kettlebells' ||
                      product.subCategory == 'resistance bands' ||
                      product.subCategory == 'benches'),
            )
            .take(4)
            .toList();
      default:
        // Fallback to general popular equipment
        return getAllProducts()
            .where(
              (product) =>
                  product.category == 'equipment' && product.rating >= 4.5,
            )
            .take(4)
            .toList();
    }
  }
}
