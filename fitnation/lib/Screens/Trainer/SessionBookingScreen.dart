import 'package:flutter/material.dart';

class SessionBookingScreen extends StatefulWidget {
  final String? trainerId;
  final String? preSelectedTimeSlot;
  
  const SessionBookingScreen({
    super.key,
    this.trainerId,
    this.preSelectedTimeSlot,
  });

  @override
  State<SessionBookingScreen> createState() => _SessionBookingScreenState();
}

class _SessionBookingScreenState extends State<SessionBookingScreen> {
  int currentStep = 0;
  final PageController _pageController = PageController();
  
  // Booking data
  DateTime? selectedDate;
  String? selectedTimeSlot;
  String selectedSessionType = 'Personal Training';
  String selectedDuration = '60 min';
  String selectedLocation = 'Gym';
  final TextEditingController _notesController = TextEditingController();
  
  // Session types
  final List<Map<String, dynamic>> sessionTypes = [
    {
      'name': 'Personal Training',
      'price': 2500,
      'description': 'One-on-one training session',
      'icon': Icons.fitness_center,
    },
    {
      'name': 'Group Training',
      'price': 1500,
      'description': 'Small group session (2-4 people)',
      'icon': Icons.group,
    },
    {
      'name': 'Online Session',
      'price': 2000,
      'description': 'Virtual training via video call',
      'icon': Icons.video_call,
    },
    {
      'name': 'Nutrition Consultation',
      'price': 1800,
      'description': 'Diet and meal planning session',
      'icon': Icons.restaurant_menu,
    },
  ];

  final List<String> durations = ['30 min', '45 min', '60 min', '90 min'];
  final List<String> locations = ['Gym', 'Home', 'Park', 'Online'];

