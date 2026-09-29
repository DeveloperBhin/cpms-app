import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:path_provider/path_provider.dart';

import '../l10n/app_localizations.dart';
import '../services/api_services/tree_api_services.dart';
import '../theme/app_text_styles.dart';

import 'scan_page.dart';
import 'tree_activity_page.dart';

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
  // DATA
  // ===============================================================

  Map<String, dynamic>? tree;

  bool _isLoading = true;
  bool _isDownloadingBarcode = false;

  String? _error;

  // ===============================================================
  // BARCODE
  // ===============================================================

  final GlobalKey _barcodeDownloadKey = GlobalKey();

  // ===============================================================
  // INIT
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _loadTree();
  }

  // ===============================================================
  // LOCALIZATION
  // ===============================================================

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  // ===============================================================
  // LOAD TREE
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
      return apiCode.trim().toUpperCase();
    }

    return 'TR-${_rawTreeId.padLeft(6, '0')}';
  }

  String get _variety {
    return tree?['variety']?.toString() ?? '-';
  }

  String get _status {
    return tree?['status']?.toString() ?? '-';
  }

  String get _plantingYear {
    return tree?['plantingYear']?.toString() ?? '-';
  }

  String _notes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final value = tree?['notes']?.toString().trim();

    if (value == null || value.isEmpty) {
      return l10n.noNotesRecorded;
    }

    return value;
  }

  String get _geometry {
    final value = tree?['geometry']?.toString().trim();
    return value == null || value.isEmpty ? '-' : value;
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

  bool get _hasGeometry {
    final value = tree?['geometry']?.toString().trim();
    return value != null && value.isNotEmpty;
  }

  // ===============================================================
  // DOWNLOAD BARCODE
  // ===============================================================

  Future<void> _downloadBarcode() async {
    if (_isDownloadingBarcode) return;

    try {
      setState(() {
        _isDownloadingBarcode = true;
      });

      // Allow the current barcode widget to finish painting.
      await Future.delayed(const Duration(milliseconds: 150));

      final RenderObject? renderObject =
          _barcodeDownloadKey.currentContext?.findRenderObject();

      if (renderObject == null || renderObject is! RenderRepaintBoundary) {
        throw Exception('Barcode image is not ready.');
      }

      final ui.Image image = await renderObject.toImage(
        pixelRatio: 4.0,
      );

      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        throw Exception('Unable to generate barcode image.');
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      final Directory directory = await _getBarcodeDirectory();

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      final String safeCode = _treeCode.replaceAll(
        RegExp(r'[^A-Za-z0-9_-]'),
        '_',
      );

      final String fileName = '${safeCode}_barcode.png';

      final File file = File(
        '${directory.path}${Platform.pathSeparator}$fileName',
      );

      await file.writeAsBytes(
        pngBytes,
        flush: true,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: primaryGreen,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 5),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Barcode downloaded successfully',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  file.path,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Unable to download barcode: ${_cleanError(e.toString())}',
            ),
          ),
        );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloadingBarcode = false;
        });
      }
    }
  }

  // ===============================================================
  // DOWNLOAD DIRECTORY
  // ===============================================================

  Future<Directory> _getBarcodeDirectory() async {
    // Windows:
    // Save directly to the user's Downloads folder when available.
    if (Platform.isWindows) {
      final String? userProfile = Platform.environment['USERPROFILE'];

      if (userProfile != null && userProfile.trim().isNotEmpty) {
        final downloads = Directory(
          '$userProfile${Platform.pathSeparator}Downloads',
        );

        if (await downloads.exists()) {
          return downloads;
        }
      }

      return getApplicationDocumentsDirectory();
    }

    // Android:
    //
    // We intentionally use the application's documents directory here.
    // This avoids relying on hard-coded Android storage paths and keeps
    // the implementation compatible with modern Android storage rules.
    if (Platform.isAndroid) {
      return getApplicationDocumentsDirectory();
    }

    // Linux/macOS or any other supported desktop platform.
    final downloads = await getDownloadsDirectory();

    if (downloads != null) {
      return downloads;
    }

    return getApplicationDocumentsDirectory();
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
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: primaryGreen,
        // borderRadius: BorderRadius.only(
        //   bottomLeft: Radius.circular(18),
        //   bottomRight: Radius.circular(18),
        // ),
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
          Expanded(
            child: Text(
              l10n.treeDetails,
              style: const TextStyle(
                color: Colors.white,
                fontSize: AppTextStyles.bodyLarge,
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
              tooltip: l10n.refresh,
            ),
        ],
      ),
    );
  }

  // ===============================================================
  // BODY
  // ===============================================================

  Widget _buildBody() {
    final l10n = _l10n;

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
        message: l10n.treeInformationNotFound,
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
  // ERROR VIEW
  // ===============================================================

  Widget _errorView({
    String? message,
  }) {
    final l10n = _l10n;

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
              Text(
                l10n.unableToLoadTree,
                style: const TextStyle(
                  color: textDark,
                  fontSize: AppTextStyles.body,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                message ??
                    _cleanError(_error) ??
                    l10n.unknownError,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: textGrey,
                  fontSize: AppTextStyles.bodySmall,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadTree,
                icon: const Icon(
                  Icons.refresh,
                  size: 16,
                ),
                label: Text(
                  l10n.tryAgain,
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
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.treeInformation,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
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
                  color: _statusBackground(_status),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.park_outlined,
                  color: _statusColor(_status),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _treeCode,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: AppTextStyles.body,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '$_variety • ${l10n.plantedYear(_plantingYear)}',
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: AppTextStyles.bodySmall,
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
            label: l10n.treeId,
            value: _treeCode,
          ),
          const SizedBox(height: 10),
          _informationRow(
            label: l10n.farm,
            value: _farmName,
          ),
          const SizedBox(height: 10),
          _informationRow(
            label: l10n.farmId,
            value: 'FM-${widget.farmId.padLeft(4, '0')}',
          ),
          const SizedBox(height: 10),
          _informationRow(
            label: l10n.block,
            value: _blockName,
          ),
          const SizedBox(height: 10),
          _informationRow(
            label: l10n.blockId,
            value: 'BL-${widget.blockId.padLeft(4, '0')}',
          ),
          const SizedBox(height: 10),
          _informationRow(
            label: l10n.variety,
            value: _variety,
          ),
          const SizedBox(height: 10),
          _informationRow(
            label: l10n.plantingYear,
            value: _plantingYear,
          ),
          const SizedBox(height: 10),
          _informationRow(
            label: l10n.status,
            value: _formattedStatus(context),
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
        color: _statusBackground(_status),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        _formattedStatus(context),
        style: TextStyle(
          color: _statusColor(_status),
          fontSize: AppTextStyles.bodySmall,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodySmall,
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
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.scanTree,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            l10n.scanTreeDescription,
            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
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
                    builder: (context) => const ScanPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.barcode_reader,
                size: 19,
              ),
              label: Text(
                l10n.scanTreeBarcode,
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
                  borderRadius: BorderRadius.circular(9),
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
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.treeIdentification,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.scanBarcodeToIdentifyTree,
            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
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
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                ),
              ),
              child: Center(
                child: RepaintBoundary(
                  key: _barcodeDownloadKey,
                  child: Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(12),
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),

                      // IMPORTANT:
                      // Keep the backend tree code exactly as it is.
                      // Example: TR-000004
                      data: _treeCode,

                      width: 250,
                      height: 80,
                      drawText: true,
                      backgroundColor: Colors.white,
                      color: Colors.black,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: AppTextStyles.body,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
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
                fontSize: AppTextStyles.bodySmall,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 18),

          // ---------------------------------------------------------
          // ENLARGE BARCODE
          // ---------------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: _showTreeBarcode,
              icon: const Icon(
                Icons.zoom_out_map,
                size: 16,
              ),
              label: Text(
                l10n.enlargeBarcode,
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ---------------------------------------------------------
          // DOWNLOAD BARCODE
          // ---------------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed:
                  _isDownloadingBarcode ? null : _downloadBarcode,
              icon: _isDownloadingBarcode
                  ? const SizedBox(
                      width: 17,
                      height: 17,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryGreen,
                      ),
                    )
                  : const Icon(
                      Icons.download_outlined,
                      size: 18,
                    ),
              label: Text(
                _isDownloadingBarcode
                    ? 'Downloading...'
                    : 'Download Barcode',
                style: const TextStyle(
                  fontSize: AppTextStyles.bodySmall,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                disabledForegroundColor: textGrey,
                side: const BorderSide(
                  color: primaryGreen,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
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
    final l10n = _l10n;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.treeBarcode,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: AppTextStyles.bodyLarge,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _treeCode,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: AppTextStyles.bodySmall,
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
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: BarcodeWidget(
                      barcode: Barcode.code128(),
                      data: _treeCode,
                      width: 280,
                      height: 100,
                      drawText: true,
                      backgroundColor: Colors.white,
                      color: Colors.black,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: AppTextStyles.body,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: OutlinedButton.icon(
                    onPressed:
                        _isDownloadingBarcode ? null : _downloadBarcode,
                    icon: _isDownloadingBarcode
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: primaryGreen,
                            ),
                          )
                        : const Icon(
                            Icons.download_outlined,
                            size: 17,
                          ),
                    label: Text(
                      _isDownloadingBarcode
                          ? 'Downloading...'
                          : 'Download Barcode',
                      style: const TextStyle(
                        fontSize: AppTextStyles.bodySmall,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryGreen,
                      side: const BorderSide(
                        color: primaryGreen,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      l10n.close,
                      style: const TextStyle(
                        fontSize: AppTextStyles.bodySmall,
                        fontWeight: FontWeight.w700,
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
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.treeLocation,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.geometry,
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: AppTextStyles.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _hasGeometry
                          ? _geometry
                          : l10n.noGpsCoordinatesRecorded,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: AppTextStyles.bodySmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (_hasGeometry) ...[
            const SizedBox(height: 14),
            const Divider(
              height: 1,
              color: borderColor,
            ),
            const SizedBox(height: 12),
            _informationRow(
              label: l10n.geometry,
              value: _geometry,
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
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.notes_outlined,
                color: primaryGreen,
                size: 17,
              ),
              const SizedBox(width: 7),
              Text(
                l10n.notes,
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: AppTextStyles.body,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _notes(context),
            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodySmall,
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
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.treeActivities,
            style: const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.body,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            l10n.treeActivitiesDescription,
            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
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
                    builder: (context) => TreeActivityPage(
                      // Raw database IDs.
                      // DO NOT LOCALIZE.
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
              label: Text(
                l10n.addViewTreeActivities,
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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // LOCALIZED STATUS
  //
  // IMPORTANT:
  // _status remains the raw backend enum value.
  // Only the displayed value is translated.
  // ===============================================================

  String _formattedStatus(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (_status.toUpperCase()) {
      case 'HEALTHY':
        return l10n.healthy;

      case 'DISEASED':
        return l10n.diseased;

      case 'DEAD':
        return l10n.dead;

      default:
        if (_status.trim().isEmpty || _status == '-') {
          return '-';
        }

        return _status;
    }
  }

  // ===============================================================
  // STATUS COLOR
  //
  // Uses RAW backend values.
  // DO NOT TRANSLATE.
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
  //
  // Uses RAW backend values.
  // DO NOT TRANSLATE.
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
  // CLEAN ERROR
  // ===============================================================

  String? _cleanError(String? error) {
    if (error == null || error.trim().isEmpty) {
      return null;
    }

    return error.replaceFirst('Exception: ', '');
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