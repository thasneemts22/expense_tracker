import 'package:expense_manager/screens/transactions_history_screen.dart';
import 'package:flutter/material.dart';
import '../features/transactions/screens/home_screen.dart';

import 'profile_screen.dart';
import '../widgets/custom_bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> pages = const [
    HomeScreen(),
    TransactionsHistoryScreen(),
    ProfileScreen(),
  ];

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: pages[selectedIndex],

      bottomNavigationBar: SafeArea(
        child: CustomBottomNav(
          currentIndex: selectedIndex,
          onTap: onItemTapped,
        ),
      ),
    );
  }
}
