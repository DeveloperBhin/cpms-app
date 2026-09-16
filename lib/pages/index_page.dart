import 'package:flutter/material.dart';

import '../services/api_services/farm_api_services.dart';
import '../services/api_services/tree_api_services.dart';
import '../services/api_services/tree_activity_api_services.dart';
import '../services/api_services/farm_harvest_api_services.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  int _currentIndex = 0;

  // ============================================================
  // COLORS
  // ============================================================

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

  // ============================================================
  // REAL API DATA
  // ============================================================

  List<Map<String, dynamic>> _farms = [];

  List<Map<String, dynamic>> _trees = [];

  List<Map<String, dynamic>> _activities = [];

  List<Map<String, dynamic>> _farmHarvests = [];

  bool _isLoading = true;

  String? _error;

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadDashboard();
  }

  // ============================================================
  // LOAD DASHBOARD DATA
  // ============================================================

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      // --------------------------------------------------------
      // FARMS
      // --------------------------------------------------------

      final farms =
          await FarmApiServices.getMyFarms();

      // --------------------------------------------------------
      // TREES
      // --------------------------------------------------------

      final trees =
          await TreeApiServices.getMyTrees();

      // --------------------------------------------------------
      // TREE ACTIVITIES
      // --------------------------------------------------------

      final activities =
          await TreeActivityApiServices
              .getMyActivities();

      // --------------------------------------------------------
      // FARM HARVESTS
      // --------------------------------------------------------

      List<Map<String, dynamic>>
          farmHarvests = [];

      try {
        farmHarvests =
            await FarmHarvestApiServices
                .getMyHarvests();
      } catch (e) {
        // Do not destroy the entire dashboard
        // if farm harvest API is temporarily
        // unavailable.
        debugPrint(
          'DASHBOARD FARM HARVEST ERROR: $e',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _farms = farms;
        _trees = trees;
        _activities = activities;
        _farmHarvests = farmHarvests;

        _isLoading = false;
      });

      debugPrint(
        '================================',
      );

      debugPrint(
        'DASHBOARD REAL DATA',
      );

      debugPrint(
        'FARMS: ${_farms.length}',
      );

      debugPrint(
        'TREES: ${_trees.length}',
      );

      debugPrint(
        'TREE ACTIVITIES: '
        '${_activities.length}',
      );

      debugPrint(
        'FARM HARVESTS: '
        '${_farmHarvests.length}',
      );

      debugPrint(
        'TREE HARVESTED KG: '
        '$_treeHarvestedKg',
      );

      debugPrint(
        'FARM HARVESTED KG: '
        '$_farmHarvestedKg',
      );

      debugPrint(
        'TOTAL HARVESTED KG: '
        '$_totalHarvestedKg',
      );

      debugPrint(
        'TREE ACTIVITY COST: '
        '$_treeActivityCost',
      );

      debugPrint(
        'FARM HARVEST COST: '
        '$_farmHarvestCost',
      );

      debugPrint(
        'TOTAL COST: $_totalCost',
      );

      debugPrint(
        '================================',
      );
    } catch (e) {
      debugPrint(
        'DASHBOARD LOAD ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ============================================================
  // TOTAL TREE HARVEST KG
  // ============================================================

  double get _treeHarvestedKg {
    double total = 0;

    for (final activity in _activities) {
      final activityType =
          activity['activityType']
                  ?.toString()
                  .trim()
                  .toUpperCase() ??
              '';

      if (activityType != 'HARVESTING') {
        continue;
      }

      final harvestedKg =
          double.tryParse(
            activity['harvestedKg']
                    ?.toString() ??
                '0',
          ) ??
          0;

      total += harvestedKg;
    }

    return total;
  }

  // ============================================================
  // TOTAL FARM HARVEST KG
  // ============================================================

  double get _farmHarvestedKg {
    double total = 0;

    for (final harvest in _farmHarvests) {
      // First use the total calculated
      // by the backend.
      final totalHarvestedKg =
          double.tryParse(
        harvest['totalHarvestedKg']
                ?.toString() ??
            '',
      );

      if (totalHarvestedKg != null) {
        total += totalHarvestedKg;

        continue;
      }

      // Fallback:
      // bucketCount × kgPerBucket

      final bucketCount =
          int.tryParse(
            harvest['bucketCount']
                    ?.toString() ??
                '0',
          ) ??
          0;

      final kgPerBucket =
          double.tryParse(
            harvest['kgPerBucket']
                    ?.toString() ??
                '0',
          ) ??
          0;

      total +=
          bucketCount * kgPerBucket;
    }

    return total;
  }

  // ============================================================
  // TOTAL HARVEST KG
  // ============================================================

  double get _totalHarvestedKg {
    return _treeHarvestedKg +
        _farmHarvestedKg;
  }

  // ============================================================
  // TREE ACTIVITY COST
  // ============================================================

  double get _treeActivityCost {
    double total = 0;

    for (final activity in _activities) {
      final cost =
          double.tryParse(
            activity['cost']
                    ?.toString() ??
                '0',
          ) ??
          0;

      total += cost;
    }

    return total;
  }

  // ============================================================
  // FARM HARVEST COST
  // ============================================================

  double get _farmHarvestCost {
    double total = 0;

    for (final harvest in _farmHarvests) {
      final cost =
          double.tryParse(
            harvest['cost']
                    ?.toString() ??
                '0',
          ) ??
          0;

      total += cost;
    }

    return total;
  }

  // ============================================================
  // TOTAL COST
  // ============================================================

  double get _totalCost {
    return _treeActivityCost +
        _farmHarvestCost;
  }

  // ============================================================
  // TOTAL ACTIVITIES
  // ============================================================

  int get _totalActivities {
    return _activities.length +
        _farmHarvests.length;
  }

  // ============================================================
  // UPCOMING ACTIVITIES
  // ============================================================

  List<Map<String, dynamic>>
      get _upcomingActivityList {
    final now = DateTime.now();

    final upcoming =
        _activities.where((activity) {
      final status =
          activity['status']
                  ?.toString()
                  .toUpperCase() ??
              '';

      final date =
          DateTime.tryParse(
        activity['activityDate']
                ?.toString() ??
            '',
      );

      if (date == null) {
        return false;
      }

      final today =
          DateTime(
        now.year,
        now.month,
        now.day,
      );

      final activityDay =
          DateTime(
        date.year,
        date.month,
        date.day,
      );

      // Planned activities should be
      // today or in the future.
      return status == 'PLANNED' &&
          !activityDay.isBefore(today);
    }).toList();

    upcoming.sort(
      (a, b) {
        final aDate =
            DateTime.tryParse(
                  a['activityDate']
                          ?.toString() ??
                      '',
                ) ??
                DateTime(2100);

        final bDate =
            DateTime.tryParse(
                  b['activityDate']
                          ?.toString() ??
                      '',
                ) ??
                DateTime(2100);

        return aDate.compareTo(bDate);
      },
    );

    return upcoming.take(3).toList();
  }

  // ============================================================
  // FORMAT KG
  // ============================================================

  String _formatKg(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }

    return value.toStringAsFixed(1);
  }

  // ============================================================
  // FORMAT MONEY
  // ============================================================

  String _formatMoney(
    double value,
  ) {
    final number =
        value.round().toString();

    final formatted =
        number.replaceAllMapped(
      RegExp(
        r'\B(?=(\d{3})+(?!\d))',
      ),
      (match) => ',',
    );

    return 'TZS $formatted';
  }

  // ============================================================
  // FORMAT ACTIVITY TYPE
  // ============================================================

  String _formatActivityType(
    dynamic value,
  ) {
    final raw =
        value
            ?.toString()
            .trim() ??
        '';

    if (raw.isEmpty) {
      return 'Activity';
    }

    return raw
        .split('_')
        .map(
          (word) {
            if (word.isEmpty) {
              return '';
            }

            return '${word[0].toUpperCase()}'
                '${word.substring(1).toLowerCase()}';
          },
        )
        .join(' ');
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(
    dynamic value,
  ) {
    final date =
        DateTime.tryParse(
      value?.toString() ?? '',
    );

    if (date == null) {
      return '-';
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

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  void _onNavigationTapped(
    int index,
  ) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Home
        break;

      case 1:
        // Farms
        break;

      case 2:
        // Trees
        break;

      case 3:
        // Tasks / Activities
        break;

      case 4:
        // More
        break;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ==================================================
            // DASHBOARD HEADER
            // ==================================================

            Container(
              width:
                  double.infinity,
              height: 52,
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 14,
              ),
              decoration:
                  const BoxDecoration(
                color: primaryGreen,
                borderRadius:
                    BorderRadius.only(
                  bottomLeft:
                      Radius.circular(
                    18,
                  ),
                  bottomRight:
                      Radius.circular(
                    18,
                  ),
                ),
              ),
              alignment:
                  Alignment.centerLeft,
              child:
                  const Text(
                'Dashboard',
                style:
                    TextStyle(
                  color:
                      Colors.white,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),

            // ==================================================
            // PAGE CONTENT
            // ==================================================

            Expanded(
              child:
                  RefreshIndicator(
                onRefresh:
                    _loadDashboard,
                child:
                    SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    12,
                    20,
                    12,
                    22,
                  ),
                  child: Column(
                    children: [
                      // ========================================
                      // ERROR
                      // ========================================

                      if (_error != null)
                        _errorCard(),

                      if (_error != null)
                        const SizedBox(
                          height: 14,
                        ),

                      // ========================================
                      // FIRST ROW
                      // FARMS / TREES
                      // ========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              title:
                                  'Farms',
                              value:
                                  _isLoading
                                      ? '-'
                                      : _farms
                                          .length
                                          .toString(),
                              subtitle:
                                  'registered',
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              title:
                                  'Trees',
                              value:
                                  _isLoading
                                      ? '-'
                                      : _trees
                                          .length
                                          .toString(),
                              subtitle:
                                  'registered',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // ========================================
                      // SECOND ROW
                      // HARVEST / COST
                      // ========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              title:
                                  'Harvested',
                              value:
                                  _isLoading
                                      ? '-'
                                      : '${_formatKg(_totalHarvestedKg)} kg',
                              subtitle:
                                  'total harvested',
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              title:
                                  'Total Cost',
                              value:
                                  _isLoading
                                      ? '-'
                                      : _formatMoney(
                                          _totalCost,
                                        ),
                              subtitle:
                                  'activity costs',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // ========================================
                      // THIRD ROW
                      // ACTIVITIES
                      // ========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              title:
                                  'Activities',
                              value:
                                  _isLoading
                                      ? '-'
                                      : _totalActivities
                                          .toString(),
                              subtitle:
                                  'recorded',
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              title:
                                  'Farm Harvests',
                              value:
                                  _isLoading
                                      ? '-'
                                      : _farmHarvests
                                          .length
                                          .toString(),
                              subtitle:
                                  'recorded',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ========================================
                      // PRODUCTION OVERVIEW
                      // ========================================

                      _productionOverview(),

                      const SizedBox(
                        height: 22,
                      ),

                      // ========================================
                      // UPCOMING ACTIVITIES
                      // ========================================

                      _upcomingActivities(),

                      const SizedBox(
                        height: 20,
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

  // ============================================================
  // ERROR CARD
  // ============================================================

  Widget _errorCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        12,
      ),
      decoration:
          BoxDecoration(
        color:
            Colors.red.shade50,
        borderRadius:
            BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color:
              Colors.red.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color:
                Colors.red.shade700,
            size: 18,
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child: Text(
              _error ??
                  'Unable to load dashboard.',
              style:
                  TextStyle(
                color:
                    Colors.red.shade700,
                fontSize: 10,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ),

          IconButton(
            onPressed:
                _loadDashboard,
            visualDensity:
                VisualDensity.compact,
            icon:
                const Icon(
              Icons.refresh,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STAT CARD
  // ============================================================

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      height: 104,
      padding:
          const EdgeInsets.fromLTRB(
        12,
        12,
        10,
        10,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        border:
            Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 17,
                height: 17,
                decoration:
                    const BoxDecoration(
                  color:
                      lightGreen,
                  shape:
                      BoxShape.circle,
                ),
              ),

              const SizedBox(
                width: 7,
              ),

              Expanded(
                child:
                    Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF637168,
                    ),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),

          Expanded(
            child:
                Align(
              alignment:
                  Alignment.centerLeft,
              child:
                  FittedBox(
                fit:
                    BoxFit.scaleDown,
                alignment:
                    Alignment.centerLeft,
                child:
                    Text(
                  value,
                  maxLines: 1,
                  style:
                      const TextStyle(
                    color:
                        primaryGreen,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),

          Text(
            subtitle,
            maxLines: 1,
            overflow:
                TextOverflow.ellipsis,
            style:
                const TextStyle(
              color:
                  Color(
                0xFF89948C,
              ),
              fontSize: 8,
              fontWeight:
                  FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCTION OVERVIEW
  // ============================================================

  Widget _productionOverview() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        14,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
        border:
            Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Production Overview',
            style:
                TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _productionRow(
            label:
                'Tree Harvest',
            value:
                '${_formatKg(_treeHarvestedKg)} kg',
          ),

          const SizedBox(
            height: 10,
          ),

          _productionRow(
            label:
                'Farm Harvest',
            value:
                '${_formatKg(_farmHarvestedKg)} kg',
          ),

          const Divider(
            height: 22,
            color: borderColor,
          ),

          _productionRow(
            label:
                'Total Harvested',
            value:
                '${_formatKg(_totalHarvestedKg)} kg',
            bold: true,
          ),

          const SizedBox(
            height: 10,
          ),

          _productionRow(
            label:
                'Total Cost',
            value:
                _formatMoney(
              _totalCost,
            ),
            bold: true,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRODUCTION ROW
  // ============================================================

  Widget _productionRow({
    required String label,
    required String value,
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child:
              Text(
            label,
            style:
                TextStyle(
              color:
                  const Color(
                0xFF637168,
              ),
              fontSize: 10,
              fontWeight:
                  bold
                      ? FontWeight.w700
                      : FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Text(
          value,
          style:
              TextStyle(
            color:
                primaryGreen,
            fontSize: 11,
            fontWeight:
                bold
                    ? FontWeight.w800
                    : FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // UPCOMING ACTIVITIES
  // ============================================================

  Widget _upcomingActivities() {
    final upcoming =
        _upcomingActivityList;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        15,
      ),
      decoration:
          BoxDecoration(
        color: primaryGreen,
        borderRadius:
            BorderRadius.circular(
          13,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child:
                    Text(
                  'Upcoming Activities',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 12,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              if (_isLoading)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                        Colors.white,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 13,
          ),

          if (!_isLoading &&
              upcoming.isEmpty)
            const Text(
              'No upcoming activities.',
              style:
                  TextStyle(
                color:
                    Colors.white70,
                fontSize: 9,
                fontWeight:
                    FontWeight.w500,
              ),
            ),

          if (!_isLoading)
            ...upcoming.map(
              (activity) {
                return Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    bottom: 12,
                  ),
                  child:
                      _upcomingActivityRow(
                    activity,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // UPCOMING ACTIVITY ROW
  // ============================================================

  Widget _upcomingActivityRow(
    Map<String, dynamic> activity,
  ) {
    final activityName =
        _formatActivityType(
      activity['activityType'],
    );

    final date =
        _formatDate(
      activity['activityDate'],
    );

    final treeCode =
        activity['treeCode']
                ?.toString() ??
            '';

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Container(
          width: 7,
          height: 7,
          margin:
              const EdgeInsets.only(
            top: 3,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            shape:
                BoxShape.circle,
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                '$activityName • $date',
                style:
                    const TextStyle(
                  color:
                      Colors.white,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              if (treeCode.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    top: 3,
                  ),
                  child:
                      Text(
                    treeCode,
                    style:
                        const TextStyle(
                      color:
                          Colors.white70,
                      fontSize: 8,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // NAVIGATION ITEM
  // ============================================================

  Widget _navigationItem({
    required int index,
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    final bool selected =
        _currentIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () =>
            _onNavigationTapped(
          index,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              selected
                  ? selectedIcon
                  : icon,
              size: 17,
              color:
                  selected
                      ? primaryGreen
                      : const Color(
                          0xFF9AA39D,
                        ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              label,
              style:
                  TextStyle(
                fontSize: 8,
                fontWeight:
                    selected
                        ? FontWeight.w700
                        : FontWeight.w500,
                color:
                    selected
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