import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/app_localizations.dart';
import '../services/api_services/tree_api_services.dart';
import '../theme/app_text_styles.dart';
import 'treesdetails_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  // ==============================================================
  // COLORS
  // ==============================================================

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  // ==============================================================
  // STATE
  // ==============================================================

  bool _isProcessing = false;
  bool _isFlashOn = false;

  String? _lastScannedCode;

  late final MobileScannerController _scannerController;

  // ==============================================================
  // LOCALIZATION
  // ==============================================================

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  // ==============================================================
  // INIT
  // ==============================================================

 @override
void initState() {
  super.initState();

  _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.code93,
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.itf,
      BarcodeFormat.codabar,
    ],
  );
}

  // ==============================================================
  // DISPOSE
  // ==============================================================

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  // ==============================================================
  // BARCODE DETECTED
  // ==============================================================
Future<void> _onBarcodeDetected(
  BarcodeCapture capture,
) async {
  if (_isProcessing) {
    return;
  }

  if (capture.barcodes.isEmpty) {
    debugPrint('SCAN: No barcodes detected');
    return;
  }

  // Check every detected barcode instead of assuming
  // the first barcode contains the usable value.
  String? rawValue;
  Barcode? detectedBarcode;

  for (final barcode in capture.barcodes) {
    debugPrint(
      'SCAN DETECTED -> '
      'format=${barcode.format}, '
      'rawValue=${barcode.rawValue}, '
      'displayValue=${barcode.displayValue}',
    );

    final value = barcode.rawValue;

    if (value != null && value.trim().isNotEmpty) {
      rawValue = value;
      detectedBarcode = barcode;
      break;
    }
  }

  if (rawValue == null) {
    debugPrint(
      'SCAN: Barcode detected but no readable raw value.',
    );
    return;
  }

  final code = rawValue.trim().toUpperCase();

  debugPrint('====================================');
  debugPrint('BARCODE SUCCESSFULLY READ');
  debugPrint('FORMAT: ${detectedBarcode?.format}');
  debugPrint('RAW: $rawValue');
  debugPrint('CODE: $code');
  debugPrint('====================================');

  if (!mounted) {
    return;
  }

  setState(() {
    _isProcessing = true;
    _lastScannedCode = code;
  });

  try {
    await _scannerController.stop();

    if (!mounted) {
      return;
    }

    await _findTree(code);
  } catch (e) {
    debugPrint('BARCODE PROCESSING ERROR: $e');

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = false;
    });

    try {
      await _scannerController.start();
    } catch (scannerError) {
      debugPrint(
        'SCANNER RESTART ERROR: $scannerError',
      );
    }
  }
}  // ==============================================================
  // FIND TREE
  // ==============================================================
Future<void> _findTree(String code) async {
  debugPrint('====================================');
  debugPrint('SEARCHING TREE');
  debugPrint('TREE CODE: $code');
  debugPrint('====================================');

  try {
    final tree = await TreeApiServices.getTreeByCode(
      treeCode: code,
    );

    debugPrint('TREE API RESPONSE: $tree');

    if (!mounted) {
      return;
    }

    final treeId = tree['id']?.toString() ?? '';
    final farmId = tree['farmId']?.toString() ?? '';
    final blockId = tree['blockId']?.toString() ?? '';

    debugPrint('TREE ID: $treeId');
    debugPrint('FARM ID: $farmId');
    debugPrint('BLOCK ID: $blockId');

    if (treeId.isEmpty ||
        farmId.isEmpty ||
        blockId.isEmpty) {
      debugPrint(
        'TREE RESPONSE IS MISSING REQUIRED IDS',
      );

      await _showTreeNotFound(code);
      return;
    }

    if (!mounted) {
      return;
    }

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TreeDetailsPage(
          farmId: farmId,
          blockId: blockId,
          treeId: treeId,
        ),
      ),
    );
  } catch (e, stackTrace) {
    debugPrint('====================================');
    debugPrint('TREE LOOKUP FAILED');
    debugPrint('CODE: $code');
    debugPrint('ERROR: $e');
    debugPrint('STACK: $stackTrace');
    debugPrint('====================================');

    if (!mounted) {
      return;
    }

    await _showTreeNotFound(code);
  }
}


