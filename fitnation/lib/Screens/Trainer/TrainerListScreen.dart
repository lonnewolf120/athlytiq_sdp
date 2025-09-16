import 'package:flutter/material.dart';
import 'package:fitnation/Screens/Trainer/TrainerProfileScreen.dart';

class TrainerListScreen extends StatefulWidget {
  const TrainerListScreen({super.key});

  @override
  State<TrainerListScreen> createState() => _TrainerListScreenState();
}

class _TrainerListScreenState extends State<TrainerListScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> filterCategories = [
    'All',
    'Weight Training',
    'Cardio',
    'Yoga',
    'Pilates',
    'CrossFit',
    'Martial Arts',
    'Dance',
    'Nutrition',
  ];

  // Sample trainers data
  final List<Map<String, dynamic>> trainers = [
    {
      'id': 'trainer_001',
      'name': 'Sarah Johnson',
      'title': 'Certified Personal Trainer',
      'rating': 4.8,
      'reviews': 156,
      'experience': '8 years',
      'price': 2500,
      'profileImage': 'https://static.vecteezy.com/system/resources/thumbnails/046/837/177/small_2x/confident-indonesian-female-fitness-trainer-in-gym-emphasizing-strength-and-wellness-perfect-for-health-and-fitness-promotions-photo.jpg',
      'specializations': ['Weight Training', 'Cardio', 'Yoga'],
      'location': 'Dhaka, Bangladesh',
      'isOnline': true,
      'sessions': 1200,
      'bio': 'Passionate fitness trainer with 8+ years of experience...',
    },
    {
      'id': 'trainer_002',
      'name': 'Rahman Ahmed',
      'title': 'CrossFit Specialist',
      'rating': 4.7,
      'reviews': 98,
      'experience': '6 years',
      'price': 2200,
      'profileImage': 'https://static.vecteezy.com/system/resources/thumbnails/046/837/133/small/confident-middle-aged-bangladeshi-male-fitness-trainer-in-black-shirt-standing-in-modern-gym-with-treadmills-photo.jpg',
      'specializations': ['CrossFit', 'Weight Training', 'Cardio'],
      'location': 'Chittagong, Bangladesh',
      'isOnline': false,
      'sessions': 850,
      'bio': 'CrossFit Level 2 trainer specializing in functional fitness...',
    },
    {
      'id': 'trainer_003',
      'name': 'Fatima Khan',
      'title': 'Yoga & Pilates Instructor',
      'rating': 4.9,
      'reviews': 210,
      'experience': '10 years',
      'price': 2800,
      'profileImage': 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
      'specializations': ['Yoga', 'Pilates', 'Meditation'],
      'location': 'Dhaka, Bangladesh',
      'isOnline': true,
      'sessions': 1500,
      'bio': 'Certified yoga instructor with expertise in Hatha and Vinyasa...',
    },
    {
      'id': 'trainer_004',
      'name': 'Imran Ali',
      'title': 'Martial Arts Expert',
      'rating': 4.6,
      'reviews': 75,
      'experience': '12 years',
      'price': 3000,
      'profileImage': 'https://images.unsplash.com/photo-1566753323558-f4e0952af115?w=400',
      'specializations': ['Martial Arts', 'Self Defense', 'Cardio'],
      'location': 'Sylhet, Bangladesh',
      'isOnline': false,
      'sessions': 600,
      'bio': 'Black belt in Karate and Taekwondo with extensive teaching experience...',
    },
    {
      'id': 'trainer_005',
      'name': 'Nadia Rahman',
      'title': 'Dance Fitness Coach',
      'rating': 4.7,
      'reviews': 132,
      'experience': '5 years',
      'price': 2100,
      'profileImage': 'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=400',
      'specializations': ['Dance', 'Cardio', 'Zumba'],
      'location': 'Dhaka, Bangladesh',
      'isOnline': true,
      'sessions': 900,
      'bio': 'Professional dancer turned fitness coach specializing in fun workouts...',
    },
    {
      'id': 'trainer_006',
      'name': 'Karim Hassan',
      'title': 'Nutrition & Fitness Expert',
      'rating': 4.8,
      'reviews': 189,
      'experience': '7 years',
      'price': 2600,
      'profileImage': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
      'specializations': ['Nutrition', 'Weight Training', 'Bodybuilding'],
      'location': 'Dhaka, Bangladesh',
      'isOnline': true,
      'sessions': 1100,
      'bio': 'Certified nutritionist and personal trainer helping clients achieve their goals...',
    },
  ];

  List<Map<String, dynamic>> get filteredTrainers {
    return trainers.where((trainer) {
      final matchesFilter = selectedFilter == 'All' || 
          (trainer['specializations'] as List<String>).contains(selectedFilter);
      final matchesSearch = searchQuery.isEmpty ||
          trainer['name'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          trainer['title'].toString().toLowerCase().contains(searchQuery.toLowerCase()) ||
          (trainer['specializations'] as List<String>)
              .any((spec) => spec.toLowerCase().contains(searchQuery.toLowerCase()));
      
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Find a Trainer',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search trainers, specializations...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          setState(() {
                            searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red, width: 2),
                ),
              ),
            ),
          ),

          // Filter Chips
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filterCategories.length,
              itemBuilder: (context, index) {
                final category = filterCategories[index];
                final isSelected = selectedFilter == category;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedFilter = selected ? category : 'All';
                      });
                    },
                    backgroundColor: Colors.grey[800],
                    selectedColor: Colors.red,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[300],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // Results Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${filteredTrainers.length} trainers found',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _showSortOptions,
                  icon: const Icon(Icons.sort, color: Colors.red, size: 18),
                  label: const Text(
                    'Sort',
                    style: TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Trainers List
          Expanded(
            child: filteredTrainers.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredTrainers.length,
                    itemBuilder: (context, index) {
                      return _buildTrainerCard(filteredTrainers[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainerCard(Map<String, dynamic> trainer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TrainerProfileScreen(trainerId: trainer['id']),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trainer Image
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          trainer['profileImage'],
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.grey,
                                size: 40,
                              ),
                            );
                          },
                        ),
                      ),
                      if (trainer['isOnline'])
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey[900]!, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Trainer Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trainer['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          trainer['title'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 12),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${trainer['rating']}',
                                    style: const TextStyle(
                                      color: Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(${trainer['reviews']})',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '• ${trainer['experience']}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.grey, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                trainer['location'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '৳${trainer['price']}',
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'per session',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Specializations
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (trainer['specializations'] as List<String>).take(3).map((spec) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Text(
                      spec,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrainerProfileScreen(trainerId: trainer['id']),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'View Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Add to favorites
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${trainer['name']} added to favorites!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        color: Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off,
              color: Colors.grey,
              size: 40,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No trainers found',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                selectedFilter = 'All';
                searchQuery = '';
                _searchController.clear();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Clear Filters',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter Options',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              
              // Price Range
              const Text(
                'Price Range',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip('Under ৳2000', false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip('৳2000-৳2500', false),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip('Above ৳2500', false),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Location
              const Text(
                'Location',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildFilterChip('Online Only', false)),
                  const SizedBox(width: 8),
                  Expanded(child: _buildFilterChip('In-Person Only', false)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Apply Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return InkWell(
      onTap: () {
        // Handle filter selection
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red : Colors.grey[800],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.red : Colors.grey[600]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              
              _buildSortOption('Highest Rated', Icons.star),
              _buildSortOption('Most Reviews', Icons.reviews),
              _buildSortOption('Price: Low to High', Icons.arrow_upward),
              _buildSortOption('Price: High to Low', Icons.arrow_downward),
              _buildSortOption('Most Experience', Icons.work),
              _buildSortOption('Nearest Location', Icons.location_on),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      onTap: () {
        Navigator.pop(context);
        // Handle sort option selection
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sorted by: $title'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }
}
