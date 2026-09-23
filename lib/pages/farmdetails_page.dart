import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_services/tree_api_services.dart';
import '../theme/app_text_styles.dart';
import '../widgets/farm_map.dart';

import 'blocks_page.dart';
import 'treesdetails_page.dart';

class FarmDetailsPage extends StatefulWidget {
  final Map<String, dynamic> farm;

  const FarmDetailsPage({
    super.key,
    required this.farm,
  });

  @override
  State<FarmDetailsPage> createState() =>
      _FarmDetailsPageState();
}

class _FarmDetailsPageState
    extends State<FarmDetailsPage> {
  static const Color primaryGreen =
      Color(0xFF087A2F);

  static const Color backgroundColor =
      Color(0xFFF8FAF8);

  static const Color borderColor =
      Color(0xFFDCE8DF);

  static const Color textDark =
      Color(0xFF25402D);

  static const Color textGrey =
      Color(0xFF718078);

  static const Color lightGreen =
      Color(0xFFE7F3EB);

  // ============================================================
  // TREE STATE
  // ============================================================

  bool _isLoadingTrees = true;

  String? _treeError;

  List<Map<String, dynamic>> _trees = [];

  // ============================================================
  // FARM
  // ============================================================

  Map<String, dynamic> get farm {
    return widget.farm;
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _loadTrees();
  }

  // ============================================================
  // FARM VALUES
  // ============================================================

  String get farmId {
    final id = farm['id'];

    if (id == null) {
      return '-';
    }

    return id.toString();
  }

  String get farmCode {
    final id = farm['id'];

    if (id == null) {
      return '-';
    }

    final parsedId =
        int.tryParse(
      id.toString(),
    );

    if (parsedId == null) {
      return id.toString();
    }

    return 'FM-${parsedId.toString().padLeft(4, '0')}';
  }

  String _farmName(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final value =
        farm['name']
            ?.toString()
            .trim();

    if (value != null &&
        value.isNotEmpty) {
      return value;
    }

    return l10n.unnamedFarm;
  }

  String get acreage {
    final value =
        farm['acreage'];

    if (value == null) {
      return '0';
    }

    if (value is num) {
      final number =
          value.toDouble();

      if (number ==
          number.roundToDouble()) {
        return number
            .toInt()
            .toString();
      }

      return number
          .toStringAsFixed(2);
    }

    final parsed =
        double.tryParse(
      value.toString(),
    );

    if (parsed != null) {
      if (parsed ==
          parsed.roundToDouble()) {
        return parsed
            .toInt()
            .toString();
      }

      return parsed
          .toStringAsFixed(2);
    }

    return value.toString();
  }

  // Keep backend value separate from
  // translated display value.

  String get rawFarmType {
    return farm['farmType']
            ?.toString()
            .trim()
            .toUpperCase() ??
        '';
  }

  String _farmType(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    switch (rawFarmType) {
      case 'NEW':
        return l10n.newFarm;

      case 'PRODUCTION':
        return l10n.productionFarm;

      default:
        if (rawFarmType.isNotEmpty) {
          return rawFarmType;
        }

        return l10n.farm;
    }
  }

  String _location(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final village =
        farm['village']
            ?.toString()
            .trim();

    final farmLocation =
        farm['farmLocation']
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

  String get plantingDate {
    final value =
        farm['plantingDate']
            ?.toString()
            .trim();

    if (value == null ||
        value.isEmpty) {
      return '-';
    }

    return value;
  }

  String get region {
    final value =
        farm['region']
            ?.toString()
            .trim();

    return value?.isNotEmpty == true
        ? value!
        : '-';
  }

  String get district {
    final value =
        farm['district']
            ?.toString()
            .trim();

    return value?.isNotEmpty == true
        ? value!
        : '-';
  }

  String get ward {
    final value =
        farm['ward']
            ?.toString()
            .trim();

    return value?.isNotEmpty == true
        ? value!
        : '-';
  }

  String get village {
    final value =
        farm['village']
            ?.toString()
            .trim();

    return value?.isNotEmpty == true
        ? value!
        : '-';
  }

  // ============================================================
  // FARM GEOMETRY
  // ============================================================

  String get farmGeometry {
    final value =
        farm['geometry']
            ?.toString()
            .trim();

    if (value == null ||
        value.isEmpty) {
      return '';
    }

    return value;
  }

  bool get hasFarmGeometry {
    return farmGeometry.isNotEmpty;
  }

  // ============================================================
  // LOAD TREES
  // ============================================================

  Future<void> _loadTrees() async {
    if (mounted) {
      setState(() {
        _isLoadingTrees = true;
        _treeError = null;
      });
    }

    try {
      final response =
          await TreeApiServices
              .getMyTrees();

      final allTrees =
          List<Map<String, dynamic>>
              .from(response);

      final currentFarmId =
          farm['id']?.toString();

      final farmTrees =
          allTrees.where(
        (tree) {
          return tree['farmId']
                  ?.toString() ==
              currentFarmId;
        },
      ).toList();

      debugPrint(
        'FARM DETAILS -> FARM: '
        '$currentFarmId',
      );

      debugPrint(
        'FARM DETAILS -> GEOMETRY: '
        '${farm['geometry']}',
      );

      debugPrint(
        'FARM DETAILS -> TREES: '
        '${farmTrees.length}',
      );

      for (final tree
          in farmTrees) {
        debugPrint(
          'FARM TREE -> '
          '${tree['treeCode'] ?? tree['id']} '
          'STATUS: ${tree['status']} '
          'GEOMETRY: ${tree['geometry']}',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _trees = farmTrees;
        _treeError = null;
      });
    } catch (e) {
      debugPrint(
        'FARM DETAILS TREE ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _treeError =
            e.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingTrees = false;
        });
      }
    }
  }

  // ============================================================
  // TREE COUNTS
  // ============================================================

  int get totalTrees {
    return _trees.length;
  }

  int get healthyTrees {
    return _trees.where(
      (tree) {
        return tree['status']
                ?.toString()
                .toUpperCase() ==
            'HEALTHY';
      },
    ).length;
  }

  int get diseasedTrees {
    return _trees.where(
      (tree) {
        return tree['status']
                ?.toString()
                .toUpperCase() ==
            'DISEASED';
      },
    ).length;
  }

  int get deadTrees {
    return _trees.where(
      (tree) {
        return tree['status']
                ?.toString()
                .toUpperCase() ==
            'DEAD';
      },
    ).length;
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

    final displayFarmName =
        _farmName(context);

    return Scaffold(
      backgroundColor:
          backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // =================================================
            // HEADER
            // =================================================

            Container(
              width: double.infinity,
              height: 52,
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 14,
              ),
              decoration:
                  const BoxDecoration(
                color: primaryGreen,
                // borderRadius:
                //     BorderRadius.only(
                //   bottomLeft:
                //       Radius.circular(
                //     18,
                //   ),
                //   bottomRight:
                //       Radius.circular(
                //     18,
                //   ),
                // ),
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                    child:
                        const Padding(
                      padding:
                          EdgeInsets
                              .all(3),
                      child: Icon(
                        Icons
                            .arrow_back_ios_new,
                        color:
                            Colors.white,
                        size: 14,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 7,
                  ),

                  Expanded(
                    child: Text(
                      l10n.farmDetails,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            AppTextStyles
                                .bodyLarge,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed:
                        _loadTrees,
                    tooltip:
                        l10n.refresh,
                    icon:
                        const Icon(
                      Icons.refresh,
                      color:
                          Colors.white,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),

            // =================================================
            // CONTENT
            // =================================================

            Expanded(
              child:
                  RefreshIndicator(
                color: primaryGreen,
                onRefresh:
                    _loadTrees,
                child:
                    SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    13,
                    24,
                    13,
                    25,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      // =======================================
                      // FARM INFORMATION
                      // =======================================

                      _informationCard(
                        context,
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =======================================
                      // FARM MAP
                      // =======================================

                      _farmMapCard(
                        context,
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =======================================
                      // VIEW BLOCKS
                      // =======================================

                      Align(
                        alignment:
                            Alignment
                                .centerRight,
                        child:
                            SizedBox(
                          height: 38,
                          child:
                              ElevatedButton
                                  .icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          BlocksPage(
                                    farmId:
                                        farmId,
                                    farmName:
                                        displayFarmName,
                                  ),
                                ),
                              );
                            },
                            icon:
                                const Icon(
                              Icons
                                  .grid_view_outlined,
                              size: 15,
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
                                    18,
                              ),
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  8,
                                ),
                              ),
                            ),
                            label: Text(
                              l10n.viewBlocks,
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
                          ),
                        ),
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // =======================================
                      // PRODUCTION SUMMARY
                      // =======================================

                      _productionSummary(
                        context,
                      ),

                      const SizedBox(
                        height: 22,
                      ),

                      // =======================================
                      // PRODUCTION HISTORY
                      // =======================================

                      _productionHistory(
                        context,
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
  // FARM INFORMATION
  // ============================================================

  Widget _informationCard(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets
              .fromLTRB(
        14,
        15,
        14,
        18,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration:
                    const BoxDecoration(
                  color: lightGreen,
                  shape:
                      BoxShape.circle,
                ),
                child:
                    const Icon(
                  Icons
                      .agriculture_outlined,
                  color:
                      primaryGreen,
                  size: 17,
                ),
              ),

              const SizedBox(
                width: 9,
              ),

              Expanded(
                child: Text(
                  l10n.farmInformation,
                  style:
                      const TextStyle(
                    color:
                        primaryGreen,
                    fontSize:
                        AppTextStyles
                            .body,
                    fontWeight:
                        FontWeight
                            .w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            '${l10n.farmId}: '
            '$farmCode',
            style:
                const TextStyle(
              color: textDark,
              fontSize:
                  AppTextStyles
                      .bodySmall,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Text(
            '${_farmName(context)} • '
            '$acreage '
            '${l10n.acres}',
            style:
                const TextStyle(
              color: textDark,
              fontSize:
                  AppTextStyles
                      .bodySmall,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // Farm type

          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration:
                BoxDecoration(
              color: lightGreen,
              borderRadius:
                  BorderRadius
                      .circular(7),
            ),
            child: Text(
              _farmType(
                context,
              ),
              style:
                  const TextStyle(
                color:
                    primaryGreen,
                fontSize:
                    AppTextStyles
                        .bodySmall,
                fontWeight:
                    FontWeight
                        .w600,
              ),
            ),
          ),

          const SizedBox(
            height: 14,
          ),

          _informationRow(
            Icons
                .location_on_outlined,
            l10n.location,
            _location(context),
          ),

          const SizedBox(
            height: 10,
          ),

          _informationRow(
            Icons
                .calendar_today_outlined,
            l10n.plantingDate,
            plantingDate,
          ),

          const SizedBox(
            height: 10,
          ),

          _informationRow(
            Icons.map_outlined,
            l10n.region,
            region,
          ),

          const SizedBox(
            height: 10,
          ),

          _informationRow(
            Icons
                .location_city_outlined,
            l10n.district,
            district,
          ),

          const SizedBox(
            height: 10,
          ),

          _informationRow(
            Icons.place_outlined,
            l10n.ward,
            ward,
          ),

          const SizedBox(
            height: 10,
          ),

          _informationRow(
            Icons
                .home_work_outlined,
            l10n.village,
            village,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FARM MAP CARD
  // ============================================================

  Widget _farmMapCard(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets
              .fromLTRB(
        12,
        14,
        12,
        14,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // MAP TITLE
          // ----------------------------------------------------

          const Row(
            children: [
              Icon(
                Icons.map_outlined,
                color: primaryGreen,
                size: 18,
              ),

              SizedBox(
                width: 7,
              ),

              Text(
                'Farm Map',
                style: TextStyle(
                  color:
                      primaryGreen,
                  fontSize:
                      AppTextStyles
                          .body,
                  fontWeight:
                      FontWeight
                          .w700,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),

          Text(
            _farmName(context),
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
            height: 14,
          ),

          // ----------------------------------------------------
          // LOADING
          // ----------------------------------------------------

          if (_isLoadingTrees)
            Container(
              width: double.infinity,
              height: 260,
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF7FAF5,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  10,
                ),
                border:
                    Border.all(
                  color:
                      borderColor,
                ),
              ),
              child:
                  const Center(
                child:
                    CircularProgressIndicator(
                  color:
                      primaryGreen,
                ),
              ),
            )

          // ----------------------------------------------------
          // ERROR
          // ----------------------------------------------------

          else if (_treeError !=
              null)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets
                      .symmetric(
                horizontal: 18,
                vertical: 30,
              ),
              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFF7FAF5,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  10,
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
                    Icons
                        .error_outline,
                    color:
                        Colors.orange,
                    size: 30,
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  Text(
                    _treeError!,
                    textAlign:
                        TextAlign
                            .center,
                    style:
                        const TextStyle(
                      color:
                          textGrey,
                      fontSize:
                          AppTextStyles
                              .bodySmall,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  TextButton.icon(
                    onPressed:
                        _loadTrees,
                    icon:
                        const Icon(
                      Icons.refresh,
                      size: 16,
                    ),
                    label:
                        const Text(
                      'Retry',
                    ),
                  ),
                ],
              ),
            )

          // ----------------------------------------------------
          // FARM MAP
          // ----------------------------------------------------

          else
            FarmMap(
              farm: farm,
              trees: _trees,
              compact: false,

              // Clicking a tree on the map
              // opens its TreeDetailsPage.
              onTreeTap: (
                tree,
              ) {
                _openTree(
                  context,
                  tree,
                );
              },
            ),

          const SizedBox(
            height: 14,
          ),

          // ----------------------------------------------------
          // TREE STATISTICS
          // ----------------------------------------------------

          _treeStatistics(),

          if (!hasFarmGeometry) ...[
            const SizedBox(
              height: 10,
            ),

            const Row(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Icon(
                  Icons
                      .info_outline,
                  color:
                      Colors.orange,
                  size: 14,
                ),

                SizedBox(
                  width: 6,
                ),

                Expanded(
                  child: Text(
                    'The farm boundary cannot be drawn until the farm geometry is available.',
                    style:
                        TextStyle(
                      color:
                          textGrey,
                      fontSize:
                          AppTextStyles
                              .bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TREE STATISTICS
  // ============================================================

  Widget _treeStatistics() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets
              .symmetric(
        horizontal: 10,
        vertical: 10,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(
          0xFFF9FBF9,
        ),
        borderRadius:
            BorderRadius
                .circular(9),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child:
                _treeStatistic(
              color:
                  primaryGreen,
              value:
                  healthyTrees,
              label:
                  'Healthy',
            ),
          ),

          _statDivider(),

          Expanded(
            child:
                _treeStatistic(
              color:
                  const Color(
                0xFFD97706,
              ),
              value:
                  diseasedTrees,
              label:
                  'Diseased',
            ),
          ),

          _statDivider(),

          Expanded(
            child:
                _treeStatistic(
              color:
                  const Color(
                0xFFB91C1C,
              ),
              value:
                  deadTrees,
              label: 'Dead',
            ),
          ),

          _statDivider(),

          Expanded(
            child:
                _treeStatistic(
              color:
                  const Color(
                0xFF455A64,
              ),
              value:
                  totalTrees,
              label: 'Total',
            ),
          ),
        ],
      ),
    );
  }

  Widget _treeStatistic({
    required Color color,
    required int value,
    required String label,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration:
                  BoxDecoration(
                color: color,
                shape:
                    BoxShape.circle,
              ),
            ),

            const SizedBox(
              width: 4,
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
                    FontWeight
                        .w800,
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

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 31,
      color: borderColor,
    );
  }

  // ============================================================
  // OPEN TREE
  // ============================================================

  void _openTree(
    BuildContext context,
    Map<String, dynamic> tree,
  ) {
    final treeId =
        tree['id']
            ?.toString();

    final treeFarmId =
        tree['farmId']
            ?.toString();

    final blockId =
        tree['blockId']
            ?.toString();

    if (treeId == null ||
        treeId.isEmpty ||
        treeFarmId == null ||
        treeFarmId.isEmpty ||
        blockId == null ||
        blockId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to open this tree because its farm or block information is missing.',
          ),
        ),
      );

      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TreeDetailsPage(
          farmId: treeFarmId,
          blockId: blockId,
          treeId: treeId,
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _informationRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 14,
          color: primaryGreen,
        ),

        const SizedBox(
          width: 8,
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              Text(
                label,
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

              const SizedBox(
                height: 2,
              ),

              Text(
                value,
                style:
                    const TextStyle(
                  color: textDark,
                  fontSize:
                      AppTextStyles
                          .bodySmall,
                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PRODUCTION SUMMARY
  // ============================================================

  Widget _productionSummary(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets
              .fromLTRB(
        14,
        15,
        14,
        16,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            l10n.productionSummary,
            style:
                const TextStyle(
              color: primaryGreen,
              fontSize:
                  AppTextStyles.body,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 17,
          ),

          Text(
            l10n.totalProduction,
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
            height: 4,
          ),

          // TODO:
          // Replace when production API is connected.

          const Text(
            '- KG',
            style: TextStyle(
              color: textDark,
              fontSize:
                  AppTextStyles
                      .largeHeading,
              fontWeight:
                  FontWeight.w800,
              height: 1,
            ),
          ),

          const SizedBox(
            height: 11,
          ),

          Text(
            '${l10n.averageProduction}: - KG',
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

  // ============================================================
  // PRODUCTION HISTORY
  // ============================================================

  Widget _productionHistory(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets
              .fromLTRB(
        14,
        15,
        14,
        18,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            l10n.productionHistory,
            style:
                const TextStyle(
              color: primaryGreen,
              fontSize:
                  AppTextStyles.body,
              fontWeight:
                  FontWeight.w700,
            ),
          ),

          const SizedBox(
            height: 17,
          ),

          Text(
            l10n.noProductionRecords,
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

  // ============================================================
  // CARD DECORATION
  // ============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(
        13,
      ),
      border: Border.all(
        color: borderColor,
        width: 1,
      ),
    );
  }
}