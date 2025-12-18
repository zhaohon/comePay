import 'package:flutter/material.dart';
import 'CardScreen.dart';
import 'HomeScreen.dart';
import 'ProfilScreen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    CardScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 🔹 Active icon dengan animasi
  Widget buildActiveIcon(IconData icon, bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: isActive
          ? const EdgeInsets.symmetric(horizontal: 50, vertical: 20)
          : const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          icon,
          key: ValueKey<bool>(isActive), // biar AnimatedSwitcher tahu state berubah
          color: isActive ? Colors.white : Colors.grey,
          size: isActive ? 28 : 26,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: [
          BottomNavigationBarItem(
            icon: buildActiveIcon(Icons.home, _selectedIndex == 0),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: buildActiveIcon(Icons.credit_card, _selectedIndex == 1),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: buildActiveIcon(Icons.person, _selectedIndex == 2),
            label: '',
          ),
        ],
      ),
    );
  }
}
