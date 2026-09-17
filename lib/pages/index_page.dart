import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';

import '../services/api_services/api_services.dart';
import '../services/api_services/farm_api_services.dart';
import '../services/api_services/tree_api_services.dart';
import '../services/api_services/tree_activity_api_services.dart';
import '../services/api_services/farm_harvest_api_services.dart';
import '../theme/app_text_styles.dart';

class IndexPage extends StatefulWidget {
  const IndexPage({
    super.key,
  });

@override
State<IndexPage> createState() =>
    IndexPageState();
}

class IndexPageState extends State<IndexPage>  {
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

  Map<String, dynamic>? _currentUser;

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
  // CURRENT USER NAME
  // ============================================================

  String get _userName {
    final fullName =
        _currentUser?['fullName']
            ?.toString()
            .trim();

    if (fullName != null &&
        fullName.isNotEmpty) {
      return _capitalizeName(fullName);
    }

    final username =
        _currentUser?['username']
            ?.toString()
            .trim();

    if (username != null &&
        username.isNotEmpty) {
      return _capitalizeName(username);
    }

    return 'User';
  }

  String _capitalizeName(
    String name,
  ) {
    return name
        .split(' ')
        .where(
          (word) =>
              word.trim().isNotEmpty,
        )
        .map(
          (word) {
            if (word.length == 1) {
              return word.toUpperCase();
            }

            return '${word[0].toUpperCase()}'
                '${word.substring(1).toLowerCase()}';
          },
        )
        .join(' ');
  }

  // ============================================================
  // GREETING
  // ============================================================

  String _greeting(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final hour =
        DateTime.now().hour;

    if (hour < 12) {
      return l10n.goodMorning;
    }

    if (hour < 17) {
      return l10n.goodAfternoon;
    }

    return l10n.goodEvening;
  }

  // ============================================================
  // PROFILE
  // ============================================================

  void _openProfile() {
    debugPrint(
      'OPEN PROFILE',
    );

    // TODO:
    // Navigate to profile page.
  }

  // ============================================================
  // MORE
  // ============================================================

  void _openMoreMenu() {
    debugPrint(
      'OPEN MORE',
    );

    // TODO:
    // Navigate to More page.
  }

