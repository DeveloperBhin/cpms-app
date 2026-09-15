import 'package:flutter/material.dart';

import 'tree_activity_page.dart';

class ActivityPage extends StatefulWidget {
  final VoidCallback? onBack;

  const ActivityPage({
    super.key,
    this.onBack,
  });

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);
  static const Color orange = Color(0xFFE7A33E);

  final TextEditingController _searchController =
      TextEditingController();

  String _search = '';
  String _selectedFilter = 'All';

  // ==============================================================
  // TEMPORARY GENERAL ACTIVITY DATA
  // Later replace with backend API data.
  // ==============================================================
  final List<Map<String, String>> _activities = [
    {
      'treeId': 'TR-0001',
      'farmId': 'FM-0001',
      'farmName': 'Shamba la Mbiyuyu',
      'blockId': 'BL-0001',
      'blockName': 'Block A',
      'title': 'Weeding',
      'date': '15 Jan 2026',
      'description': 'Weeding around the cashew tree.',
      'status': 'Completed',
    },
    {
      'treeId': 'TR-0002',
      'farmId': 'FM-0001',
      'farmName': 'Shamba la Mbiyuyu',
      'blockId': 'BL-0001',
      'blockName': 'Block A',
      'title': 'Pesticide Application',
      'date': '05 Mar 2026',
      'description': 'Pesticide applied to control pests.',
      'status': 'Completed',
    },
    {
      'treeId': 'TR-0003',
      'farmId': 'FM-0001',
      'farmName': 'Shamba la Mbiyuyu',
      'blockId': 'BL-0002',
      'blockName': 'Block B',
      'title': 'Pruning',
      'date': '30 Oct 2025',
      'description': 'Removed unwanted and dry branches.',
      'status': 'Completed',
    },
    {
      'treeId': 'TR-0004',
      'farmId': 'FM-0002',
      'farmName': 'Farm FM-0002',
      'blockId': 'BL-0003',
      'blockName': 'Block A',
      'title': 'Fertilizer Application',
      'date': '20 Sep 2025',
      'description': 'Organic fertilizer applied around the tree.',
      'status': 'Completed',
    },
  ];

  final List<String> _filters = [
    'All',
    'Weeding',
    'Pruning',
    'Pesticide',
    'Fertilizer',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ==============================================================
  // FILTERED ACTIVITIES
  // ==============================================================
  List<Map<String, String>> get _filteredActivities {
    return _activities.where((activity) {
      final search = _search.toLowerCase();

      final matchesSearch =
          (activity['treeId'] ?? '')
                  .toLowerCase()
                  .contains(search) ||
              (activity['farmId'] ?? '')
                  .toLowerCase()
                  .contains(search) ||
              (activity['farmName'] ?? '')
                  .toLowerCase()
                  .contains(search) ||
              (activity['blockId'] ?? '')
                  .toLowerCase()
                  .contains(search) ||
              (activity['blockName'] ?? '')
                  .toLowerCase()
                  .contains(search) ||
              (activity['title'] ?? '')
                  .toLowerCase()
                  .contains(search);

      bool matchesFilter = true;

      if (_selectedFilter != 'All') {
        matchesFilter = (activity['title'] ?? '')
            .toLowerCase()
            .contains(
              _selectedFilter.toLowerCase(),
            );
      }

      return matchesSearch && matchesFilter;
    }).toList();
  }

  // ==============================================================
  // OPEN TREE ACTIVITIES
  // ==============================================================
  void _openTreeActivities(
    Map<String, String> activity,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TreeActivityPage(
          treeId: activity['treeId']!,
          farmId: activity['farmId']!,
          blockId: activity['blockId']!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activities = _filteredActivities;

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
                  if (widget.onBack != null) ...[
                    InkWell(
                      onTap: widget.onBack,
                      borderRadius:
                          BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  const Expanded(
                    child: Text(
                      'Activities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.15,
                      ),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${_activities.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // BODY
            // =====================================================
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  20,
                  14,
                  30,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    // =============================================
                    // TITLE
                    // =============================================
                    const Text(
                      'Tree Activities',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'View and manage activities performed on cashew trees.',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 9,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // =============================================
                    // SUMMARY
                    // =============================================
                    Row(
                      children: [
                        Expanded(
                          child: _summaryCard(
                            icon: Icons.task_alt,
                            label: 'Activities',
                            value:
                                '${_activities.length}',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _summaryCard(
                            icon: Icons.park_outlined,
                            label: 'Trees',
                            value:
                                '${_uniqueTreeCount()}',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // =============================================
                    // SEARCH
                    // =============================================
                    TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _search = value;
                        });
                      },
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 10,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Search tree, farm, block or activity...',
                        hintStyle: const TextStyle(
                          color: textGrey,
                          fontSize: 9,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: textGrey,
                          size: 19,
                        ),
                        suffixIcon: _search.isNotEmpty
                            ? IconButton(
                                onPressed: () {
                                  _searchController
                                      .clear();

                                  setState(() {
                                    _search = '';
                                  });
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: textGrey,
                                  size: 17,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding:
                            const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                        enabledBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(
                            color: borderColor,
                          ),
                        ),
                        focusedBorder:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(10),
                          borderSide:
                              const BorderSide(
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // =============================================
                    // FILTERS
                    // =============================================
                    SizedBox(
                      height: 34,
                      child: ListView.separated(
                        scrollDirection:
                            Axis.horizontal,
                        itemCount: _filters.length,
                        separatorBuilder:
                            (context, index) =>
                                const SizedBox(
                          width: 7,
                        ),
                        itemBuilder: (context, index) {
                          final filter =
                              _filters[index];

                          final selected =
                              _selectedFilter ==
                                  filter;

                          return InkWell(
                            onTap: () {
                              setState(() {
                                _selectedFilter =
                                    filter;
                              });
                            },
                            borderRadius:
                                BorderRadius.circular(
                              8,
                            ),
                            child: Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 13,
                                vertical: 8,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: selected
                                    ? primaryGreen
                                    : Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(8),
                                border: Border.all(
                                  color: selected
                                      ? primaryGreen
                                      : borderColor,
                                ),
                              ),
                              child: Text(
                                filter,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : textGrey,
                                  fontSize: 8,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =============================================
                    // ACTIVITY COUNT
                    // =============================================
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Recent Activities',
                            style: TextStyle(
                              color: textDark,
                              fontSize: 12,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                        Text(
                          '${activities.length} found',
                          style: const TextStyle(
                            color: textGrey,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // =============================================
                    // LIST
                    // =============================================
                    if (activities.isEmpty)
                      _emptyState()
                    else
                      ...activities.map(
                        (activity) => Padding(
                          padding:
                              const EdgeInsets.only(
                            bottom: 12,
                          ),
                          child: _activityCard(
                            activity,
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

  // ==============================================================
  // SUMMARY
  // ==============================================================
  int _uniqueTreeCount() {
    return _activities
        .map((activity) => activity['treeId'])
        .whereType<String>()
        .toSet()
        .length;
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // ACTIVITY CARD
  // ==============================================================
  Widget _activityCard(
    Map<String, String> activity,
  ) {
    return InkWell(
      onTap: () {
        _openTreeActivities(activity);
      },
      borderRadius: BorderRadius.circular(13),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _activityIcon(
                  activity['title'] ?? '',
                ),
                color: primaryGreen,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          activity['title'] ?? '',
                          style: const TextStyle(
                            color: textDark,
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: lightGreen,
                          borderRadius:
                              BorderRadius.circular(
                            6,
                          ),
                        ),
                        child: Text(
                          activity['status'] ?? '',
                          style: const TextStyle(
                            color: primaryGreen,
                            fontSize: 7,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // TREE
                  Row(
                    children: [
                      const Icon(
                        Icons.park_outlined,
                        color: primaryGreen,
                        size: 13,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        activity['treeId'] ?? '',
                        style: const TextStyle(
                          color: primaryGreen,
                          fontSize: 9,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${activity['farmName']} • ${activity['blockName']}',
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 8,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    activity['description'] ?? '',
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: 8,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 9),

                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: textGrey,
                        size: 11,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        activity['date'] ?? '',
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: 8,
                        ),
                      ),

                      const Spacer(),

                      const Text(
                        'View Tree Activities',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 8,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),

                      const SizedBox(width: 3),

                      const Icon(
                        Icons.arrow_forward_ios,
                        color: primaryGreen,
                        size: 9,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _activityIcon(String title) {
    final value = title.toLowerCase();

    if (value.contains('weed')) {
      return Icons.grass_outlined;
    }

    if (value.contains('pesticide') ||
        value.contains('spray')) {
      return Icons.water_drop_outlined;
    }

    if (value.contains('prun')) {
      return Icons.content_cut;
    }

    if (value.contains('harvest')) {
      return Icons.agriculture_outlined;
    }

    if (value.contains('fertil')) {
      return Icons.eco_outlined;
    }

    return Icons.task_alt;
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            color: textGrey,
            size: 40,
          ),
          SizedBox(height: 10),
          Text(
            'No activities found',
            style: TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Try changing your search or filter.',
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
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
}