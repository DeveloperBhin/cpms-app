import 'package:flutter/material.dart';
import 'blocks_page.dart';


class FarmDetailsPage extends StatelessWidget {
  const FarmDetailsPage({super.key});

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =====================================================
            // HEADER
            // =====================================================
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
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: const Padding(
                      padding: EdgeInsets.all(3),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                  const SizedBox(width: 7),

                  const Text(
                    'Farm Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // CONTENT
            // =====================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  13,
                  24,
                  13,
                  25,
                ),
                child: Column(
                  children: [
                    // =============================================
                    // FARM INFORMATION
                    // =============================================
                    _informationCard(context),

                    const SizedBox(height: 14),

// =================================================
// ADD FARM BUTTON - RIGHT SIDE
// =================================================
const SizedBox(height: 14),

Align(
  alignment: Alignment.centerRight,
  child: SizedBox(
    height: 38,
    child: ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BlocksPage(
              farmId: 'FM-0001',
              farmName: 'Shamba la Mbiyuyu',
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text(
        'View Blocks',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  ),
),

const SizedBox(height: 14),


                    // =============================================
                    // PRODUCTION SUMMARY
                    // =============================================
                    _productionSummary(),

                    const SizedBox(height: 22),

                    // =============================================
                    // PRODUCTION HISTORY
                    // =============================================
                    _productionHistory(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _bottomNavigation(context),
    );
  }

  // ===============================================================
  // FARM INFORMATION
  // ===============================================================
Widget _informationCard(BuildContext context) {    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        15,
        14,
        18,
      ),
      decoration: _cardDecoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Information',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 14),

          Text(
            'Farm ID: FM-0001',
            style: TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 9),

          Text(
            'Shamba la Mbiyuyu • 10 Acres',
            style: TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PRODUCTION SUMMARY
  // ===============================================================
  Widget _productionSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        15,
        14,
        16,
      ),
      decoration: _cardDecoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Production Summary',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 17),

          Text(
            'Total production',
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(height: 4),

          Text(
            '250 KG',
            style: TextStyle(
              color: textDark,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),

          SizedBox(height: 11),

          Text(
            'Average production: 8.80 KG',
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // PRODUCTION HISTORY
  // ===============================================================
  Widget _productionHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        15,
        14,
        18,
      ),
      decoration: _cardDecoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Production History',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 17),

          Text(
            '2025 26 KG',
            style: TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 12),

          Text(
            '2024 64 KG',
            style: TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: 12),

          Text(
            '2023 240 KG',
            style: TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CARD DECORATION
  // ===============================================================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: borderColor,
        width: 1,
      ),
    );
  }

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================
  Widget _bottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _navigationItem(
                icon: Icons.home_outlined,
                label: 'Home',
                selected: false,
                onTap: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },
              ),

              _navigationItem(
                icon: Icons.crop_square_outlined,
                label: 'Farms',
                selected: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),

              _navigationItem(
                icon: Icons.park_outlined,
                label: 'Trees',
                selected: false,
                onTap: () {},
              ),

              _navigationItem(
                icon: Icons.check_outlined,
                label: 'Tasks',
                selected: false,
                onTap: () {},
              ),

              _navigationItem(
                icon: Icons.menu,
                label: 'More',
                selected: false,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // NAV ITEM
  // ===============================================================
  Widget _navigationItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
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