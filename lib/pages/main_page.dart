import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/bottom_nav.dart';

import 'activity_page.dart';
import 'farms_page.dart';
import 'index_page.dart';
import 'login_page.dart';
import 'me_page.dart';
import 'trees_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    super.key,
  });

  @override
  State<MainPage> createState() =>
      _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // ============================================================
  // CURRENT NAVIGATION INDEX
  // ============================================================

  int _currentIndex = 0;

  // ============================================================
  // PAGE REFRESH KEYS
  // ============================================================

  int _homeRefreshKey = 0;
  int _farmsRefreshKey = 0;
  int _treesRefreshKey = 0;
  int _activitiesRefreshKey = 0;
  int _moreRefreshKey = 0;

  // Prevent multiple redirects to LoginPage.
  bool _redirectingToLogin = false;

  // ============================================================
  // BOTTOM NAVIGATION
  // ============================================================

  void _onBottomNavTap(int index) {
    if (_currentIndex == index) {
      _refreshCurrentPage(index);
      return;
    }

    setState(() {
      _currentIndex = index;

      _incrementRefreshKey(index);
    });
  }

  // ============================================================
  // REFRESH CURRENT PAGE
  // ============================================================

  void _refreshCurrentPage(int index) {
    setState(() {
      _incrementRefreshKey(index);
    });
  }

  // ============================================================
  // INCREMENT REFRESH KEY
  // ============================================================

  void _incrementRefreshKey(int index) {
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
  // REDIRECT TO LOGIN
  // ============================================================

  void _redirectToLogin() {
    if (_redirectingToLogin) {
      return;
    }

    _redirectingToLogin = true;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ),
          (route) => false,
        );
      },
    );
  }

  // ============================================================
  // BUILD APPLICATION PAGES
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
    final authProvider =
        context.watch<AuthProvider>();

    // ==========================================================
    // SESSION CHECKING
    // ==========================================================

    if (authProvider.isChecking) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF11732E),
          ),
        ),
      );
    }

    // ==========================================================
    // SESSION INVALID / USER LOGGED OUT
    // ==========================================================

    if (!authProvider.isAuthenticated) {
      _redirectToLogin();

      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF11732E),
          ),
        ),
      );
    }

    // ==========================================================
    // AUTHENTICATED APPLICATION
    // ==========================================================

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