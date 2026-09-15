/// HomePage - Main screen of PlantDoctor
///
/// This page serves as the main hub of the app where users can:
/// - View instructions on how to use the app
/// - Access the camera to scan plant leaves
/// - Learn about plant disease detection
///
/// Features a FloatingActionButton to launch the camera scanner.

import 'package:flutter/material.dart';

// import 'camera_page.dart';
import 'tips_page.dart';
// import 'scan_page.dart';
import 'detail_page.dart';
import 'login_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _index = 0;
late List<Widget> pages;

final PageController _pageController = PageController();
int _currentSlide = 0;
// @override
// void dispose() {
//   _pageController.dispose();
//   super.dispose();
// }

@override
void dispose() {
  _imageController.dispose();
  super.dispose();
}

final PageController _imageController = PageController();

int _currentImage = 0;

final List<String> _slideImages = [
  'assets/images/app_icon.png',
  'assets/images/avocado.jpeg',
  'assets/images/cashew.jpeg',
];

final List<Map<String, String>> _slides = [
  {
    'image': 'assets/images/scan.jpeg',
    'title': 'Detect Plant Diseases',
    'description': 'Scan your plant leaves and identify possible diseases.',
  },
  {
    'image': 'assets/images/avocado.jpeg',
    'title': 'Protect Your Plants',
    'description': 'Get useful information to help keep your plants healthy.',
  },
  {
    'image': 'assets/images/cashew.jpeg',
    'title': 'Better Harvests',
    'description': 'Make informed decisions for healthier and better harvests.',
  },
];

  @override
  Widget build(BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;
      final isDark = Theme.of(context).brightness == Brightness.dark;
 pages = [
      _buildHomeContent(context),
      // const CameraPage(),
// ScanPage(
//   onBack: () {
//     Navigator.pop(context);
//   },
// ),
      const TipsPage(),
      const PlantDetailPage(
        plantName: "Avocado",
        image: "assets/images/avocado.jpeg",

      ),
    ];
   
 return Scaffold(
      // appBar: AppBar(title: const Text('TARI Disease Detector')),
         
      body: pages[_index],
     


    );
}





// Widget _buildHomeContent(BuildContext context) {
//   return SafeArea(
//     child: Column(
//       children: [
//         const SizedBox(height: 8),

//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: SizedBox.expand(
//               child: Card(
//                 margin: EdgeInsets.zero,
//                 clipBehavior: Clip.antiAlias,
//                 shape: const RoundedRectangleBorder(
//   borderRadius: BorderRadius.vertical(
//     top: Radius.circular(20),
//     bottom: Radius.circular(0),
//   ),
// ),
//                 child: Stack(
//                   children: [
//                     Positioned.fill(
//                       child: Image.asset(
//                         'assets/images/scan.jpeg',
//                         fit: BoxFit.cover,
//                       ),
//                     ),

//                     Positioned.fill(
//                       child: Container(
//                         color: Colors.green.withOpacity(0.45),
//                       ),
//                     ),

//                     Center(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           _buildInnerCard(
//                             context: context,
//                             image: 'assets/images/avocado.jpeg',
//                             title: 'Avocado',
//                             plantName: 'Avocado',
//                           ),
//                           const SizedBox(height: 20),
//                           _buildInnerCard(
//                             context: context,
//                             image: 'assets/images/cashew.jpeg',
//                             title: 'Cashew',
//                             plantName: 'Cashew',
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
// }
Widget _buildHomeContent(BuildContext context) {
  return SafeArea(
    child: Column(
      children: [
        const SizedBox(height: 8),

        Expanded(
          child: Card(
            margin: EdgeInsets.zero,
            clipBehavior: Clip.antiAlias,

            child: Stack(
              children: [
                // Center content
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // IMAGE SLIDER
                      SizedBox(
  width: 150,
  height: 150,
  child: PageView(
    controller: _imageController,
    scrollDirection: Axis.horizontal,
    physics: const PageScrollPhysics(),
    onPageChanged: (index) {
      setState(() {
        _currentImage = index;
      });
    },
    children: _slideImages.map((image) {
      return Container(
        width: 150,
        height: 150,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.green,
            width: 4,
          ),
        ),
        child: ClipOval(
          child: Image.asset(
            image,
            width: 140,
            height: 140,
            fit: BoxFit.cover,
          ),
        ),
      );
    }).toList(),
  ),
),

                      const SizedBox(height: 15),

                      const Text(
                        'TARI Disease',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),

                      const Text(
                        'Detector',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        '"Healthy Plants, Better Harvests"',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 15),

                      // THREE DOTS
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: List.generate(
                      //     _slideImages.length,
                      //     (index) {
                      //       return AnimatedContainer(
                      //         duration: const Duration(
                      //           milliseconds: 250,
                      //         ),
                      //         margin: const EdgeInsets.symmetric(
                      //           horizontal: 4,
                      //         ),
                      //         width:
                      //             _currentImage == index ? 22 : 8,
                      //         height: 8,
                      //         decoration: BoxDecoration(
                      //           color: _currentImage == index
                      //               ? Colors.green
                      //               : Colors.grey.shade400,
                      //           borderRadius:
                      //               BorderRadius.circular(10),
                      //         ),
                      //       );
                      //     },
                      //   ),
                      // ),

                      
                    ],
                  ),
                ),

                // NEXT BUTTON
                Positioned(
                  bottom: 65,
                  left: 30,
                  right: 30,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                    onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const LoginPage(),
    ),
  );
},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward),
                        ],
                      ),
                    ),
                  ),
                ),

                // SKIP / LOGIN
                Positioned(
                  bottom: 30,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                         onPressed: () {
//                       Navigator.push(
//   context,
//   MaterialPageRoute(
//     builder: (context) => ScanPage(
//       onBack: () {
//         Navigator.pop(context);
//       },
//     ),
//   ),
// );
                      },
                        child: const Text(
                          'Skip to Login',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ),

                      

                     
                    ],
                  ),
                ),

                // POWERED BY TARI
                const Positioned(
                  bottom: 5,
                  left: 0,
                  right: 0,
                  child: Text(
                    'Powered by TARI',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}


  /// Show the about dialog
  
}