  Future<void> refreshDashboard() async {
  await _loadDashboard();
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
      // ========================================================
      // CURRENT USER
      // GET /api/v1/auth/me
      // ========================================================

      Map<String, dynamic>?
          currentUser;

      try {
        currentUser =
            await ApiServices
                .getCurrentUser();

        debugPrint(
          'CURRENT USER: '
          '$currentUser',
        );
      } catch (e) {
        debugPrint(
          'CURRENT USER ERROR: $e',
        );
      }

      // ========================================================
      // FARMS
      // ========================================================

      final farms =
          await FarmApiServices
              .getMyFarms();

      // ========================================================
      // TREES
      // ========================================================

      final trees =
          await TreeApiServices
              .getMyTrees();

      // ========================================================
      // TREE ACTIVITIES
      // ========================================================

      final activities =
          await TreeActivityApiServices
              .getMyActivities();

      // ========================================================
      // FARM HARVESTS
      // ========================================================

      List<Map<String, dynamic>>
          farmHarvests = [];

      try {
        farmHarvests =
            await FarmHarvestApiServices
                .getMyHarvests();
      } catch (e) {
        debugPrint(
          'DASHBOARD FARM HARVEST ERROR: $e',
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _currentUser =
            currentUser;

        _farms =
            farms;

        _trees =
            trees;

        _activities =
            activities;

        _farmHarvests =
            farmHarvests;

        _isLoading =
            false;
      });

      debugPrint(
        '================================',
      );

      debugPrint(
        'DASHBOARD REAL DATA',
      );

      debugPrint(
        'USER: $_userName',
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
        'TOTAL COST: '
        '$_totalCost',
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
        _isLoading =
            false;

        _error =
            e.toString();
      });
    }
  }

  // ============================================================
  // TREE HARVEST KG
  // ============================================================

  double get _treeHarvestedKg {
    double total = 0;

    for (final activity
        in _activities) {
      final activityType =
          activity['activityType']
                  ?.toString()
                  .trim()
                  .toUpperCase() ??
              '';

      if (activityType !=
          'HARVESTING') {
        continue;
      }

      final harvestedKg =
          double.tryParse(
                activity[
                            'harvestedKg']
                        ?.toString() ??
                    '0',
              ) ??
              0;

      total += harvestedKg;
    }

    return total;
  }

  // ============================================================
  // FARM HARVEST KG
  // ============================================================

  double get _farmHarvestedKg {
    double total = 0;

    for (final harvest
        in _farmHarvests) {
      final totalHarvestedKg =
          double.tryParse(
        harvest['totalHarvestedKg']
                ?.toString() ??
            '',
      );

      if (totalHarvestedKg !=
          null) {
        total += totalHarvestedKg;

        continue;
      }

      final bucketCount =
          int.tryParse(
                harvest[
                            'bucketCount']
                        ?.toString() ??
                    '0',
              ) ??
              0;

      final kgPerBucket =
          double.tryParse(
                harvest[
                            'kgPerBucket']
                        ?.toString() ??
                    '0',
              ) ??
              0;

      total +=
          bucketCount *
              kgPerBucket;
    }

    return total;
  }

  // ============================================================
  // TOTAL HARVEST
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

    for (final activity
        in _activities) {
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

    for (final harvest
        in _farmHarvests) {
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
    final now =
        DateTime.now();

    final today =
        DateTime(
      now.year,
      now.month,
      now.day,
    );

    final upcoming =
        _activities.where(
      (activity) {
        final status =
            activity['status']
                    ?.toString()
                    .trim()
                    .toUpperCase() ??
                '';

        final date =
            DateTime.tryParse(
          activity[
                      'activityDate']
                  ?.toString() ??
              '',
        );

        if (date == null) {
          return false;
        }

        final activityDay =
            DateTime(
          date.year,
          date.month,
          date.day,
        );

        return status ==
                'PLANNED' &&
            !activityDay
                .isBefore(today);
      },
    ).toList();

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

        return aDate.compareTo(
          bDate,
        );
      },
    );

    return upcoming
        .take(3)
        .toList();
  }

  // ============================================================
  // FORMAT KG
  // ============================================================

  String _formatKg(
    double value,
  ) {
    if (value ==
        value.roundToDouble()) {
      return value
          .toStringAsFixed(0);
    }

    return value
        .toStringAsFixed(1);
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
  // FORMAT ACTIVITY TYPE - LOCALIZED
  // ============================================================

  String _formatActivityType(
    BuildContext context,
    dynamic value,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final raw =
        value
                ?.toString()
                .trim()
                .toUpperCase() ??
            '';

    switch (raw) {
      case 'WEEDING':
        return l10n.weeding;

      case 'PRUNING':
        return l10n.pruning;

      case 'PESTICIDE_APPLICATION':
        return l10n.pesticideApplication;

      case 'FERTILIZER_APPLICATION':
        return l10n.fertilizerApplication;

      case 'HARVESTING':
        return l10n.harvesting;

      case 'OTHER':
        return l10n.other;

      default:
        return l10n.activity;
    }
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
  // BUILD
  // ============================================================

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
            // ==================================================
            // GREEN USER HEADER
            // ==================================================

            _dashboardHeader(),

            // ==================================================
            // DASHBOARD CONTENT
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

                      if (_error !=
                          null)
                        _errorCard(),

                      if (_error !=
                          null)
                        const SizedBox(
                          height: 14,
                        ),

                      // ========================================
                      // FARMS + TREES
                      // ========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              title:
                                  l10n.farms,

                              value:
                                  _isLoading
                                      ? '-'
                                      : _farms
                                          .length
                                          .toString(),

                              subtitle:
                                  l10n.registered,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              title:
                                  l10n.trees,

                              value:
                                  _isLoading
                                      ? '-'
                                      : _trees
                                          .length
                                          .toString(),

                              subtitle:
                                  l10n.registered,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // ========================================
                      // HARVEST + COST
                      // ========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              title:
                                  l10n.harvested,

                              value:
                                  _isLoading
                                      ? '-'
                                      : '${_formatKg(_totalHarvestedKg)} kg',

                              subtitle:
                                  l10n.totalHarvested,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              title:
                                  l10n.totalCost,

                              value:
                                  _isLoading
                                      ? '-'
                                      : _formatMoney(
                                          _totalCost,
                                        ),

                              subtitle:
                                  l10n.activityCosts,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(
                        height: 14,
                      ),

                      // ========================================
                      // ACTIVITIES + FARM HARVESTS
                      // ========================================

                      Row(
                        children: [
                          Expanded(
                            child:
                                _statCard(
                              title:
                                  l10n.activities,

                              value:
                                  _isLoading
                                      ? '-'
                                      : _totalActivities
                                          .toString(),

                              subtitle:
                                  l10n.recorded,
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ),

                          Expanded(
                            child:
                                _statCard(
                              title:
                                  l10n.farmHarvests,

                              value:
                                  _isLoading
                                      ? '-'
                                      : _farmHarvests
                                          .length
                                          .toString(),

                              subtitle:
                                  l10n.recorded,
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
                      // UPCOMING
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
  // DASHBOARD HEADER
  // ============================================================

  Widget _dashboardHeader() {
    final l10n =
        AppLocalizations.of(context)!;

    final language =
        context.watch<LanguageProvider>();

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets
              .fromLTRB(
        16,
        16,
        16,
        18,
      ),

      decoration:
          const BoxDecoration(
        color:
            primaryGreen,

        borderRadius:
            BorderRadius.only(
          bottomLeft:
              Radius.circular(26),

          bottomRight:
              Radius.circular(26),
        ),
      ),

      child: Row(
        children: [
          // ====================================================
          // PROFILE AVATAR
          // ====================================================

          InkWell(
            onTap:
                _openProfile,

            borderRadius:
                BorderRadius.circular(
              50,
            ),

            child: Container(
              width: 54,
              height: 54,

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,

                shape:
                    BoxShape.circle,

                border:
                    Border.all(
                  color:
                      Colors.white,

                  width: 2,
                ),

                boxShadow: [
                  BoxShadow(
                    color:
                        Colors.black
                            .withValues(
                      alpha: 0.10,
                    ),

                    blurRadius: 8,

                    offset:
                        const Offset(
                      0,
                      3,
                    ),
                  ),
                ],
              ),

              child:
                  const Icon(
                Icons.person,

                size: 34,

                color:
                    Color(
                  0xFFBDBDBD,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 13,
          ),

          // ====================================================
          // GREETING + USER NAME
          // ====================================================

          Expanded(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment
                      .center,

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  _greeting(
                    context,
                  ),

                  maxLines: 1,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      TextStyle(
                    color:
                        Colors.white
                            .withValues(
                      alpha: 0.85,
                    ),

  fontSize: AppTextStyles.body,

                    fontWeight:
                        FontWeight
                            .w400,
                  ),
                ),

                const SizedBox(
                  height: 3,
                ),

                Text(
                  _userName,

                  maxLines: 1,

                  overflow:
                      TextOverflow
                          .ellipsis,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize: AppTextStyles.body,

                    fontWeight:
                        FontWeight
                            .w800,

                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          // ====================================================
          // LANGUAGE
          // ====================================================

          PopupMenuButton<String>(
            tooltip:
                l10n.changeLanguage,

            offset:
                const Offset(
              0,
              50,
            ),

            color:
                Colors.white,

            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),

            onSelected:
                (languageCode) async {
              await context
                  .read<
                      LanguageProvider>()
                  .setLanguage(
                    languageCode,
                  );
            },

            itemBuilder:
                (context) => [
              PopupMenuItem<String>(
                value: 'sw',

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.swahili,
                      ),
                    ),

                    if (language
                            .languageCode ==
                        'sw')
                      const Icon(
                        Icons.check,

                        color:
                            primaryGreen,

                        size: 18,
                      ),
                  ],
                ),
              ),

              PopupMenuItem<String>(
                value: 'en',

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.english,
                      ),
                    ),

                    if (language
                            .languageCode ==
                        'en')
                      const Icon(
                        Icons.check,

                        color:
                            primaryGreen,

                        size: 18,
                      ),
                  ],
                ),
              ),
            ],

            child:
                _dashboardHeaderCircle(
              child: Text(
                language
                    .languageCode
                    .toUpperCase(),

                style:
                    const TextStyle(
                  color:
                      Colors.white,

  fontSize: AppTextStyles.bodySmall,

                  fontWeight:
                      FontWeight
                          .w800,
                ),
              ),
            ),
          ),

          const SizedBox(
            width: 10,
          ),

          // ====================================================
          // MORE
          // ====================================================

          InkWell(
            onTap:
                _openMoreMenu,

            borderRadius:
                BorderRadius.circular(
              50,
            ),

            child:
                _dashboardHeaderCircle(
              child:
                  const Icon(
                Icons.more_vert,

                color:
                    Colors.white,

                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER CIRCLE
  // ============================================================

  Widget _dashboardHeaderCircle({
    required Widget child,
  }) {
    return Container(
      width: 45,
      height: 45,

      alignment:
          Alignment.center,

      decoration:
          BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.10,
        ),

        shape:
            BoxShape.circle,

        border:
            Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.42,
          ),

          width: 2,
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black
                    .withValues(
              alpha: 0.08,
            ),

            blurRadius: 10,

            offset:
                const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      child: child,
    );
  }

  // ============================================================
  // ERROR CARD
  // ============================================================

  Widget _errorCard() {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width:
          double.infinity,

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

        border:
            Border.all(
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
                  l10n
                      .unableToLoadDashboard,

              style:
                  TextStyle(
                color:
                    Colors.red.shade700,

  fontSize: AppTextStyles.body,

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
          const EdgeInsets
              .fromLTRB(
        12,
        12,
        10,
        10,
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
                      0xFF637168,
                    ),

  fontSize: AppTextStyles.body,

                    fontWeight:
                        FontWeight
                            .w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),

          Expanded(
            child: Align(
              alignment:
                  Alignment
                      .centerLeft,

              child:
                  FittedBox(
                fit:
                    BoxFit.scaleDown,

                alignment:
                    Alignment
                        .centerLeft,

                child: Text(
                  value,

                  maxLines: 1,

                  style:
                      const TextStyle(
                    color:
                        primaryGreen,

  fontSize: AppTextStyles.bodyLarge,

                    fontWeight:
                        FontWeight
                            .w800,

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
                TextOverflow
                    .ellipsis,

            style:
                const TextStyle(
              color:
                  Color(
                0xFF89948C,
              ),

  fontSize: AppTextStyles.bodySmall,

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
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
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

          width: 1,
        ),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            l10n.productionOverview,

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
            height: 14,
          ),

          _productionRow(
            label:
                l10n.treeHarvest,

            value:
                '${_formatKg(_treeHarvestedKg)} kg',
          ),

          const SizedBox(
            height: 10,
          ),

          _productionRow(
            label:
                l10n.farmHarvest,

            value:
                '${_formatKg(_farmHarvestedKg)} kg',
          ),

          const Divider(
            height: 22,

            color:
                borderColor,
          ),

          _productionRow(
            label:
                l10n.totalHarvested,

            value:
                '${_formatKg(_totalHarvestedKg)} kg',

            bold: true,
          ),

          const SizedBox(
            height: 10,
          ),

          _productionRow(
            label:
                l10n.totalCost,

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
          child: Text(
            label,

            style:
                TextStyle(
              color:
                  const Color(
                0xFF637168,
              ),

              fontSize: AppTextStyles.bodySmall,

              fontWeight:
                  bold
                      ? FontWeight
                          .w700
                      : FontWeight
                          .w500,
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

            fontSize: AppTextStyles.bodySmall,

            fontWeight:
                bold
                    ? FontWeight
                        .w800
                    : FontWeight
                        .w700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // UPCOMING ACTIVITIES
  // ============================================================

  Widget _upcomingActivities() {
    final l10n =
        AppLocalizations.of(context)!;

    final upcoming =
        _upcomingActivityList;

    return Container(
      width:
          double.infinity,

      padding:
          const EdgeInsets
              .fromLTRB(
        14,
        14,
        14,
        15,
      ),

      decoration:
          BoxDecoration(
        color:
            primaryGreen,

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
              Expanded(
                child: Text(
                  l10n
                      .upcomingActivities,

                  style:
                      const TextStyle(
                    color:
                        Colors.white,

                    fontSize: AppTextStyles.body,

                    fontWeight:
                        FontWeight
                            .w700,
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
            Text(
              l10n
                  .noUpcomingActivities,

              style:
                  const TextStyle(
                color:
                    Colors.white70,

                fontSize: AppTextStyles.bodySmall,

                fontWeight:
                    FontWeight.w500,
              ),
            ),

          if (!_isLoading)
            ...upcoming.map(
              (activity) =>
                  Padding(
                padding:
                    const EdgeInsets
                        .only(
                  bottom: 12,
                ),

                child:
                    _upcomingActivityRow(
                  activity,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // UPCOMING ACTIVITY ROW
  // ============================================================

  Widget _upcomingActivityRow(
    Map<String, dynamic>
        activity,
  ) {
    final activityName =
        _formatActivityType(
      context,
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
            color:
                Colors.white,

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
                CrossAxisAlignment
                    .start,

            children: [
              Text(
                '$activityName • $date',

                style:
                    const TextStyle(
                  color:
                      Colors.white,

                  fontSize: AppTextStyles.bodySmall,

                  fontWeight:
                      FontWeight
                          .w600,
                ),
              ),

              if (treeCode
                  .isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets
                          .only(
                    top: 3,
                  ),

                  child: Text(
                    treeCode,

                    style:
                        const TextStyle(
                      color:
                          Colors.white70,

                      fontSize: AppTextStyles.bodySmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}