import 'package:flutter/material.dart';

import 'tree_activity_page.dart';
import '../services/api_services/tree_activity_api_services.dart';
import 'add_activity_page.dart';

class ActivityPage extends StatefulWidget {
  final VoidCallback? onBack;

  const ActivityPage({
    super.key,
    this.onBack,
  });

  @override
  State<ActivityPage> createState() =>
      _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  static const Color primaryGreen =
      Color(0xFF087A2F);

  static const Color backgroundColor =
      Color(0xFFF8FAF8);

  static const Color borderColor =
      Color(0xFFDCE8DF);

  static const Color lightGreen =
      Color(0xFFE7F3EB);

  static const Color textDark =
      Color(0xFF25402D);

  static const Color textGrey =
      Color(0xFF718078);

  // ============================================================
  // SEARCH
  // ============================================================

  final TextEditingController _searchController =
      TextEditingController();

  String _search = '';

  String _selectedFilter = 'All';

  // ============================================================
  // API DATA
  // ============================================================

  List<Map<String, dynamic>> _activities = [];

  bool _isLoading = true;

  String? _error;

  // ============================================================
  // FILTERS
  // ============================================================

  final List<String> _filters = [
    'All',
    'Weeding',
    'Pruning',
    'Pesticide',
    'Fertilizer',
    'Harvesting',
    'Other',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD ALL USER ACTIVITIES
  // ============================================================

  Future<void> _loadActivities() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final result =
          await TreeActivityApiServices
              .getMyActivities();

      if (!mounted) {
        return;
      }

      setState(() {
        _activities = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'LOAD MY ACTIVITIES ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // FILTERED ACTIVITIES
  // ============================================================

  List<Map<String, dynamic>>
      get _filteredActivities {
    return _activities.where((activity) {
      final search =
          _search.trim().toLowerCase();

      final treeCode =
          _treeCode(activity).toLowerCase();

      final farmId =
          _displayFarmId(
        activity['farmId'],
      ).toLowerCase();

      final farmName =
          activity['farmName']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final blockId =
          _displayBlockId(
        activity['blockId'],
      ).toLowerCase();

      final blockName =
          activity['blockName']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final variety =
          activity['variety']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final title =
          _formatActivityType(
        activity['activityType']
                ?.toString() ??
            '',
      ).toLowerCase();

      final description =
          activity['description']
                  ?.toString()
                  .toLowerCase() ??
              '';

      final matchesSearch =
          search.isEmpty ||
              treeCode.contains(search) ||
              farmId.contains(search) ||
              farmName.contains(search) ||
              blockId.contains(search) ||
              blockName.contains(search) ||
              variety.contains(search) ||
              title.contains(search) ||
              description.contains(search);

      bool matchesFilter = true;

      if (_selectedFilter != 'All') {
        matchesFilter =
            title.contains(
          _selectedFilter.toLowerCase(),
        );
      }

      return matchesSearch &&
          matchesFilter;
    }).toList();
  }
Future<void> _showTreeActivityForm() async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const AddActivityPage(
        mode: AddActivityMode.treeActivity,
      ),
    ),
  );

  if (result == true) {
    await _loadActivities();
  }
}

Future<void> _showFarmHarvestForm() async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const AddActivityPage(
        mode: AddActivityMode.farmHarvest,
      ),
    ),
  );

  if (result == true) {
    await _loadActivities();
  }
}

