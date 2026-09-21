import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

import 'treesdetails_page.dart';

import '../services/api_services/tree_api_services.dart';
import '../services/api_services/tree_activity_api_services.dart';
import '../services/api_services/farm_harvest_api_services.dart';
import '../theme/app_text_styles.dart';

class TreePage extends StatefulWidget {
  final VoidCallback onBack;

  const TreePage({
    super.key,
    required this.onBack,
  });

  @override
  State<TreePage> createState() =>
      _TreePageState();
}

class _TreePageState extends State<TreePage> {
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

  static const Color textGrey =
      Color(0xFF718078);

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _searchController =
      TextEditingController();

  // ============================================================
  // DATA
  // ============================================================

  List<Map<String, dynamic>> trees = [];

  List<Map<String, dynamic>> activities = [];

  List<Map<String, dynamic>> farmHarvests = [];

  String _searchText = '';

  bool _isLoading = true;

  String? _error;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadDashboard();
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
  // LOAD TREES + ACTIVITIES + FARM HARVESTS
  // ============================================================

  Future<void> _loadDashboard() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      /*
       * Keep farm harvest isolated.
       *
       * This prevents a farm-harvest endpoint problem from
       * stopping the entire Trees page from loading.
       */

      final treeFuture =
          TreeApiServices.getMyTrees();

      final activityFuture =
          TreeActivityApiServices.getMyActivities();

      final treeResult =
          await treeFuture;

      final activityResult =
          await activityFuture;

      List<Map<String, dynamic>>
          harvestResult = [];

      try {
        harvestResult =
            await FarmHarvestApiServices
                .getMyHarvests();
      } catch (e) {
        debugPrint(
          'FARM HARVEST LOAD ERROR: $e',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        trees = treeResult;

        activities = activityResult;

        farmHarvests = harvestResult;

        _isLoading = false;
      });

      debugPrint(
        '================================',
      );

      debugPrint(
        'TREES: ${trees.length}',
      );

      debugPrint(
        'TREE ACTIVITIES: '
        '${activities.length}',
      );

      debugPrint(
        'FARM HARVESTS: '
        '${farmHarvests.length}',
      );

      debugPrint(
        'TREE HARVESTED: '
        '$totalTreeHarvestedKg KG',
      );

      debugPrint(
        'FARM HARVESTED: '
        '$totalFarmHarvestedKg KG',
      );

      debugPrint(
        'TOTAL HARVESTED: '
        '$totalHarvestedKg KG',
      );

      debugPrint(
        'TREE ACTIVITY COST: '
        '$totalTreeActivityCost',
      );

      debugPrint(
        'FARM HARVEST COST: '
        '$totalFarmHarvestCost',
      );

      debugPrint(
        'TOTAL COST: '
        '$totalCost',
      );

