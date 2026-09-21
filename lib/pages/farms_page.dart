import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_services/farm_api_services.dart';
import '../services/api_services/tree_api_services.dart';
import '../services/local_data_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/farm_map.dart';

import 'addfarm_page.dart';
import 'farmdetails_page.dart';

class FarmsPage extends StatefulWidget {
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

  @override
  State<FarmsPage> createState() => _FarmsPageState();
}

class _FarmsPageState extends State<FarmsPage> {
  // ===============================================================
  // COLORS
  // ===============================================================

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  // ===============================================================
  // STATE
  // ===============================================================

  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _farms = [];
  List<Map<String, dynamic>> _trees = [];

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  // ===============================================================
  // LOAD FARMS + TREES
  // ===============================================================

  Future<void> _loadFarms() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    // -------------------------------------------------------------
    // 1. Load local farms first.
    // -------------------------------------------------------------

    try {
      final localFarms =
          await LocalDataService.instance.getFarms();

      if (mounted && localFarms.isNotEmpty) {
        setState(() {
          _farms =
              List<Map<String, dynamic>>.from(
            localFarms,
          );
        });
      }
    } catch (e) {
      debugPrint(
        'FARMS PAGE LOCAL LOAD ERROR: $e',
      );
    }

    // -------------------------------------------------------------
    // 2. Load latest farms + trees from backend.
    // -------------------------------------------------------------

