import 'package:flutter/material.dart';

import '../services/api_services/block_api_services.dart';
import 'addblocks_page.dart';
import 'blocksdetails_page.dart';

class BlocksPage extends StatefulWidget {
  final String farmId;
  final String farmName;

  const BlocksPage({
    super.key,
    required this.farmId,
    required this.farmName,
  });

  @override
  State<BlocksPage> createState() => _BlocksPageState();
}

class _BlocksPageState extends State<BlocksPage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  bool _isLoading = true;
  String? _error;

  List<Map<String, dynamic>> _blocks = [];

  @override
  void initState() {
    super.initState();

    _loadBlocks();
  }

  // ============================================================
  // LOAD BLOCKS
  // ============================================================

  Future<void> _loadBlocks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final blocks =
          await BlockApiServices.getBlocksByFarm(
        widget.farmId,
      );

      if (!mounted) return;

      setState(() {
        _blocks = blocks;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // ============================================================
  // DISPLAY HELPERS
  // ============================================================

  String _displayBlockId(
    Map<String, dynamic> block,
  ) {
    final id = block['id'];

    if (id == null) {
      return 'BL----';
    }

    final value = id.toString().padLeft(
          4,
          '0',
        );

    return 'BL-$value';
  }

  String _blockName(
    Map<String, dynamic> block,
  ) {
    final value = block['name'];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return 'Unnamed Block';
    }

    return value.toString();
  }

  String _blockSize(
    Map<String, dynamic> block,
  ) {
    final value = block['size'];

    if (value == null) {
      return '-';
    }

    final parsed = double.tryParse(
      value.toString(),
    );

    if (parsed == null) {
      return '$value Acres';
    }

    if (parsed == parsed.roundToDouble()) {
      return '${parsed.toInt()} Acres';
    }

    return '$parsed Acres';
  }

  String _treeCount(
    Map<String, dynamic> block,
  ) {
    final value = block['treeCount'];

    if (value == null) {
      return '-';
    }

    return value.toString();
  }

  String _variety(
    Map<String, dynamic> block,
  ) {
    final value = block['variety'];

    if (value == null ||
        value.toString().trim().isEmpty) {
      return '-';
    }

    return value.toString();
  }

  // ============================================================
  // ADD BLOCK
  // ============================================================

  Future<void> _openAddBlock() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddBlockPage(
          farmId: widget.farmId,
          farmName: widget.farmName,
        ),
      ),
    );

    if (added == true) {
      await _loadBlocks();
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
            _header(),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadBlocks,
                color: primaryGreen,
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    13,
                    20,
                    13,
                    25,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _farmInformation(),

                      const SizedBox(height: 18),

                      _blocksHeader(),

                      const SizedBox(height: 14),

                      _buildBlocksContent(),
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

  Widget _header() {
    return Container(
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
            'Farm Blocks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FARM INFORMATION
  // ============================================================

  Widget _farmInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            widget.farmName,
            style: const TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            'Farm ID: ${_displayFarmId()}',
            style: const TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  String _displayFarmId() {
    final numericId = int.tryParse(
      widget.farmId,
    );

    if (numericId == null) {
      return widget.farmId;
    }

    return 'FM-${numericId.toString().padLeft(4, '0')}';
  }

  // ============================================================
  // BLOCKS HEADER
  // ============================================================

  Widget _blocksHeader() {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _blocks.isEmpty
              ? 'Blocks'
              : 'Blocks (${_blocks.length})',
          style: const TextStyle(
            color: textDark,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        SizedBox(
          height: 38,
          child: ElevatedButton.icon(
            onPressed: _openAddBlock,
            icon: const Icon(
              Icons.add,
              size: 15,
            ),
            label: const Text(
              'Add Block',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BLOCK CONTENT
  // ============================================================

  Widget _buildBlocksContent() {
    if (_isLoading) {
      return _loadingState();
    }

    if (_error != null) {
      return _errorState();
    }

    if (_blocks.isEmpty) {
      return _emptyState();
    }

    return Column(
      children: _blocks
          .map(
            (block) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              child: _blockCard(block),
            ),
          )
          .toList(),
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _loadingState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: const Center(
        child: Column(
          children: [
            SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: primaryGreen,
              ),
            ),

            SizedBox(height: 12),

            Text(
              'Loading blocks...',
              style: TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _errorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.redAccent,
            size: 35,
          ),

          const SizedBox(height: 10),

          const Text(
            'Unable to load blocks',
            style: TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
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

          const SizedBox(height: 15),

          OutlinedButton.icon(
            onPressed: _loadBlocks,
            icon: const Icon(
              Icons.refresh,
              size: 15,
            ),
            label: const Text(
              'Try Again',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryGreen,
              side: const BorderSide(
                color: primaryGreen,
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

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 40,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: borderColor,
        ),
      ),
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
              Icons.grid_view_rounded,
              color: primaryGreen,
              size: 25,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'No blocks yet',
            style: TextStyle(
              color: textDark,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Create the first block for this farm.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textGrey,
              fontSize: 9,
            ),
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _openAddBlock,
            icon: const Icon(
              Icons.add,
              size: 15,
            ),
            label: const Text(
              'Add Block',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BLOCK CARD
  // ============================================================

  Widget _blockCard(
    Map<String, dynamic> block,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
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
              Expanded(
                child: Text(
                  _blockName(block),
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius:
                      BorderRadius.circular(6),
                ),
                child: Text(
                  _displayBlockId(block),
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 7,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _blockInfo(
                  'Size',
                  _blockSize(block),
                ),
              ),

              Expanded(
                child: _blockInfo(
                  'Trees',
                  _treeCount(block),
                ),
              ),

              Expanded(
                child: _blockInfo(
                  'Variety',
                  _variety(block),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                final rawBlockId =
                    block['id'];

                if (rawBlockId == null) {
                  return;
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BlockDetailsPage(
                      farmId:
                          widget.farmId,

                      // IMPORTANT:
                      // send actual database ID,
                      // e.g. "1", not "BL-0001".
                      blockId:
                          rawBlockId.toString(),

                      blockName:
                          _blockName(block),
                    ),
                  ),
                );
              },
              child: const Text(
                'View Block ›',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 9,
                  fontWeight:
                      FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BLOCK INFORMATION
  // ============================================================

  Widget _blockInfo(
    String label,
    String value,
  ) {
    return Column(
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

        const SizedBox(height: 4),

        Text(
          value,
          style: const TextStyle(
            color: textDark,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}