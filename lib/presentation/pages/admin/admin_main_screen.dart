import 'package:flutter/material.dart';
import 'package:app/core/app_constants.dart';
import 'package:app/presentation/pages/admin/dashboard/admin_dashboard_screen.dart';
import 'package:app/presentation/pages/admin/seniors/admin_seniors_screen.dart';
import 'package:app/presentation/pages/admin/volunteers/admin_volunteers_screen.dart';
import 'package:app/presentation/pages/admin/chat/admin_chat_list_screen.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminDashboardScreen(),
    const AdminSeniorsScreen(),
    const AdminChatListScreen(),
    const AdminVolunteersScreen(),
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
            icon: Icon(Icons.people_outline),
            label: 'Seniors',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: 'Chatbox',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard_outlined),
            label: 'Volunteers',
          ),
        ],
      ),
    );
  }
}
