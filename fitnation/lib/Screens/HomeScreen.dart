import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/providers/auth_provider.dart';
import 'package:fitnation/models/ProfileModel.dart';
import 'package:fitnation/models/Workout.dart';
import 'package:intl/intl.dart';

// Profile provider from auth state
final profileProvider = Provider<Profile?>((ref) {
  final authState = ref.watch(authProvider);
  return authState is Authenticated ? authState.user.profile : null;
});

// Recent workouts provider
final recentWorkoutsProvider = FutureProvider<List<Workout>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return <Workout>[];
});

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final workoutsAsync = ref.watch(recentWorkoutsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: const [
            Icon(Icons.fitness_center, color: Colors.red),
            SizedBox(width: 8),
            Text('FitNation'),
          ],
        ),
        actions: [
          if (profile != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.red,
                child: Text(
                  profile.displayName![0].toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.red),
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stories Section
            Container(
              height: 100,
              margin: const EdgeInsets.only(top: 10),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  const SizedBox(width: 10),
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[800],
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Your Story',
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  ...['Alex', 'Jordan', 'Casey', 'Taylor', 'Mom']
                      .map(
                        (name) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: Colors.grey[800],
                                child: Text(
                                  name[0],
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ],
              ),
            ),
            // Welcome Message
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Text(
                'Welcome, ${profile?.displayName!.split(' ').first ?? ''}',
                style: Theme.of(
                  context,
                ).textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
            ),
            // Buttons Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Wrap(
                spacing: 20.0,
                runSpacing: 20.0,
                alignment: WrapAlignment.center,
                children: [
                  _buildButton(
                    context,
                    Icons.fitness_center,
                    'Workouts',
                    'Log your fitness activities',
                  ),
                  _buildButton(
                    context,
                    Icons.trending_up,
                    'Progress',
                    'Track your fitness journey',
                  ),
                  _buildButton(
                    context,
                    Icons.people,
                    'Community',
                    'Connect with fitness enthusiasts',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Recent Activity
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recent Activity',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  workoutsAsync.when(
                    data: (workouts) => workouts.isEmpty
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "You haven't logged any workouts yet.",
                                style: TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    'Start Logging',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: workouts
                                .map(
                                  (w) => Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                                  // Row(
                                                  //   mainAxisAlignment:
                                                  //       MainAxisAlignment.spaceBetween,
                                                  //   children: [
                                            Text(
                                                    w.type ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                                  // Text(
                                                  //   DateFormat.yMMMd().format(w.createdAt),
                                                  //   style: const TextStyle(
                                                  //     fontSize: 12,
                                                  //     color: Colors.grey,
                                                  //   ),
                                                  // ),
                                                  //   ],
                                                  // ),
                                        const SizedBox(height: 5),
                                                  // Row(
                                                  //   children: [
                                                  //     Text(
                                                  //       '${w.duration} min',
                                                  //       style: const TextStyle(
                                                  //         fontSize: 14,
                                                  //         color: Colors.grey,
                                                  //       ),
                                                  //     ),
                                                  //     const SizedBox(width: 20),
                                                  //     Text(
                                                  //       'Intensity: ${w.intensity}/10',
                                                  //       style: const TextStyle(
                                                  //         fontSize: 14,
                                                  //         color: Colors.grey,
                                                  //       ),
                                                  //     ),
                                                  //   ],
                                                  // ),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: Colors.red),
                    ),
                    error: (_, __) => const Text(
                      'Error loading workouts',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      // bottomNavigationBar: Theme(
      //   data: ThemeData(
      //     highlightColor: Colors.transparent,
      //     splashColor: Colors.transparent,
      //   ),
      //   child: navbar2(),
      // ),
    );
  }

  Widget _buildButton(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.grey[900],
      ),
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 20.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 30, color: Colors.red),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

}

