import 'package:fitnation/providers/active_workout_provider.dart'; // Corrected import
import 'package:fitnation/core/themes/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters

class ActiveWorkoutSetRow extends StatefulWidget {
  final ActiveWorkoutSet set;
  final int setNumber;
  final ValueChanged<ActiveWorkoutSet> onSetUpdated; // Callback for changes

  const ActiveWorkoutSetRow({
    super.key,
    required this.set,
    required this.setNumber,
    required this.onSetUpdated,
  });

  @override
  State<ActiveWorkoutSetRow> createState() => _ActiveWorkoutSetRowState();
}

class _ActiveWorkoutSetRowState extends State<ActiveWorkoutSetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late bool _isCompleted;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: widget.set.weight);
    _repsController = TextEditingController(text: widget.set.reps);
    _isCompleted = widget.set.isCompleted;

    // Add listeners to update the model and notify parent on change
    _weightController.addListener(_updateSet);
    _repsController.addListener(_updateSet);
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  // Method to notify parent when state changes
  void _updateSet() {
     // Only notify if the text has actually changed to avoid excessive rebuilds
     final newWeight = _weightController.text.trim();
     final newReps = _repsController.text.trim();

     if (newWeight != widget.set.weight || newReps != widget.set.reps || _isCompleted != widget.set.isCompleted) {
       widget.onSetUpdated(ActiveWorkoutSet(
         id: widget.set.id, // Pass the original set ID
         weight: newWeight,
         reps: newReps,
         isCompleted: _isCompleted,
       ));
     }
  }

  void _toggleCompletion(bool? value) {
    if (value == null) return;
    setState(() {
      _isCompleted = value;
    });
    _updateSet(); // Notify parent immediately on completion toggle
  }


  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Custom decoration for the input containers to match UI
    BoxDecoration inputDecoration = BoxDecoration(
      color: AppColors.mutedBackground,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(color: AppColors.inputBorderColor),
    );

    // Input field styling (minimal)
    InputDecoration minimalInputDecoration = const InputDecoration(
      border: InputBorder.none,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      isDense: true, // Compact padding
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0), // Space between set rows
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Completion Checkbox/Indicator
          SizedBox(
            width: 24, // Fixed width for checkbox
            child: Checkbox(
              value: _isCompleted,
              onChanged: _toggleCompletion,
              activeColor: AppColors.primary,
              checkColor: AppColors.primaryForeground,
              side: BorderSide(color: AppColors.mutedForeground),
              shape: CircleBorder(), // Circular shape
            ),
          ),
          const SizedBox(width: 8),
          // Set Number
          SizedBox(
            width: 30, // Fixed width for set number
            child: Text('${widget.setNumber}',
                style: textTheme.bodyLarge?.copyWith(color: AppColors.foreground, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center),
          ),
          const SizedBox(width: 16),

          // Weight Input
          Expanded(
            flex: 2,
            child: Container(
              decoration: inputDecoration,
              child: TextField(
                controller: _weightController,
                decoration: minimalInputDecoration.copyWith(hintText: 'KG'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))], // Allow numbers and decimals
                style: textTheme.bodyMedium?.copyWith(color: AppColors.foreground),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Reps Input
          Expanded(
             flex: 2,
            child: Container(
              decoration: inputDecoration,
              child: TextField(
                controller: _repsController,
                decoration: minimalInputDecoration.copyWith(hintText: 'Reps'),
                keyboardType: TextInputType.number,
                 inputFormatters: [FilteringTextInputFormatter.digitsOnly], // Allow only digits
                style: textTheme.bodyMedium?.copyWith(color: AppColors.foreground),
                 textAlign: TextAlign.center,
              ),
            ),
          ),
           const SizedBox(width: 8),

          // Optional: Set Options (e.g., Remove Set)
          // IconButton(
          //   icon: Icon(Icons.more_vert, color: AppColors.mutedForeground),
          //   onPressed: () { /* TODO: Set options */ },
          // ),
        ],
      ),
    );
  }
}
