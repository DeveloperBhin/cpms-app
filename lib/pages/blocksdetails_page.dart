import 'package:flutter/material.dart';
import 'addtrees_page.dart';
import 'treesdetails_page.dart';

class BlockDetailsPage extends StatefulWidget {
  final String farmId;
  final String blockId;
  final String blockName;

  const BlockDetailsPage({
    super.key,
    required this.farmId,
    required this.blockId,
    required this.blockName,
  });

  @override
  State<BlockDetailsPage> createState() => _BlockDetailsPageState();
}

class _BlockDetailsPageState extends State<BlockDetailsPage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  // Temporary data.
  // Later this will come from the API using blockId.
  final List<Map<String, String>> trees = [
    {
      'id': 'TR-0001',
      'variety': 'Common',
      'age': '5 years',
      'status': 'Active',
    },
    {
      'id': 'TR-0002',
      'variety': 'Improved',
      'age': '4 years',
      'status': 'Active',
    },
    {
      'id': 'TR-0003',
      'variety': 'Common',
      'age': '5 years',
      'status': 'Active',
    },
  ];

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
                    onTap: () => Navigator.pop(context),
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
                    'Block Details',
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
                  25,
                ),
                child: Column(
                  children: [
                    // BLOCK INFORMATION
                    _blockInformation(),

                    const SizedBox(height: 18),

                    // BLOCK SUMMARY
                    _blockSummary(),

                    const SizedBox(height: 22),

                    // TREES HEADER
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Trees',
                          style: TextStyle(
                            color: textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(
                          height: 38,
                          child: ElevatedButton.icon(
                           onPressed: () async {
  final added = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) => AddTreePage(
        farmId: widget.farmId,
        blockId: widget.blockId,
        blockName: widget.blockName,
      ),
    ),
  );

  if (added == true) {
    // Later reload trees from API.
    setState(() {});
  }
},
                            icon: const Icon(
                              Icons.add,
                              size: 15,
                            ),
                            label: const Text(
                              'Add Tree',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // TREE LIST
                    ...trees.map(
                      (tree) => Padding(
                        padding:
                            const EdgeInsets.only(bottom: 12),
                        child: _treeCard(tree),
                      ),
                    ),
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
  // BLOCK INFORMATION
  // ===============================================================
  Widget _blockInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Block Information',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Block ID: ${widget.blockId}',
            style: const TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.blockName,
            style: const TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Farm ID: ${widget.farmId}',
            style: const TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BLOCK SUMMARY
  // ===============================================================
  Widget _blockSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Block Summary',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  label: 'Size',
                  value: '4 Acres',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  label: 'Trees',
                  value: '200',
                ),
              ),
              Expanded(
                child: _summaryItem(
                  label: 'Variety',
                  value: 'Common',
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
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // TREE CARD
  // ===============================================================
  Widget _treeCard(Map<String, String> tree) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // TREE ICON
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.park_outlined,
                  color: primaryGreen,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      tree['id']!,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${tree['variety']} • ${tree['age']}',
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

              // STATUS
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  tree['status']!,
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
            onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => TreeDetailsPage(
        farmId: widget.farmId,
        blockId: widget.blockId,
        treeId: tree['id']!,
        variety: tree['variety']!,
        age: tree['age']!,
        status: tree['status']!,
      ),
    ),
  );
},
              child: const Text(
                'View Tree ›',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

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
  Widget _bottomNavigation(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _navItem(
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
              _navItem(
                icon: Icons.crop_square_outlined,
                label: 'Farms',
                selected: true,
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              _navItem(
                icon: Icons.park_outlined,
                label: 'Trees',
                selected: false,
                onTap: () {},
              ),
              _navItem(
                icon: Icons.check_outlined,
                label: 'Tasks',
                selected: false,
                onTap: () {},
              ),
              _navItem(
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