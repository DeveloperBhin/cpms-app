import 'package:flutter/material.dart';


import '../services/api_services/tree_activity_api_services.dart';
import '../services/api_services/tree_api_services.dart';

class TreeActivityPage extends StatefulWidget {
  final String treeId;
  final String farmId;
  final String blockId;

  const TreeActivityPage({
    super.key,
    required this.treeId,
    required this.farmId,
    required this.blockId,
  });

  @override
  State<TreeActivityPage> createState() =>
      _TreeActivityPageState();
}

class _TreeActivityPageState
    extends State<TreeActivityPage> {
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
  // DATA
  // ============================================================

  List<Map<String, dynamic>> activities = [];

  bool _isLoading = true;
  String? _error;

  Map<String, dynamic>? _tree;

bool _isLoadingTree = true;
String? _treeError;

  // ============================================================
  // INIT
  // ============================================================

 @override
void initState() {
  super.initState();

  _loadTree();
  _loadActivities();
}

  // ============================================================
  // LOAD ACTIVITIES
  // ============================================================
Future<void> _loadTree() async {
  if (mounted) {
    setState(() {
      _isLoadingTree = true;
      _treeError = null;
    });
  }

  try {
    final result =
        await TreeApiServices.getTree(
      farmId: widget.farmId,
      blockId: widget.blockId,
      treeId: widget.treeId,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _tree = result;
      _isLoadingTree = false;
    });
  } catch (e) {
    debugPrint(
      'LOAD TREE ERROR: $e',
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _treeError = e.toString();
      _isLoadingTree = false;
    });
  }
}
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
              .getTreeActivities(
        farmId: widget.farmId,
        blockId: widget.blockId,
        treeId: widget.treeId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        activities = result;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'LOAD TREE ACTIVITIES ERROR: $e',
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
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                  const Expanded(
                    child: Text(
                      'Tree Activities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
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
                onRefresh: _loadActivities,
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding:
                      const EdgeInsets.fromLTRB(
                    14,
                    20,
                    14,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // ========================================
                      // TREE INFORMATION
                      // ========================================

                      _treeCard(),

                      const SizedBox(height: 18),

                      // ========================================
                      // TITLE + ADD ACTIVITY
                      // ========================================

                      Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'Activities',
                                  style: TextStyle(
                                    color: textDark,
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Activities performed on this tree',
                                  style: TextStyle(
                                    color: textGrey,
                                    fontSize: 8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 38,
                            child:
                                ElevatedButton.icon(
                              onPressed:
                                  _showAddActivity,
                              icon: const Icon(
                                Icons.add,
                                size: 15,
                              ),
                              label: const Text(
                                'Add Activity',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight:
                                      FontWeight.w700,
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
                                  horizontal: 13,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      // ========================================
                      // ACTIVITIES
                      // ========================================

                      _buildActivitiesContent(),
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
  // ACTIVITIES CONTENT
  // ============================================================

  Widget _buildActivitiesContent() {
    if (_isLoading) {
      return _loadingActivities();
    }

    if (_error != null) {
      return _errorActivities();
    }

    if (activities.isEmpty) {
      return _emptyActivities();
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
                  _activityCard(activity),
            ),
          )
          .toList(),
    );
  }

  // ============================================================
  // TREE CARD
  // ============================================================

 Widget _treeCard() {
  if (_isLoadingTree) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryGreen,
            ),
          ),
          SizedBox(width: 12),
          Text(
            'Loading tree information...',
            style: TextStyle(
              color: textGrey,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  if (_treeError != null ||
      _tree == null) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Unable to load tree information',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _treeError ?? '',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: _loadTree,
            icon: const Icon(
              Icons.refresh,
              color: primaryGreen,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  final tree = _tree!;

  final treeCode =
      tree['treeCode']?.toString() ??
          _formatTreeId(widget.treeId);

  final variety =
      tree['variety']?.toString() ??
          '-';

  final plantingYear =
      tree['plantingYear']?.toString() ??
          '-';

  final status =
      tree['status']?.toString() ??
          '-';

  final farmName =
      tree['farmName']?.toString() ??
          _formatFarmId(widget.farmId);

  final blockName =
      tree['blockName']?.toString() ??
          _formatBlockId(widget.blockId);

  final latitude =
      tree['latitude']?.toString() ??
          '-';

  final longitude =
      tree['longitude']?.toString() ??
          '-';

  final notes =
      tree['notes']?.toString() ?? '';

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: _cardDecoration(),
    child: Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // ======================================================
        // HEADER
        // ======================================================

        Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration:
                  const BoxDecoration(
                color: lightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.park_outlined,
                color: primaryGreen,
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    treeCode,
                    style:
                        const TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    variety,
                    style:
                        const TextStyle(
                      color: textGrey,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),

            _treeStatusBadge(
              status,
            ),
          ],
        ),

        const SizedBox(height: 15),

        const Divider(
          color: borderColor,
          height: 1,
        ),

        const SizedBox(height: 14),

        // ======================================================
        // FARM + BLOCK
        // ======================================================

        Row(
          children: [
            Expanded(
              child: _treeInfoItem(
                icon:
                    Icons.landscape_outlined,
                label: 'Farm',
                value: farmName,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _treeInfoItem(
                icon:
                    Icons.grid_view_outlined,
                label: 'Block',
                value: blockName,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ======================================================
        // VARIETY + PLANTING YEAR
        // ======================================================

        Row(
          children: [
            Expanded(
              child: _treeInfoItem(
                icon: Icons.eco_outlined,
                label: 'Variety',
                value: variety,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _treeInfoItem(
                icon:
                    Icons.calendar_month_outlined,
                label: 'Planting Year',
                value: plantingYear,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ======================================================
        // LOCATION
        // ======================================================

        Row(
          children: [
            Expanded(
              child: _treeInfoItem(
                icon:
                    Icons.location_on_outlined,
                label: 'Latitude',
                value: latitude,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _treeInfoItem(
                icon:
                    Icons.location_on_outlined,
                label: 'Longitude',
                value: longitude,
              ),
            ),
          ],
        ),

        // ======================================================
        // NOTES
        // ======================================================

        if (notes.trim().isNotEmpty) ...[
          const SizedBox(height: 14),

          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius:
                  BorderRadius.circular(9),
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons
                          .description_outlined,
                      color: primaryGreen,
                      size: 14,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Notes',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 8,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                Text(
                  notes,
                  style:
                      const TextStyle(
                    color: textDark,
                    fontSize: 9,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

Widget _treeInfoItem({
  required IconData icon,
  required String label,
  required String value,
}) {
  return Row(
    crossAxisAlignment:
        CrossAxisAlignment.start,
    children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: lightGreen,
          borderRadius:
              BorderRadius.circular(7),
        ),
        child: Icon(
          icon,
          color: primaryGreen,
          size: 15,
        ),
      ),

      const SizedBox(width: 8),

      Expanded(
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: textGrey,
                fontSize: 7,
              ),
            ),

            const SizedBox(height: 2),

            Text(
              value,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                color: textDark,
                fontSize: 9,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Widget _treeStatusBadge(
  String status,
) {
  Color color;

  switch (status.toUpperCase()) {
    case 'HEALTHY':
      color = primaryGreen;
      break;

    case 'DISEASED':
      color = Colors.orange;
      break;

    case 'DEAD':
      color = Colors.red;
      break;

    default:
      color = textGrey;
  }

  return Container(
    padding:
        const EdgeInsets.symmetric(
      horizontal: 9,
      vertical: 5,
    ),
    decoration: BoxDecoration(
      color: color.withValues(
        alpha: 0.10,
      ),
      borderRadius:
          BorderRadius.circular(7),
    ),
    child: Text(
      _capitalizeWords(
        status.replaceAll('_', ' '),
      ),
      style: TextStyle(
        color: color,
        fontSize: 8,
        fontWeight:
            FontWeight.w700,
      ),
    ),
  );
}

  // ============================================================
  // ACTIVITY CARD
  // ============================================================

  Widget _activityCard(
  Map<String, dynamic> activity,
) {
  final type =
      activity['activityType']
              ?.toString() ??
          '';

  final title =
      _formatActivityType(type);

  final status =
      _formatStatus(
    activity['status']?.toString() ??
        '',
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

  // ============================================================
  // COST
  // ============================================================

  final cost =
      double.tryParse(
        activity['cost']
                ?.toString() ??
            '0',
      ) ??
      0;

  // ============================================================
  // HARVEST
  // ============================================================

  final isHarvesting =
      type.toUpperCase() ==
          'HARVESTING';

  final harvestedKg =
      double.tryParse(
        activity['harvestedKg']
                ?.toString() ??
            '0',
      ) ??
      0;

  return Container(
    width: double.infinity,
    padding:
        const EdgeInsets.all(14),
    decoration: _cardDecoration(),
    child: Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        // ======================================================
        // ICON
        // ======================================================

        Container(
          width: 38,
          height: 38,
          decoration:
              const BoxDecoration(
            color: lightGreen,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _activityIcon(title),
            color: primaryGreen,
            size: 19,
          ),
        ),

        const SizedBox(width: 12),

        // ======================================================
        // CONTENT
        // ======================================================

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              // =================================================
              // TITLE + STATUS
              // =================================================

              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style:
                          const TextStyle(
                        color: textDark,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 8,
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
                              .circular(6),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color:
                            _statusColor(
                          status,
                        ),
                        fontSize: 7,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              // =================================================
              // DESCRIPTION
              // =================================================

              if (description
                  .isNotEmpty) ...[
                const SizedBox(
                  height: 6,
                ),
                Text(
                  description,
                  style:
                      const TextStyle(
                    color: textGrey,
                    fontSize: 8,
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(
                height: 10,
              ),

              // =================================================
              // DATE
              // =================================================

              _activityInfoRow(
                icon: Icons
                    .calendar_today_outlined,
                label: date,
              ),

              const SizedBox(
                height: 7,
              ),

              // =================================================
              // COST
              // =================================================

              _activityInfoRow(
                icon:
                    Icons.payments_outlined,
                label:
                    'Cost: ${_formatMoney(cost)}',
                valueColor:
                    primaryGreen,
              ),

              // =================================================
              // HARVESTED KG
              // Only show for HARVESTING
              // =================================================

              if (isHarvesting) ...[
                const SizedBox(
                  height: 7,
                ),

                _activityInfoRow(
                  icon:
                      Icons.scale_outlined,
                  label:
                      'Harvested: ${_formatKg(harvestedKg)} kg',
                  valueColor:
                      primaryGreen,
                ),
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _activityInfoRow({
  required IconData icon,
  required String label,
  Color valueColor = textGrey,
}) {
  return Row(
    children: [
      Icon(
        icon,
        color: valueColor,
        size: 13,
      ),

      const SizedBox(width: 6),

      Expanded(
        child: Text(
          label,
          style: TextStyle(
            color: valueColor,
            fontSize: 8,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}


String _formatMoney(
  double amount,
) {
  final rounded =
      amount.round();

  final value =
      rounded.toString();

  final buffer =
      StringBuffer();

  for (int i = 0;
      i < value.length;
      i++) {
    final position =
        value.length - i;

    buffer.write(value[i]);

    if (position > 1 &&
        position % 3 == 1) {
      buffer.write(',');
    }
  }

  return 'TZS ${buffer.toString()}';
}

String _formatKg(
  double kg,
) {
  if (kg ==
      kg.truncateToDouble()) {
    return kg
        .toInt()
        .toString();
  }

  return kg
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

  // ============================================================
  // ADD ACTIVITY
  // ============================================================

  Future<void>
      _showAddActivity() async {
    final result =
        await showModalBottomSheet<
            Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return _AddActivitySheet(
          treeId:
              _formatTreeId(
            widget.treeId,
          ),
        );
      },
    );

    if (result == null ||
        !mounted) {
      return;
    }

    try {
      await TreeActivityApiServices
          .createActivity(
        farmId: widget.farmId,
        blockId: widget.blockId,
        treeId: widget.treeId,
        activityType:
            result['activityType']!,
        activityDate:
            result['activityDate']!,
        description:
            result['description'] ?? '',
        status:
            result['status'] ??
                'COMPLETED',
      );

      await _loadActivities();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Tree activity added successfully',
          ),
          backgroundColor:
              primaryGreen,
        ),
      );
    } catch (e) {
      debugPrint(
        'CREATE ACTIVITY ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save activity: $e',
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loadingActivities() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          SizedBox(
            width: 25,
            height: 25,
            child:
                CircularProgressIndicator(
              strokeWidth: 2.5,
              color: primaryGreen,
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

  Widget _errorActivities() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 30,
        horizontal: 20,
      ),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 10),
          const Text(
            'Unable to load activities',
            style: TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _error ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
          const SizedBox(height: 12),
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
                  ElevatedButton.styleFrom(
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

  Widget _emptyActivities() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      decoration: _cardDecoration(),
      child: const Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            color: textGrey,
            size: 35,
          ),
          SizedBox(height: 10),
          Text(
            'No activities recorded',
            style: TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Add the first activity for this tree.',
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMATTING
  // ============================================================

  String _formatTreeId(
    String value,
  ) {
    if (value
        .toUpperCase()
        .startsWith('TR-')) {
      return value.toUpperCase();
    }

    final number =
        int.tryParse(value);

    if (number == null) {
      return value;
    }

    return 'TR-${number.toString().padLeft(6, '0')}';
  }

  String _formatFarmId(
    String value,
  ) {
    if (value
        .toUpperCase()
        .startsWith('FM-')) {
      return value.toUpperCase();
    }

    final number =
        int.tryParse(value);

    if (number == null) {
      return value;
    }

    return 'FM-${number.toString().padLeft(4, '0')}';
  }

  String _formatBlockId(
    String value,
  ) {
    if (value
        .toUpperCase()
        .startsWith('BL-')) {
      return value.toUpperCase();
    }

    final number =
        int.tryParse(value);

    if (number == null) {
      return value;
    }

    return 'BL-${number.toString().padLeft(4, '0')}';
  }

  String _formatActivityType(
    String value,
  ) {
    switch (value.toUpperCase()) {
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
          value.replaceAll('_', ' '),
        );
    }
  }

  String _formatStatus(
    String value,
  ) {
    if (value.isEmpty) {
      return '-';
    }

    return _capitalizeWords(
      value.replaceAll('_', ' '),
    );
  }

  String _capitalizeWords(
    String value,
  ) {
    return value
        .toLowerCase()
        .split(' ')
        .where(
          (word) => word.isNotEmpty,
        )
        .map(
          (word) =>
              '${word[0].toUpperCase()}'
              '${word.substring(1)}',
        )
        .join(' ');
  }

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
    switch (status.toLowerCase()) {
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
    switch (status.toLowerCase()) {
      case 'completed':
        return lightGreen;

      case 'planned':
        return Colors.blue
            .withValues(alpha: 0.10);

      case 'in progress':
        return Colors.orange
            .withValues(alpha: 0.10);

      case 'cancelled':
        return Colors.red
            .withValues(alpha: 0.10);

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

// =================================================================
// ADD ACTIVITY BOTTOM SHEET
// =================================================================

class _AddActivitySheet
    extends StatefulWidget {
  final String treeId;

  const _AddActivitySheet({
    required this.treeId,
  });

  @override
  State<_AddActivitySheet>
      createState() =>
          _AddActivitySheetState();
}

class _AddActivitySheetState
    extends State<_AddActivitySheet> {
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

  final _formKey =
      GlobalKey<FormState>();

  String? _selectedActivity;

  DateTime? _selectedDate;

  final TextEditingController
      _dateController =
      TextEditingController();

  final TextEditingController
      _descriptionController =
      TextEditingController();

  final List<String> _activityTypes = [
    'Weeding',
    'Pruning',
    'Pesticide Application',
    'Fertilizer Application',
    'Harvesting',
    'Other',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _dateController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final date =
        await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ??
              DateTime.now(),
      firstDate:
          DateTime(2020),
      lastDate:
          DateTime(2100),
    );

    if (date == null) {
      return;
    }

    setState(() {
      _selectedDate = date;

      _dateController.text =
          '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    });
  }

  // ============================================================
  // CONVERT ACTIVITY TYPE TO BACKEND ENUM
  // ============================================================

  String _toApiActivityType(
    String value,
  ) {
    switch (value) {
      case 'Weeding':
        return 'WEEDING';

      case 'Pruning':
        return 'PRUNING';

      case 'Pesticide Application':
        return 'PESTICIDE_APPLICATION';

      case 'Fertilizer Application':
        return 'FERTILIZER_APPLICATION';

      case 'Harvesting':
        return 'HARVESTING';

      default:
        return 'OTHER';
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    if (!_formKey
        .currentState!
        .validate()) {
      return;
    }

    if (_selectedDate == null) {
      return;
    }

    final apiDate =
        '${_selectedDate!.year}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';

    Navigator.pop(
      context,
      <String, String>{
        'activityType':
            _toApiActivityType(
          _selectedActivity!,
        ),
        'activityDate': apiDate,
        'description':
            _descriptionController
                .text
                .trim(),
        'status': 'COMPLETED',
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.of(context)
                .viewInsets
                .bottom +
            25,
      ),
      decoration:
          const BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.only(
          topLeft:
              Radius.circular(22),
          topRight:
              Radius.circular(22),
        ),
      ),
      child:
          SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment
                    .start,
            children: [
              // ================================================
              // HANDLE
              // ================================================

              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration:
                      BoxDecoration(
                    color: borderColor,
                    borderRadius:
                        BorderRadius
                            .circular(5),
                  ),
                ),
              ),

              const SizedBox(
                height: 18,
              ),

              // ================================================
              // TITLE
              // ================================================

              const Text(
                'Add Tree Activity',
                style: TextStyle(
                  color: textDark,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(
                height: 5,
              ),

              Text(
                'Record activity for ${widget.treeId}',
                style:
                    const TextStyle(
                  color: textGrey,
                  fontSize: 9,
                ),
              ),

              const SizedBox(
                height: 20,
              ),

              // ================================================
              // ACTIVITY TYPE
              // ================================================

              const Text(
                'Activity Type',
                style: TextStyle(
                  color: textDark,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              DropdownButtonFormField<
                  String>(
                initialValue:
                    _selectedActivity,
                hint: const Text(
                  'Select activity',
                  style: TextStyle(
                    fontSize: 9,
                    color: textGrey,
                  ),
                ),
                items: _activityTypes
                    .map(
                      (activity) =>
                          DropdownMenuItem<
                              String>(
                        value: activity,
                        child: Text(
                          activity,
                          style:
                              const TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivity =
                        value;
                  });
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Select activity';
                  }

                  return null;
                },
                decoration:
                    _inputDecoration(),
              ),

              const SizedBox(
                height: 15,
              ),

              // ================================================
              // ACTIVITY DATE
              // ================================================

              const Text(
                'Activity Date',
                style: TextStyle(
                  color: textDark,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              TextFormField(
                controller:
                    _dateController,
                readOnly: true,
                onTap: _selectDate,
                style:
                    const TextStyle(
                  fontSize: 10,
                ),
                decoration:
                    _inputDecoration(
                  hint: 'Select date',
                  suffixIcon:
                      const Icon(
                    Icons
                        .calendar_today_outlined,
                    size: 17,
                    color:
                        primaryGreen,
                  ),
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Select activity date';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 15,
              ),

              // ================================================
              // DESCRIPTION
              // ================================================

              const Text(
                'Description',
                style: TextStyle(
                  color: textDark,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),

              const SizedBox(
                height: 7,
              ),

              TextFormField(
                controller:
                    _descriptionController,
                maxLines: 4,
                style:
                    const TextStyle(
                  fontSize: 10,
                ),
                decoration:
                    _inputDecoration(
                  hint:
                      'Describe the activity performed...',
                ),
                validator: (value) {
                  if (value == null ||
                      value
                          .trim()
                          .isEmpty) {
                    return 'Description is required';
                  }

                  return null;
                },
              ),

              const SizedBox(
                height: 22,
              ),

              // ================================================
              // SAVE BUTTON
              // ================================================

              SizedBox(
                width:
                    double.infinity,
                height: 44,
                child:
                    ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(
                    Icons.add_task,
                    size: 17,
                  ),
                  label: const Text(
                    'Save Activity',
                    style: TextStyle(
                      fontSize: 10,
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
                              .circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          const TextStyle(
        color: textGrey,
        fontSize: 9,
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor:
          backgroundColor,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide:
            const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide:
            const BorderSide(
          color: primaryGreen,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }
}