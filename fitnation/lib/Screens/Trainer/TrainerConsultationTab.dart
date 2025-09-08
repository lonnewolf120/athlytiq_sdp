import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/trainer/trainer_application.dart';

class TrainerConsultationTab extends ConsumerStatefulWidget {
  const TrainerConsultationTab({super.key});

  @override
  ConsumerState<TrainerConsultationTab> createState() => _TrainerConsultationTabState();
}

class _TrainerConsultationTabState extends ConsumerState<TrainerConsultationTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TextEditingController _searchController = TextEditingController();
  String _selectedSpecialization = 'All';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Expert Consultation',
          style: TextStyle(color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.red,
          tabs: const [
            Tab(text: 'Trainers'),
            Tab(text: 'Posts'),
            Tab(text: 'Saved'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search trainers or posts...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[900],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Specialization Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedSpecialization == 'All',
                        onSelected: (selected) {
                          setState(() {
                            _selectedSpecialization = 'All';
                          });
                        },
                        backgroundColor: Colors.grey[800],
                        selectedColor: Colors.red,
                        labelStyle: TextStyle(
                          color: _selectedSpecialization == 'All'
                              ? Colors.white
                              : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...TrainerSpecialization.values.map((spec) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(spec.displayName),
                            selected: _selectedSpecialization == spec.name,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSpecialization = spec.name;
                              });
                            },
                            backgroundColor: Colors.grey[800],
                            selectedColor: Colors.red,
                            labelStyle: TextStyle(
                              color: _selectedSpecialization == spec.name
                                  ? Colors.white
                                  : Colors.grey[300],
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTrainersTab(),
                _buildPostsTab(),
                _buildSavedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainersTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Replace with actual data
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: NetworkImage(
                        'https://example.com/trainer$index.jpg',
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Trainer Name $index',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${5 + index} years experience',
                            style: TextStyle(color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.bookmark_border, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Weight Training',
                    'Nutrition',
                    'Cardio',
                  ].map((spec) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        spec,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'View Profile',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Book Session',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Replace with actual data
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Trainer Info Header
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(
                    'https://example.com/trainer$index.jpg',
                  ),
                ),
                title: Text(
                  'Trainer Name $index',
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  '2h ago',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {},
                ),
              ),

              // Post Image (if any)
              if (index % 2 == 0)
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://example.com/post$index.jpg',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              // Post Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post Title $index',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is a sample post content that demonstrates what trainers can share. It can include tips, advice, and other fitness-related information.',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildPostActionButton(
                          Icons.favorite_border,
                          '${index + 10}',
                        ),
                        const SizedBox(width: 24),
                        _buildPostActionButton(
                          Icons.comment_outlined,
                          '${index + 5}',
                        ),
                        const SizedBox(width: 24),
                        _buildPostActionButton(
                          Icons.bookmark_border,
                          'Save',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSavedTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5, // Replace with actual saved items
      itemBuilder: (context, index) {
        return Card(
          color: Colors.grey[900],
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(
                'https://example.com/saved$index.jpg',
              ),
            ),
            title: Text(
              'Saved Item $index',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Trainer Name • Category',
              style: TextStyle(color: Colors.grey[400]),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.bookmark, color: Colors.red),
              onPressed: () {},
            ),
          ),
        );
      },
    );
  }

  Widget _buildPostActionButton(IconData icon, String label) {
    return InkWell(
      onTap: () {},
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }
}
