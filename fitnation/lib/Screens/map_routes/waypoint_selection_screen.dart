import 'package:flutter/material.dart';
import 'package:map_routes/themes/colors.dart';
import 'package:map_routes/themes/text_styles.dart';

class WaypointSelectionScreen extends StatefulWidget {
  const WaypointSelectionScreen({super.key});

  @override
  State<WaypointSelectionScreen> createState() =>
      _WaypointSelectionScreenState();
}

class _WaypointSelectionScreenState extends State<WaypointSelectionScreen> {
  final List<TextEditingController> _controllers = [TextEditingController()];

  void _addWaypoint() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeWaypoint(int index) {
    if (_controllers.length > 1) {
      setState(() {
        _controllers.removeAt(index);
      });
    }
  }

  void _reorderWaypoints(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex--;
      final item = _controllers.removeAt(oldIndex);
      _controllers.insert(newIndex, item);
    });
  }

  void _onNext() {
    final waypoints = _controllers
        .map((c) => c.text)
        .where((text) => text.isNotEmpty)
        .toList();
    debugPrint("Selected Waypoints: $waypoints");

    // You can navigate or use a Provider to store the waypoints
    Navigator.pop(context, waypoints);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Select Waypoints',
          style: AppTextStyles.lightHeadlineMedium,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ReorderableListView.builder(
                itemCount: _controllers.length,
                onReorder: _reorderWaypoints,
                buildDefaultDragHandles: false,
                itemBuilder: (context, index) {
                  return Dismissible(
                    key: ValueKey(_controllers[index]),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => _removeWaypoint(index),
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      color: Colors.red,
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      leading: ReorderableDragStartListener(
                        index: index,
                        child: const Icon(Icons.drag_handle),
                      ),
                      title: TextField(
                        controller: _controllers[index],
                        decoration: InputDecoration(
                          hintText: 'Enter waypoint ${index + 1}',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _addWaypoint,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _onNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: Text('Next', style: AppTextStyles.buttonText),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
