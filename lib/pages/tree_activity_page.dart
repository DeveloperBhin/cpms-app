import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_services/tree_activity_api_services.dart';
import '../services/api_services/tree_api_services.dart';
import '../theme/app_text_styles.dart';

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
  State<TreeActivityPage> createState() => _TreeActivityPageState();
}

class _TreeActivityPageState extends State<TreeActivityPage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  List<Map<String, dynamic>> _activities = [];
  Map<String, dynamic>? _tree;

  bool _isLoadingActivities = true;
  bool _isLoadingTree = true;

  String? _activitiesError;
  String? _treeError;

  @override
  void initState() {
    super.initState();
    _loadTree();
    _loadActivities();
  }

  // ============================================================
  // LOAD TREE
  // ============================================================

  Future<void> _loadTree() async {
    if (mounted) {
      setState(() {
        _isLoadingTree = true;
        _treeError = null;
      });
    }

    try {
      final result = await TreeApiServices.getTree(
        farmId: widget.farmId,
        blockId: widget.blockId,
        treeId: widget.treeId,
      );

      if (!mounted) return;

      setState(() {
        _tree = result;
        _isLoadingTree = false;
      });
    } catch (e) {
      debugPrint('LOAD TREE ERROR: $e');

      if (!mounted) return;

      setState(() {
        _treeError = e.toString();
        _isLoadingTree = false;
      });
    }
  }

  // ============================================================
  // LOAD ACTIVITIES
  // ============================================================

 Future<void> _loadActivities() async {
  if (mounted) {
    setState(() {
      _isLoadingActivities = true;
      _activitiesError = null;
    });
  }

  try {
    final result =
        await TreeActivityApiServices.getTreeActivities(
      farmId: widget.farmId,
      blockId: widget.blockId,
      treeId: widget.treeId,
    );

    if (!mounted) return;

    setState(() {
      _activities =
          List<Map<String, dynamic>>.from(result);

      _isLoadingActivities = false;
    });

    debugPrint(
      'TREE ${widget.treeId} ACTIVITIES: ${_activities.length}',
    );
  } catch (e) {
    debugPrint(
      'LOAD TREE ACTIVITIES ERROR: $e',
    );

    if (!mounted) return;

    setState(() {
      _activitiesError =
          _cleanError(e.toString());

      _isLoadingActivities = false;
    });
  }
}

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await Future.wait([
      _loadTree(),
      _loadActivities(),
    ]);
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(
              child: RefreshIndicator(
                color: primaryGreen,
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    14,
                    18,
                    14,
                    30,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTreeCard(),
                      const SizedBox(height: 22),
                      _buildActivitiesHeader(l10n),
                      const SizedBox(height: 14),
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
  // HEADER
  // ============================================================

  Widget _buildHeader(AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      height: 55,
      padding: const EdgeInsets.symmetric(horizontal: 14),
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
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(20),
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
          Expanded(
            child: Text(
              l10n.treeActivities,
              style: const TextStyle(
                color: Colors.white,
  fontSize: AppTextStyles.bodyLarge,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.refresh,
            onPressed: _refresh,
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TREE CARD
  // ============================================================

  Widget _buildTreeCard() {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoadingTree) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.loadingTreeInformation,
              style: const TextStyle(
                color: textGrey,
                fontSize: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    if (_treeError != null || _tree == null) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.unableToLoadTreeInformation,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: AppTextStyles.bodySmall,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _cleanError(_treeError ?? ''),
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: AppTextStyles.bodySmall,
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
        tree['variety']?.toString() ?? '-';

    final plantingYear =
        tree['plantingYear']?.toString() ?? '-';

    final status =
        tree['status']?.toString() ?? '-';

    final farmName =
        tree['farmName']?.toString() ??
            _formatFarmId(widget.farmId);

    final blockName =
        tree['blockName']?.toString() ??
            _formatBlockId(widget.blockId);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.park_outlined,
                  color: primaryGreen,
                  size: 25,
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
                      style: const TextStyle(
                        color: textDark,
                        fontSize: AppTextStyles.bodyLarge,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      variety,
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: AppTextStyles.bodySmall,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              _treeStatusBadge(status),
            ],
          ),

          const SizedBox(height: 15),

          const Divider(
            color: borderColor,
            height: 1,
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _treeInfoItem(
                  icon: Icons.qr_code_2_outlined,
                  label: 'Tree ID',
                  value: treeCode,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _treeInfoItem(
                  icon: Icons.eco_outlined,
                  label: l10n.variety,
                  value: variety,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _treeInfoItem(
                  icon: Icons.landscape_outlined,
                  label: l10n.farm,
                  value: farmName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _treeInfoItem(
                  icon: Icons.grid_view_outlined,
                  label: l10n.block,
                  value: blockName,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _treeInfoItem(
                  icon: Icons.calendar_month_outlined,
                  label: l10n.plantingYear,
                  value: plantingYear,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _treeInfoItem(
                  icon: Icons.health_and_safety_outlined,
                  label: 'Status',
                  value: _formatTreeStatus(status),
                ),
              ),
            ],
          ),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: lightGreen,
            borderRadius: BorderRadius.circular(7),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: textGrey,
                  fontSize: AppTextStyles.bodySmall,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: textDark,
                  fontSize: AppTextStyles.bodySmall,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIVITIES HEADER
  // ============================================================

  Widget _buildActivitiesHeader(
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.activities,
                style: const TextStyle(
                  color: textDark,
                  fontSize: AppTextStyles.bodyLarge,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                l10n.activitiesPerformedOnTree,
                style: const TextStyle(
                  color: textGrey,
                  fontSize: AppTextStyles.bodySmall,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 38,
          child: ElevatedButton.icon(
            onPressed: _showAddActivity,
            icon: const Icon(
              Icons.add,
              size: 15,
            ),
            label: Text(
              l10n.addActivity,
              style: const TextStyle(
                fontSize: AppTextStyles.bodySmall,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTIVITIES CONTENT
  // ============================================================

  Widget _buildActivitiesContent() {
    if (_isLoadingActivities) {
      return _loadingActivities();
    }

    if (_activitiesError != null) {
      return _errorActivities();
    }

    if (_activities.isEmpty) {
      return _emptyActivities();
    }

    return Column(
      children: _activities.map((activity) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _activityCard(activity),
        );
      }).toList(),
    );
  }

  // ============================================================
  // ACTIVITY CARD
  // ============================================================

  Widget _activityCard(
    Map<String, dynamic> activity,
  ) {
    final l10n = AppLocalizations.of(context)!;

    final rawType =
        activity['activityType']?.toString() ?? '';

    final rawStatus =
        activity['status']?.toString() ?? '';

    final description =
        activity['description']?.toString() ?? '';

    final date = _formatDate(
      activity['activityDate']?.toString(),
    );

    final cost =
        double.tryParse(
          activity['cost']?.toString() ?? '0',
        ) ??
        0;

    final harvestedKg =
        double.tryParse(
          activity['harvestedKg']?.toString() ?? '0',
        ) ??
        0;

    final isHarvesting =
        rawType.toUpperCase() == 'HARVESTING';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _activityIcon(rawType),
              color: primaryGreen,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        _formatActivityType(rawType),
                        style: const TextStyle(
                          color: textDark,
                          fontSize: AppTextStyles.bodySmall,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _activityStatusBadge(rawStatus),
                  ],
                ),

                if (description.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(
                      color: textGrey,
                      fontSize: AppTextStyles.bodySmall,
                      height: 1.4,
                    ),
                  ),
                ],

                const SizedBox(height: 11),

                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  children: [
                    _activityDetail(
                      icon: Icons.calendar_today_outlined,
                      value: date,
                    ),

                    _activityDetail(
                      icon: Icons.payments_outlined,
                      value: _formatMoney(cost),
                      color: primaryGreen,
                    ),

                    if (isHarvesting)
                      _activityDetail(
                        icon: Icons.scale_outlined,
                        value:
                            '${_formatKg(harvestedKg)} Kg',
                        color: primaryGreen,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityDetail({
    required IconData icon,
    required String value,
    Color color = textGrey,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: 13,
        ),
        const SizedBox(width: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: AppTextStyles.bodySmall,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ADD ACTIVITY
  // ============================================================
Future<void> _showAddActivity() async {
  final result =
      await showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return _AddActivitySheet(
        treeId:
            _tree?['treeCode']?.toString() ??
            _formatTreeId(widget.treeId),
      );
    },
  );

  if (result == null || !mounted) {
    return;
  }

  try {
    debugPrint(
      'CREATING ACTIVITY FOR '
      'FARM=${widget.farmId}, '
      'BLOCK=${widget.blockId}, '
      'TREE=${widget.treeId}',
    );

    debugPrint(
      'ACTIVITY REQUEST: $result',
    );

    await TreeActivityApiServices.createActivity(
      farmId: widget.farmId,
      blockId: widget.blockId,
      treeId: widget.treeId,

      // Backend ActivityType enum
      activityType:
          result['activityType'].toString(),

      activityDate:
          result['activityDate'].toString(),

      // Backend ActivityStatus enum
      status:
          result['status'].toString(),

      description:
          result['description']?.toString() ?? '',

      cost:
          (result['cost'] as num).toDouble(),

      // Only supplied for HARVESTING
      harvestMethod:
          result['harvestMethod']?.toString(),

      harvestedKg:
          result['harvestedKg'] == null
              ? null
              : (result['harvestedKg'] as num)
                  .toDouble(),
    );

    debugPrint(
      'TREE ACTIVITY SAVED SUCCESSFULLY',
    );

    // Reload from backend.
    await _loadActivities();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .treeActivityAddedSuccessfully,
          ),
          backgroundColor: primaryGreen,
        ),
      );
  } catch (e) {
    debugPrint(
      'CREATE TREE ACTIVITY ERROR: $e',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!
                .failedToSaveActivity(
              _cleanError(e.toString()),
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
  }
}

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loadingActivities() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 45,
        horizontal: 20,
      ),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          const SizedBox(
            width: 25,
            height: 25,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: primaryGreen,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.loadingActivities,
            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
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
          Text(
            l10n.unableToLoadActivities,
            style: const TextStyle(
              color: textDark,
  fontSize: AppTextStyles.body,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            _cleanError(
              _activitiesError ?? '',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 34,
            child: ElevatedButton.icon(
              onPressed: _loadActivities,
              icon: const Icon(
                Icons.refresh,
                size: 14,
              ),
              label: Text(
                l10n.retry,
                style: const TextStyle(
                  fontSize: AppTextStyles.bodySmall,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
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
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 40,
        horizontal: 20,
      ),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: const BoxDecoration(
              color: lightGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_outlined,
              color: primaryGreen,
              size: 27,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.noActivitiesRecorded,
            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.body,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n.addFirstTreeActivity,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 36,
            child: ElevatedButton.icon(
              onPressed: _showAddActivity,
              icon: const Icon(
                Icons.add,
                size: 14,
              ),
              label: Text(
                l10n.addActivity,
                style: const TextStyle(
                  fontSize: AppTextStyles.bodySmall,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TREE STATUS
  // ============================================================

  String _formatTreeStatus(String status) {
    final l10n = AppLocalizations.of(context)!;

    switch (status.toUpperCase()) {
      case 'HEALTHY':
        return l10n.healthy;

      case 'DISEASED':
        return l10n.diseased;

      case 'DEAD':
        return l10n.dead;

      default:
        return _capitalizeWords(
          status.replaceAll('_', ' '),
        );
    }
  }

  Widget _treeStatusBadge(String status) {
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
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        _formatTreeStatus(status),
        style: TextStyle(
          color: color,
          fontSize: AppTextStyles.bodySmall,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVITY STATUS
  // ============================================================

  Widget _activityStatusBadge(String status) {
    final color = _statusColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        _formatStatus(status),
        style: TextStyle(
          color: color,
          fontSize: AppTextStyles.bodySmall,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final normalized =
        status.toUpperCase().replaceAll(' ', '_');

    switch (normalized) {
      case 'COMPLETED':
        return primaryGreen;

      case 'PLANNED':
        return Colors.blue;

      case 'IN_PROGRESS':
        return Colors.orange;

      case 'CANCELLED':
      case 'CANCELED':
        return Colors.red;

      default:
        return textGrey;
    }
  }

  // ============================================================
  // ACTIVITY TYPE
  // ============================================================

  String _formatActivityType(String value) {
    final l10n = AppLocalizations.of(context)!;

    switch (value.toUpperCase()) {
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
        return _capitalizeWords(
          value.replaceAll('_', ' '),
        );
    }
  }

  IconData _activityIcon(String type) {
    switch (type.toUpperCase()) {
      case 'WEEDING':
        return Icons.grass_outlined;

      case 'PRUNING':
        return Icons.content_cut;

      case 'PESTICIDE_APPLICATION':
        return Icons.water_drop_outlined;

      case 'FERTILIZER_APPLICATION':
        return Icons.eco_outlined;

      case 'HARVESTING':
        return Icons.agriculture_outlined;

      default:
        return Icons.task_alt;
    }
  }

  // ============================================================
  // STATUS FORMAT
  // ============================================================

  String _formatStatus(String value) {
    final l10n = AppLocalizations.of(context)!;

    final normalized =
        value.toUpperCase().replaceAll(' ', '_');

    switch (normalized) {
      case 'COMPLETED':
        return l10n.completed;

      case 'PLANNED':
        return l10n.planned;

      case 'IN_PROGRESS':
        return l10n.inProgress;

      case 'CANCELLED':
      case 'CANCELED':
        return l10n.cancelled;

      default:
        if (value.trim().isEmpty) {
          return '-';
        }

        return _capitalizeWords(
          value.replaceAll('_', ' '),
        );
    }
  }

  // ============================================================
  // FORMATTERS
  // ============================================================

  String _formatTreeId(String value) {
    if (value.toUpperCase().startsWith('TR-')) {
      return value.toUpperCase();
    }

    final number = int.tryParse(value);

    if (number == null) {
      return value;
    }

    return 'TR-${number.toString().padLeft(6, '0')}';
  }

  String _formatFarmId(String value) {
    if (value.toUpperCase().startsWith('FM-')) {
      return value.toUpperCase();
    }

    final number = int.tryParse(value);

    if (number == null) {
      return value;
    }

    return 'FM-${number.toString().padLeft(4, '0')}';
  }

  String _formatBlockId(String value) {
    if (value.toUpperCase().startsWith('BL-')) {
      return value.toUpperCase();
    }

    final number = int.tryParse(value);

    if (number == null) {
      return value;
    }

    return 'BL-${number.toString().padLeft(4, '0')}';
  }

  String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }

    final date = DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return MaterialLocalizations.of(
      context,
    ).formatMediumDate(date);
  }

  String _formatMoney(double amount) {
    final value = amount.round().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final position = value.length - i;

      buffer.write(value[i]);

      if (position > 1 && position % 3 == 1) {
        buffer.write(',');
      }
    }

    return 'TZS ${buffer.toString()}';
  }

  String _formatKg(double kg) {
    if (kg == kg.truncateToDouble()) {
      return kg.toInt().toString();
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

  String _capitalizeWords(String value) {
    return value
        .toLowerCase()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}'
              '${word.substring(1)}',
        )
        .join(' ');
  }

  String _cleanError(String value) {
    return value.replaceFirst(
      RegExp(
        r'^Exception:\s*',
        caseSensitive: false,
      ),
      '',
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

// =================================================================
// ADD TREE ACTIVITY SHEET
// =================================================================

class _AddActivitySheet extends StatefulWidget {
  final String treeId;

  const _AddActivitySheet({
    required this.treeId,
  });

  @override
  State<_AddActivitySheet> createState() =>
      _AddActivitySheetState();
}

class _AddActivitySheetState
    extends State<_AddActivitySheet> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController _dateController =
      TextEditingController();

  final TextEditingController _costController =
      TextEditingController();

  final TextEditingController _harvestedKgController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  String? _selectedActivity;
  String? _selectedStatus;

  DateTime? _selectedDate;

  // RAW BACKEND ENUM VALUES
  final List<String> _activityTypes = [
    'WEEDING',
    'PRUNING',
    'PESTICIDE_APPLICATION',
    'FERTILIZER_APPLICATION',
    'HARVESTING',
    'OTHER',
  ];

  // RAW BACKEND ENUM VALUES
  final List<String> _statuses = [
    'PLANNED',
    'IN_PROGRESS',
    'COMPLETED',
    'CANCELLED',
  ];

  bool get _isHarvesting =>
      _selectedActivity == 'HARVESTING';

  @override
  void dispose() {
    _dateController.dispose();
    _costController.dispose();
    _harvestedKgController.dispose();
    _descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOCAL TEXT
  // ============================================================

  String _text({
    required String en,
    required String sw,
  }) {
    final language =
        Localizations.localeOf(context)
            .languageCode
            .toLowerCase();

    return language == 'sw' ? sw : en;
  }

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date == null || !mounted) {
      return;
    }

    setState(() {
      _selectedDate = date;

      _dateController.text =
          MaterialLocalizations.of(context)
              .formatMediumDate(date);
    });
  }

  // ============================================================
  // ACTIVITY LABEL
  // ============================================================

  String _activityLabel(String value) {
    final l10n = AppLocalizations.of(context)!;

    switch (value) {
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
        return value;
    }
  }

  // ============================================================
  // STATUS LABEL
  // ============================================================

  String _statusLabel(String value) {
    final l10n = AppLocalizations.of(context)!;

    switch (value) {
      case 'PLANNED':
        return l10n.planned;

      case 'IN_PROGRESS':
        return l10n.inProgress;

      case 'COMPLETED':
        return l10n.completed;

      case 'CANCELLED':
        return l10n.cancelled;

      default:
        return value;
    }
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    final valid =
        _formKey.currentState?.validate() ??
            false;

    if (!valid ||
        _selectedActivity == null ||
        _selectedDate == null ||
        _selectedStatus == null) {
      return;
    }

    final cost =
        double.tryParse(
          _costController.text.trim(),
        ) ??
        0;

    double? harvestedKg;

    if (_isHarvesting) {
      harvestedKg =
          double.tryParse(
        _harvestedKgController.text.trim(),
      );

      if (harvestedKg == null ||
          harvestedKg <= 0) {
        return;
      }
    }

    final apiDate =
        '${_selectedDate!.year}-'
        '${_selectedDate!.month.toString().padLeft(2, '0')}-'
        '${_selectedDate!.day.toString().padLeft(2, '0')}';

    Navigator.pop(
      context,
      <String, dynamic>{
        'activityType': _selectedActivity!,
        'activityDate': apiDate,
        'status': _selectedStatus!,
        'cost': cost,
        'description':
            _descriptionController.text.trim(),

        // Only TREE harvesting
        'harvestMethod':
            _isHarvesting ? 'TREE' : null,

        'harvestedKg':
            _isHarvesting ? harvestedKg : null,
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: BoxConstraints(
        maxHeight:
            MediaQuery.of(context).size.height *
                0.90,
      ),
      padding: EdgeInsets.fromLTRB(
        18,
        12,
        18,
        MediaQuery.of(context).viewInsets.bottom +
            25,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                        BorderRadius.circular(5),
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // TITLE
              // ==================================================

              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration:
                        const BoxDecoration(
                      color: lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_task_outlined,
                      color: primaryGreen,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.addTreeActivity,
                          style:
                              const TextStyle(
                            color: textDark,
                            fontSize: AppTextStyles.bodyLarge,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          l10n.recordActivityForTree(
                            widget.treeId,
                          ),
                          style:
                              const TextStyle(
                            color: textGrey,
                            fontSize: AppTextStyles.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // ==================================================
              // TREE
              // ==================================================

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                      BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.park_outlined,
                      color: primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            _text(
                              en: 'Tree ID',
                              sw: 'Namba ya Mkorosho',
                            ),
                            style:
                                const TextStyle(
                              color: textGrey,
                              fontSize: AppTextStyles.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.treeId,
                            style:
                                const TextStyle(
                              color: textDark,
                              fontSize: AppTextStyles.bodySmall,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ==================================================
              // ACTIVITY TYPE
              // ==================================================

              _fieldLabel(
                l10n.activityType,
                required: true,
              ),

              const SizedBox(height: 7),

              DropdownButtonFormField<String>(
                value: _selectedActivity,
                isExpanded: true,
                hint: Text(
                  l10n.selectActivity,
                  style: const TextStyle(
                    fontSize: AppTextStyles.bodySmall,
                    color: textGrey,
                  ),
                ),
                items:
                    _activityTypes.map(
                  (activity) {
                    return DropdownMenuItem<
                        String>(
                      value: activity,
                      child: Text(
                        _activityLabel(
                          activity,
                        ),
                        style:
                            const TextStyle(
                          fontSize: AppTextStyles.bodySmall,
                          color: textDark,
                        ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivity = value;

                    if (value !=
                        'HARVESTING') {
                      _harvestedKgController
                          .clear();
                    }
                  });
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return l10n
                        .selectActivity;
                  }

                  return null;
                },
                decoration:
                    _inputDecoration(
                  prefixIcon:
                      Icons.assignment_outlined,
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // ACTIVITY DATE
              // ==================================================

              _fieldLabel(
                l10n.activityDate,
                required: true,
              ),

              const SizedBox(height: 7),

              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                style: const TextStyle(
                  fontSize: AppTextStyles.bodySmall,
                  color: textDark,
                ),
                decoration: _inputDecoration(
                  hint: l10n.selectDate,
                  prefixIcon:
                      Icons.calendar_today_outlined,
                  suffixIcon: const Icon(
                    Icons.chevron_right,
                    color: textGrey,
                    size: 18,
                  ),
                ),
                validator: (_) {
                  if (_selectedDate == null) {
                    return l10n
                        .selectActivityDate;
                  }

                  return null;
                },
              ),

              const SizedBox(height: 15),

              // ==================================================
              // STATUS
              // ==================================================

              _fieldLabel(
                _text(
                  en: 'Status',
                  sw: 'Hali',
                ),
                required: true,
              ),

              const SizedBox(height: 7),

              DropdownButtonFormField<String>(
                value: _selectedStatus,
                isExpanded: true,
                hint: Text(
                  _text(
                    en: 'Select status',
                    sw: 'Chagua hali',
                  ),
                  style: const TextStyle(
                    fontSize: AppTextStyles.bodySmall,
                    color: textGrey,
                  ),
                ),
                items: _statuses.map(
                  (status) {
                    return DropdownMenuItem<
                        String>(
                      value: status,
                      child: Text(
                        _statusLabel(status),
                        style:
                            const TextStyle(
                          fontSize: AppTextStyles.bodySmall,
                          color: textDark,
                        ),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return _text(
                      en: 'Status is required',
                      sw: 'Hali inahitajika',
                    );
                  }

                  return null;
                },
                decoration:
                    _inputDecoration(
                  prefixIcon:
                      Icons.flag_outlined,
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // COST
              // ==================================================

              _fieldLabel(
                _text(
                  en: 'Cost (TZS)',
                  sw: 'Gharama (TZS)',
                ),
                required: true,
              ),

              const SizedBox(height: 7),

              TextFormField(
                controller: _costController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                style: const TextStyle(
                  fontSize: AppTextStyles.bodySmall,
                  color: textDark,
                ),
                decoration:
                    _inputDecoration(
                  hint: _text(
                    en: 'Example: 25000',
                    sw: 'Mfano: 25000',
                  ),
                  prefixIcon:
                      Icons.payments_outlined,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return _text(
                      en: 'Cost is required',
                      sw: 'Gharama inahitajika',
                    );
                  }

                  final cost =
                      double.tryParse(
                    value.trim(),
                  );

                  if (cost == null) {
                    return _text(
                      en:
                          'Enter a valid cost',
                      sw:
                          'Weka gharama sahihi',
                    );
                  }

                  if (cost < 0) {
                    return _text(
                      en:
                          'Cost cannot be negative',
                      sw:
                          'Gharama haiwezi kuwa hasi',
                    );
                  }

                  return null;
                },
              ),

              // ==================================================
              // HARVESTING FIELDS
              // ==================================================

              if (_isHarvesting) ...[
                const SizedBox(height: 15),

                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius:
                        BorderRadius.circular(9),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .agriculture_outlined,
                        color: primaryGreen,
                        size: 18,
                      ),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          _text(
                            en:
                                'Enter the amount harvested from this tree.',
                            sw:
                                'Weka kiasi kilichovunwa kutoka kwenye mkorosho huu.',
                          ),
                          style:
                              const TextStyle(
                            color: textDark,
                            fontSize: AppTextStyles.bodySmall,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                _fieldLabel(
                  _text(
                    en:
                        'Amount Harvested (Kg)',
                    sw:
                        'Kiasi Kilichovunwa (Kg)',
                  ),
                  required: true,
                ),

                const SizedBox(height: 7),

                TextFormField(
                  controller:
                      _harvestedKgController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  style:
                      const TextStyle(
                    fontSize: AppTextStyles.bodySmall,
                    color: textDark,
                  ),
                  decoration:
                      _inputDecoration(
                    hint: _text(
                      en: 'Example: 18.5',
                      sw: 'Mfano: 18.5',
                    ),
                    prefixIcon:
                        Icons.scale_outlined,
                  ),
                  validator: (value) {
                    if (!_isHarvesting) {
                      return null;
                    }

                    if (value == null ||
                        value
                            .trim()
                            .isEmpty) {
                      return _text(
                        en:
                            'Harvested amount is required',
                        sw:
                            'Kiasi kilichovunwa kinahitajika',
                      );
                    }

                    final kg =
                        double.tryParse(
                      value.trim(),
                    );

                    if (kg == null) {
                      return _text(
                        en:
                            'Enter a valid amount',
                        sw:
                            'Weka kiasi sahihi',
                      );
                    }

                    if (kg <= 0) {
                      return _text(
                        en:
                            'Amount must be greater than zero',
                        sw:
                            'Kiasi lazima kiwe zaidi ya sifuri',
                      );
                    }

                    return null;
                  },
                ),
              ],

              const SizedBox(height: 15),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              _fieldLabel(
                l10n.description,
                required: true,
              ),

              const SizedBox(height: 7),

              TextFormField(
                controller:
                    _descriptionController,
                minLines: 3,
                maxLines: 5,
                style: const TextStyle(
                  fontSize: AppTextStyles.bodySmall,
                  color: textDark,
                ),
                decoration:
                    _inputDecoration(
                  hint: l10n
                      .describeActivityPerformed,
                  prefixIcon:
                      Icons.description_outlined,
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return l10n
                        .descriptionRequired;
                  }

                  return null;
                },
              ),

              const SizedBox(height: 22),

              // ==================================================
              // SAVE
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(
                    Icons
                        .check_circle_outline,
                    size: 17,
                  ),
                  label: Text(
                    l10n.saveActivity,
                    style:
                        const TextStyle(
                      fontSize: AppTextStyles.bodySmall,
                      fontWeight:
                          FontWeight.w700,
                    ),
                  ),
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        primaryGreen,
                    foregroundColor:
                        Colors.white,
                    elevation: 0,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        9,
                      ),
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
  // FIELD LABEL
  // ============================================================

  Widget _fieldLabel(
    String value, {
    bool required = false,
  }) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: textDark,
          fontSize: AppTextStyles.bodySmall,
          fontWeight: FontWeight.w700,
        ),
        children: [
          TextSpan(
            text: value,
          ),
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    String? hint,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: textGrey,
        fontSize: AppTextStyles.bodySmall,
      ),
      prefixIcon: prefixIcon == null
          ? null
          : Icon(
              prefixIcon,
              color: primaryGreen,
              size: 17,
            ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: backgroundColor,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.2,
        ),
      ),
    );
  }
}