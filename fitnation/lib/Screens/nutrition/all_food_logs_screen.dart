import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';

class AllFoodLogsScreen extends ConsumerStatefulWidget {
  final List<Map<String, dynamic>> allFoodLogs;

  const AllFoodLogsScreen({super.key, required this.allFoodLogs});

  @override
  ConsumerState<AllFoodLogsScreen> createState() => _AllFoodLogsScreenState();
}

class _AllFoodLogsScreenState extends ConsumerState<AllFoodLogsScreen> {
  String _selectedFilter = 'All';

  // Filter options
  final List<String> _filterOptions = [
    'All',
    'Today',
    'Yesterday',
    'This Week',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Snack',
  ];

  List<Map<String, dynamic>> get _filteredLogs {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final weekStart = today.subtract(Duration(days: now.weekday - 1));

    return widget.allFoodLogs.where((log) {
        final logDate = DateTime.parse(log['log_date']);
        final logDay = DateTime(logDate.year, logDate.month, logDate.day);

        switch (_selectedFilter) {
          case 'Today':
            return logDay.isAtSameMomentAs(today);
          case 'Yesterday':
            return logDay.isAtSameMomentAs(yesterday);
          case 'This Week':
            return logDay.isAfter(weekStart.subtract(Duration(days: 1))) &&
                logDay.isBefore(today.add(Duration(days: 1)));
          case 'Breakfast':
          case 'Lunch':
          case 'Dinner':
          case 'Snack':
            return log['meal_type'] == _selectedFilter;
          default:
            return true; // 'All'
        }
      }).toList()
      ..sort(
        (a, b) => DateTime.parse(
          b['log_date'],
        ).compareTo(DateTime.parse(a['log_date'])),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'All Food Logs',
          style: AppTextStyles.darkHeadlineMedium.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.darkGradientStart,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.filter_list,
                      color: AppColors.darkGradientStart,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Filter by:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkGradientStart,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filterOptions.length,
                    separatorBuilder:
                        (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final option = _filterOptions[index];
                      final isSelected = _selectedFilter == option;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = option;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isSelected
                                    ? AppColors.darkGradientStart
                                    : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.darkGradientStart
                                      : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color:
                                  isSelected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Results Count
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_filteredLogs.length} logs found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const Spacer(),
                if (_filteredLogs.isNotEmpty) ...[
                  Text(
                    'Total: ${_calculateTotalCalories().toStringAsFixed(0)} cal',
                    style: TextStyle(
                      color: AppColors.darkGradientStart,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Food Logs List
          Expanded(
            child:
                _filteredLogs.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: _filteredLogs.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final log = _filteredLogs[index];
                        return _buildFoodLogItem(log);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No logs found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedFilter == 'All'
                  ? 'You haven\'t logged any meals yet.'
                  : 'No meals found for "$_selectedFilter".',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
              label: Text('Back to Nutrition'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkGradientStart,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFoodLogItem(Map<String, dynamic> log) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    log['food_name'] ?? 'Unknown Food',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getMealTypeColor(log['meal_type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log['meal_type'] ?? 'N/A',
                    style: TextStyle(
                      color: _getMealTypeColor(log['meal_type']),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildNutrientInfo(
                    'Calories',
                    '${log['calories']?.toStringAsFixed(0) ?? 'N/A'}',
                    Icons.local_fire_department,
                    Colors.orange,
                    'kcal',
                  ),
                ),
                Expanded(
                  child: _buildNutrientInfo(
                    'Protein',
                    '${log['protein']?.toStringAsFixed(1) ?? 'N/A'}',
                    Icons.fitness_center,
                    Colors.red,
                    'g',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildNutrientInfo(
                    'Carbs',
                    '${log['carbs']?.toStringAsFixed(1) ?? 'N/A'}',
                    Icons.grain,
                    Colors.green,
                    'g',
                  ),
                ),
                Expanded(
                  child: _buildNutrientInfo(
                    'Fat',
                    '${log['fat']?.toStringAsFixed(1) ?? 'N/A'}',
                    Icons.opacity,
                    Colors.blue,
                    'g',
                  ),
                ),
              ],
            ),
            if (log['log_date'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 6),
                  Text(
                    _formatLogDate(log['log_date']),
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientInfo(
    String label,
    String value,
    IconData icon,
    Color color,
    String unit,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(
          '$label: $value$unit',
          style: TextStyle(
            fontSize: 13,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getMealTypeColor(String? mealType) {
    switch (mealType?.toLowerCase()) {
      case 'breakfast':
        return Colors.orange;
      case 'lunch':
        return Colors.green;
      case 'dinner':
        return Colors.blue;
      case 'snack':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatLogDate(String dateString) {
    final logDate = DateTime.parse(dateString);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final logDay = DateTime(logDate.year, logDate.month, logDate.day);

    final difference = today.difference(logDay).inDays;

    if (difference == 0) {
      // Today - show time
      final hour = logDate.hour;
      final minute = logDate.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return 'Today at $displayHour:$minute $period';
    } else if (difference == 1) {
      return 'Yesterday at ${logDate.hour}:${logDate.minute.toString().padLeft(2, '0')}';
    } else if (difference <= 7) {
      final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return '${weekdays[logDate.weekday - 1]} at ${logDate.hour}:${logDate.minute.toString().padLeft(2, '0')}';
    } else {
      return '${logDate.month}/${logDate.day}/${logDate.year}';
    }
  }

  double _calculateTotalCalories() {
    return _filteredLogs.fold(
      0.0,
      (sum, log) => sum + (log['calories']?.toDouble() ?? 0.0),
    );
  }
}