      debugPrint(
        '================================',
      );
    } catch (e) {
      debugPrint(
        'LOAD DASHBOARD ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;

        _error =
            e.toString();
      });
    }
  }

  // ============================================================
  // FILTER TREES
  // ============================================================

  List<Map<String, dynamic>>
      get filteredTrees {
    if (_searchText.trim().isEmpty) {
      return trees;
    }

    final query =
        _searchText
            .toLowerCase()
            .trim();

    return trees.where(
      (tree) {
        final id =
            tree['id']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final treeCode =
            tree['treeCode']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final farmName =
            tree['farmName']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final blockName =
            tree['blockName']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final variety =
            tree['variety']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final status =
            tree['status']
                    ?.toString()
                    .toLowerCase() ??
                '';

        final plantingYear =
            tree['plantingYear']
                    ?.toString()
                    .toLowerCase() ??
                '';

        return id.contains(query) ||
            treeCode.contains(query) ||
            farmName.contains(query) ||
            blockName.contains(query) ||
            variety.contains(query) ||
            status.contains(query) ||
            plantingYear.contains(query);
      },
    ).toList();
  }

  // ============================================================
  // TOTAL ACTIVITIES
  // ============================================================

  int get totalActivities {
    return activities.length;
  }

  // ============================================================
  // TREE HARVEST
  // ============================================================

  double get totalTreeHarvestedKg {
    double total = 0;

    for (final activity in activities) {
      final type =
          activity['activityType']
                  ?.toString()
                  .toUpperCase() ??
              '';

      if (type != 'HARVESTING') {
        continue;
      }

      final kg =
          double.tryParse(
                activity['harvestedKg']
                        ?.toString() ??
                    '0',
              ) ??
              0;

      total += kg;
    }

    return total;
  }

  // ============================================================
  // FARM HARVEST
  // ============================================================

  double get totalFarmHarvestedKg {
    double total = 0;

    for (final harvest
        in farmHarvests) {
      // Prefer calculated total from backend.

      final apiTotal =
          double.tryParse(
        harvest['totalHarvestedKg']
                ?.toString() ??
            '',
      );

      if (apiTotal != null) {
        total += apiTotal;

        continue;
      }

      // Fallback:
      // bucketCount * kgPerBucket.

      final buckets =
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
          buckets *
              kgPerBucket;
    }

    return total;
  }

  // ============================================================
  // TOTAL HARVEST
  // ============================================================

  double get totalHarvestedKg {
    return totalTreeHarvestedKg +
        totalFarmHarvestedKg;
  }

  // ============================================================
  // TREE ACTIVITY COST
  // ============================================================

  double get totalTreeActivityCost {
    double total = 0;

    for (final activity
        in activities) {
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

  double get totalFarmHarvestCost {
    double total = 0;

    for (final harvest
        in farmHarvests) {
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

  double get totalCost {
    return totalTreeActivityCost +
        totalFarmHarvestCost;
  }

  // ============================================================
  // OPEN TREE
  // ============================================================

  Future<void> _openTree(
    Map<String, dynamic> tree,
  ) async {
    final farmId =
        tree['farmId']
                ?.toString() ??
            '';

    final blockId =
        tree['blockId']
                ?.toString() ??
            '';

    final treeId =
        tree['id']
                ?.toString() ??
            '';

    if (farmId.isEmpty ||
        blockId.isEmpty ||
        treeId.isEmpty) {
      _showMessage(
        AppLocalizations.of(context)!
            .unableToOpenTree,
      );

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TreeDetailsPage(
          farmId: farmId,
          blockId: blockId,
          treeId: treeId,
        ),
      ),
    );

    if (mounted) {
      await _loadDashboard();
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final visibleTrees =
        filteredTrees;

    return Scaffold(
      backgroundColor:
          backgroundColor,

      body: Column(
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            // ==================================================
// HEADER
// ==================================================
Container(
  width: double.infinity,
  color: primaryGreen,

  // Green covers the system/status-bar area.
  // +8 puts the words/icons a little lower.
  padding: EdgeInsets.only(
    top: MediaQuery.of(context).padding.top + 8,
  ),

  child: SizedBox(
    height: 55,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          // =========================================
          // BACK
          // =========================================
          InkWell(
            onTap: widget.onBack,
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

          const SizedBox(width: 8),

          // =========================================
          // TITLE
          // =========================================
          Expanded(
            child: Text(
              l10n.trees,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTextStyles.bodyLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          // =========================================
          // REFRESH
          // =========================================
          IconButton(
            onPressed: _loadDashboard,
            tooltip: l10n.refresh,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 19,
            ),
          ),
        ],
      ),
    ),
  ),
),

            // ==================================================
            // CONTENT
            // ==================================================

            Expanded(
              child:
                  RefreshIndicator(
                color:
                    primaryGreen,

                onRefresh:
                    _loadDashboard,

                child:
                    SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),

                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    13,
                    20,
                    13,
                    25,
                  ),

                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      // =========================================
                      // SUMMARY
                      // =========================================

                      _buildSummary(
                        context,
                      ),

                      const SizedBox(
                        height: 20,
                      ),

                      // =========================================
                      // SEARCH
                      // =========================================

                      Container(
                        height: 43,

                        decoration:
                            BoxDecoration(
                          color:
                              Colors.white,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            9,
                          ),

                          border:
                              Border.all(
                            color:
                                borderColor,
                          ),
                        ),

                        child:
                            TextField(
                          controller:
                              _searchController,

                          onChanged:
                              (value) {
                            setState(() {
                              _searchText =
                                  value;
                            });
                          },

                          style:
                              const TextStyle(
                            color:
                                textDark,

                            fontSize: AppTextStyles.bodySmall,
                          ),

                          decoration:
                              InputDecoration(
                            border:
                                InputBorder
                                    .none,

                            hintText:
                                l10n.searchTreeHint,

                            hintStyle:
                                const TextStyle(
                              color:
                                  textGrey,

                              fontSize:
                                  AppTextStyles.bodySmall,
                            ),

                            prefixIcon:
                                const Icon(
                              Icons.search,

                              color:
                                  textGrey,

                              size: 18,
                            ),

                            suffixIcon:
                                _searchText
                                        .isNotEmpty
                                    ? IconButton(
                                        onPressed:
                                            () {
                                          _searchController
                                              .clear();

                                          setState(
                                            () {
                                              _searchText =
                                                  '';
                                            },
                                          );
                                        },

                                        icon:
                                            const Icon(
                                          Icons.close,

                                          size: 16,

                                          color:
                                              textGrey,
                                        ),
                                      )
                                    : null,
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // =========================================
                      // REGISTERED TREES HEADER
                      // =========================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment
                                .spaceBetween,

                        children: [
                          Text(
                            l10n.registeredTrees,

                            style:
                                const TextStyle(
                              color:
                                  textDark,

                              fontSize: AppTextStyles.body,

                              fontWeight:
                                  FontWeight
                                      .w700,
                            ),
                          ),

                          if (!_isLoading)
                            Text(
                              l10n.treeCount(
                                visibleTrees
                                    .length,
                              ),

                              style:
                                  const TextStyle(
                                color:
                                    textGrey,

                                fontSize:
                                    AppTextStyles.bodySmall,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =========================================
                      // TREE LIST
                      // =========================================

                      _buildTreeList(
                        context,
                        visibleTrees,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    if (_isLoading) {
      return Row(
        children: [
          Expanded(
            child:
                _summaryCard(
              title:
                  l10n.totalTrees,

              value: '-',

              icon:
                  Icons.park_outlined,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child:
                _summaryCard(
              title:
                  l10n.activities,

              value: '-',

              icon:
                  Icons.assignment_outlined,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child:
                _summaryCard(
              title:
                  l10n.harvested,

              value: '-',

              icon:
                  Icons.scale_outlined,
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          Expanded(
            child:
                _summaryCard(
              title:
                  l10n.totalCost,

              value: '-',

              icon:
                  Icons.payments_outlined,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        // ======================================================
        // TOTAL TREES
        // ======================================================

        Expanded(
          child:
              _summaryCard(
            title:
                l10n.totalTrees,

            value:
                trees.length
                    .toString(),

            icon:
                Icons.park_outlined,
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        // ======================================================
        // ACTIVITIES
        // ======================================================

        Expanded(
          child:
              _summaryCard(
            title:
                l10n.activities,

            value:
                totalActivities
                    .toString(),

            icon:
                Icons.assignment_outlined,
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        // ======================================================
        // HARVESTED
        // ======================================================

        Expanded(
          child:
              _summaryCard(
            title:
                l10n.harvested,

          
                value:
    '${_formatKg(totalTreeHarvestedKg)} kg',

            icon:
                Icons.scale_outlined,
          ),
        ),

        const SizedBox(
          width: 8,
        ),

        // ======================================================
        // TOTAL COST
        // ======================================================

        Expanded(
          child:
              _summaryCard(
            title:
                l10n.totalCost,

            value:
                _formatCompactMoney(
              totalCost,
            ),

            icon:
                Icons.payments_outlined,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TREE LIST
  // ============================================================

  Widget _buildTreeList(
    BuildContext context,
    List<Map<String, dynamic>>
        visibleTrees,
  ) {
    if (_isLoading) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 40,
        ),

        child: Center(
          child:
              CircularProgressIndicator(
            color:
                primaryGreen,
          ),
        ),
      );
    }

    if (_error != null) {
      return _errorState(
        context,
      );
    }

    if (visibleTrees.isEmpty) {
      return _emptyState(
        context,
      );
    }

    return Column(
      children:
          visibleTrees
              .map(
                (tree) =>
                    Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    bottom: 12,
                  ),

                  child:
                      _treeCard(
                    context,
                    tree,
                  ),
                ),
              )
              .toList(),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      height: 83,

      padding:
          const EdgeInsets.all(
        8,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          11,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [
          Row(
            children: [
              Icon(
                icon,

                color:
                    primaryGreen,

                size: 14,
              ),

              const SizedBox(
                width: 4,
              ),

              Expanded(
                child: Text(
                  title,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color:
                        textGrey,

  fontSize: AppTextStyles.tiny,

                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),
              ),
            ],
          ),

          FittedBox(
            fit:
                BoxFit.scaleDown,

            alignment:
                Alignment.centerLeft,

            child: Text(
              value,

              style:
                  const TextStyle(
                color:
                    textDark,

                fontSize: AppTextStyles.subtitle,

                fontWeight:
                    FontWeight
                        .w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TREE CARD
  // ============================================================

  Widget _treeCard(
    BuildContext context,
    Map<String, dynamic> tree,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final rawId =
        tree['id']
                ?.toString() ??
            '';

    final treeCode =
        tree['treeCode']
                ?.toString() ??
            'TR-${rawId.padLeft(6, '0')}';

    final variety =
        tree['variety']
                ?.toString() ??
            '-';

    final plantingYear =
        tree['plantingYear']
                ?.toString() ??
            '-';

    final status =
        tree['status']
                ?.toString() ??
            '-';

    final farmName =
        tree['farmName']
                ?.toString() ??
            '-';

    final blockName =
        tree['blockName']
                ?.toString() ??
            '-';

    final formattedStatus =
        _formatStatus(
      context,
      status,
    );

    final statusColor =
        _statusColor(
      status,
    );

    final statusBackground =
        _statusBackground(
      status,
    );

    return InkWell(
      onTap: () {
        _openTree(
          tree,
        );
      },

      borderRadius:
          BorderRadius.circular(
        13,
      ),

      child: Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets.all(
          14,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            13,
          ),

          border:
              Border.all(
            color:
                borderColor,
          ),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ================================================
            // TOP
            // ================================================

            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,

                  decoration:
                      BoxDecoration(
                    color:
                        statusBackground,

                    shape:
                        BoxShape.circle,
                  ),

                  child: Icon(
                    Icons.park_outlined,

                    color:
                        statusColor,

                    size: 20,
                  ),
                ),

                const SizedBox(
                  width: 11,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,

                    children: [
                      Text(
                        treeCode,

                        style:
                            const TextStyle(
                          color:
                              textDark,

                          fontSize: AppTextStyles.body,

                          fontWeight:
                              FontWeight
                                  .w800,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      Text(
                        '$variety • '
                        '${l10n.planted} '
                        '$plantingYear',

                        style:
                            const TextStyle(
                          color:
                              textGrey,

                          fontSize: AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),

                  decoration:
                      BoxDecoration(
                    color:
                        statusBackground,

                    borderRadius:
                        BorderRadius
                            .circular(
                      6,
                    ),
                  ),

                  child: Text(
                    formattedStatus,

                    style:
                        TextStyle(
                      color:
                          statusColor,

                      fontSize: AppTextStyles.bodySmall,

                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 13,
            ),

            const Divider(
              height: 1,
              color:
                  borderColor,
            ),

            const SizedBox(
              height: 12,
            ),

            // ================================================
            // FARM / BLOCK
            // ================================================

            Row(
              children: [
                Expanded(
                  child:
                      _treeInfo(
                    title:
                        l10n.farm,

                    value:
                        farmName,
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),

                Expanded(
                  child:
                      _treeInfo(
                    title:
                        l10n.block,

                    value:
                        blockName,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 13,
            ),

            // ================================================
            // TREE CODE / VIEW
            // ================================================

            Row(
              children: [
                const Icon(
                  Icons
                      .qr_code_scanner,

                  color:
                      primaryGreen,

                  size: 18,
                ),

                const SizedBox(
                  width: 6,
                ),

                Expanded(
                  child: Text(
                    treeCode,

                    overflow:
                        TextOverflow
                            .ellipsis,

                    style:
                        const TextStyle(
                      color:
                          textGrey,

                      fontSize: AppTextStyles.bodySmall,

                      fontWeight:
                          FontWeight
                              .w600,
                    ),
                  ),
                ),

                TextButton(
                  onPressed: () {
                    _openTree(
                      tree,
                    );
                  },

                  style:
                      TextButton
                          .styleFrom(
                    foregroundColor:
                        primaryGreen,

                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 6,
                    ),
                  ),

                  child: Text(
                    '${l10n.viewTree} ›',

                    style:
                        const TextStyle(
                      fontSize: AppTextStyles.bodySmall,

                      fontWeight:
                          FontWeight
                              .w700,
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

  // ============================================================
  // TREE INFORMATION
  // ============================================================

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

          style:
              const TextStyle(
            color:
                textGrey,

            fontSize: AppTextStyles.bodySmall,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          value,

          maxLines: 1,

          overflow:
              TextOverflow.ellipsis,

          style:
              const TextStyle(
            color:
                textDark,

            fontSize: AppTextStyles.bodySmall,

            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // FORMAT KG
  // ============================================================

  String _formatKg(
    double value,
  ) {
    if (value ==
        value.truncateToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(
          RegExp(r'0+$'),
          '',
        )
        .replaceFirst(
          RegExp(r'\.$'),
          '',
        );
  }

  // ============================================================
  // FORMAT MONEY
  // ============================================================

  String _formatCompactMoney(
    double value,
  ) {
    if (value >=
        1000000000) {
      return 'TZS '
          '${_cleanNumber(value / 1000000000)}B';
    }

    if (value >=
        1000000) {
      return 'TZS '
          '${_cleanNumber(value / 1000000)}M';
    }

    if (value >=
        1000) {
      return 'TZS '
          '${_cleanNumber(value / 1000)}K';
    }

    return 'TZS '
        '${value.toStringAsFixed(0)}';
  }

  String _cleanNumber(
    double value,
  ) {
    if (value ==
        value.truncateToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value
        .toStringAsFixed(1)
        .replaceFirst(
          RegExp(r'0+$'),
          '',
        )
        .replaceFirst(
          RegExp(r'\.$'),
          '',
        );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets
              .symmetric(
        vertical: 35,
        horizontal: 20,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          13,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.error_outline,

            color:
                Colors.redAccent,

            size: 32,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            l10n.unableToLoadTrees,

            style:
                const TextStyle(
              color:
                  textDark,

              fontSize: AppTextStyles.body,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          Text(
            _error ??
                l10n.unknownError,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  textGrey,

              fontSize: AppTextStyles.bodySmall,
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          TextButton.icon(
            onPressed:
                _loadDashboard,

            icon:
                const Icon(
              Icons.refresh,

              size: 16,
            ),

            label: Text(
              l10n.tryAgain,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final searching =
        _searchText
            .trim()
            .isNotEmpty;

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets
              .symmetric(
        vertical: 45,
        horizontal: 20,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          13,
        ),

        border:
            Border.all(
          color:
              borderColor,
        ),
      ),

      child: Column(
        children: [
          Icon(
            searching
                ? Icons.search_off
                : Icons
                    .park_outlined,

            color:
                textGrey,

            size: 32,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            searching
                ? l10n.noTreesFound
                : l10n
                    .noTreesRegistered,

            style:
                const TextStyle(
              color:
                  textDark,

              fontSize: AppTextStyles.body,

              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            searching
                ? l10n
                    .tryAnotherTreeSearch
                : l10n
                    .registeredTreesAppearHere,

            textAlign:
                TextAlign.center,

            style:
                const TextStyle(
              color:
                  textGrey,

              fontSize: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOCALIZED STATUS
  // ============================================================

  String _formatStatus(
    BuildContext context,
    String status,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    switch (
        status.trim().toUpperCase()) {
      case 'HEALTHY':
        return l10n.healthy;

      case 'DISEASED':
        return l10n.diseased;

      case 'DEAD':
        return l10n.dead;

      default:
        return '-';
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(
    String status,
  ) {
    switch (
        status.toUpperCase()) {
      case 'HEALTHY':
        return primaryGreen;

      case 'DISEASED':
        return const Color(
          0xFFD97706,
        );

      case 'DEAD':
        return const Color(
          0xFFB91C1C,
        );

      default:
        return textGrey;
    }
  }

  // ============================================================
  // STATUS BACKGROUND
  // ============================================================

  Color _statusBackground(
    String status,
  ) {
    switch (
        status.toUpperCase()) {
      case 'HEALTHY':
        return lightGreen;

      case 'DISEASED':
        return const Color(
          0xFFFFF3D6,
        );

      case 'DEAD':
        return const Color(
          0xFFFFE4E4,
        );

      default:
        return const Color(
          0xFFF0F2F1,
        );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(
          message,
        ),
      ),
    );
  }
}