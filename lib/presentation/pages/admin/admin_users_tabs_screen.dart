import 'package:flutter/material.dart';
import 'package:app/core/app_constants.dart';
import 'package:app/presentation/pages/admin/seniors/admin_seniors_screen.dart';
import 'package:app/presentation/pages/admin/volunteers/admin_volunteers_screen.dart';

class AdminUsersTabsScreen extends StatelessWidget {
  const AdminUsersTabsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'User Management',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Seniors'),
              Tab(text: 'Volunteers'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            AdminSeniorsScreen(),
            AdminVolunteersScreen(),
          ],
        ),
      ),
    );
  }
}
