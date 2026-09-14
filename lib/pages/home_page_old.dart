/// HomePage - Main screen of TARI Disease Detector
///
/// Main hub of the application where users can:
/// - Access plant disease scanning
/// - View available crops
/// - Access plant information
/// - Navigate to tips
///
/// The application can remain in dark mode globally,
/// while this page intentionally uses a white background.

import 'package:flutter/material.dart';

import 'tips_page.dart';
import 'scan_page.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;

  late List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    pages = [
      _buildHomeContent(context),
      const ScanPage(),
      const TipsPage(),
      const PlantDetailPage(
        plantName: 'Avocado',
        image: 'assets/images/avocado.jpeg',
      ),
    ];

    return Scaffold(
      // ============================================================
      // WHITE PAGE BACKGROUND
      // ============================================================
      backgroundColor: Colors.white,

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        title: const Text(
          'TARI Disease Detector',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(
              Icons.language,
              color: Colors.black87,
            ),
            tooltip: 'Select Language',
            onPressed: () {
              _showLanguageDialog(context);
            },
          ),
        ],
      ),

      // ============================================================
      // PAGE CONTENT
      // ============================================================
      body: pages[_index],

      // ============================================================
      // SCAN BUTTON
      // ============================================================
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerDocked,

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF11732E),
        foregroundColor: Colors.white,
        elevation: 4,

        onPressed: () {
          setState(() {
            _index = 1;
          });
        },

        child: const Icon(
          Icons.camera_alt,
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================
      bottomNavigationBar: BottomAppBar(
        height: 55,
        color: Colors.white,
        surfaceTintColor: Colors.white,

        shape: const CircularNotchedRectangle(),
        notchMargin: 8,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // HOME
            IconButton(
              tooltip: 'Home',
              icon: Icon(
                Icons.home,
                color: _index == 0
                    ? const Color(0xFF11732E)
                    : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _index = 0;
                });
              },
            ),

            // TIPS
            IconButton(
              tooltip: 'Tips',
              icon: Icon(
                Icons.tips_and_updates,
                color: _index == 2
                    ? const Color(0xFF11732E)
                    : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _index = 2;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // HOME CONTENT
  // ================================================================

  Widget _buildHomeContent(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,

      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),

            Expanded(
              child: Card(
                color: Colors.white,
                margin: EdgeInsets.zero,

                clipBehavior: Clip.antiAlias,

                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                    bottom: Radius.zero,
                  ),
                ),

                child: Stack(
                  children: [
                    // ==================================================
                    // BACKGROUND IMAGE
                    // ==================================================

                    Positioned.fill(
                      child: Image.asset(
                        'assets/images/scan.jpeg',
                        fit: BoxFit.cover,
                      ),
                    ),

                    // ==================================================
                    // GREEN OVERLAY
                    // ==================================================

                    Positioned.fill(
                      child: Container(
                        color: Colors.green.withOpacity(0.45),
                      ),
                    ),

                    // ==================================================
                    // CROP CARDS
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                      ),

                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildInnerCard(
                              context: context,
                              image:
                                  'assets/images/avocado.jpeg',
                              title: 'Avocado',
                              plantName: 'Avocado',
                            ),

                            const SizedBox(height: 20),

                            _buildInnerCard(
                              context: context,
                              image:
                                  'assets/images/cashew.jpeg',
                              title: 'Cashew',
                              plantName: 'Cashew',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // CROP CARD
  // ================================================================

  Widget _buildInnerCard({
    required BuildContext context,
    required String image,
    required String title,
    required String plantName,
  }) {
    return Card(
      color: Colors.white,
      elevation: 8,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),

      clipBehavior: Clip.antiAlias,

      child: SizedBox(
        height: 160,
        width: double.infinity,

        child: Stack(
          children: [
            // ========================================================
            // IMAGE
            // ========================================================

            Positioned.fill(
              child: Image.asset(
                image,
                fit: BoxFit.cover,
              ),
            ),

            // ========================================================
            // BOTTOM BAR
            // ========================================================

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,

              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlantDetailPage(
                        plantName: plantName,
                        image: image,
                      ),
                    ),
                  );
                },

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),

                  color: const Color(0xFF11732E),

                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [
                      // =================================================
                      // CROP NAME
                      // =================================================

                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),

                          overflow:
                              TextOverflow.ellipsis,
                        ),
                      ),

                      // =================================================
                      // ARROW
                      // =================================================

                      Container(
                        padding:
                            const EdgeInsets.all(4),

                        decoration:
                            const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: Color(0xFF11732E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // LANGUAGE DIALOG
  // ================================================================

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          title: const Text(
            'Select Language',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Color(0xFF11732E),
                ),

                title: const Text(
                  'English',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),

                onTap: () {
                  Navigator.pop(context);
                },
              ),

              ListTile(
                leading: const Icon(
                  Icons.language,
                  color: Color(0xFF11732E),
                ),

                title: const Text(
                  'Swahili',
                  style: TextStyle(
                    color: Colors.black87,
                  ),
                ),

                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ================================================================
  // ABOUT DIALOG
  // ================================================================

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,

      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,

          title: Row(
            children: [
              ClipOval(
                child: Image.asset(
                  'assets/images/app_icon.png',
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(width: 8),

              const Text(
                'About',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Text(
                'TARI Disease Detector uses artificial '
                'intelligence to detect plant diseases '
                'from leaf images.',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 16),

              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 8),

              Text(
                '• Works 100% offline\n'
                '• Supports 38 plant diseases\n'
                '• Fast AI inference',
                style: TextStyle(
                  color: Colors.black87,
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },

              child: const Text(
                'Close',
                style: TextStyle(
                  color: Color(0xFF11732E),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}