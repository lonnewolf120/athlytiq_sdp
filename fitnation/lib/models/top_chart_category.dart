// lib/models/top_chart_category.dart
class TopChartCategory {
  final String id; // For unique identification or routing
  final String title;
  // final IconData? icon; // Optional: if you want icons next to each category title in the future

  TopChartCategory({
    required this.id,
    required this.title,
    // this.icon,
  });
}