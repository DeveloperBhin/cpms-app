import 'package:flutter/material.dart';

import 'index_page.dart';
import 'me_page.dart';
import 'farms_page.dart';
import 'trees_page.dart';
import 'activity_page.dart';
import '../theme/app_text_styles.dart';
import '../widgets/bottom_nav.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  // Used to force a fresh instance of a page when
  // the user selects a bottom-navigation tab.
  int _homeRefreshKey = 0;
  int _farmsRefreshKey = 0;
  int _treesRefreshKey = 0;
  int _activitiesRefreshKey = 0;
  int _moreRefreshKey = 0;

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;

      // Force the selected page to be recreated.
      //
      // Its initState() will run again and therefore
      // reload fresh data from the backend.
      switch (index) {
        case 0:
          _homeRefreshKey++;
          break;

        case 1:
          _farmsRefreshKey++;
          break;

        case 2:
          _treesRefreshKey++;
          break;

        case 3:
          _activitiesRefreshKey++;
          break;

        case 4:
          _moreRefreshKey++;
          break;
      }
    });
  }

  // ============================================================
  // GO HOME
  // ============================================================

  void _goHome() {
    setState(() {
      _currentIndex = 0;
      _homeRefreshKey++;
    });
  }

  // ============================================================
  // PAGES
  // ============================================================

  List<Widget> _buildPages() {
    return [
      // ========================================================
      // HOME
      // ========================================================

      IndexPage(
        key: ValueKey(
          'home_$_homeRefreshKey',
        ),
      ),

      // ========================================================
      // FARMS
      // ========================================================

      FarmsPage(
        key: ValueKey(
          'farms_$_farmsRefreshKey',
        ),
        onBack: _goHome,
      ),

      // ========================================================
      // TREES
      // ========================================================

      TreePage(
        key: ValueKey(
          'trees_$_treesRefreshKey',
        ),
        onBack: _goHome,
      ),

      // ========================================================
      // ACTIVITIES
      // ========================================================

      ActivityPage(
        key: ValueKey(
          'activities_$_activitiesRefreshKey',
        ),
        onBack: _goHome,
      ),

      // ========================================================
      // MORE / PROFILE
      // ========================================================

      MePage(
        key: ValueKey(
          'more_$_moreRefreshKey',
        ),
        onBack: _goHome,
      ),
    ];
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _buildPages(),
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}