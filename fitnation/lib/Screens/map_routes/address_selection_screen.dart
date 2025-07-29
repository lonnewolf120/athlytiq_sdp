import 'package:flutter/material.dart';
import 'package:map_routes/themes/colors.dart';
import 'package:map_routes/themes/text_styles.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<String> _suggestedAddresses = [
    'Gulshan, Dhaka',
    'Banani, Dhaka',
    'Uttara, Dhaka',
    'Dhanmondi, Dhaka',
    'Mohakhali, Dhaka',
    'Mirpur DOHS, Dhaka',
  ];

  List<String> _filteredAddresses = [];

  @override
  void initState() {
    super.initState();
    _filteredAddresses = _suggestedAddresses;
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredAddresses = _suggestedAddresses
          .where((addr) => addr.toLowerCase().contains(query))
          .toList();
    });
  }

  void _onAddressSelected(String address) {
    debugPrint('Selected Address: $address');
    Navigator.pop(context, address);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Select Address', style: AppTextStyles.lightHeadlineMedium),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredAddresses.isEmpty
                  ? Center(
                      child: Text(
                        'No matches found.',
                        style: AppTextStyles.lightBody,
                      ),
                    )
                  : ListView.separated(
                      itemCount: _filteredAddresses.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final address = _filteredAddresses[index];
                        return ListTile(
                          title: Text(address, style: AppTextStyles.darkBody),
                          onTap: () => _onAddressSelected(address),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
