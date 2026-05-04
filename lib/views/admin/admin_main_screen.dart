import 'package:flutter/material.dart';

import 'package:senior_care/core/app_constants.dart';
import 'package:senior_care/views/admin/admin_users_tabs_screen.dart';
import 'package:senior_care/views/admin/chat/admin_chat_list_screen.dart';
import 'package:senior_care/views/admin/dashboard/admin_dashboard_screen.dart';
import 'package:senior_care/views/admin/requests/admin_requests_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  List<Widget> get _screens => [
    const AdminDashboardScreen(),
    const AdminRequestsScreen(),
    const AdminUsersTabsScreen(),
    const AdminChatListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Requests',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chatbox',
          ),
        ],
      ),
    );
  }
}
