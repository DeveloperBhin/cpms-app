import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';

import 'scan_page.dart';
import 'tree_activity_page.dart';
import '../services/api_services/tree_api_services.dart';

class TreeDetailsPage extends StatefulWidget {
  final String farmId;
  final String blockId;
  final String treeId;

  const TreeDetailsPage({
    super.key,
    required this.farmId,
    required this.blockId,
    required this.treeId,
  });

  @override
  State<TreeDetailsPage> createState() => _TreeDetailsPageState();
}

class _TreeDetailsPageState extends State<TreeDetailsPage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  Map<String, dynamic>? tree;

  bool _isLoading = true;
  String? _error;

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  // ===============================================================
  // LOAD TREE FROM API
  // ===============================================================

  Future<void> _loadTree() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
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
        tree = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  // ===============================================================
  // TREE VALUES
  // ===============================================================

  String get _rawTreeId {
    return tree?['id']?.toString() ?? widget.treeId;
  }

  String get _treeCode {
    final apiCode = tree?['treeCode']?.toString();

    if (apiCode != null && apiCode.trim().isNotEmpty) {
      return apiCode;
    }

    return 'TR-${_rawTreeId.padLeft(6, '0')}';
  }

  String get _variety {
    return tree?['variety']?.toString() ?? '-';
  }

  String get _status {
    return tree?['status']?.toString() ?? '-';
  }

  String get _formattedStatus {
    return _formatStatus(_status);
  }

  String get _plantingYear {
    return tree?['plantingYear']?.toString() ?? '-';
  }

  String get _notes {
    final value = tree?['notes']?.toString().trim();

    if (value == null || value.isEmpty) {
      return 'No notes recorded';
    }

    return value;
  }

  String get _latitude {
    final value = tree?['latitude'];

    if (value == null) {
      return '-';
    }

    return value.toString();
  }

  String get _longitude {
    final value = tree?['longitude'];

    if (value == null) {
      return '-';
    }

    return value.toString();
  }

  String get _farmName {
    final value = tree?['farmName']?.toString().trim();

    if (value == null || value.isEmpty) {
      return '-';
    }

    return value;
  }

  String get _blockName {
    final value = tree?['blockName']?.toString().trim();

    if (value == null || value.isEmpty) {
      return '-';
    }

    return value;
  }

  bool get _hasCoordinates {
    return tree?['latitude'] != null &&
        tree?['longitude'] != null;
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
            _header(),

            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // HEADER
  // ===============================================================

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
            onTap: () {
              Navigator.pop(context);
            },
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

          const Expanded(
            child: Text(
              'Tree Details',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          if (!_isLoading && tree != null)
            IconButton(
              onPressed: _loadTree,
              icon: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 19,
              ),
              tooltip: 'Refresh',
            ),
        ],
      ),
    );
  }

  // ===============================================================
  // BODY
  // ===============================================================

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      );
    }

    if (_error != null) {
      return _errorView();
    }

    if (tree == null) {
      return _errorView(
        message: 'Tree information was not found.',
      );
    }

    return RefreshIndicator(
      color: primaryGreen,
      onRefresh: _loadTree,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          13,
          20,
          13,
          30,
        ),
        child: Column(
          children: [
            _treeInformation(),

            const SizedBox(height: 18),

            _scanTreeButton(),

            const SizedBox(height: 18),

            _treeCodeCard(),

            const SizedBox(height: 18),

            _locationCard(),

            const SizedBox(height: 18),

            _notesCard(),

            const SizedBox(height: 18),

            _activityActions(),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ERROR
  // ===============================================================

  Widget _errorView({
    String? message,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: _cardDecoration(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.redAccent,
                size: 38,
              ),

              const SizedBox(height: 12),

              const Text(
                'Unable to load tree',
                style: TextStyle(
                  color: textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                message ?? _error ?? 'Unknown error',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textGrey,
                  fontSize: 9,
                ),
              ),

              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _loadTree,
                icon: const Icon(
                  Icons.refresh,
                  size: 16,
                ),
                label: const Text(
                  'Try Again',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // TREE INFORMATION
  // ===============================================================

  Widget _treeInformation() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tree Information',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _statusBackground(
                    _status,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.park_outlined,
                  color: _statusColor(
                    _status,
                  ),
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
                      _treeCode,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '$_variety • Planted $_plantingYear',
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(),
            ],
          ),

          const SizedBox(height: 18),

          const Divider(
            color: borderColor,
            height: 1,
          ),

          const SizedBox(height: 14),

          _informationRow(
            label: 'Tree ID',
            value: _treeCode,
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Farm',
            value: _farmName,
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Farm ID',
            value:
                'FM-${widget.farmId.padLeft(4, '0')}',
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Block',
            value: _blockName,
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Block ID',
            value:
                'BL-${widget.blockId.padLeft(4, '0')}',
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Variety',
            value: _variety,
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Planting Year',
            value: _plantingYear,
          ),

          const SizedBox(height: 10),

          _informationRow(
            label: 'Status',
            value: _formattedStatus,
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // STATUS BADGE
  // ===============================================================

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _statusBackground(
          _status,
        ),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        _formattedStatus,
        style: TextStyle(
          color: _statusColor(
            _status,
          ),
          fontSize: 8,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ===============================================================
  // INFORMATION ROW
  // ===============================================================

  Widget _informationRow({
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // SCAN TREE
  // ===============================================================

  Widget _scanTreeButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Scan Tree',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Scan a tree barcode to identify and view its information.',
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ScanPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.barcode_reader,
                size: 19,
              ),
              label: const Text(
                'Scan Tree Barcode',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // TREE IDENTIFICATION / BARCODE
  // ===============================================================

  Widget _treeCodeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tree Identification',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Scan this barcode to identify this tree.',
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),

          const SizedBox(height: 22),

          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 18,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: BarcodeWidget(
                barcode: Barcode.code128(),

                // User-facing unique tree code.
                data: _treeCode,

                width: 250,
                height: 80,
                drawText: true,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          Center(
            child: Text(
              _treeCode,
              style: const TextStyle(
                color: textGrey,
                fontSize: 8,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton.icon(
              onPressed: () {
                _showTreeBarcode();
              },
              icon: const Icon(
                Icons.zoom_out_map,
                size: 15,
              ),
              label: const Text(
                'Enlarge Barcode',
                style: TextStyle(
                  fontSize: 9,
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

  // ===============================================================
  // ENLARGE BARCODE
  // ===============================================================

  void _showTreeBarcode() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Tree Barcode',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _treeCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 9,
                  ),
                ),

                const SizedBox(height: 25),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: borderColor,
                    ),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: BarcodeWidget(
                    barcode: Barcode.code128(),
                    data: _treeCode,
                    width: 280,
                    height: 100,
                    drawText: true,
                    style: const TextStyle(
                      color: textDark,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
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
                          8,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // LOCATION
  // ===============================================================

  Widget _locationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tree Location',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: lightGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: primaryGreen,
                  size: 18,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'GPS Coordinates',
                      style: TextStyle(
                        color: textGrey,
                        fontSize: 8,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _hasCoordinates
                          ? '$_latitude, $_longitude'
                          : 'No GPS coordinates recorded',
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_hasCoordinates) ...[
            const SizedBox(height: 14),

            const Divider(
              height: 1,
              color: borderColor,
            ),

            const SizedBox(height: 12),

            _informationRow(
              label: 'Latitude',
              value: _latitude,
            ),

            const SizedBox(height: 8),

            _informationRow(
              label: 'Longitude',
              value: _longitude,
            ),
          ],
        ],
      ),
    );
  }

  // ===============================================================
  // NOTES
  // ===============================================================

  Widget _notesCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.notes_outlined,
                color: primaryGreen,
                size: 17,
              ),

              SizedBox(width: 7),

              Text(
                'Notes',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _notes,
            style: const TextStyle(
              color: textDark,
              fontSize: 9,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // TREE ACTIVITIES
  // ===============================================================

  Widget _activityActions() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tree Activities',
            style: TextStyle(
              color: primaryGreen,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Record and manage activities performed on this tree.',
            style: TextStyle(
              color: textGrey,
              fontSize: 8,
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        TreeActivityPage(
                      // Raw DB IDs for API calls.
                      treeId: _rawTreeId,
                      farmId: widget.farmId,
                      blockId: widget.blockId,
                    ),
                  ),
                );

                if (mounted) {
                  await _loadTree();
                }
              },
              icon: const Icon(
                Icons.add_task,
                size: 16,
              ),
              label: const Text(
                'Add / View Tree Activities',
                style: TextStyle(
                  fontSize: 9,
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

  // ===============================================================
  // FORMAT STATUS
  // ===============================================================

  String _formatStatus(String status) {
    final value = status.trim();

    if (value.isEmpty || value == '-') {
      return '-';
    }

    final lower = value.toLowerCase();

    return lower[0].toUpperCase() +
        lower.substring(1);
  }

  // ===============================================================
  // STATUS COLOR
  // ===============================================================

  Color _statusColor(String status) {
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

  Color _statusBackground(String status) {
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
      borderRadius: BorderRadius.circular(13),
      border: Border.all(
        color: borderColor,
      ),
    );
  }
}