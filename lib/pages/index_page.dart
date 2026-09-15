import 'package:flutter/material.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _currentIndex = 0;

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color orange = Color(0xFFE7A33E);

  void _onNavigationTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Home
        break;

      case 1:
        // TODO: Navigate to Farms page
        break;

      case 2:
        // TODO: Navigate to Trees page
        break;

      case 3:
        // TODO: Navigate to Tasks page
        break;

      case 4:
        // TODO: Navigate to More page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // BODY
      // ============================================================
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ======================================================
            // DASHBOARD HEADER
            // ======================================================
            Container(
              width: double.infinity,
              height: 52,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration: const BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // ======================================================
            // PAGE CONTENT
            // ======================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  20,
                  12,
                  22,
                ),
                child: Column(
                  children: [
                    // ==================================================
                    // FIRST ROW
                    // FARMS / TREES
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            title: 'Farms',
                            value: '3',
                            subtitle: 'registered',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            title: 'Trees',
                            value: '1,250',
                            subtitle: 'active',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // ==================================================
                    // SECOND ROW
                    // HARVEST / ACTIVITIES
                    // ==================================================
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            title: 'Harvest',
                            value: '12,050 kg',
                            subtitle: 'season total',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _statCard(
                            title: 'Activities',
                            value: '8',
                            subtitle: 'this week',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 22),

                    // ==================================================
                    // PRODUCTION OVERVIEW
                    // ==================================================
                    _productionOverview(),

                    const SizedBox(height: 22),

                    // ==================================================
                    // UPCOMING ACTIVITIES
                    // ==================================================
                    _upcomingActivities(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ============================================================
      // BOTTOM NAVIGATION
      // ============================================================
    );
  }

  // ==============================================================
  // STAT CARD
  // ==============================================================
  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(
        12,
        12,
        10,
        10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Container(
                width: 17,
                height: 17,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF637168),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          // Value
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),

          const Spacer(),

          // Subtitle
          Text(
            subtitle,
            style: const TextStyle(
              color: Color(0xFF89948C),
              fontSize: 8,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // PRODUCTION OVERVIEW
  // ==============================================================
  Widget _productionOverview() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Production Overview',
            style: TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 10),

          Expanded(
            child: CustomPaint(
              painter: ProductionChartPainter(),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // UPCOMING ACTIVITIES
  // ==============================================================
  Widget _upcomingActivities() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        15,
      ),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(13),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Upcoming Activities',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 13),

          Text(
            'Weeding • Jan 15',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 13),

          Text(
            'Pesticide Application • Mar 05',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 13),

          Text(
            'Pruning • Oct 30',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // BOTTOM NAVIGATION
  // ==============================================================
  

  // ==============================================================
  // NAVIGATION ITEM
  // ==============================================================
  Widget _navigationItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final bool selected = _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavigationTapped(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? selectedIcon : icon,
              size: 17,
              color: selected
                  ? primaryGreen
                  : const Color(0xFF9AA39D),
            ),

            const SizedBox(height: 4),

            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: selected
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: selected
                    ? primaryGreen
                    : const Color(0xFF9AA39D),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =================================================================
// PRODUCTION CHART PAINTER
// =================================================================
class ProductionChartPainter extends CustomPainter {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color orange = Color(0xFFE7A33E);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final linePaint = Paint()
      ..color = primaryGreen
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final points = <Offset>[
      Offset(
        size.width * 0.02,
        size.height * 0.72,
      ),
      Offset(
        size.width * 0.18,
        size.height * 0.49,
      ),
      Offset(
        size.width * 0.33,
        size.height * 0.64,
      ),
      Offset(
        size.width * 0.48,
        size.height * 0.28,
      ),
      Offset(
        size.width * 0.63,
        size.height * 0.40,
      ),
      Offset(
        size.width * 0.77,
        size.height * 0.06,
      ),
      Offset(
        size.width * 0.98,
        size.height * 0.18,
      ),
    ];

    final path = Path();

    path.moveTo(
      points.first.dx,
      points.first.dy,
    );

    for (int i = 1; i < points.length; i++) {
      path.lineTo(
        points[i].dx,
        points[i].dy,
      );
    }

    canvas.drawPath(
      path,
      linePaint,
    );

    // Highlight point
    final highlightPaint = Paint()
      ..color = orange
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      points[5],
      5,
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) {
    return false;
  }
}