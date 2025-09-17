import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/exercise_search_provider.dart';

class ExerciseFilters extends ConsumerWidget {
  final String? selectedBodyPart;
  final String? selectedEquipment;
  final String? selectedTargetMuscle;
  final ValueChanged<String?> onBodyPartChanged;
  final ValueChanged<String?> onEquipmentChanged;
  final ValueChanged<String?> onTargetMuscleChanged;
  final VoidCallback onClearFilters;

  const ExerciseFilters({
    Key? key,
    this.selectedBodyPart,
    this.selectedEquipment,
    this.selectedTargetMuscle,
    required this.onBodyPartChanged,
    required this.onEquipmentChanged,
    required this.onTargetMuscleChanged,
    required this.onClearFilters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bodyPartsAsync = ref.watch(exerciseBodyPartsProvider);
    final equipmentsAsync = ref.watch(exerciseEquipmentsProvider);
    final targetMusclesAsync = ref.watch(exerciseTargetMusclesProvider);

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filters',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: onClearFilters,
                child: const Text('Clear All'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Body Part Filter
          bodyPartsAsync.when(
            data:
                (bodyParts) => _buildDropdown(
                  context: context,
                  label: 'Body Part',
                  value: selectedBodyPart,
                  items: bodyParts,
                  onChanged: onBodyPartChanged,
                  icon: Icons.accessibility_new,
                ),
            loading: () => _buildLoadingDropdown(context, 'Body Part'),
            error: (error, stack) => _buildErrorDropdown(context, 'Body Part'),
          ),

          const SizedBox(height: 12),

          // Equipment Filter
          equipmentsAsync.when(
            data:
                (equipments) => _buildDropdown(
                  context: context,
                  label: 'Equipment',
                  value: selectedEquipment,
                  items: equipments,
                  onChanged: onEquipmentChanged,
                  icon: Icons.fitness_center,
                ),
            loading: () => _buildLoadingDropdown(context, 'Equipment'),
            error: (error, stack) => _buildErrorDropdown(context, 'Equipment'),
          ),

          const SizedBox(height: 12),

          // Target Muscle Filter
          targetMusclesAsync.when(
            data:
                (targetMuscles) => _buildDropdown(
                  context: context,
                  label: 'Target Muscle',
                  value: selectedTargetMuscle,
                  items: targetMuscles,
                  onChanged: onTargetMuscleChanged,
                  icon: Icons.sports_gymnastics,
                ),
            loading: () => _buildLoadingDropdown(context, 'Target Muscle'),
            error:
                (error, stack) => _buildErrorDropdown(context, 'Target Muscle'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12.0,
          vertical: 8.0,
        ),
      ),
      items: [
        DropdownMenuItem<String>(value: null, child: Text('All ${label}s')),
        ...items.map(
          (item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              _capitalizeFirst(item),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
      onChanged: onChanged,
      isExpanded: true,
      menuMaxHeight: 300,
    );
  }

  Widget _buildLoadingDropdown(BuildContext context, String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [],
      onChanged: null,
    );
  }

  Widget _buildErrorDropdown(BuildContext context, String label) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.error, color: Colors.red),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: const [],
      onChanged: null,
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