Future<void> _showTreeHarvestForm() async {
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const AddActivityPage(
        mode: AddActivityMode.treeHarvest,
      ),
    ),
  );

  if (result == true) {
    await _loadActivities();
  }
}

  // ============================================================
  // OPEN TREE ACTIVITIES
  // ============================================================

  void _openTreeActivities(
    Map<String, dynamic> activity,
  ) {
    final treeId =
        activity['treeId']?.toString();

    final farmId =
        activity['farmId']?.toString();

    final blockId =
        activity['blockId']?.toString();

    if (treeId == null ||
        treeId.isEmpty ||
        farmId == null ||
        farmId.isEmpty ||
        blockId == null ||
        blockId.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open tree activities. '
            'Tree relationship information is missing.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TreeActivityPage(
          treeId: treeId,
          farmId: farmId,
          blockId: blockId,
        ),
      ),
    );
  }

  Future<void> _showHarvestingOptions() async {
  final result = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(
          18,
          12,
          18,
          25,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Harvesting Method',
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'How was this harvest recorded?',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 18),

              _activityOption(
                icon: Icons.landscape_outlined,
                title: 'Farm Harvesting',
                subtitle:
                    'Record harvest using number of buckets and kilograms per bucket.',
                onTap: () {
                  Navigator.pop(
                    context,
                    'FARM',
                  );
                },
              ),

              const SizedBox(height: 10),

              _activityOption(
                icon: Icons.park_outlined,
                title: 'Tree Harvesting',
                subtitle:
                    'Record kilograms harvested from a specific cashew tree.',
                onTap: () {
                  Navigator.pop(
                    context,
                    'TREE',
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );

  if (!mounted || result == null) {
    return;
  }

  if (result == 'FARM') {
    _showFarmHarvestForm();
  } else if (result == 'TREE') {
    _showTreeHarvestForm();
  }
}

  Future<void> _showAddActivityOptions() async {
  final result = await showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(
          18,
          12,
          18,
          25,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(22),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Add Activity',
                style: TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Choose the type of activity you want to record.',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 18),

              _activityOption(
                icon: Icons.task_alt,
                title: 'Tree Activity',
                subtitle:
                    'Weeding, pruning, pesticide, fertilizer and other tree activities.',
                onTap: () {
                  Navigator.pop(
                    context,
                    'TREE_ACTIVITY',
                  );
                },
              ),

              const SizedBox(height: 10),

              _activityOption(
                icon: Icons.agriculture_outlined,
                title: 'Harvesting',
                subtitle:
                    'Record farm harvesting or harvesting from a specific tree.',
                onTap: () {
                  Navigator.pop(
                    context,
                    'HARVESTING',
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );

  if (!mounted || result == null) {
    return;
  }

  if (result == 'TREE_ACTIVITY') {
    _showTreeActivityForm();
  } else if (result == 'HARVESTING') {
    _showHarvestingOptions();
  }
}

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final activities =
        _filteredActivities;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Container(
              width: double.infinity,
              height: 55,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration:
                  const BoxDecoration(
                color: primaryGreen,
                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(18),
                  bottomRight:
                      Radius.circular(18),
                ),
              ),
              child: Row(
                children: [
                  if (widget.onBack !=
                      null) ...[
                    InkWell(
                      onTap: widget.onBack,
                      borderRadius:
                          BorderRadius
                              .circular(20),
                      child:
                          const Padding(
                        padding:
                            EdgeInsets.all(
                          4,
                        ),
                        child: Icon(
                          Icons
                              .arrow_back_ios_new,
                          color:
                              Colors.white,
                          size: 15,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                  ],
                  const Expanded(
                    child: Text(
                      'Activities',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 14,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration:
                        BoxDecoration(
                      color: Colors.white
                          .withValues(
                        alpha: 0.15,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(8),
                    ),
                    child: Text(
                      '${_activities.length}',
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: 9,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // BODY
            // ==================================================

            Expanded(
              child: RefreshIndicator(
                color: primaryGreen,
                onRefresh:
                    _loadActivities,
                child:
                    SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    14,
                    20,
                    14,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      // ========================================
                      // TITLE
                      // ========================================

                      const Text(
                        'Tree Activities',
                        style: TextStyle(
                          color: textDark,
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 5,
                      ),

                     const Text(
  'View and manage farm and tree activities.',
  style: TextStyle(
    color: textGrey,
    fontSize: 9,
  ),
),

const SizedBox(
  height: 14,
),

// ============================================================
// ADD ACTIVITY BUTTON
// ============================================================

SizedBox(
  width: double.infinity,
  height: 42,
  child: ElevatedButton.icon(
    onPressed: _showAddActivityOptions,
    icon: const Icon(
      Icons.add,
      size: 18,
    ),
    label: const Text(
      'Add Activity',
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
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  ),
),

const SizedBox(
  height: 18,
),

                      // ========================================
                      // SUMMARY
                      // ========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _summaryCard(
                              icon: Icons
                                  .task_alt,
                              label:
                                  'Activities',
                              value:
                                  '${_activities.length}',
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:
                                _summaryCard(
                              icon: Icons
                                  .park_outlined,
                              label: 'Trees',
                              value:
                                  '${_uniqueTreeCount()}',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // ========================================
                      // SEARCH
                      // ========================================

                      TextField(
                        controller:
                            _searchController,
                        onChanged: (value) {
                          setState(() {
                            _search = value;
                          });
                        },
                        style:
                            const TextStyle(
                          color: textDark,
                          fontSize: 10,
                        ),
                        decoration:
                            InputDecoration(
                          hintText:
                              'Search tree, farm, block or activity...',
                          hintStyle:
                              const TextStyle(
                            color:
                                textGrey,
                            fontSize: 9,
                          ),
                          prefixIcon:
                              const Icon(
                            Icons.search,
                            color:
                                textGrey,
                            size: 19,
                          ),
                          suffixIcon: _search
                                  .isNotEmpty
                              ? IconButton(
                                  onPressed:
                                      () {
                                    _searchController
                                        .clear();

                                    setState(
                                      () {
                                        _search =
                                            '';
                                      },
                                    );
                                  },
                                  icon:
                                      const Icon(
                                    Icons.close,
                                    color:
                                        textGrey,
                                    size: 17,
                                  ),
                                )
                              : null,
                          filled: true,
                          fillColor:
                              Colors.white,
                          contentPadding:
                              const EdgeInsets
                                  .symmetric(
                            vertical: 12,
                          ),
                          enabledBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  borderColor,
                            ),
                          ),
                          focusedBorder:
                              OutlineInputBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                            borderSide:
                                const BorderSide(
                              color:
                                  primaryGreen,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // ========================================
                      // FILTERS
                      // ========================================

                      SizedBox(
                        height: 34,
                        child:
                            ListView.separated(
                          scrollDirection:
                              Axis.horizontal,
                          itemCount:
                              _filters.length,
                          separatorBuilder:
                              (
                            context,
                            index,
                          ) =>
                                  const SizedBox(
                            width: 7,
                          ),
                          itemBuilder:
                              (
                            context,
                            index,
                          ) {
                            final filter =
                                _filters[
                                    index];

                            final selected =
                                _selectedFilter ==
                                    filter;

                            return InkWell(
                              onTap: () {
                                setState(
                                  () {
                                    _selectedFilter =
                                        filter;
                                  },
                                );
                              },
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                8,
                              ),
                              child:
                                  Container(
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      13,
                                  vertical:
                                      8,
                                ),
                                decoration:
                                    BoxDecoration(
                                  color: selected
                                      ? primaryGreen
                                      : Colors
                                          .white,
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    8,
                                  ),
                                  border:
                                      Border.all(
                                    color: selected
                                        ? primaryGreen
                                        : borderColor,
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style:
                                      TextStyle(
                                    color: selected
                                        ? Colors
                                            .white
                                        : textGrey,
                                    fontSize:
                                        8,
                                    fontWeight:
                                        FontWeight
                                            .w700,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // ========================================
                      // RECENT ACTIVITIES
                      // ========================================

                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Recent Activities',
                              style:
                                  TextStyle(
                                color:
                                    textDark,
                                fontSize:
                                    12,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ),
                          if (!_isLoading)
                            Text(
                              '${activities.length} found',
                              style:
                                  const TextStyle(
                                color:
                                    textGrey,
                                fontSize:
                                    8,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      // ========================================
                      // API STATE
                      // ========================================

                      _buildActivityContent(
                        activities,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _activityOption({
  required IconData icon,
  required String title,
  required String subtitle,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 8,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          const Icon(
            Icons.arrow_forward_ios,
            color: textGrey,
            size: 13,
          ),
        ],
      ),
    ),
  );
}

  // ============================================================
  // ACTIVITY CONTENT
  // ============================================================

  Widget _buildActivityContent(
    List<Map<String, dynamic>>
        activities,
  ) {
    if (_isLoading) {
      return _loadingState();
    }

    if (_error != null) {
      return _errorState();
    }

    if (activities.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: activities
          .map(
            (activity) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child:
                  _activityCard(
                activity,
              ),
            ),
          )
          .toList(),
    );
  }

  // ============================================================
  // UNIQUE TREES
  // ============================================================

  int _uniqueTreeCount() {
    return _activities
        .map(
          (activity) =>
              activity['treeId']
                  ?.toString(),
        )
        .whereType<String>()
        .where(
          (id) => id.isNotEmpty,
        )
        .toSet()
        .length;
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(13),
      decoration:
          _cardDecoration(),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration:
                const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryGreen,
              size: 19,
            ),
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  value,
                  style:
                      const TextStyle(
                    color: textDark,
                    fontSize: 14,
                    fontWeight:
                        FontWeight
                            .w800,
                  ),
                ),
                const SizedBox(
                  height: 2,
                ),
                Text(
                  label,
                  style:
                      const TextStyle(
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

  // ============================================================
  // ACTIVITY CARD
  // ============================================================

  Widget _activityCard(
    Map<String, dynamic> activity,
  ) {
    final title =
        _formatActivityType(
      activity['activityType']
              ?.toString() ??
          '',
    );

    final status =
        _formatStatus(
      activity['status']?.toString() ??
          '',
    );

    final treeCode =
        _treeCode(activity);

    final farmName =
        activity['farmName']
                ?.toString() ??
            _displayFarmId(
              activity['farmId'],
            );

    final blockName =
        activity['blockName']
                ?.toString() ??
            _displayBlockId(
              activity['blockId'],
            );

    final description =
        activity['description']
                ?.toString() ??
            '';

    final date =
        _formatDate(
      activity['activityDate']
          ?.toString(),
    );

    return InkWell(
      onTap: () {
        _openTreeActivities(
          activity,
        );
      },
      borderRadius:
          BorderRadius.circular(13),
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(14),
        decoration:
            _cardDecoration(),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  const BoxDecoration(
                color: lightGreen,
                shape:
                    BoxShape.circle,
              ),
              child: Icon(
                _activityIcon(title),
                color: primaryGreen,
                size: 20,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style:
                              const TextStyle(
                            color:
                                textDark,
                            fontSize:
                                10,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ),
                      Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              _statusBackground(
                            status,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            6,
                          ),
                        ),
                        child: Text(
                          status,
                          style:
                              TextStyle(
                            color:
                                _statusColor(
                              status,
                            ),
                            fontSize:
                                7,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  // TREE
                  Row(
                    children: [
                      const Icon(
                        Icons
                            .park_outlined,
                        color:
                            primaryGreen,
                        size: 13,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        treeCode,
                        style:
                            const TextStyle(
                          color:
                              primaryGreen,
                          fontSize:
                              9,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    '$farmName • $blockName',
                    style:
                        const TextStyle(
                      color: textGrey,
                      fontSize: 8,
                    ),
                  ),

                  if (description
                      .isNotEmpty) ...[
                    const SizedBox(
                      height: 7,
                    ),
                    Text(
                      description,
                      style:
                          const TextStyle(
                        color:
                            textGrey,
                        fontSize: 8,
                        height: 1.4,
                      ),
                    ),
                  ],

                  const SizedBox(
                    height: 9,
                  ),

                  Row(
                    children: [
                      const Icon(
                        Icons
                            .calendar_today_outlined,
                        color:
                            textGrey,
                        size: 11,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        date,
                        style:
                            const TextStyle(
                          color:
                              textGrey,
                          fontSize:
                              8,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'View Tree Activities',
                        style:
                            TextStyle(
                          color:
                              primaryGreen,
                          fontSize:
                              8,
                          fontWeight:
                              FontWeight
                                  .w700,
                        ),
                      ),
                      const SizedBox(
                        width: 3,
                      ),
                      const Icon(
                        Icons
                            .arrow_forward_ios,
                        color:
                            primaryGreen,
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

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loadingState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),
      decoration:
          _cardDecoration(),
      child: const Column(
        children: [
          SizedBox(
            width: 27,
            height: 27,
            child:
                CircularProgressIndicator(
              color: primaryGreen,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Loading activities...',
            style: TextStyle(
              color: textGrey,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorState() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 35,
        horizontal: 20,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 36,
          ),
          const SizedBox(
            height: 10,
          ),
          const Text(
            'Unable to load activities',
            style: TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            _error ?? '',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
          const SizedBox(
            height: 13,
          ),
          SizedBox(
            height: 34,
            child:
                ElevatedButton.icon(
              onPressed:
                  _loadActivities,
              icon: const Icon(
                Icons.refresh,
                size: 14,
              ),
              label: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    primaryGreen,
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _emptyState() {
    final hasSearchOrFilter =
        _search.trim().isNotEmpty ||
            _selectedFilter != 'All';

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.assignment_outlined,
            color: textGrey,
            size: 40,
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            hasSearchOrFilter
                ? 'No activities found'
                : 'No activities recorded',
            style:
                const TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            hasSearchOrFilter
                ? 'Try changing your search or filter.'
                : 'Activities added to your cashew trees will appear here.',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTIVITY ICON
  // ============================================================

  IconData _activityIcon(
    String title,
  ) {
    final value =
        title.toLowerCase();

    if (value.contains('weed')) {
      return Icons.grass_outlined;
    }

    if (value.contains(
          'pesticide',
        ) ||
        value.contains('spray')) {
      return Icons.water_drop_outlined;
    }

    if (value.contains('prun')) {
      return Icons.content_cut;
    }

    if (value.contains(
      'harvest',
    )) {
      return Icons.agriculture_outlined;
    }

    if (value.contains(
      'fertil',
    )) {
      return Icons.eco_outlined;
    }

    return Icons.task_alt;
  }

  // ============================================================
  // TREE CODE
  // ============================================================

  String _treeCode(
    Map<String, dynamic> activity,
  ) {
    final code =
        activity['treeCode']
            ?.toString();

    if (code != null &&
        code.trim().isNotEmpty) {
      return code;
    }

    final id =
        activity['treeId']
            ?.toString();

    if (id == null ||
        id.isEmpty) {
      return '-';
    }

    final number =
        int.tryParse(id);

    if (number == null) {
      return id;
    }

    return 'TR-${number.toString().padLeft(6, '0')}';
  }

  // ============================================================
  // DISPLAY FARM ID
  // ============================================================

  String _displayFarmId(
    dynamic value,
  ) {
    if (value == null) {
      return '-';
    }

    final id =
        value.toString();

    final number =
        int.tryParse(id);

    if (number == null) {
      return id;
    }

    return 'FM-${number.toString().padLeft(4, '0')}';
  }

  // ============================================================
  // DISPLAY BLOCK ID
  // ============================================================

  String _displayBlockId(
    dynamic value,
  ) {
    if (value == null) {
      return '-';
    }

    final id =
        value.toString();

    final number =
        int.tryParse(id);

    if (number == null) {
      return id;
    }

    return 'BL-${number.toString().padLeft(4, '0')}';
  }

  // ============================================================
  // ACTIVITY TYPE
  // ============================================================

  String _formatActivityType(
    String value,
  ) {
    switch (value
        .toUpperCase()) {
      case 'WEEDING':
        return 'Weeding';

      case 'PRUNING':
        return 'Pruning';

      case 'PESTICIDE_APPLICATION':
        return 'Pesticide Application';

      case 'FERTILIZER_APPLICATION':
        return 'Fertilizer Application';

      case 'HARVESTING':
        return 'Harvesting';

      case 'OTHER':
        return 'Other';

      default:
        return _capitalizeWords(
          value.replaceAll(
            '_',
            ' ',
          ),
        );
    }
  }

  // ============================================================
  // STATUS
  // ============================================================

  String _formatStatus(
    String value,
  ) {
    if (value.isEmpty) {
      return '-';
    }

    return _capitalizeWords(
      value.replaceAll(
        '_',
        ' ',
      ),
    );
  }

  String _capitalizeWords(
    String value,
  ) {
    return value
        .toLowerCase()
        .split(' ')
        .where(
          (word) =>
              word.isNotEmpty,
        )
        .map(
          (word) =>
              '${word[0].toUpperCase()}'
              '${word.substring(1)}',
        )
        .join(' ');
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return '-';
    }

    final date =
        DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day.toString().padLeft(2, '0')} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  // ============================================================
  // STATUS COLORS
  // ============================================================

  Color _statusColor(
    String status,
  ) {
    switch (status
        .toLowerCase()) {
      case 'completed':
        return primaryGreen;

      case 'planned':
        return Colors.blue;

      case 'in progress':
        return Colors.orange;

      case 'cancelled':
        return Colors.red;

      default:
        return textGrey;
    }
  }

  Color _statusBackground(
    String status,
  ) {
    switch (status
        .toLowerCase()) {
      case 'completed':
        return lightGreen;

      case 'planned':
        return Colors.blue
            .withValues(
          alpha: 0.10,
        );

      case 'in progress':
        return Colors.orange
            .withValues(
          alpha: 0.10,
        );

      case 'cancelled':
        return Colors.red
            .withValues(
          alpha: 0.10,
        );

      default:
        return backgroundColor;
    }
  }

  // ============================================================
  // CARD DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(13),
      border: Border.all(
        color: borderColor,
      ),
    );
  }
}