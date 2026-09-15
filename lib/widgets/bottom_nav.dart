import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,

      type: BottomNavigationBarType.fixed,

      backgroundColor: Colors.white,

      selectedItemColor: Colors.green,
      unselectedItemColor: Colors.grey,

      selectedFontSize: 11,
      unselectedFontSize: 10,

      elevation: 8,

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.crop_square_outlined),
          activeIcon: Icon(Icons.crop_square),
          label: 'Farms',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.park_outlined),
          activeIcon: Icon(Icons.park),
          label: 'Trees',
        ),

        BottomNavigationBarItem(
  icon: Icon(Icons.assignment_outlined),
  activeIcon: Icon(Icons.assignment),
  label: 'Activities',
),

        BottomNavigationBarItem(
          icon: Icon(Icons.menu_outlined),
          activeIcon: Icon(Icons.menu),
          label: 'More',
        ),
      ],
    );
  }
}