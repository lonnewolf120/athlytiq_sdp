import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/trainer/trainer_application.dart';
import 'package:fitnation/providers/trainer_provider.dart';

class ExpertVerificationListScreen extends ConsumerStatefulWidget {
  final String planId;
  final String planType;

  const ExpertVerificationListScreen({
    super.key,
    required this.planId,
    required this.planType,
  });

  @override
  ConsumerState<ExpertVerificationListScreen> createState() =>
      _ExpertVerificationListScreenState();
}

class _ExpertVerificationListScreenState
    extends ConsumerState<ExpertVerificationListScreen> {
  String _selectedSpecialization = '';
  bool _showOnlineOnly = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get relevant specializations based on plan type
    final relevantSpecializations = widget.planType == 'workout'
        ? [
            TrainerSpecialization.weightTraining,
            TrainerSpecialization.cardio,
            TrainerSpecialization.crossfit,
            TrainerSpecialization.rehabilitation,
          ]
        : [TrainerSpecialization.nutrition];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Find ${widget.planType.toUpperCase()} Expert',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(
                bottom: BorderSide(color: Colors.grey[800]!),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search experts...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: Colors.grey[800],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedSpecialization.isEmpty,
                        onSelected: (selected) {
                          setState(() {
                            _selectedSpecialization = '';
                          });
                        },
                        backgroundColor: Colors.grey[800],
                        selectedColor: Colors.red,
                        labelStyle: TextStyle(
                          color: _selectedSpecialization.isEmpty
                              ? Colors.white
                              : Colors.grey[300],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...relevantSpecializations.map((spec) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(spec.displayName),
                            selected: _selectedSpecialization == spec.name,
                            onSelected: (selected) {
                              setState(() {
                                _selectedSpecialization =
                                    selected ? spec.name : '';
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
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Showing experts for ${widget.planType} plans',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const Spacer(),
                    Switch(
                      value: _showOnlineOnly,
                      onChanged: (value) {
                        setState(() {
                          _showOnlineOnly = value;
                        });
                      },
                      activeColor: Colors.red,
                    ),
                    Text(
                      'Online now',
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Experts List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: 10, // Replace with actual data
              itemBuilder: (context, index) {
                final isOnline = index % 3 == 0;
                if (_showOnlineOnly && !isOnline) return const SizedBox.shrink();

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: Colors.grey[900],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(
                                    'https://example.com/expert$index.jpg',
                                  ),
                                ),
                                if (isOnline)
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Dr. Jane Smith',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Nutrition Expert • ${5 + index} years',
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: Colors.yellow,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${4.5 + (index * 0.1)}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${50 + index} reviews',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Available for quick verification and consultation. '
                          'Specializes in personalized nutrition plans and dietary advice.',
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.yellow,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Within 24h',
                                    style: TextStyle(
                                      color: Colors.grey[300],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: () {
                                // Navigate to expert profile
                              },
                              child: const Text(
                                'View Profile',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () {
                                // Request verification
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'Request Review',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
