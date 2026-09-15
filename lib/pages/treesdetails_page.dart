import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'scan_page.dart';
import 'tree_activity_page.dart';
class TreeDetailsPage extends StatelessWidget {
  final String farmId;
  final String blockId;
  final String treeId;
  final String variety;
  final String age;
  final String status;
  const TreeDetailsPage({
    super.key,
    required this.farmId,
    required this.blockId,
    required this.treeId,
    required this.variety,
    required this.age,
    required this.status,

  });

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
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
                    'Tree Details',
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
                  20,
                  13,
                  30,
                ),
                child: Column(
                  children: [
                    // =============================================
                    // TREE INFORMATION
                    // =============================================
          _treeInformation(),

const SizedBox(height: 18),

_scanTreeButton(context),

const SizedBox(height: 18),

_treeCodeCard(context),

const SizedBox(height: 18),

_locationCard(),
                    const SizedBox(height: 18),

                    // =============================================
                    // PRODUCTION SUMMARY
                    // =============================================
                    _productionSummary(),

                    const SizedBox(height: 18),

                    // =============================================
                    // PRODUCTION HISTORY
                    // =============================================
                    _productionHistory(),

                    const SizedBox(height: 18),

                    // =============================================
                    // RECENT ACTIVITIES
                    // =============================================
_activityActions(context),

const SizedBox(height: 18),

_recentActivities(),                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  // ===============================================================
  // TREE INFORMATION
  // ===============================================================
  Widget _treeInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tree Information',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.park_outlined,
                  color: primaryGreen,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      treeId,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '$variety • $age',
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(
            color: borderColor,
            height: 1,
          ),

          const SizedBox(height: 14),

          _informationRow(
            label: 'Farm ID',
            value: farmId,
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Block ID',
            value: blockId,
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Variety',
            value: variety,
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Age',
            value: age,
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Status',
            value: status,
          ),
        ],
      ),
    );
  }

  Widget _activityActions(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tree Activities',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Record and manage activities performed on this tree.',
          style: TextStyle(
            color: textGrey,
            fontSize: 8,
          ),
        ),

        const SizedBox(height: 15),

        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TreeActivityPage(
                    treeId: treeId,
                    farmId: farmId,
                    blockId: blockId,
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.add_task,
              size: 16,
            ),
            label: const Text(
              'Add / View Tree Activities',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _scanTreeButton(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: borderColor,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Scan Tree',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Scan a tree barcode to identify and view its information.',
          style: TextStyle(
            color: textGrey,
            fontSize: 8,
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ScanPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.barcode_reader,
              size: 19,
            ),
            label: const Text(
              'Scan Tree Barcode',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
Widget _treeCodeCard(BuildContext context) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tree Identification',
          style: TextStyle(
            color: primaryGreen,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 5),

        const Text(
          'Scan this barcode to identify this tree.',
          style: TextStyle(
            color: textGrey,
            fontSize: 8,
          ),
        ),

        const SizedBox(height: 22),

        // BARCODE
        Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: BarcodeWidget(
              barcode: Barcode.code128(),
              data: treeId,
              width: 250,
              height: 80,
              drawText: true,
              style: const TextStyle(
                color: textDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ),

        const SizedBox(height: 12),

        const Center(
          child: Text(
            'Unique Tree Barcode',
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ),

        const SizedBox(height: 18),

        Row(
          children: [
            // PRINT
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Later:
                  // Print barcode label.
                },
                icon: const Icon(
                  Icons.print_outlined,
                  size: 15,
                ),
                label: const Text(
                  'Print',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryGreen,
                  side: const BorderSide(
                    color: primaryGreen,
                  ),
                  minimumSize: const Size(
                    double.infinity,
                    40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // ENLARGE
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  _showTreeBarcode(context);
                },
                icon: const Icon(
                  Icons.barcode_reader,
                  size: 15,
                ),
                label: const Text(
                  'Enlarge',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size(
                    double.infinity,
                    40,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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

void _showTreeBarcode(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tree Barcode',
                style: TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Scan this barcode to identify the tree',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textGrey,
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: borderColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: BarcodeWidget(
                  barcode: Barcode.code128(),
                  data: treeId,
                  width: 280,
                  height: 100,
                  drawText: true,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        status,
        style: const TextStyle(
          color: primaryGreen,
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _informationRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: const TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // LOCATION
  // ===============================================================
  Widget _locationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tree Location',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: primaryGreen,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GPS Coordinates',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 8,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      '-6.7924, 39.2083',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Production Summary',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 17),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  label: 'Total Production',
                  value: '26 KG',
                ),
              ),

              Expanded(
                child: _summaryItem(
                  label: 'Average / Season',
                  value: '8.6 KG',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGrey,
            fontSize: 8,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          value,
          style: const TextStyle(
            color: textDark,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // PRODUCTION HISTORY
  // ===============================================================
  Widget _productionHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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

          SizedBox(height: 16),

          _HistoryRow(
            year: '2025',
            production: '10 KG',
          ),

          SizedBox(height: 12),

          _HistoryRow(
            year: '2024',
            production: '9 KG',
          ),

          SizedBox(height: 12),

          _HistoryRow(
            year: '2023',
            production: '7 KG',
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // RECENT ACTIVITIES
  // ===============================================================
  Widget _recentActivities() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activities',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 16),

          _ActivityRow(
            title: 'Weeding',
            date: '15 Jan 2026',
          ),

          SizedBox(height: 14),

          _ActivityRow(
            title: 'Pesticide Application',
            date: '05 Mar 2026',
          ),

          SizedBox(height: 14),

          _ActivityRow(
            title: 'Pruning',
            date: '30 Oct 2025',
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CARD
  // ===============================================================
  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: borderColor,
      ),
    );
  }

  // ===============================================================
  // BOTTOM NAVIGATION
  // ===============================================================
 

  Widget _navItem({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
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

// =================================================================
// HISTORY ROW
// =================================================================
class _HistoryRow extends StatelessWidget {
  final String year;
  final String production;

  const _HistoryRow({
    required this.year,
    required this.production,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            year,
            style: const TextStyle(
              color: Color(0xFF25402D),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Text(
          production,
          style: const TextStyle(
            color: Color(0xFF087A2F),
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =================================================================
// ACTIVITY ROW
// =================================================================
class _ActivityRow extends StatelessWidget {
  final String title;
  final String date;

  const _ActivityRow({
    required this.title,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFF087A2F),
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF25402D),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Text(
          date,
          style: const TextStyle(
            color: Color(0xFF718078),
            fontSize: 8,
          ),
        ),
      ],
    );
  }
}