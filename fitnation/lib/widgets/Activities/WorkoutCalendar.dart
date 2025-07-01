import 'package:fitnation/core/themes/colors.dart';
import 'package:fitnation/core/themes/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class WorkoutCalendar extends StatefulWidget {
  final List<DateTime> workoutDates; // List of dates with workouts (only day, month, year matters)
  final ValueChanged<DateTime> onMonthChanged; // Callback when month changes

  const WorkoutCalendar({
    super.key,
    required this.workoutDates,
    required this.onMonthChanged,
  });

  @override
  State<WorkoutCalendar> createState() => _WorkoutCalendarState();
}

class _WorkoutCalendarState extends State<WorkoutCalendar> {
  late DateTime _displayedMonth;

  @override
  void initState() {
    super.initState();
    _displayedMonth = DateTime.now(); // Start with the current month
  }

  // Helper to get the first day of the week for the displayed month
  DateTime _getFirstDayOfWeek(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    // Adjust to the first day of the week (Sunday = 0, Monday = 1, etc.)
    // In Flutter, weekday is 1 for Monday, 7 for Sunday.
    // We want the calendar to start on Sunday (index 0).
    // If firstDayOfMonth is Monday (1), diff is 1. We want it to be 0.
    // If firstDayOfMonth is Sunday (7), diff is 7. We want it to be 6.
    // So, dayOfWeek - 1 gives Monday=0, ..., Sunday=6.
    // To start week on Sunday: (dayOfWeek % 7) gives Monday=1, ..., Sunday=0.
    // Let's adjust to start on Sunday (index 0):
    int weekday = firstDayOfMonth.weekday; // 1 (Mon) to 7 (Sun)
    int daysToSubtract = (weekday % 7); // 1 for Mon, ..., 0 for Sun. We want 0 for Sun, 1 for Mon...
     if (weekday == 7) daysToSubtract = 0; // Sunday is the first day (index 0)

    return firstDayOfMonth.subtract(Duration(days: daysToSubtract));
  }

  // Helper to check if a date has a workout
  bool _hasWorkout(DateTime date) {
    return widget.workoutDates.any(
      (workoutDate) =>
          workoutDate.year == date.year &&
          workoutDate.month == date.month &&
          workoutDate.day == date.day,
    );
  }

  // Helper to check if a date is in the currently displayed month
  bool _isInDisplayedMonth(DateTime date) {
    return date.year == _displayedMonth.year && date.month == _displayedMonth.month;
  }

  // Navigate to the previous month
  void _goToPreviousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
    widget.onMonthChanged(_displayedMonth);
  }

  // Navigate to the next month
  void _goToNextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
    widget.onMonthChanged(_displayedMonth);
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final firstDayOfGrid = _getFirstDayOfWeek(_displayedMonth);
    final daysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final totalDaysInGrid = 42; // Usually enough for 6 weeks (6 * 7)

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Header and Navigation
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, color: AppColors.foreground),
              onPressed: _goToPreviousMonth,
              tooltip: 'Previous Month',
            ),
            Text(
              DateFormat.yMMMM().format(_displayedMonth), // e.g., May 2025
              style: AppTextStyles.headlineSmall?.copyWith(color: AppColors.foreground),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: AppColors.foreground),
              onPressed: _goToNextMonth,
              tooltip: 'Next Month',
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Weekday Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (index) {
            // Reorder to start with Sunday (index 6) then Monday (0) to Saturday (5)
            final orderedDays = [
              DateFormat.EEEE().dateSymbols.STANDALONEWEEKDAYS[7 % 7], // Sunday
              ...DateFormat.EEEE().dateSymbols.STANDALONEWEEKDAYS.sublist(1, 7), // Monday to Saturday
            ];
            return Expanded(
              child: Text(
                orderedDays[index],
                style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.mutedForeground),
                textAlign: TextAlign.center,
              ),
            );
          }),
        ),
        const SizedBox(height: 8),

        // Calendar Grid
        GridView.builder(
          shrinkWrap: true, // Important for GridView inside Column/ListView
          physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7, // 7 days a week
            childAspectRatio: 1.0, // Square cells
            crossAxisSpacing: 4.0, // Spacing between columns
            mainAxisSpacing: 4.0, // Spacing between rows
          ),
          itemCount: totalDaysInGrid,
          itemBuilder: (context, index) {
            final date = firstDayOfGrid.add(Duration(days: index));
            final isToday = date.year == DateTime.now().year &&
                            date.month == DateTime.now().month &&
                            date.day == DateTime.now().day;
            final hasWorkout = _hasWorkout(date);
            final isInMonth = _isInDisplayedMonth(date);

            return GestureDetector(
              onTap: isInMonth ? () {
                 // TODO: Handle tapping on a specific date (e.g., show workouts for that day)
                 print("Tapped on ${DateFormat.yMMMd().format(date)}");
              } : null, // Disable tap for days outside the month
              child: Container(
                decoration: BoxDecoration(
                  color: hasWorkout ? AppColors.primary : (isInMonth ? AppColors.mutedBackground : AppColors.secondary), // Red for workout, muted for month, secondary for outside
                  borderRadius: BorderRadius.circular(8.0),
                  border: isToday ? Border.all(color: AppColors.foreground, width: 1.5) : null, // Highlight today
                ),
                alignment: Alignment.center,
                child: Text(
                  '${date.day}',
                  style: AppTextStyles.bodyMedium?.copyWith(
                    color: hasWorkout ? AppColors.primary : (isInMonth ? AppColors.foreground : AppColors.mutedForeground), // White for workout, foreground for month, muted for outside
                    fontWeight: isToday || hasWorkout ? FontWeight.w600 : FontWeight.w400, // Bold for today/workout
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        // Legend
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('Workout day', style: AppTextStyles.bodyMedium?.copyWith(color: AppColors.mutedForeground)),
          ],
        ),
      ],
    );
  }
}