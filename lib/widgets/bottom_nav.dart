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
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        12,
        0,
        12,
        10,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.08,
              ),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,

          type: BottomNavigationBarType.fixed,

          backgroundColor: Colors.white,

          selectedItemColor:
              const Color(0xFF087A2F),

          unselectedItemColor:
              const Color(0xFF9AA39D),

          selectedFontSize: 10,
          unselectedFontSize: 9,

          selectedLabelStyle:
              const TextStyle(
            fontWeight: FontWeight.w600,
          ),

          unselectedLabelStyle:
              const TextStyle(
            fontWeight: FontWeight.w500,
          ),

          elevation: 0,

          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_outlined,
                size: 20,
              ),
              activeIcon: Icon(
                Icons.home,
                size: 20,
              ),
              label: 'Home',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.crop_square_outlined,
                size: 20,
              ),
              activeIcon: Icon(
                Icons.crop_square,
                size: 20,
              ),
              label: 'Farms',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.park_outlined,
                size: 20,
              ),
              activeIcon: Icon(
                Icons.park,
                size: 20,
              ),
              label: 'Trees',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.assignment_outlined,
                size: 20,
              ),
              activeIcon: Icon(
                Icons.assignment,
                size: 20,
              ),
              label: 'Activities',
            ),

            BottomNavigationBarItem(
              icon: Icon(
                Icons.menu_outlined,
                size: 20,
              ),
              activeIcon: Icon(
                Icons.menu,
                size: 20,
              ),
              label: 'More',
            ),
          ],
        ),
      ),
    );
  }
}