String _normalizeTreeCode(String input) {
  final value = input.trim().toUpperCase();

  // User entered only the numeric tree ID.
  // Example: 4 -> TR-000004
  if (RegExp(r'^\d+$').hasMatch(value)) {
    final id = int.tryParse(value);

    if (id != null && id > 0) {
      return 'TR-${id.toString().padLeft(6, '0')}';
    }
  }

  return value;
}
  // ==============================================================
  // TREE NOT FOUND
  // ==============================================================

  Future<void> _showTreeNotFound(
    String code,
  ) async {
    final l10n = _l10n;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 22,
              ),
              const SizedBox(width: 9),
              Text(
                l10n.treeNotFound,
                style: const TextStyle(
                  color: textDark,
                  fontSize: AppTextStyles.bodyLarge,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            l10n.noTreeFoundWithBarcode(code),
            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                l10n.scanAgain,
                style: const TextStyle(
                  color: primaryGreen,
                  fontSize: AppTextStyles.bodySmall,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = false;
      _lastScannedCode = null;
    });

    await _scannerController.start();
  }

  // ==============================================================
  // FLASH
  // ==============================================================

  Future<void> _toggleFlash() async {
    await _scannerController.toggleTorch();

    if (!mounted) {
      return;
    }

    setState(() {
      _isFlashOn = !_isFlashOn;
    });
  }

  // ==============================================================
  // MANUAL TREE CODE
  // ==============================================================

  Future<void> _manualTreeCode() async {
    final l10n = _l10n;

    final TextEditingController controller =
        TextEditingController();

    final String? result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            l10n.enterTreeCode,
            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodyLarge,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization:
                TextCapitalization.characters,
            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.body,
            ),
            decoration: InputDecoration(
              hintText: l10n.treeCodeExample,
              hintStyle: const TextStyle(
                color: textGrey,
                fontSize: AppTextStyles.bodySmall,
              ),
              filled: true,
              fillColor: backgroundColor,
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 13,
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
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                l10n.cancel,
                style: const TextStyle(
                  color: textGrey,
                  fontSize: AppTextStyles.bodySmall,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // =================================================
                // RAW TREE CODE
                // =================================================

                final value = controller.text
                    .trim()
                    .toUpperCase();

                if (value.isEmpty) {
                  return;
                }

                Navigator.pop(
                  dialogContext,
                  value,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(8),
                ),
              ),
              child: Text(
                l10n.findTree,
                style: const TextStyle(
                  fontSize: AppTextStyles.bodySmall,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || result == null) {
      return;
    }

    await _scannerController.stop();

    if (!mounted) {
      return;
    }

    setState(() {
      _isProcessing = true;
      _lastScannedCode = result;
    });

    // await _findTree(result);
    final code = _normalizeTreeCode(result);

debugPrint('MANUAL INPUT: $result');
debugPrint('NORMALIZED TREE CODE: $code');

await _findTree(code);
  }

  // ==============================================================
  // BUILD
  // ==============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Container(
              width: double.infinity,
              height: 55,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
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

                  Expanded(
                    child: Text(
                      l10n.scanTreeBarcode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppTextStyles.bodyLarge,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: _toggleFlash,
                    tooltip: _isFlashOn
                        ? l10n.turnOffFlash
                        : l10n.turnOnFlash,
                    icon: Icon(
                      _isFlashOn
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ====================================================
            // PAGE CONTENT
            // ====================================================

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  20,
                  14,
                  30,
                ),
                child: Column(
                  children: [
                    // ============================================
                    // INTRODUCTION
                    // ============================================

                    Text(
                      l10n.scanTreeBarcode,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: AppTextStyles.bodyLarge,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Text(
                        l10n.positionTreeBarcode,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: textGrey,
                          fontSize: AppTextStyles.bodySmall,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ============================================
                    // SCANNER
                    // ============================================

                    _scannerCard(),

                    const SizedBox(height: 18),

                    // ============================================
                    // STATUS
                    // ============================================

                    _scannerStatus(),

                    const SizedBox(height: 18),

                    // ============================================
                    // MANUAL ENTRY
                    // ============================================

                    _manualEntryButton(),

                    const SizedBox(height: 18),

                    // ============================================
                    // INFORMATION
                    // ============================================

                    _informationCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // SCANNER CARD
  // ==============================================================

  Widget _scannerCard() {
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ====================================================
            // CAMERA
            // ====================================================

            Positioned.fill(
              child: MobileScanner(
                controller: _scannerController,
                onDetect: _onBarcodeDetected,
              ),
            ),

            // ====================================================
            // DARK OVERLAY
            // ====================================================

            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.18,
                  ),
                ),
              ),
            ),

            // ====================================================
            // BARCODE SCAN AREA
            // ====================================================

            Container(
              width: 280,
              height: 115,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),

            // ====================================================
            // TOP LEFT
            // ====================================================

            Positioned(
              left: 28,
              top: 88,
              child: _corner(
                top: true,
                left: true,
              ),
            ),

            // ====================================================
            // TOP RIGHT
            // ====================================================

            Positioned(
              right: 28,
              top: 88,
              child: _corner(
                top: true,
                left: false,
              ),
            ),

            // ====================================================
            // BOTTOM LEFT
            // ====================================================

            Positioned(
              left: 28,
              bottom: 88,
              child: _corner(
                top: false,
                left: true,
              ),
            ),

            // ====================================================
            // BOTTOM RIGHT
            // ====================================================

            Positioned(
              right: 28,
              bottom: 88,
              child: _corner(
                top: false,
                left: false,
              ),
            ),

            // ====================================================
            // SCAN LINE
            // ====================================================

            Container(
              width: 245,
              height: 2,
              decoration: BoxDecoration(
                color: primaryGreen,
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withValues(
                      alpha: 0.5,
                    ),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),

            // ====================================================
            // INSTRUCTION
            // ====================================================

            Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Text(
                l10n.keepBarcodeSteady,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: AppTextStyles.bodySmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // CORNER
  // ==============================================================

  Widget _corner({
    required bool top,
    required bool left,
  }) {
    return SizedBox(
      width: 28,
      height: 28,
      child: CustomPaint(
        painter: _ScannerCornerPainter(
          top: top,
          left: left,
        ),
      ),
    );
  }

  // ==============================================================
  // SCANNER STATUS
  // ==============================================================

  Widget _scannerStatus() {
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isProcessing
                  ? Icons.search
                  : Icons.barcode_reader,
              color: primaryGreen,
              size: 17,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _isProcessing
                      ? l10n.barcodeDetected
                      : l10n.scannerReady,
                  style: const TextStyle(
                    color: textDark,
                    fontSize: AppTextStyles.bodySmall,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _lastScannedCode != null
                      ? l10n.readingBarcode(
                          _lastScannedCode!,
                        )
                      : l10n.waitingForTreeBarcode,
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          if (!_isProcessing)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: primaryGreen,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  // ==============================================================
  // MANUAL ENTRY
  // ==============================================================

  Widget _manualEntryButton() {
    final l10n = _l10n;

    return SizedBox(
      width: double.infinity,
      height: 43,
      child: OutlinedButton.icon(
        onPressed: _manualTreeCode,
        icon: const Icon(
          Icons.keyboard_alt_outlined,
          size: 17,
        ),
        label: Text(
          l10n.enterTreeCodeManually,
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
            borderRadius: BorderRadius.circular(9),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // INFORMATION
  // ==============================================================

  Widget _informationCard() {
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: primaryGreen,
            size: 18,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              l10n.treeBarcodeInformation,
              style: const TextStyle(
                color: textGrey,
                fontSize: AppTextStyles.bodySmall,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =================================================================
// SCANNER CORNER PAINTER
// =================================================================

class _ScannerCornerPainter extends CustomPainter {
  final bool top;
  final bool left;

  const _ScannerCornerPainter({
    required this.top,
    required this.left,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    if (top && left) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (top && !left) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(
        size.width,
        size.height,
      );
    } else if (!top && left) {
      path.moveTo(0, 0);
      path.lineTo(
        0,
        size.height,
      );
      path.lineTo(
        size.width,
        size.height,
      );
    } else {
      path.moveTo(
        0,
        size.height,
      );
      path.lineTo(
        size.width,
        size.height,
      );
      path.lineTo(
        size.width,
        0,
      );
    }

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant _ScannerCornerPainter oldDelegate,
  ) {
    return oldDelegate.top != top ||
        oldDelegate.left != left;
  }
}