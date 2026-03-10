import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../core/app_constants.dart';
import '../../../domain/entities/volunteer_entity.dart';
import '../../providers/auth_provider.dart';
import '../chat/chat_detail_screen.dart';

import '../../widgets/volunteer_card.dart';

class VolunteersScreen extends StatefulWidget {
  const VolunteersScreen({super.key});

  @override
  State<VolunteersScreen> createState() => _VolunteersScreenState();
}

class _VolunteersScreenState extends State<VolunteersScreen> {
  List<VolunteerEntity> _allVolunteers = [];
  List<VolunteerEntity> _volunteers = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = ['All', 'Nearby', 'Top Rated', 'Doctors'];

  @override
  void initState() {
    super.initState();
    _loadVolunteers();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVolunteers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', whereIn: ['volunteer', 'both'])
          .get();

      final currentUser = context.read<AuthProvider>().user;
      final currentLat = currentUser?.latitude;
      final currentLng = currentUser?.longitude;

      List<VolunteerEntity> volunteerList = [];
      for (var doc in snapshot.docs) {
        if (doc.id == currentUser?.id) continue;

        final data = doc.data();
        double distance = 0.0;
        final double? lat = data['latitude'] as double?;
        final double? lng = data['longitude'] as double?;

        if (currentLat != null &&
            currentLng != null &&
            lat != null &&
            lng != null) {
          distance =
              Geolocator.distanceBetween(currentLat, currentLng, lat, lng) /
              1000; // to km
        }

        volunteerList.add(
          VolunteerEntity(
            id: doc.id,
            name: data['name'] ?? 'Unknown',
            specialty: data['profession'] ?? 'General Helper',
            rating: (data['rating'] ?? 5.0).toDouble(),
            reviewCount: data['completedTasks'] ?? 0,
            distance: distance,
            imageUrl:
                data['profileImageUrl'] ??
                'https://i.pravatar.cc/150?u=${doc.id}',
          ),
        );
      }

      if (mounted) {
        setState(() {
          _allVolunteers = volunteerList;
          _isLoading = false;
        });
        _applyFilters();
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    List<VolunteerEntity> filtered = List.from(_allVolunteers);

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((v) {
        return v.name.toLowerCase().contains(query) ||
            v.specialty.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedFilter == 'Nearby') {
      filtered = filtered
          .where((v) => v.distance < 20.0)
          .toList(); // less than 20km
      filtered.sort((a, b) => a.distance.compareTo(b.distance));
    } else if (_selectedFilter == 'Top Rated') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedFilter == 'Doctors') {
      filtered = filtered
          .where(
            (v) =>
                v.specialty.toLowerCase().contains('doctor') ||
                v.specialty.toLowerCase().contains('dr.') ||
                v.specialty.toLowerCase().contains('nurse') ||
                v.specialty.toLowerCase().contains('md'),
          )
          .toList();
    }

    if (mounted) {
      setState(() {
        _volunteers = filtered;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Volunteers',
          style: TextStyle(color: AppColors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: AppColors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by name or skills.',
                      prefixIcon: const Icon(Icons.search, color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: const Icon(Icons.tune, color: AppColors.black),
                ),
              ],
            ),
          ),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = filter;
                      _applyFilters();
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      filter,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.black,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          // Volunteer List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _volunteers.isEmpty
                ? Center(
                    child: Text(
                      'No active volunteers found.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _volunteers.length,
                    itemBuilder: (context, index) {
                      return VolunteerCard(
                        volunteer: _volunteers[index],
                        onCall: () {
                          // Call logic
                        },
                        onChat: () {
                          final currentUser = context.read<AuthProvider>().user;
                          if (currentUser != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatDetailScreen(
                                  taskId: _volunteers[index].id,
                                  currentUserId: currentUser.id,
                                  userName: _volunteers[index].name,
                                  userAvatar: _volunteers[index].imageUrl,
                                  recipientId: _volunteers[index].id,
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