    try {
      final results = await Future.wait([
        FarmApiServices.getMyFarms(),
        TreeApiServices.getMyTrees(),
      ]);

      if (!mounted) return;

      final apiFarms =
          List<Map<String, dynamic>>.from(
        results[0],
      );

      final apiTrees =
          List<Map<String, dynamic>>.from(
        results[1],
      );

      debugPrint(
        'FARMS PAGE -> FARMS: ${apiFarms.length}',
      );

      debugPrint(
        'FARMS PAGE -> TREES: ${apiTrees.length}',
      );

      // Helpful while testing farm geometry.
      for (final farm in apiFarms) {
        debugPrint(
          'FARM ${farm['id']} '
          '${farm['name']} '
          'GEOMETRY: ${farm['geometry']}',
        );
      }

      // Helpful while testing tree positions.
      for (final tree in apiTrees) {
        debugPrint(
          'TREE ${tree['treeCode'] ?? tree['id']} '
          'FARM: ${tree['farmId']} '
          'GEOMETRY: ${tree['geometry']}',
        );
      }

      setState(() {
        _farms = apiFarms;
        _trees = apiTrees;
        _error = null;
      });
    } catch (e) {
      debugPrint(
        'FARMS PAGE API LOAD ERROR: $e',
      );

      if (!mounted) return;

      // Keep local farms visible if we already have them.
      if (_farms.isEmpty) {
        setState(() {
          _error = _cleanError(
            e.toString(),
          );
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ===============================================================
  // STATISTICS
  // ===============================================================

  int get _totalFarms {
    return _farms.length;
  }

  int get _totalTrees {
    return _trees.length;
  }

  double get _totalAcres {
    return _farms.fold<double>(
      0,
      (total, farm) {
        final value = farm['acreage'];

        if (value == null) {
          return total;
        }

        if (value is num) {
          return total + value.toDouble();
        }

        return total +
            (double.tryParse(
                  value.toString(),
                ) ??
                0);
      },
    );
  }

  // ===============================================================
  // FORMAT NUMBER
  // ===============================================================

  String _formatNumber(
    double value,
  ) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  // ===============================================================
  // GET TREES FOR FARM
  // ===============================================================

  List<Map<String, dynamic>> _treesForFarm(
    Map<String, dynamic> farm,
  ) {
    final farmId =
        farm['id']?.toString();

    if (farmId == null ||
        farmId.trim().isEmpty) {
      return [];
    }

    return _trees.where((tree) {
      return tree['farmId']?.toString() ==
          farmId;
    }).toList();
  }

  // ===============================================================
  // TREE COUNTS
  // ===============================================================

  int _healthyTrees(
    List<Map<String, dynamic>> trees,
  ) {
    return trees.where((tree) {
      return tree['status']
              ?.toString()
              .toUpperCase() ==
          'HEALTHY';
    }).length;
  }

  int _diseasedTrees(
    List<Map<String, dynamic>> trees,
  ) {
    return trees.where((tree) {
      return tree['status']
              ?.toString()
              .toUpperCase() ==
          'DISEASED';
    }).length;
  }

  int _deadTrees(
    List<Map<String, dynamic>> trees,
  ) {
    return trees.where((tree) {
      return tree['status']
              ?.toString()
              .toUpperCase() ==
          'DEAD';
    }).length;
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Column(
          children: [
            // =====================================================
            // HEADER
            // =====================================================

           // =====================================================
// HEADER
// =====================================================
Container(
  width: double.infinity,
  color: primaryGreen,

  // Green reaches the very top.
  // +8 moves the header content slightly lower.
  padding: EdgeInsets.only(
    top: MediaQuery.of(context).padding.top + 8,
  ),

  child: SizedBox(
    height: 52,
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      child: Row(
        children: [
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

          Expanded(
            child: Text(
              l10n.farmDashboard,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTextStyles.bodyLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          IconButton(
            onPressed: _loadFarms,
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

            // =====================================================
            // CONTENT
            // =====================================================

            Expanded(
              child: RefreshIndicator(
                color: primaryGreen,
                onRefresh: _loadFarms,
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
                    25,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      // ===========================================
                      // STATISTICS
                      // ===========================================

                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              title:
                                  l10n.farms,
                              value:
                                  _totalFarms
                                      .toString(),
                              icon: Icons
                                  .agriculture_outlined,
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: _statCard(
                              title:
                                  l10n.acres,
                              value:
                                  _formatNumber(
                                _totalAcres,
                              ),
                              icon: Icons
                                  .landscape_outlined,
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child: _statCard(
                              title:
                                  l10n.trees,
                              value:
                                  _totalTrees
                                      .toString(),
                              icon: Icons
                                  .park_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // ===========================================
                      // ADD FARM
                      // ===========================================

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.farms,
                              style:
                                  const TextStyle(
                                color:
                                    textDark,
                                fontSize:
                                    AppTextStyles
                                        .bodyLarge,
                                fontWeight:
                                    FontWeight
                                        .w800,
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 40,
                            child:
                                ElevatedButton
                                    .icon(
                              onPressed:
                                  () async {
                                final created =
                                    await Navigator
                                        .push<
                                            bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const AddFarmPage(),
                                  ),
                                );

                                if (created ==
                                    true) {
                                  await _loadFarms();
                                }
                              },
                              icon:
                                  const Icon(
                                Icons.add,
                                size: 16,
                              ),
                              label: Text(
                                l10n.addFarm,
                                style:
                                    const TextStyle(
                                  fontSize:
                                      AppTextStyles
                                          .bodySmall,
                                  fontWeight:
                                      FontWeight
                                          .w700,
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
                                padding:
                                    const EdgeInsets
                                        .symmetric(
                                  horizontal:
                                      16,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    9,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      // ===========================================
                      // FARMS
                      // ===========================================

                      _buildFarmContent(
                        context,
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

  // ===============================================================
  // FARM CONTENT
  // ===============================================================

  Widget _buildFarmContent(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    // -------------------------------------------------------------
    // Loading
    // -------------------------------------------------------------

    if (_isLoading && _farms.isEmpty) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 60,
        ),
        child: Center(
          child:
              CircularProgressIndicator(
            color: primaryGreen,
          ),
        ),
      );
    }

    // -------------------------------------------------------------
    // Error
    // -------------------------------------------------------------

    if (_error != null &&
        _farms.isEmpty) {
      return _errorCard(
        context,
      );
    }

    // -------------------------------------------------------------
    // No farms
    // -------------------------------------------------------------

    if (_farms.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 45,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.agriculture_outlined,
              color: primaryGreen,
              size: 42,
            ),

            const SizedBox(
              height: 12,
            ),

            Text(
              l10n.noFarmsAddedYet,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: textDark,
                fontSize:
                    AppTextStyles
                        .bodyLarge,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              l10n.addFirstFarmMessage,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: textGrey,
                fontSize:
                    AppTextStyles
                        .bodySmall,
                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // -------------------------------------------------------------
    // Farms available
    // -------------------------------------------------------------

    return Column(
      children: _farms.map(
        (farm) {
          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 16,
            ),
            child: _featuredFarm(
              context,
              farm,
            ),
          );
        },
      ).toList(),
    );
  }

  // ===============================================================
  // ERROR CARD
  // ===============================================================

  Widget _errorCard(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 38,
          ),

          const SizedBox(
            height: 12,
          ),

          Text(
            l10n.unableToLoadFarms,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: textDark,
              fontSize:
                  AppTextStyles
                      .bodyLarge,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            _error ?? '',
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color: textGrey,
              fontSize:
                  AppTextStyles
                      .bodySmall,
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          const SizedBox(
            height: 15,
          ),

          SizedBox(
            height: 38,
            child:
                ElevatedButton.icon(
              onPressed: _loadFarms,
              icon: const Icon(
                Icons.refresh,
                size: 15,
              ),
              label: Text(
                l10n.retry,
                style:
                    const TextStyle(
                  fontSize:
                      AppTextStyles
                          .bodySmall,
                  fontWeight:
                      FontWeight
                          .w700,
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
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    9,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // STAT CARD
  // ===============================================================

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      height: 82,
      padding:
          const EdgeInsets.fromLTRB(
        10,
        10,
        8,
        8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20,
                height: 20,
                decoration:
                    const BoxDecoration(
                  color: lightGreen,
                  shape:
                      BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 12,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(
                width: 5,
              ),

              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color: Color(
                      0xFF68766D,
                    ),
                    fontSize:
                        AppTextStyles
                            .bodySmall,
                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ),
            ],
          ),

          const Spacer(),

          Text(
            value,
            style:
                const TextStyle(
              color: primaryGreen,
              fontSize:
                  AppTextStyles.heading,
              fontWeight:
                  FontWeight.w800,
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

  Widget _featuredFarm(
    BuildContext context,
    Map<String, dynamic> farm,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final farmName =
        farm['name']
                ?.toString()
                .trim() ??
            '';

    final displayFarmName =
        farmName.isNotEmpty
            ? farmName
            : l10n.farm;

    final acreage =
        _getFarmAcreage(
      farm,
    );

    final farmType =
        _getFarmTypeLabel(
      context,
      farm,
    );

    final location =
        _getFarmLocation(
      context,
      farm,
    );

    // -------------------------------------------------------------
    // IMPORTANT:
    // Only trees belonging to this farm are passed to its map.
    // -------------------------------------------------------------

    final farmTrees =
        _treesForFarm(farm);

    final healthy =
        _healthyTrees(farmTrees);

    final diseased =
        _diseasedTrees(farmTrees);

    final dead =
        _deadTrees(farmTrees);

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.fromLTRB(
        14,
        14,
        14,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // =======================================================
          // FARM NAME
          // =======================================================

          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration:
                    const BoxDecoration(
                  color: lightGreen,
                  shape:
                      BoxShape.circle,
                ),
                child: const Icon(
                  Icons
                      .agriculture_outlined,
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
                      displayFarmName,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        color: textDark,
                        fontSize:
                            AppTextStyles
                                .bodyLarge,
                        fontWeight:
                            FontWeight
                                .w800,
                      ),
                    ),

                    const SizedBox(
                      height: 3,
                    ),

                    Text(
                      '${farmTrees.length} ${l10n.trees}',
                      style:
                          const TextStyle(
                        color: textGrey,
                        fontSize:
                            AppTextStyles
                                .bodySmall,
                        fontWeight:
                            FontWeight
                                .w500,
                      ),
                    ),
                  ],
                ),
              ),

              if (farm['_pendingSync'] ==
                  true)
                const Tooltip(
                  message:
                      'Waiting to sync',
                  child: Icon(
                    Icons
                        .cloud_upload_outlined,
                    color:
                        Colors.orange,
                    size: 17,
                  ),
                ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          // =======================================================
          // LOCATION
          // =======================================================

          Row(
            children: [
              const Icon(
                Icons
                    .location_on_outlined,
                size: 13,
                color: textGrey,
              ),

              const SizedBox(
                width: 4,
              ),

              Expanded(
                child: Text(
                  location,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color: textGrey,
                    fontSize:
                        AppTextStyles
                            .bodySmall,
                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 12,
          ),

          // =======================================================
          // FARM TYPE + ACREAGE
          // =======================================================

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _farmBadge(
                icon:
                    Icons.category_outlined,
                label: farmType,
              ),

              _farmBadge(
                icon:
                    Icons.landscape_outlined,
                label:
                    '$acreage ${l10n.acres}',
              ),

              _farmBadge(
                icon:
                    Icons.park_outlined,
                label:
                    '${farmTrees.length} ${l10n.trees}',
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          // =======================================================
          // FARM MAP
          //
          // Polygon = farm geometry from database.
          // Markers = tree coordinates from database.
          // =======================================================

          FarmMap(
            farm: farm,
            trees: farmTrees,
            compact: true,
          ),

          const SizedBox(
            height: 13,
          ),

          // =======================================================
          // TREE STATUS SUMMARY
          // =======================================================

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color:
                  const Color(
                0xFFF9FBF9,
              ),
              borderRadius:
                  BorderRadius.circular(
                9,
              ),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child:
                      _treeStatusItem(
                    color:
                        primaryGreen,
                    value: healthy,
                    label: 'Healthy',
                  ),
                ),

                _verticalDivider(),

                Expanded(
                  child:
                      _treeStatusItem(
                    color:
                        const Color(
                      0xFFD97706,
                    ),
                    value:
                        diseased,
                    label:
                        'Diseased',
                  ),
                ),

                _verticalDivider(),

                Expanded(
                  child:
                      _treeStatusItem(
                    color:
                        const Color(
                      0xFFB91C1C,
                    ),
                    value: dead,
                    label: 'Dead',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 13,
          ),

          // =======================================================
          // PLANTING DATE
          // =======================================================

          if (_plantingDateText(
            context,
            farm,
          ).isNotEmpty)
            Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 13,
                    color: textGrey,
                  ),

                  const SizedBox(
                    width: 5,
                  ),

                  Expanded(
                    child: Text(
                      _plantingDateText(
                        context,
                        farm,
                      ).replaceFirst(
                        ' • ',
                        '',
                      ),
                      style:
                          const TextStyle(
                        color: textGrey,
                        fontSize:
                            AppTextStyles
                                .bodySmall,
                        fontWeight:
                            FontWeight
                                .w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // =======================================================
          // VIEW FARM
          // =======================================================

          SizedBox(
            width: double.infinity,
            height: 42,
            child:
                ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        FarmDetailsPage(
                      farm: farm,
                    ),
                  ),
                );

                // Refresh when coming back from details.
                if (mounted) {
                  await _loadFarms();
                }
              },
              icon: const Icon(
                Icons
                    .visibility_outlined,
                size: 17,
              ),
              label: Text(
                l10n.viewFarm,
                style:
                    const TextStyle(
                  fontSize:
                      AppTextStyles
                          .bodySmall,
                  fontWeight:
                      FontWeight
                          .w700,
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
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    9,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FARM BADGE
  // ===============================================================

  Widget _farmBadge({
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius:
            BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize:
            MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: primaryGreen,
            size: 13,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            label,
            style:
                const TextStyle(
              color: primaryGreen,
              fontSize:
                  AppTextStyles
                      .bodySmall,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // TREE STATUS
  // ===============================================================

  Widget _treeStatusItem({
    required Color color,
    required int value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(
                color: color,
                shape:
                    BoxShape.circle,
              ),
            ),

            const SizedBox(
              width: 5,
            ),

            Text(
              value.toString(),
              style:
                  const TextStyle(
                color: textDark,
                fontSize:
                    AppTextStyles
                        .body,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          label,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            color: textGrey,
            fontSize:
                AppTextStyles
                    .bodySmall,
            fontWeight:
                FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 31,
      color: borderColor,
    );
  }

  // ===============================================================
  // FARM ACREAGE
  // ===============================================================

  String _getFarmAcreage(
    Map<String, dynamic> farm,
  ) {
    final value =
        farm['acreage'];

    if (value == null) {
      return '0';
    }

    if (value is num) {
      return _formatNumber(
        value.toDouble(),
      );
    }

    final parsed =
        double.tryParse(
      value.toString(),
    );

    if (parsed == null) {
      return value.toString();
    }

    return _formatNumber(
      parsed,
    );
  }

  // ===============================================================
  // FARM TYPE
  //
  // Backend enum values are not translated or modified.
  // Only their displayed labels are localized.
  // ===============================================================

  String _getFarmTypeLabel(
    BuildContext context,
    Map<String, dynamic> farm,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final type =
        farm['farmType']
            ?.toString()
            .trim()
            .toUpperCase();

    switch (type) {
      case 'NEW':
        return l10n.newFarm;

      case 'PRODUCTION':
        return l10n.productionFarm;

      default:
        if (type != null &&
            type.isNotEmpty) {
          return type;
        }

        return l10n.farm;
    }
  }

  // ===============================================================
  // FARM LOCATION
  // ===============================================================

  String _getFarmLocation(
    BuildContext context,
    Map<String, dynamic> farm,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final village =
        farm['village']
            ?.toString()
            .trim();

    final ward =
        farm['ward']
            ?.toString()
            .trim();

    final district =
        farm['district']
            ?.toString()
            .trim();

    final region =
        farm['region']
            ?.toString()
            .trim();

    final farmLocation =
        farm['farmLocation']
            ?.toString()
            .trim();

    if (village != null &&
        village.isNotEmpty) {
      return village;
    }

    if (farmLocation != null &&
        farmLocation.isNotEmpty) {
      return farmLocation;
    }

    if (ward != null &&
        ward.isNotEmpty) {
      return ward;
    }

    if (district != null &&
        district.isNotEmpty) {
      return district;
    }

    if (region != null &&
        region.isNotEmpty) {
      return region;
    }

    return l10n.locationNotAvailable;
  }

  // ===============================================================
  // PLANTING DATE
  // ===============================================================

  String _plantingDateText(
    BuildContext context,
    Map<String, dynamic> farm,
  ) {
    final plantingDate =
        farm['plantingDate']
            ?.toString()
            .trim();

    if (plantingDate == null ||
        plantingDate.isEmpty) {
      return '';
    }

    final l10n =
        AppLocalizations.of(context)!;

    return ' • ${l10n.planted}: '
        '$plantingDate';
  }

  // ===============================================================
  // CLEAN ERROR
  // ===============================================================

  String _cleanError(
    String error,
  ) {
    return error.replaceFirst(
      'Exception: ',
      '',
    );
  }

  // ===============================================================
  // NAV ITEM
  // Kept for compatibility with your existing FarmsPage.
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

            const SizedBox(
              height: 4,
            ),

            Text(
              label,
              style: TextStyle(
                fontSize:
                    AppTextStyles
                        .bodySmall,
                fontWeight:
                    selected
                        ? FontWeight
                            .w700
                        : FontWeight
                            .w500,
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