import 'package:flutter/material.dart';

// import 'camera_page.dart';
import 'tips_page.dart';

class ScanPage extends StatefulWidget {
  final VoidCallback onBack;

  const ScanPage({
    super.key,
    required this.onBack,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  int _index = 0;

  late final List<Widget> _pages = [
    _buildHomeContent(),
    // const CameraPage(),
    const TipsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
  backgroundColor: Colors.white,
  elevation: 0,

  leading: IconButton(
    onPressed: widget.onBack,
    icon: const Icon(
      Icons.arrow_back,
      color: Colors.black,
    ),
  ),

  title: const Text(
    'Scan',
    style: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
  ),

  centerTitle: true,
),

      body: _pages[_index],

      floatingActionButton: Transform.translate(
        offset: const Offset(0, -20),
        child: FloatingActionButton.extended(
          onPressed: () {
            _navigateToCamera(context);
          },
          backgroundColor: Colors.green,
          icon: const Icon(
            Icons.document_scanner,
            color: Colors.white,
          ),
          label: const Text(
            'Scan Leaf',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
    );
  }

  // ============================================================
  // HOME CONTENT
  // ============================================================

  Widget _buildHomeContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWelcomeCard(),

            const SizedBox(height: 80),

            const Text(
              'How to Use',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              children: [
                _buildInstructionCard(
                  icon: Icons.camera_alt,
                  title: 'Capture',
                  description:
                      'Take a clear photo of the plant leaf.',
                  onTap: () {
                    _navigateToCamera(context);
                  },
                ),

                _buildInstructionCard(
                  icon: Icons.psychology,
                  title: 'Analyze',
                  description:
                      'AI analyzes the image for diseases.',
                  onTap: () {
                    // Analysis information
                  },
                ),

                _buildInstructionCard(
                  icon: Icons.article,
                  title: 'Results',
                  description:
                      'View diagnosis and recommendations.',
                  onTap: () {
                    // Results information
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              'Tips for Best Results',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            _buildTipsList(),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WELCOME CARD
  // ============================================================

  Widget _buildWelcomeCard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: const Offset(0, 80),
              child: SizedBox(
                width: constraints.maxWidth,
                height: 180,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/scan.jpeg',
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
            ),

            Card(
              color: Colors.green.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to TARI Disease Detector',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            'Detect plant diseases instantly using AI',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // INSTRUCTION CARD
  // ============================================================

  Widget _buildInstructionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 28,
                color: Colors.green,
              ),

              const SizedBox(height: 8),

              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                description,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TIPS LIST
  // ============================================================

  Widget _buildTipsList() {
    final tips = [
      'Use good lighting (natural daylight works best)',
      'Focus on the affected area of the leaf',
      'Keep the camera steady while capturing',
      'Avoid shadows and reflections on the leaf',
      'Include both healthy and diseased parts if possible',
    ];

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: tips.map((tip) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 20,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      tip,
                      style: const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _navigateToCamera(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraPage(),
      ),
    );
  }
}