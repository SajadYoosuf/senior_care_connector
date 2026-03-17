import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app/core/app_constants.dart';
import 'package:app/presentation/providers/admin_provider.dart';
import 'admin_volunteer_details_screen.dart';

class AdminVolunteersScreen extends StatefulWidget {
  const AdminVolunteersScreen({super.key});

  @override
  State<AdminVolunteersScreen> createState() => _AdminVolunteersScreenState();
}

class _AdminVolunteersScreenState extends State<AdminVolunteersScreen> {
  String selectedFilter = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final volunteers = adminProvider.volunteers;

    // Filter logic
    final filteredVolunteers = volunteers.where((v) {
      // Role check (already handled in provider but safe to keep)
      // Name search
      final nameMatches = (v['name'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase());
      if (!nameMatches) return false;

      // Status filter
      if (selectedFilter == 'All') return true;
      if (selectedFilter == 'Pending') return v['isApproved'] != true;
      if (selectedFilter == 'Approved') return v['isApproved'] == true && v['isActive'] != false;
      if (selectedFilter == 'Deactivated') return v['isActive'] == false;
      
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Volunteer Management',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search volunteers...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.zero,
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

          // Status Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All'),
                const SizedBox(width: 8),
                _buildFilterChip('Pending'),
                const SizedBox(width: 8),
                _buildFilterChip('Approved'),
                const SizedBox(width: 8),
                _buildFilterChip('Deactivated'),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Volunteers List
          Expanded(
            child: filteredVolunteers.isEmpty
                ? const Center(child: Text('No volunteers found matching filters'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: filteredVolunteers.length,
                    itemBuilder: (context, index) {
                      final volunteer = filteredVolunteers[index];
                      return _buildVolunteerCard(volunteer, adminProvider);
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
      onTap: () => setState(() => selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isSelected ? AppColors.primary : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildVolunteerCard(Map<String, dynamic> v, AdminProvider provider) {
    final bool isApproved = v['isApproved'] == true;
    final bool isActive = v['isActive'] != false;
    final String name = v['name'] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(v['email'] ?? v['phone'] ?? 'No contact info', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  ],
                ),
              ),
              _buildSimpleStatusBadge(isApproved, isActive),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!isApproved)
                TextButton.icon(
                  onPressed: () => provider.approveVolunteer(v['id']),
                  icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                  label: const Text('Approve', style: TextStyle(color: Colors.green)),
                ),
              if (isApproved)
                TextButton.icon(
                  onPressed: () => provider.toggleVolunteerStatus(v['id'], !isActive),
                  icon: Icon(isActive ? Icons.block : Icons.replay, size: 18, color: isActive ? Colors.red : Colors.orange),
                  label: Text(isActive ? 'Deactivate' : 'Reactivate', style: TextStyle(color: isActive ? Colors.red : Colors.orange)),
                ),
              const SizedBox(width: 8),
              OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminVolunteerDetailsScreen(volunteer: v))),
                style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatusBadge(bool isApproved, bool isActive) {
    String label = 'Pending';
    Color color = Colors.orange;
    
    if (isApproved) {
      if (isActive) {
        label = 'Active';
        color = Colors.green;
      } else {
        label = 'Disabled';
        color = Colors.red;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
