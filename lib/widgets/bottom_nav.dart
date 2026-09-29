import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        18,
        8,
        18,
        16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: const Color(0xFFDCE8DF),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(
                alpha: 0.14,
              ),
              blurRadius: 18,
              spreadRadius: 1,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF087A2F),
          unselectedItemColor: const Color(0xFF9AA39D),
          selectedFontSize: 10,
          unselectedFontSize: 9,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,

          items: [
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.home_outlined,
                size: 20,
              ),
              activeIcon: const Icon(
                Icons.home,
                size: 20,
              ),
              label: l10n.home,
            ),

            BottomNavigationBarItem(
              icon: const Icon(
                Icons.crop_square_outlined,
                size: 20,
              ),
              activeIcon: const Icon(
                Icons.crop_square,
                size: 20,
              ),
              label: l10n.farms,
            ),

            BottomNavigationBarItem(
              icon: const Icon(
                Icons.park_outlined,
                size: 20,
              ),
              activeIcon: const Icon(
                Icons.park,
                size: 20,
              ),
              label: l10n.trees,
            ),

            BottomNavigationBarItem(
              icon: const Icon(
                Icons.assignment_outlined,
                size: 20,
              ),
              activeIcon: const Icon(
                Icons.assignment,
                size: 20,
              ),
              label: l10n.activities,
            ),

            BottomNavigationBarItem(
              icon: const Icon(
                Icons.menu_outlined,
                size: 20,
              ),
              activeIcon: const Icon(
                Icons.menu,
                size: 20,
              ),
              label: l10n.more,
            ),
          ],
        ),
      ),
    );
  }
}