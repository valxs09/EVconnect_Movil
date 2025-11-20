import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/wallet/wallet_screen.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  final Color _backgroundColor = const Color(0xFF37A686);

  final List<Widget> _screens = [
    const HomeScreen(),
    const VirtualCardScreen(),
    const HistoryScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        elevation: 0,
        backgroundColor: _backgroundColor,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white70,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        items: [
          _buildNavItem(Icons.star, 'Inicio', 0),
          _buildNavItem(Icons.credit_card_outlined, 'Tarjetas', 1),
          _buildNavItem(Icons.history, 'Historial', 2),
        ],
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    String label,
    int index,
  ) {
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        decoration:
            index == _selectedIndex
                ? BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                )
                : null,
        child: Icon(icon, size: 24),
      ),
      label: label,
    );
  }
}
