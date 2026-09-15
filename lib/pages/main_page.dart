import 'package:flutter/material.dart';
import 'home_page.dart';
import 'index_page.dart';
import 'me_page.dart';
import 'farms_page.dart';
import 'blocks_page.dart';
import '../widgets/bottom_nav.dart';
import 'trees_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

List<Widget> get _pages => [
  const IndexPage(
    
  ),
        // const Center(
        //   child: Text(
        //     'History',
        //     style: TextStyle(
        //       fontSize: 24,
        //       fontWeight: FontWeight.bold,
        //     ),
        //   ),
        // ),

           FarmsPage(
          onBack: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),



        BlocksPage(
          onBack: () {
            setState(() {
              _currentIndex = 0;
            });
          },
        ),

         

        TreesPage(
          
          onBack: () {
            setState(() {
              _currentIndex = 0;
            });
          },
           onScan: () {
    setState(() {
              _currentIndex = 0;
    });
  },
        ),

MePage(
  onBack: () {
    setState(() {
      _currentIndex = 0;
    });
  },
),
      ];

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}