import 'package:flutter/material.dart';
import 'package:isro/screens/infoPage.dart';
import 'package:isro/screens/quizHome.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    Quizhome(),
    Infopage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.deepPurple,   // active icon color
        unselectedItemColor: Colors.grey,       // inactive icon color
        showSelectedLabels: false,              // hide text labels
        showUnselectedLabels: false,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Stats",
          ),
        ],
      ),
    );
  }
}
