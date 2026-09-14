import 'package:flutter/material.dart';

import 'scan_page.dart';
import 'history_page.dart';
import 'crop_page.dart';
import '../services/api_services/api_services.dart';


class IndexPage extends StatefulWidget {
  const IndexPage({super.key});
  

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _currentIndex = 0;

  String _fullName = 'User';
  bool _loadingUser = true;

  @override
void initState() {
  super.initState();
  _loadCurrentUser();
}

  void _onNavigationTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

Future<void> _loadCurrentUser() async {
  try {
    final user = await ApiServices.getCurrentUser();

    if (!mounted) return;

    setState(() {
      _fullName = user['fullName'] ?? 'User';
      
      _loadingUser = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _fullName = 'User';
      _loadingUser = false;
    });
  }
}

String _getGreeting() {
  final hour = DateTime.now().hour;

  if (hour < 12) {
    return 'Good Morning,';
  } else if (hour < 18) {
    return 'Good Afternoon,';
  } else {
    return 'Good Evening,';
  }
}


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F8),

      body: SafeArea(
        child: Column(
          children: [
            // =========================================================
            // TOP HEADER
            // =========================================================
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFFE5E5E5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Profile picture
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade300,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                      // Online indicator
                      Positioned(
                        right: 0,
                        bottom: 1,
                        child: Container(
                          width: 13,
                          height: 13,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 10),

                  // Greeting
                  Expanded(
  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Text(
        _getGreeting(),
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
      ),

      const SizedBox(height: 2),

      Text(
        _loadingUser
            ? 'Loading...'
            : _fullName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    ],
  ),
),

                  // Notification
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    child: Stack(
                      children: [
                        const Center(
                          child: Icon(
                            Icons.notifications_none,
                            color: Colors.black87,
                            size: 24,
                          ),
                        ),

                        Positioned(
                          right: 8,
                          top: 7,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // =========================================================
            // PAGE CONTENT
            // =========================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =================================================
                    // IDENTIFY PLANT HEALTH CARD
                    // =================================================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FFF3),
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFBDEFC8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Identify Plant Health',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight:
                                            FontWeight.bold,
                                        color:
                                            Color(0xFF174D2A),
                                      ),
                                    ),

                                    SizedBox(height: 5),

                                    Text(
                                      'Get instant AI diagnosis and\n'
                                      'expert treatment\n'
                                      'recommendations.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        height: 1.4,
                                        color:
                                            Color(0xFF52705A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Microscope icon
                              Container(
                                width: 55,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFDDF9E4,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.biotech_outlined,
                                  color: Colors.green,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Scan button
                          SizedBox(
                            width: double.infinity,
                            height: 42,
                            child: ElevatedButton.icon(
                              onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                               ScanPage(
  onBack: () {
    Navigator.pop(context);
  },
),
                                ),
                              );
                              },
                              icon: const Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                              ),
                              label: const Text(
                                'Scan Plant',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    const Color(0xFF16C653),
                                foregroundColor:
                                    Colors.white,
                                elevation: 0,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 105),

                    // =================================================
                    // RECENT SCANS
                    // =================================================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Scans',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        TextButton(
                          
                                              onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                               HistoryPage(
  onBack: () {
    Navigator.pop(context);
  },
),
  ),
                              );
                              },
                          child: const Text(
                            'See All ›',
                            style: TextStyle(
                              color: Color(0xFF16B94D),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    Row(
                      children: [
                        Expanded(
                          child: _recentScanCard(
                            image:
                                'assets/images/tomato.jpg',
                            title: 'Tomato',
                            date: 'Oct 12, 2023',
                            status: 'Disease Detected',
                            isDisease: true,
                          ),
                        ),

                        const SizedBox(width: 18),

                        Expanded(
                          child: _recentScanCard(
                            image:
                                'assets/images/maize.jpg',
                            title: 'Maize',
                            date: 'Oct 10, 2023',
                            status: 'Healthy',
                            isDisease: false,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // =================================================
                    // TUTORIALS
                    // =================================================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Crops',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),

                        TextButton(
                                           onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                               CropPage(
  onBack: () {
    Navigator.pop(context);
  },
 
  onScan: () {
    // open ScanPage here
  },

),
  ),
                              );
                              },
                          child: const Text(
                            'See All ›',
                            style: TextStyle(
                              color: Color(0xFF16B94D),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 2),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8FFDC),
                        borderRadius:
                            BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFC9F1B7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFFD8F9C9),
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                            child: const Icon(
                            Icons.eco_outlined,
                              color: Color(0xFF20C95A),
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Crops',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        Color(0xFF315D2F),
                                  ),
                                ),

                                SizedBox(height: 2),

                                Text(
                                  'Access different plants, how to\n'
                                  'take care of them, their common\n'
                                  'diseases and how to treat them.',
                                  style: TextStyle(
                                    fontSize: 9,
                                    height: 1.3,
                                    color:
                                        Color(0xFF658061),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

     
    );
  }

  // ===============================================================
  // RECENT SCAN CARD
  // ===============================================================
  Widget _recentScanCard({
    required String image,
    required String title,
    required String date,
    required String status,
    required bool isDisease,
  }) {
    return Container(
      height: 123,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    image,
                    fit: BoxFit.cover,
                  ),
                ),

                Positioned(
                  left: 5,
                  bottom: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDisease
                          ? Colors.red
                          : Colors.green,
                      borderRadius:
                          BorderRadius.circular(4),
                    ),
                    child: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 7,
              vertical: 4,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(
                    fontSize: 7,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}