import 'package:flutter/material.dart';

import 'addtrees_page.dart';
import 'treesdetails_page.dart';
import '../services/api_services/tree_api_services.dart';

class BlockDetailsPage extends StatefulWidget {
  final String farmId;
  final String blockId;
  final String blockName;

  const BlockDetailsPage({
    super.key,
    required this.farmId,
    required this.blockId,
    required this.blockName,
  });

  @override
  State<BlockDetailsPage> createState() => _BlockDetailsPageState();
}

class _BlockDetailsPageState extends State<BlockDetailsPage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  List<Map<String, dynamic>> trees = [];

  bool _isLoadingTrees = true;
  String? _treeError;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _loadTrees();
  }

  // ===============================================================
  // LOAD TREES
  // ===============================================================

  Future<void> _loadTrees() async {
    if (mounted) {
      setState(() {
        _isLoadingTrees = true;
        _treeError = null;
      });
    }

    try {
      final result = await TreeApiServices.getTreesByBlock(
        farmId: widget.farmId,
        blockId: widget.blockId,
      );

      if (!mounted) return;

      setState(() {
        trees = result;
        _isLoadingTrees = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingTrees = false;
        _treeError = e.toString();
      });
    }
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
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
              height: 52,
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
                    onTap: () => Navigator.pop(context),
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
                  const SizedBox(width: 7),
                  const Text(
                    'Block Details',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // =====================================================
            // CONTENT
            // =====================================================

            Expanded(
              child: RefreshIndicator(
                color: primaryGreen,
                onRefresh: _loadTrees,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    13,
                    20,
                    13,
                    25,
                  ),
                  child: Column(
                    children: [
                      // BLOCK INFORMATION
                      _blockInformation(),

                      const SizedBox(height: 18),

                      // BLOCK SUMMARY
                      _blockSummary(),

                      const SizedBox(height: 22),

                      // =================================================
                      // TREES HEADER
                      // =================================================

                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Trees',
                            style: TextStyle(
                              color: textDark,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizedBox(
                            height: 38,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final added =
                                    await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AddTreePage(
                                      farmId: widget.farmId,
                                      blockId: widget.blockId,
                                      blockName:
                                          widget.blockName,
                                    ),
                                  ),
                                );

                                if (added == true) {
                                  await _loadTrees();
                                }
                              },
                              icon: const Icon(
                                Icons.add,
                                size: 15,
                              ),
                              label: const Text(
                                'Add Tree',
                                style: TextStyle(
                                  fontSize: 9,
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
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(
                                    8,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // =================================================
                      // TREE LIST
                      // =================================================

                      _buildTreeList(),
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

  // ===============================================================
  // BLOCK INFORMATION
  // ===============================================================

  Widget _blockInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Block Information',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 14),

          Text(
            'Block ID: BL-${widget.blockId.padLeft(4, '0')}',
            style: const TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            widget.blockName,
            style: const TextStyle(
              color: textDark,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Farm ID: FM-${widget.farmId.padLeft(4, '0')}',
            style: const TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BLOCK SUMMARY
  // ===============================================================

  Widget _blockSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Block Summary',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _summaryItem(
                  label: 'Block',
                  value:
                      'BL-${widget.blockId.padLeft(4, '0')}',
                ),
              ),

              Expanded(
                child: _summaryItem(
                  label: 'Trees',
                  value: _isLoadingTrees
                      ? '...'
                      : trees.length.toString(),
                ),
              ),

              Expanded(
                child: _summaryItem(
                  label: 'Varieties',
                  value: _varietyCount().toString(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // SUMMARY ITEM
  // ===============================================================

  Widget _summaryItem({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: textGrey,
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: textDark,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // VARIETY COUNT
  // ===============================================================

  int _varietyCount() {
    final varieties = trees
        .map(
          (tree) =>
              tree['variety']?.toString().trim() ?? '',
        )
        .where((value) => value.isNotEmpty)
        .toSet();

    return varieties.length;
  }

  // ===============================================================
  // TREE LIST
  // ===============================================================

  Widget _buildTreeList() {
    if (_isLoadingTrees) {
      return const Padding(
        padding: EdgeInsets.symmetric(
          vertical: 35,
        ),
        child: Center(
          child: CircularProgressIndicator(
            color: primaryGreen,
          ),
        ),
      );
    }

    if (_treeError != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 30,
            ),

            const SizedBox(height: 10),

            const Text(
              'Unable to load trees',
              style: TextStyle(
                color: textDark,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _treeError!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: textGrey,
                fontSize: 8,
              ),
            ),

            const SizedBox(height: 12),

            TextButton.icon(
              onPressed: _loadTrees,
              icon: const Icon(
                Icons.refresh,
                size: 16,
              ),
              label: const Text(
                'Try Again',
              ),
            ),
          ],
        ),
      );
    }

    if (trees.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: 30,
          horizontal: 16,
        ),
        decoration: _cardDecoration(),
        child: const Column(
          children: [
            Icon(
              Icons.park_outlined,
              color: textGrey,
              size: 34,
            ),

            SizedBox(height: 10),

            Text(
              'No trees registered in this block',
              style: TextStyle(
                color: textDark,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),

            SizedBox(height: 5),

            Text(
              'Tap Add Tree to register the first tree.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textGrey,
                fontSize: 8,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: trees
          .map(
            (tree) => Padding(
              padding:
                  const EdgeInsets.only(bottom: 12),
              child: _treeCard(tree),
            ),
          )
          .toList(),
    );
  }

  // ===============================================================
  // TREE CARD
  // ===============================================================

  Widget _treeCard(Map<String, dynamic> tree) {
    final rawId =
        tree['id']?.toString() ?? '';

    final treeCode =
        tree['treeCode']?.toString() ??
            'TR-${rawId.padLeft(6, '0')}';

    final variety =
        tree['variety']?.toString() ?? '-';

    final status =
        tree['status']?.toString() ?? '-';

    final plantingYear =
        tree['plantingYear']?.toString() ?? '-';

    final formattedStatus =
        _formatStatus(status);

    final statusColor =
        _getStatusColor(status);

    final statusBackground =
        _getStatusBackground(status);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // TREE ICON
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: statusBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.park_outlined,
                  color: statusColor,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      treeCode,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '$variety • Planted $plantingYear',
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),

              // STATUS
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusBackground,
                  borderRadius:
                      BorderRadius.circular(6),
                ),
                child: Text(
                  formattedStatus,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 7,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: rawId.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                      builder: (context) => TreeDetailsPage(
  farmId: widget.farmId,
  blockId: widget.blockId,
  treeId: rawId,
),
                        ),
                      );
                    },
              child: const Text(
                'View Tree ›',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // FORMAT STATUS
  // ===============================================================

  String _formatStatus(String status) {
    if (status.trim().isEmpty ||
        status == '-') {
      return '-';
    }

    final value =
        status.trim().toLowerCase();

    return value[0].toUpperCase() +
        value.substring(1);
  }

  // ===============================================================
  // STATUS COLOR
  // ===============================================================

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'HEALTHY':
        return primaryGreen;

      case 'DISEASED':
        return const Color(0xFFD97706);

      case 'DEAD':
        return const Color(0xFFB91C1C);

      default:
        return textGrey;
    }
  }

  // ===============================================================
  // STATUS BACKGROUND
  // ===============================================================

  Color _getStatusBackground(
    String status,
  ) {
    switch (status.toUpperCase()) {
      case 'HEALTHY':
        return lightGreen;

      case 'DISEASED':
        return const Color(0xFFFFF3D6);

      case 'DEAD':
        return const Color(0xFFFFE4E4);

      default:
        return const Color(0xFFF0F2F1);
    }
  }

  // ===============================================================
  // CARD DECORATION
  // ===============================================================

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