  @override
  void initState() {
    super.initState();
    selectedTimeSlot = widget.preSelectedTimeSlot;
    selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (currentStep < 2) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  int _getSelectedSessionPrice() {
    final session = sessionTypes.firstWhere(
      (session) => session['name'] == selectedSessionType,
      orElse: () => sessionTypes[0],
    );
    return session['price'];
  }

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
          'Book Session',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: List.generate(3, (index) {
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: index <= currentStep ? Colors.red : Colors.grey[800],
                            border: Border.all(
                              color: index <= currentStep ? Colors.red : Colors.grey[600]!,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: index < currentStep
                                ? const Icon(Icons.check, color: Colors.white, size: 16)
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color: index <= currentStep ? Colors.white : Colors.grey[400],
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                          ),
                        ),
                        if (index < 2)
                          Expanded(
                            child: Container(
                              height: 2,
                              margin: const EdgeInsets.only(left: 8),
                              decoration: BoxDecoration(
                                color: index < currentStep ? Colors.red : Colors.grey[800],
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),

          // Step Labels
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStepLabel('Select Session', 0),
                _buildStepLabel('Date & Time', 1),
                _buildStepLabel('Confirmation', 2),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Page View
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentStep = index;
                });
              },
              children: [
                _buildSessionSelectionStep(),
                _buildDateTimeStep(),
                _buildConfirmationStep(),
              ],
            ),
          ),

          // Bottom Navigation
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              border: Border(top: BorderSide(color: Colors.grey[700]!, width: 1)),
            ),
            child: Column(
              children: [
                // Price Summary
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '৳${_getSelectedSessionPrice()}',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Navigation Buttons
                Row(
                  children: [
                    if (currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Previous',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    if (currentStep > 0) const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: currentStep < 2 ? _nextStep : _confirmBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          currentStep < 2 ? 'Next' : 'Confirm Booking',
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int step) {
    return Text(
      label,
      style: TextStyle(
        color: step <= currentStep ? Colors.white : Colors.grey[400],
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSessionSelectionStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Session Type',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose the type of training session you want',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Session Types
          ...sessionTypes.map((session) {
            final isSelected = selectedSessionType == session['name'];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.red : Colors.grey[700]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20),
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    session['icon'],
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                title: Text(
                  session['name'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      session['description'],
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '৳${session['price']}',
                      style: TextStyle(
                        color: isSelected ? Colors.red : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: Radio<String>(
                  value: session['name'],
                  groupValue: selectedSessionType,
                  onChanged: (value) {
                    setState(() {
                      selectedSessionType = value!;
                    });
                  },
                  activeColor: Colors.red,
                ),
                onTap: () {
                  setState(() {
                    selectedSessionType = session['name'];
                  });
                },
              ),
            );
          }),

          const SizedBox(height: 24),

          // Duration Selection
          const Text(
            'Duration',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: durations.map((duration) {
              final isSelected = selectedDuration == duration;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedDuration = duration;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.grey[600]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        duration,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Location Selection
          const Text(
            'Location',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: locations.map((location) {
              final isSelected = selectedLocation == location;
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedLocation = location;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.red : Colors.grey[800],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.red : Colors.grey[600]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        location,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Date & Time',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Choose when you want your training session',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Date Selection
          const Text(
            'Select Date',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          
          // Date picker (simplified)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!, width: 1),
            ),
            child: InkWell(
              onTap: () => _showDatePicker(),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.grey),
                  const SizedBox(width: 12),
                  Text(
                    selectedDate != null
                        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                        : 'Select Date',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Time Selection
          const Text(
            'Available Time Slots',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // Time slots grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 2.5,
            ),
            itemCount: _getAvailableTimeSlots().length,
            itemBuilder: (context, index) {
              final timeSlot = _getAvailableTimeSlots()[index];
              final isSelected = selectedTimeSlot == timeSlot;
              return InkWell(
                onTap: () {
                  setState(() {
                    selectedTimeSlot = timeSlot;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.red : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.red : Colors.grey[600]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      timeSlot,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          // Special Instructions
          const Text(
            'Special Instructions (Optional)',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Any special requirements or notes for your trainer...',
              hintStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: Colors.grey[900],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[700]!, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Confirmation',
            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            'Please review your booking details',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),

          // Trainer Info
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[700]!, width: 1),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1594381898411-846e7d193883?w=400',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sarah Johnson',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Certified Personal Trainer',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.orange, size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            '4.8',
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(156 reviews)',
                            style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Booking Details
          _buildDetailSection('Session Details', [
            {'label': 'Session Type', 'value': selectedSessionType},
            {'label': 'Duration', 'value': selectedDuration},
            {'label': 'Location', 'value': selectedLocation},
          ]),

          const SizedBox(height: 16),

          _buildDetailSection('Date & Time', [
            {
              'label': 'Date',
              'value': selectedDate != null
                  ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                  : 'Not selected'
            },
            {'label': 'Time', 'value': selectedTimeSlot ?? 'Not selected'},
          ]),

          const SizedBox(height: 16),

          _buildDetailSection('Payment Summary', [
            {'label': 'Session Fee', 'value': '৳${_getSelectedSessionPrice()}'},
            {'label': 'Platform Fee', 'value': '৳100'},
            {'label': 'Total Amount', 'value': '৳${_getSelectedSessionPrice() + 100}', 'isTotal': true},
          ]),

          if (_notesController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection('Special Instructions', [
              {'label': 'Notes', 'value': _notesController.text},
            ]),
          ],

          const SizedBox(height: 24),

          // Terms and Conditions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[700]!, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cancellation Policy',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '• Free cancellation up to 24 hours before the session\n'
                  '• 50% refund for cancellations within 24 hours\n'
                  '• No refund for no-shows or same-day cancellations',
                  style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Map<String, dynamic>> details) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[700]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...details.map((detail) {
            final isTotal = detail['isTotal'] ?? false;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    detail['label'],
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    detail['value'],
                    style: TextStyle(
                      color: isTotal ? Colors.red : Colors.white,
                      fontSize: isTotal ? 16 : 14,
                      fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  List<String> _getAvailableTimeSlots() {
    return [
      '09:00 AM',
      '10:30 AM',
      '12:00 PM',
      '01:30 PM',
      '03:00 PM',
      '04:30 PM',
      '06:00 PM',
      '07:30 PM',
    ];
  }

  void _showDatePicker() {
    showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.red,
              surface: Colors.grey[900],
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    ).then((date) {
      if (date != null) {
        setState(() {
          selectedDate = date;
        });
      }
    });
  }

  void _confirmBooking() {
    // Handle booking confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Booking Confirmed!', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your training session has been booked successfully.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking ID: #TRN2025001',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'You will receive a confirmation email shortly.',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
