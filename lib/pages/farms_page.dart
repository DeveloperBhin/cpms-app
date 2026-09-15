import 'package:flutter/material.dart';
import 'addfarm_page.dart';
import 'farmdetails_page.dart';

class FarmsPage extends StatelessWidget {
  final VoidCallback? onHome;
  final VoidCallback? onTrees;
  final VoidCallback? onTasks;
  final VoidCallback? onMore;
  final VoidCallback onBack;

  const FarmsPage({
    super.key,
    this.onHome,
    this.onTrees,
    this.onTasks,
    this.onMore,
     required this.onBack,
  });

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =========================================================
            // HEADER
            // =========================================================
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
                'Farm Dashboard',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // =========================================================
            // CONTENT
            // =========================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  12,
                  20,
                  12,
                  25,
                ),
                child: Column(
                  children: [
                    // =================================================
                    // STATISTICS
                    // =================================================
                    Row(
                      children: [
                        Expanded(
                          child: _statCard(
                            title: 'Farms',
                            value: '3',
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _statCard(
                            title: 'Acres',
                            value: '60',
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _statCard(
                            title: 'Trees',
                            value: '500',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
const SizedBox(height: 18),

// =================================================
// ADD FARM BUTTON - RIGHT SIDE
// =================================================
Align(
  alignment: Alignment.centerRight,
  child: SizedBox(
    height: 40,
    child: ElevatedButton.icon(
   
      onPressed: () async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AddFarmPage(),
    ),
  );
},
      icon: const Icon(
        Icons.add,
        size: 16,
      ),
      label: const Text(
        'Add Farm',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(9),
        ),
      ),
    ),
  ),
),

const SizedBox(height: 18),

// =================================================
// FEATURED FARM
// =================================================
_featuredFarm(context),
                    const SizedBox(height: 24),

                    // =================================================
                    // FARM LIST CARD
                    // =================================================
                    _farmCard(
                      farmName: 'Farm FM-0001',
                      location: 'Mbiyuyu',
                      acres: '10 Acres',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // =============================================================
      // BOTTOM NAVIGATION
      // =============================================================
      
    );
  }

  // ===============================================================
  // STAT CARD
  // ===============================================================
  Widget _statCard({
    required String title,
    required String value,
  }) {
    return Container(
      height: 78,
      padding: const EdgeInsets.fromLTRB(
        10,
        10,
        8,
        8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF68766D),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          Text(
            value,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
  

  // ===============================================================
  // FEATURED FARM
  // ===============================================================
  Widget _featuredFarm(BuildContext context)  {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Shamba la Mbiyuyu',
            style: TextStyle(
              color: textDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          // Existing farm badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: lightGreen,
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Text(
              'Existing farm',
              style: TextStyle(
                color: primaryGreen,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Expanded(
                child: Text(
                  '10 Acres • Age: 5 years',
                  style: TextStyle(
                    color: Color(0xFF68766D),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              SizedBox(
                height: 42,
                child: ElevatedButton(
                 onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const FarmDetailsPage(),
    ),
  );
},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'View Farm',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FARM CARD
  // ===============================================================
  Widget _farmCard({
    required String farmName,
    required String location,
    required String acres,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            farmName,
            style: const TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '$location • $acres',
            style: const TextStyle(
              color: Color(0xFF718078),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================
 

  // ===============================================================
  // NAV ITEM
  // ===============================================================
  Widget _navigationItem({
    required IconData icon,
    required String label,
    required bool selected,
    VoidCallback? onTap,
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