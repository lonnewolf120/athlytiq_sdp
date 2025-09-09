import 'package:flutter/material.dart';

class TrainerApplicationStatusScreen extends StatefulWidget {
  const TrainerApplicationStatusScreen({super.key});

  @override
  State<TrainerApplicationStatusScreen> createState() =>
      _TrainerApplicationStatusScreenState();
}

class _TrainerApplicationStatusScreenState
    extends State<TrainerApplicationStatusScreen> {
  String applicationStatus =
      'Under Review'; // Can be: 'Pending', 'Under Review', 'Approved', 'Rejected'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Application Status',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[700]!, width: 1),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _getStatusColor().withOpacity(0.2),
                      border: Border.all(color: _getStatusColor(), width: 3),
                    ),
                    child: Icon(
                      _getStatusIcon(),
                      size: 40,
                      color: _getStatusColor(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Application Status',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    applicationStatus,
                    style: TextStyle(
                      color: _getStatusColor(),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _getStatusMessage(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Application Details
            const Text(
              'Application Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailItem('Application ID', '#TR2025001'),
            _buildDetailItem('Submitted On', 'Aug 10, 2025'),
            _buildDetailItem('Full Name', 'Rahman Ahmed'),
            _buildDetailItem('Email', 'rahman.ahmed@email.com'),
            _buildDetailItem('Phone', '+880 1712 345 678'),
            _buildDetailItem('Experience', '5 years'),
            _buildDetailItem(
              'Specializations',
              'Weight Training, Cardio, Yoga',
            ),

            const SizedBox(height: 32),

            // Timeline
            const Text(
              'Application Timeline',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),

            _buildTimelineItem(
              'Application Submitted',
              'Aug 10, 2025 at 2:30 PM',
              Icons.send,
              true,
              isFirst: true,
            ),
            _buildTimelineItem(
              'Under Review',
              'Aug 11, 2025 at 9:00 AM',
              Icons.rate_review,
              true,
            ),
            _buildTimelineItem(
              'Background Verification',
              'Pending',
              Icons.verified_user,
              false,
            ),
            _buildTimelineItem(
              'Final Decision',
              'Pending',
              Icons.check_circle,
              false,
              isLast: true,
            ),

            const SizedBox(height: 32),

            // Action Buttons
            if (applicationStatus == 'Rejected') ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/trainer-registration');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Reapply',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  // Show contact support dialog
                  _showContactSupport();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Contact Support',
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

  Color _getStatusColor() {
    switch (applicationStatus) {
      case 'Approved':
        return Colors.green;
      case 'Rejected':
        return Colors.red;
      case 'Under Review':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (applicationStatus) {
      case 'Approved':
        return Icons.check_circle;
      case 'Rejected':
        return Icons.cancel;
      case 'Under Review':
        return Icons.rate_review;
      default:
        return Icons.pending;
    }
  }

  String _getStatusMessage() {
    switch (applicationStatus) {
      case 'Approved':
        return 'Congratulations! Your trainer application has been approved. You can now start accepting sessions.';
      case 'Rejected':
        return 'Your application has been rejected. Please review the feedback and consider reapplying with updated information.';
      case 'Under Review':
        return 'Your application is currently under review by our team. We will notify you within 24-48 hours with an update.';
      default:
        return 'Your application has been submitted and is pending initial review.';
    }
  }

  Widget _buildDetailItem(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String subtitle,
    IconData icon,
    bool isCompleted, {
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            if (!isFirst)
              Container(
                width: 2,
                height: 20,
                color: isCompleted ? Colors.green : Colors.grey[600],
              ),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? Colors.green : Colors.grey[800],
                border: Border.all(
                  color: isCompleted ? Colors.green : Colors.grey[600]!,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isCompleted ? Colors.white : Colors.grey[400],
              ),
            ),
            if (!isLast)
              Container(width: 2, height: 20, color: Colors.grey[600]),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isCompleted ? Colors.white : Colors.grey[400],
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showContactSupport() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text(
              'Contact Support',
              style: TextStyle(color: Colors.white),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need help with your application?',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Email: support@pulse.com',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Phone: +880 1700 000 000',
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'WhatsApp: +880 1700 000 000',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }
}
