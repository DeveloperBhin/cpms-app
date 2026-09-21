import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_services/tree_api_services.dart';
import '../theme/app_text_styles.dart';
import 'addtrees_page.dart';
import 'treesdetails_page.dart';
import '../services/local_data_service.dart';

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
  State<BlockDetailsPage> createState() =>
      _BlockDetailsPageState();
}

class _BlockDetailsPageState
    extends State<BlockDetailsPage> {
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

  List<Map<String, dynamic>> trees = [];

  bool _isLoadingTrees = true;

  String? _treeError;

  // Tells the parent page that tree data changed.
  bool _treeDataChanged = false;

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

  // Future<void> _loadTrees() async {
  //   if (mounted) {
  //     setState(() {
  //       _isLoadingTrees = true;
  //       _treeError = null;
  //     });
  //   }

  //   try {
  //     final result = await LocalDataService.instance.getTrees(
  //       widget.farmId,
  //       widget.blockId,
  //     final result =
  //         await TreeApiServices.getTreesByBlock(
  //       farmId: widget.farmId,
  //       blockId: widget.blockId,
  //     );

  //     debugPrint(
  //       'BLOCK ${widget.blockId} -> TREES: ${result.length}',
  //     );

  //     if (!mounted) return;

  //     setState(() {
  //       trees = result;
  //       _isLoadingTrees = false;
  //     });
  //   } catch (e) {
  //     debugPrint(
  //       'LOAD BLOCK TREES ERROR: $e',
  //     );

  //     if (!mounted) return;

  //     setState(() {
  //       _isLoadingTrees = false;

  //       _treeError = e
  //           .toString()
  //           .replaceFirst(
  //             'Exception: ',
  //             '',
  //           );
  //     });
  //   }
  // }


  Future<void> _loadTrees() async {
  if (mounted) {
    setState(() {
      _isLoadingTrees = true;
      _treeError = null;
    });
  }

  try {
    // Load local/offline trees first.
    final localTrees =
        await LocalDataService.instance.getTrees(
      widget.farmId,
      widget.blockId,
    );

    if (!mounted) return;

    setState(() {
      trees = List<Map<String, dynamic>>.from(
        localTrees,
      );
    });

    debugPrint(
      'BLOCK ${widget.blockId} -> LOCAL TREES: ${localTrees.length}',
    );

    // Then get the latest trees from the API.
    final apiTrees =
        await TreeApiServices.getTreesByBlock(
      farmId: widget.farmId,
      blockId: widget.blockId,
    );

    if (!mounted) return;

    debugPrint(
      'BLOCK ${widget.blockId} -> API TREES: ${apiTrees.length}',
    );

    setState(() {
      trees = List<Map<String, dynamic>>.from(
        apiTrees,
      );
      _isLoadingTrees = false;
    });
  } catch (e) {
    debugPrint(
      'LOAD BLOCK TREES ERROR: $e',
    );

    if (!mounted) return;

    setState(() {
      _isLoadingTrees = false;

      // If local trees exist, continue showing them.
      if (trees.isEmpty) {
        _treeError = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      }
    });
  }
}

  // ===============================================================
  // DISPLAY IDS
  // ===============================================================

  String get _blockDisplayId {
    final id =
        int.tryParse(widget.blockId);

    if (id == null) {
      return widget.blockId;
    }

    return 'BL-${id.toString().padLeft(4, '0')}';
  }

  String get _farmDisplayId {
    final id =
        int.tryParse(widget.farmId);

    if (id == null) {
      return widget.farmId;
    }

    return 'FM-${id.toString().padLeft(4, '0')}';
  }

  // ===============================================================
  // ADD TREE
  // ===============================================================

  Future<void> _openAddTree() async {
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

    if (!mounted) return;

    if (added == true) {
      // Remember that something changed.
      _treeDataChanged = true;

      // Immediately refresh this block.
      await _loadTrees();
    }
  }

  // ===============================================================
  // OPEN TREE DETAILS
  // ===============================================================

  Future<void> _openTreeDetails(
    String treeId,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TreeDetailsPage(
          farmId: widget.farmId,
          blockId: widget.blockId,
          treeId: treeId,
        ),
      ),
    );

    if (!mounted) return;

    // Refresh when returning from tree details too.
    await _loadTrees();
  }

  // ===============================================================
  // BACK
  // ===============================================================

  void _goBack() {
    Navigator.pop(
      context,
      _treeDataChanged,
    );
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
        bool didPop,
        Object? result,
      ) {
        if (didPop) {
          return;
        }

        _goBack();
      },
      child: Scaffold(
        backgroundColor:
            backgroundColor,
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
                      onTap: _goBack,
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                      child:
                          const Padding(
                        padding:
                            EdgeInsets.all(
                          3,
                        ),
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
                    Text(
                      l10n.blockDetails,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize: AppTextStyles.bodyLarge,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ],
                ),
              ),

              // =====================================================
              // CONTENT
              // =====================================================

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
                      20,
                      13,
                      25,
                    ),
                    child: Column(
                      children: [
                        // BLOCK INFORMATION

                        _blockInformation(),

                        const SizedBox(
                          height: 18,
                        ),

                        // BLOCK SUMMARY

                        _blockSummary(),

                        const SizedBox(
                          height: 22,
                        ),

                        // =========================================
                        // TREES HEADER
                        // =========================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              l10n.trees,
                              style:
                                  const TextStyle(
                                color:
                                    textDark,
                                fontSize:
                                    AppTextStyles.body,
                                fontWeight:
                                    FontWeight
                                        .w700,
                              ),
                            ),
                            SizedBox(
                              height: 38,
                              child:
                                  ElevatedButton
                                      .icon(
                                onPressed:
                                    _openAddTree,
                                icon:
                                    const Icon(
                                  Icons.add,
                                  size: 15,
                                ),
                                label: Text(
                                  l10n.addTree,
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
                                  elevation:
                                      0,
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        14,
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
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // TREE LIST

                        _buildTreeList(),
                      ],
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

  // ===============================================================
  // BLOCK INFORMATION
  // ===============================================================

  Widget _blockInformation() {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            l10n.blockInformation,
            style:
                const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 14,
          ),
          Text(
            '${l10n.blockId}: '
            '$_blockDisplayId',
            style:
                const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodySmall,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            widget.blockName,
            style:
                const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.body,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            '${l10n.farmId}: '
            '$_farmDisplayId',
            style:
                const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
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
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            l10n.blockSummary,
            style:
                const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            children: [
              Expanded(
                child:
                    _summaryItem(
                  label:
                      l10n.block,
                  value:
                      _blockDisplayId,
                ),
              ),
              Expanded(
                child:
                    _summaryItem(
                  label:
                      l10n.trees,
                  value:
                      _isLoadingTrees
                          ? '...'
                          : trees
                              .length
                              .toString(),
                ),
              ),
              Expanded(
                child:
                    _summaryItem(
                  label:
                      l10n.varieties,
                  value:
                      _varietyCount()
                          .toString(),
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
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style:
              const TextStyle(
            color: textGrey,
            fontSize: AppTextStyles.bodySmall,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        Text(
          value,
          style:
              const TextStyle(
            color: textDark,
            fontSize: AppTextStyles.bodySmall,
            fontWeight:
                FontWeight.w700,
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
              tree['variety']
                  ?.toString()
                  .trim() ??
              '',
        )
        .where(
          (value) =>
              value.isNotEmpty,
        )
        .toSet();

    return varieties.length;
  }

  // ===============================================================
  // TREE LIST
  // ===============================================================

  Widget _buildTreeList() {
    final l10n =
        AppLocalizations.of(context)!;

    if (_isLoadingTrees) {
      return const Padding(
        padding:
            EdgeInsets.symmetric(
          vertical: 35,
        ),
        child: Center(
          child:
              CircularProgressIndicator(
            color: primaryGreen,
          ),
        ),
      );
    }

    if (_treeError != null) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(
          18,
        ),
        decoration:
            _cardDecoration(),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              color:
                  Colors.redAccent,
              size: 30,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              l10n
                  .unableToLoadTrees,
              style:
                  const TextStyle(
                color: textDark,
                fontSize: AppTextStyles.body,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Text(
              _treeError!,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: textGrey,
                fontSize: AppTextStyles.bodySmall,
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
              label: Text(
                l10n.tryAgain,
              ),
            ),
          ],
        ),
      );
    }

    if (trees.isEmpty) {
      return Container(
        width: double.infinity,
        padding:
            const EdgeInsets
                .symmetric(
          vertical: 30,
          horizontal: 16,
        ),
        decoration:
            _cardDecoration(),
        child: Column(
          children: [
            const Icon(
              Icons.park_outlined,
              color: textGrey,
              size: 34,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              l10n.noTreesInBlock,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: textDark,
                fontSize: AppTextStyles.bodySmall,
                fontWeight:
                    FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              l10n
                  .addFirstTreeMessage,
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: textGrey,
                fontSize: AppTextStyles.bodySmall,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: trees
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
                tree,
              ),
            ),
          )
          .toList(),
    );
  }

  // ===============================================================
  // TREE CARD
  // ===============================================================

  Widget _treeCard(
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

    final status =
        tree['status']
                ?.toString() ??
            '-';

    final plantingYear =
        tree['plantingYear']
                ?.toString() ??
            '-';

    final formattedStatus =
        _formatStatus(
      context,
      status,
    );

    final statusColor =
        _getStatusColor(
      status,
    );

    final statusBackground =
        _getStatusBackground(
      status,
    );

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(
        14,
      ),
      decoration:
          _cardDecoration(),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // TREE ICON

              Container(
                width: 34,
                height: 34,
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
                  size: 18,
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
                      treeCode,
                      style:
                          const TextStyle(
                        color:
                            textDark,
                        fontSize:
                            AppTextStyles.bodySmall,
                        fontWeight:
                            FontWeight
                                .w700,
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
                        fontSize:
                            AppTextStyles.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),

              // STATUS
              if (tree['_pendingSync'] == true)
                const Padding(
                  padding: EdgeInsets.only(right: 7),
                  child: Tooltip(
                    message: 'Waiting to sync',
                    child: Icon(
                      Icons.cloud_upload_outlined,
                      color: Colors.orange,
                      size: 17,
                    ),
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
                            .w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 8,
          ),

          Align(
            alignment:
                Alignment.centerRight,
            child: TextButton(
              onPressed:
                  rawId.isEmpty
                      ? null
                      : () {
                          _openTreeDetails(
                            rawId,
                          );
                        },
              child: Text(
                '${l10n.viewTree} ›',
                style:
                    const TextStyle(
                  color:
                      primaryGreen,
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
    );
  }

  // ===============================================================
  // FORMAT STATUS
  // ===============================================================

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

  // ===============================================================
  // STATUS COLOR
  // ===============================================================

  Color _getStatusColor(
    String status,
  ) {
    switch (status.toUpperCase()) {
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

  // ===============================================================
  // CARD DECORATION
  // ===============================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(
        13,
      ),
      border: Border.all(
        color: borderColor,
      ),
    );
  }
}