import 'package:flutter/material.dart';

import '../services/local_data_service.dart';
import '../l10n/app_localizations.dart';
import '../services/api_services/farm_api_services.dart';
import '../theme/app_text_styles.dart';
import 'addfarm_page.dart';
import 'farmdetails_page.dart';
import '../services/api_services/tree_api_services.dart';

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
  State<FarmsPage> createState() =>
      _FarmsPageState();
}

class _FarmsPageState extends State<FarmsPage> {
  // =========================================================
  // COLORS
  // =========================================================

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

  // =========================================================
  // STATE
  // =========================================================

  bool _isLoading = true;

  String? _error;

List<Map<String, dynamic>> _farms = [];
List<Map<String, dynamic>> _trees = [];
  // =========================================================
  // INIT
  // =========================================================

  @override
  void initState() {
    super.initState();

    _loadFarms();
  }

  // =========================================================
  // LOAD FARMS
  // =========================================================
// Future<void> _loadFarms() async {
//   if (mounted) {
//     setState(() {
//       _isLoading = true;
//       _error = null;
//     });
//   }

//     try {
//       final farms = await LocalDataService.instance.getFarms();
//   try {
//     final results = await Future.wait([
//       FarmApiServices.getMyFarms(),
//       TreeApiServices.getMyTrees(),
//     ]);

//     if (!mounted) return;

//     final farms =
//         List<Map<String, dynamic>>.from(
//       results[0],
//     );

//     final trees =
//         List<Map<String, dynamic>>.from(
//       results[1],
//     );

//     debugPrint(
//       'FARMS PAGE -> FARMS: ${farms.length}',
//     );

//     debugPrint(
//       'FARMS PAGE -> TREES: ${trees.length}',
//     );

//     setState(() {
//       _farms = farms;
//       _trees = trees;
//     });
//   } catch (e) {
//     debugPrint(
//       'FARMS PAGE LOAD ERROR: $e',
//     );

//     if (!mounted) return;

//     setState(() {
//       _error = e.toString().replaceFirst(
//             'Exception: ',
//             '',
//           );
//     });
//   } finally {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }


Future<void> _loadFarms() async {
  if (mounted) {
    setState(() {
      _isLoading = true;
      _error = null;
    });
  }

  try {
    final localFarms =
        await LocalDataService.instance.getFarms();

    if (mounted) {
      setState(() {
        _farms =
            List<Map<String, dynamic>>.from(localFarms);
      });
    }

    final results = await Future.wait([
      FarmApiServices.getMyFarms(),
      TreeApiServices.getMyTrees(),
    ]);

    if (!mounted) return;

    final apiFarms =
        List<Map<String, dynamic>>.from(results[0]);

    final trees =
        List<Map<String, dynamic>>.from(results[1]);

    setState(() {
      _farms = apiFarms;
      _trees = trees;
    });
  } catch (e) {
    debugPrint('FARMS PAGE LOAD ERROR: $e');

    if (!mounted) return;

    if (_farms.isEmpty) {
      setState(() {
        _error = e.toString().replaceFirst(
          'Exception: ',
          '',
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

  // =========================================================
  // FARM STATISTICS
  // =========================================================

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
        final value =
            farm['acreage'];

        if (value == null) {
          return total;
        }

        if (value is num) {
          return total +
              value.toDouble();
        }

        return total +
            (double.tryParse(
                  value.toString(),
                ) ??
                0);
      },
    );
  }

  // =========================================================
  // FORMAT NUMBER
  // =========================================================

  String _formatNumber(
    double value,
  ) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value.toStringAsFixed(
      2,
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

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
              width:
                  double.infinity,

              height: 52,

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
              ),

              decoration:
                  const BoxDecoration(
                color:
                    primaryGreen,

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

              child: Text(
                l10n.farmDashboard,

                style:
                    const TextStyle(
                  color:
                      Colors.white,

  fontSize: AppTextStyles.bodyLarge,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),

            // =================================================
            // CONTENT
            // =================================================

            Expanded(
              child:
                  RefreshIndicator(
                color:
                    primaryGreen,

                onRefresh:
                    _loadFarms,

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
                      // =========================================
                      // STATISTICS
                      // =========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              title:
                                  l10n.farms,

                              value:
                                  _totalFarms
                                      .toString(),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              title:
                                  l10n.acres,

                              value:
                                  _formatNumber(
                                _totalAcres,
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          Expanded(
                            child:
                                _statCard(
  title: l10n.trees,
  value: _totalTrees.toString(),
),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 24,
                      ),

                      // =========================================
                      // ADD FARM BUTTON
                      // =========================================

                      Align(
                        alignment:
                            Alignment
                                .centerRight,

                        child: SizedBox(
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
                                    AppTextStyles.bodySmall,

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
                      ),

                      const SizedBox(
                        height: 18,
                      ),

                      // =========================================
                      // FARM CONTENT
                      // =========================================

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
      ),
    );
  }

  // =========================================================
  // FARM CONTENT
  // =========================================================

  Widget _buildFarmContent(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    // ---------------------------------------------------------
    // Loading
    // ---------------------------------------------------------

    if (_isLoading) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 60,
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

    // ---------------------------------------------------------
    // Error
    // ---------------------------------------------------------

    if (_error != null) {
      return Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 20,
          vertical: 35,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            14,
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
                  Colors.red,

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
                color:
                    textDark,

                fontSize: AppTextStyles.bodyLarge,

                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              _error!,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF718078,
                ),

  fontSize: AppTextStyles.bodySmall,
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
                onPressed:
                    _loadFarms,

                icon:
                    const Icon(
                  Icons.refresh,

                  size: 15,
                ),

                label: Text(
                  l10n.retry,

                  style:
                      const TextStyle(
                    fontSize: AppTextStyles.bodySmall,

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

    // ---------------------------------------------------------
    // No farms
    // ---------------------------------------------------------

    if (_farms.isEmpty) {
      return Container(
        width:
            double.infinity,

        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 20,
          vertical: 45,
        ),

        decoration:
            BoxDecoration(
          color:
              Colors.white,

          borderRadius:
              BorderRadius.circular(
            14,
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
                  .agriculture_outlined,

              color:
                  primaryGreen,

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
                color:
                    textDark,

                fontSize: AppTextStyles.bodyLarge,

                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(
              height: 6,
            ),

            Text(
              l10n
                  .addFirstFarmMessage,

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(
                  0xFF718078,
                ),

                fontSize: AppTextStyles.bodySmall,

                fontWeight:
                    FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // ---------------------------------------------------------
    // Farms available
    // ---------------------------------------------------------

    return Column(
      children:
          _farms.map(
        (farm) {
          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 16,
            ),

            child:
                _featuredFarm(
              context,
              farm,
            ),
          );
        },
      ).toList(),
    );
  }

  // =========================================================
  // STAT CARD
  // =========================================================

  Widget _statCard({
    required String title,
    required String value,
  }) {
    return Container(
      height: 78,

      padding:
          const EdgeInsets
              .fromLTRB(
        10,
        10,
        8,
        8,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          12,
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
          Row(
            children: [
              Container(
                width: 16,
                height: 16,

                decoration:
                    const BoxDecoration(
                  color:
                      lightGreen,

                  shape:
                      BoxShape.circle,
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
                    color:
                        Color(
                      0xFF68766D,
                    ),

                    fontSize: AppTextStyles.bodySmall,

                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 7,
          ),

          Text(
            value,

            style:
                const TextStyle(
              color:
                  primaryGreen,

              fontSize: AppTextStyles.heading,

              fontWeight:
                  FontWeight.w800,

              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // FEATURED FARM
  // =========================================================

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

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets
              .fromLTRB(
        14,
        14,
        14,
        14,
      ),

      decoration:
          BoxDecoration(
        color:
            Colors.white,

        borderRadius:
            BorderRadius.circular(
          14,
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
          Row(
  children: [
    Expanded(
      child: Text(
        displayFarmName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: textDark,
          fontSize: AppTextStyles.bodyLarge,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
    if (farm['_pendingSync'] == true)
      const Tooltip(
        message: 'Waiting to sync',
        child: Icon(
          Icons.cloud_upload_outlined,
          color: Colors.orange,
          size: 17,
        ),
      ),
  ],
),

  //         Row(
  //           children: [
  //             Expanded(
  //               child: Text(
  //                 farmName,
  //         // =====================================================
  //         // FARM NAME
  //         // =====================================================

  //         Text(
  //           displayFarmName,

  //           style:
  //               const TextStyle(
  //             color:
  //                 textDark,

  // fontSize: AppTextStyles.bodyLarge,

  //             fontWeight:
  //                 FontWeight.w800,
  //           ),
  //               ),
  //             ),
  //             if (farm['_pendingSync'] == true)
  //               const Tooltip(
  //                 message: 'Waiting to sync',
  //                 child: Icon(
  //                   Icons.cloud_upload_outlined,
  //                   color: Colors.orange,
  //                   size: 17,
  //                 ),
  //               ),
  //           ],
  //         ),

          const SizedBox(
            height: 6,
          ),

          // =====================================================
          // LOCATION
          // =====================================================

          Row(
            children: [
              const Icon(
                Icons
                    .location_on_outlined,

                size: 12,

                color:
                    Color(
                  0xFF718078,
                ),
              ),

              const SizedBox(
                width: 3,
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
                    color:
                        Color(
                      0xFF718078,
                    ),

                    fontSize: AppTextStyles.bodySmall,

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

          // =====================================================
          // FARM TYPE BADGE
          // =====================================================

          Container(
            padding:
                const EdgeInsets
                    .symmetric(
              horizontal: 9,
              vertical: 6,
            ),

            decoration:
                BoxDecoration(
              color:
                  lightGreen,

              borderRadius:
                  BorderRadius
                      .circular(
                7,
              ),
            ),

            child: Text(
              farmType,

              style:
                  const TextStyle(
                color:
                    primaryGreen,

                fontSize: AppTextStyles.bodySmall,

                fontWeight:
                    FontWeight
                        .w600,
              ),
            ),
          ),

          const SizedBox(
            height: 8,
          ),

          // =====================================================
          // ACREAGE + PLANTING DATE + VIEW BUTTON
          // =====================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.end,

            children: [
              Expanded(
                child: Text(
                  '$acreage ${l10n.acres}'
                  '${_plantingDateText(context, farm)}',

                  maxLines: 2,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Color(
                      0xFF68766D,
                    ),

                    fontSize: AppTextStyles.bodySmall,

                    fontWeight:
                        FontWeight
                            .w500,
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              SizedBox(
                height: 42,

                child:
                    ElevatedButton(
                  onPressed:
                      () async {
                    await Navigator
                        .push(
                      context,

                      MaterialPageRoute(
                        builder:
                            (context) =>
                                FarmDetailsPage(
                          farm: farm,
                        ),
                      ),
                    );
                  },

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
                          22,
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

                  child: Text(
                    l10n.viewFarm,

                    style:
                        const TextStyle(
                      fontSize: AppTextStyles.bodySmall,

                      fontWeight:
                          FontWeight
                              .w700,
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

  // =========================================================
  // FARM HELPERS
  // =========================================================

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

  // =========================================================
  // FARM TYPE
  // =========================================================

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

  // =========================================================
  // FARM LOCATION
  // =========================================================

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

  // =========================================================
  // PLANTING DATE
  // =========================================================

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

  // =========================================================
  // NAV ITEM
  // Kept because it existed in your original page.
  // =========================================================

  Widget _navigationItem({
    required IconData icon,
    required String label,
    required bool selected,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap:
            onTap,

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              icon,

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
                fontSize: AppTextStyles.bodySmall,

                fontWeight:
                    selected
                        ? FontWeight
                            .w700
                        : FontWeight
                            .w500,

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