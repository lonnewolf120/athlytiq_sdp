import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitnation/models/trainer/trainer_application.dart';
import 'package:fitnation/providers/trainer_provider.dart';

class PlanVerificationRequestScreen extends ConsumerStatefulWidget {
  final String planId;
  final String planType; // 'workout' or 'meal'

  const PlanVerificationRequestScreen({
    super.key,
    required this.planId,
    required this.planType,
  });

  @override
  ConsumerState<PlanVerificationRequestScreen> createState() =>
      _PlanVerificationRequestScreenState();
}

class _PlanVerificationRequestScreenState
    extends ConsumerState<PlanVerificationRequestScreen> {
  String _selectedSpecialization = '';
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submitVerificationRequest() async {
    if (_selectedSpecialization.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a specialization'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(trainerProvider.notifier).requestPlanVerification({
        'plan_id': widget.planId,
        'plan_type': widget.planType,
        'specialization': _selectedSpecialization,
        'notes': _notesController.text,
      });

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification request submitted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Verify ${widget.planType.toUpperCase()} Plan',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 32),
            const Text(
              'Select Expert Specialization',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: relevantSpecializations.map((spec) {
                final isSelected = _selectedSpecialization == spec.name;
                return FilterChip(
                  label: Text(spec.displayName),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedSpecialization = selected ? spec.name : '';
                    });
                  },
                  backgroundColor: Colors.grey[800],
                  selectedColor: Colors.red,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[300],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            const Text(
              'Additional Notes (Optional)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _notesController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Any specific concerns or questions...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitVerificationRequest,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Submit for Verification',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                widget.planType == 'workout'
                    ? Icons.fitness_center
                    : Icons.restaurant_menu,
                color: Colors.red,
              ),
              const SizedBox(width: 12),
              Text(
                '${widget.planType.toUpperCase()} Plan Verification',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Get your ${widget.planType} plan reviewed by a certified expert. '
            'They will provide feedback and suggestions to ensure your plan is safe and effective.',
            style: TextStyle(color: Colors.grey[400]),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Colors.yellow, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Usually reviewed within 24-48 hours',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
