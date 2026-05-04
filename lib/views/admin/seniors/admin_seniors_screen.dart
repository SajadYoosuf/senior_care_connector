import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:senior_care/core/app_constants.dart';
import 'package:senior_care/viewmodels/admin_viewmodel.dart';
import 'package:senior_care/views/admin/seniors/admin_senior_details_screen.dart';

class AdminSeniorsScreen extends StatefulWidget {
  const AdminSeniorsScreen({super.key});

  @override
  State<AdminSeniorsScreen> createState() => _AdminSeniorsScreenState();
}

class _AdminSeniorsScreenState extends State<AdminSeniorsScreen> {
  String selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final adminViewModel = context.watch<AdminViewModel>();
    final seniors = adminViewModel.seniors;

    // Filter logic
    final filteredSeniors = seniors.where((senior) {
      if (selectedFilter == 'All') return true;

      // Determine dynamic status
      final medCount = adminViewModel.userMedicineCounts[senior['id']] ?? 0;
      final hasCritical =
          adminViewModel.userHasCriticalMeds[senior['id']] ?? false;

      String effectiveStatus = (senior['status'] ?? 'Active').toString();
      if (medCount >= 3 || hasCritical) effectiveStatus = 'Highcare';

      return effectiveStatus.toLowerCase() == selectedFilter.toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      // Remove internal app bar as it is inside a main TabBar now
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search seniors...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
              ),
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 12),
                _buildFilterChip('Active'),
                const SizedBox(width: 12),
                _buildFilterChip('Inactive'),
                const SizedBox(width: 12),
                _buildFilterChip('Highcare'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Seniors List
          Expanded(
            child: filteredSeniors.isEmpty
                ? const Center(child: Text('No seniors found'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredSeniors.length,
                    itemBuilder: (context, index) {
                      final senior = filteredSeniors[index];
                      final medCount =
                          adminViewModel.userMedicineCounts[senior['id']] ?? 0;
                      final hasCritical =
                          adminViewModel.userHasCriticalMeds[senior['id']] ??
                          false;

                      String status = (senior['status'] ?? 'Active').toString();
                      if (medCount >= 3 || hasCritical) status = 'Highcare';

                      return _buildSeniorCard(
                        senior: senior,
                        name: senior['name'] ?? 'Unknown',
                        location:
                            senior['room'] ??
                            senior['address'] ??
                            'No location',
                        status: status,
                        medicineCount: medCount,
                        hasCriticalMeds: hasCritical,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSeniorCard({
    required Map<String, dynamic> senior,
    required String name,
    required String location,
    required String status,
    int medicineCount = 0,
    bool hasCriticalMeds = false,
  }) {
    Color statusColor;
    Color statusTextColor;

    switch (status.toLowerCase()) {
      case 'highcare':
      case 'high care':
        statusColor = Colors.red.shade100;
        statusTextColor = Colors.red;
        break;
      case 'active':
        statusColor = Colors.green.shade100;
        statusTextColor = Colors.green;
        break;
      case 'inactive':
        statusColor = Colors.orange.shade100;
        statusTextColor = Colors.orange;
        break;
      default:
        statusColor = Colors.blue.shade100;
        statusTextColor = Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AdminSeniorDetailsScreen(senior: senior),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (senior['isOnline'] == true)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (medicineCount > 0 || hasCriticalMeds) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.medication_outlined,
                          size: 14,
                          color: hasCriticalMeds ? Colors.red : Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          hasCriticalMeds
                              ? 'Critical Meds ($medicineCount)'
                              : '$medicineCount Medicines',
                          style: TextStyle(
                            color: hasCriticalMeds ? Colors.red : Colors.blue,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                status,
                style: TextStyle(
                  color: statusTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
