import 'package:flutter/material.dart';
import 'treesdetails_page.dart';

class TreePage extends StatefulWidget {
  const TreePage({super.key});

  @override
  State<TreePage> createState() => _TreePageState();
}

class _TreePageState extends State<TreePage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  final TextEditingController _searchController =
      TextEditingController();

  String _searchText = '';

  // ==============================================================
  // TEMPORARY DATA
  //
  // Later replace this with:
  // ApiServices.getTrees()
  // ==============================================================
  final List<Map<String, String>> trees = [
    {
      'id': 'TR-0001',
      'farmId': 'FM-0001',
      'farmName': 'Shamba la Mbiyuyu',
      'blockId': 'BL-0001',
      'blockName': 'Block A',
      'variety': 'Common',
      'age': '5 years',
      'status': 'Active',
    },
    {
      'id': 'TR-0002',
      'farmId': 'FM-0001',
      'farmName': 'Shamba la Mbiyuyu',
      'blockId': 'BL-0001',
      'blockName': 'Block A',
      'variety': 'Improved',
      'age': '4 years',
      'status': 'Active',
    },
    {
      'id': 'TR-0003',
      'farmId': 'FM-0001',
      'farmName': 'Shamba la Mbiyuyu',
      'blockId': 'BL-0002',
      'blockName': 'Block B',
      'variety': 'Common',
      'age': '5 years',
      'status': 'Active',
    },
    {
      'id': 'TR-0004',
      'farmId': 'FM-0002',
      'farmName': 'Farm FM-0002',
      'blockId': 'BL-0003',
      'blockName': 'Block A',
      'variety': 'Improved',
      'age': '3 years',
      'status': 'Inactive',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==============================================================
  // FILTER TREES
  // ==============================================================
  List<Map<String, String>> get filteredTrees {
    if (_searchText.trim().isEmpty) {
      return trees;
    }

    final query = _searchText.toLowerCase().trim();

    return trees.where((tree) {
      final id = tree['id']?.toLowerCase() ?? '';
      final farm = tree['farmName']?.toLowerCase() ?? '';
      final block = tree['blockName']?.toLowerCase() ?? '';
      final variety = tree['variety']?.toLowerCase() ?? '';

      return id.contains(query) ||
          farm.contains(query) ||
          block.contains(query) ||
          variety.contains(query);
    }).toList();
  }

  // ==============================================================
  // COUNTS
  // ==============================================================
  int get activeTrees {
    return trees
        .where(
          (tree) => tree['status'] == 'Active',
        )
        .length;
  }

  int get inactiveTrees {
    return trees
        .where(
          (tree) => tree['status'] != 'Active',
        )
        .length;
  }

  // ==============================================================
  // OPEN TREE
  // ==============================================================
  void _openTree(Map<String, String> tree) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreeDetailsPage(
          farmId: tree['farmId']!,
          blockId: tree['blockId']!,
          treeId: tree['id']!,
          variety: tree['variety']!,
          age: tree['age']!,
          status: tree['status']!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleTrees = filteredTrees;

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
              height: 55,
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
              ),
              decoration: const BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
              ),
              child: const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Trees',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
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
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =============================================
                    // SUMMARY
                    // =============================================
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            title: 'Total Trees',
                            value: trees.length.toString(),
                            icon: Icons.park_outlined,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _summaryCard(
                            title: 'Active',
                            value: activeTrees.toString(),
                            icon:
                                Icons.check_circle_outline,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _summaryCard(
                            title: 'Inactive',
                            value: inactiveTrees.toString(),
                            icon: Icons.remove_circle_outline,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // =============================================
                    // SEARCH
                    // =============================================
                    Container(
                      height: 43,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(9),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchText = value;
                          });
                        },
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 10,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              'Search tree by code, farm, block or variety',
                          hintStyle: const TextStyle(
                            color: textGrey,
                            fontSize: 9,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: textGrey,
                            size: 18,
                          ),
                          suffixIcon:
                              _searchText.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _searchController
                                            .clear();

                                        setState(() {
                                          _searchText = '';
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: textGrey,
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =============================================
                    // TITLE
                    // =============================================
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Registered Trees',
                          style: TextStyle(
                            color: textDark,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        Text(
                          '${visibleTrees.length} trees',
                          style: const TextStyle(
                            color: textGrey,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // =============================================
                    // LIST
                    // =============================================
                    if (visibleTrees.isEmpty)
                      _emptyState()
                    else
                      ...visibleTrees.map(
                        (tree) => Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),
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

      bottomNavigationBar: _bottomNavigation(),
    );
  }

  // ==============================================================
  // SUMMARY CARD
  // ==============================================================
  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      height: 83,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: primaryGreen,
                size: 15,
              ),

              const SizedBox(width: 5),

              Expanded(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 7,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // TREE CARD
  // ==============================================================
  Widget _treeCard(
    Map<String, String> tree,
  ) {
    final bool isActive =
        tree['status'] == 'Active';

    return InkWell(
      onTap: () {
        _openTree(tree);
      },
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(13),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ===========================================
            // TOP
            // ===========================================
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: lightGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.park_outlined,
                    color: primaryGreen,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 11),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        tree['id']!,
                        style: const TextStyle(
                          color: textDark,
                          fontSize: 11,
                          fontWeight:
                              FontWeight.w800,
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

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? lightGreen
                        : const Color(0xFFF3F3F3),
                    borderRadius:
                        BorderRadius.circular(6),
                  ),
                  child: Text(
                    tree['status']!,
                    style: TextStyle(
                      color: isActive
                          ? primaryGreen
                          : textGrey,
                      fontSize: 7,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            const Divider(
              height: 1,
              color: borderColor,
            ),

            const SizedBox(height: 12),

            // ===========================================
            // FARM / BLOCK
            // ===========================================
            Row(
              children: [
                Expanded(
                  child: _treeInfo(
                    title: 'Farm',
                    value:
                        tree['farmName']!,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _treeInfo(
                    title: 'Block',
                    value:
                        tree['blockName']!,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 13),

            // ===========================================
            // BARCODE + VIEW
            // ===========================================
            Row(
              children: [
                const Icon(
                  Icons.barcode_reader,
                  color: primaryGreen,
                  size: 18,
                ),

                const SizedBox(width: 6),

                Text(
                  tree['id']!,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 8,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),

                const Spacer(),

                TextButton(
                  onPressed: () {
                    _openTree(tree);
                  },
                  style:
                      TextButton.styleFrom(
                    foregroundColor:
                        primaryGreen,
                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                  ),
                  child: const Text(
                    'View Tree ›',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // TREE INFORMATION
  // ==============================================================
  Widget _treeInfo({
    required String title,
    required String value,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: textGrey,
            fontSize: 7,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: textDark,
            fontSize: 8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ==============================================================
  // EMPTY
  // ==============================================================
  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off,
            color: textGrey,
            size: 32,
          ),

          SizedBox(height: 10),

          Text(
            'No trees found',
            style: TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Try another tree code, farm or block.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // BOTTOM NAVIGATION
  // ==============================================================
  Widget _bottomNavigation() {
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
                icon:
                    Icons.crop_square_outlined,
                label: 'Farms',
                selected: false,
                onTap: () {
                  // Connect FarmsPage here
                },
              ),

              _navItem(
                icon: Icons.park_outlined,
                label: 'Trees',
                selected: true,
                onTap: () {},
              ),

              _navItem(
                icon: Icons.check_outlined,
                label: 'Tasks',
                selected: false,
                onTap: () {
                  // Connect TasksPage here
                },
              ),

              _navItem(
                icon: Icons.menu,
                label: 'More',
                selected: false,
                onTap: () {
                  // Connect MorePage here
                },
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
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected
                  ? primaryGreen
                  : const Color(
                      0xFF9AA39D,
                    ),
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
                    : const Color(
                        0xFF9AA39D,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}