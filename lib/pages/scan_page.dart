import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'treesdetails_page.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  bool _isProcessing = false;
  bool _isFlashOn = false;
  String? _lastScannedCode;

  late final MobileScannerController _scannerController;

  // ==============================================================
  // TEMPORARY TREE DATA
  //
  // Later this will be replaced by:
  //
  // ApiServices.getTreeByCode(code)
  // ==============================================================
  final Map<String, Map<String, String>> _demoTrees = {
    'TR-0001': {
      'farmId': 'FM-0001',
      'blockId': 'BL-0001',
      'variety': 'Common',
      'age': '5 years',
      'status': 'Active',
    },
    'TR-0002': {
      'farmId': 'FM-0001',
      'blockId': 'BL-0001',
      'variety': 'Improved',
      'age': '4 years',
      'status': 'Active',
    },
    'TR-0003': {
      'farmId': 'FM-0001',
      'blockId': 'BL-0002',
      'variety': 'Common',
      'age': '5 years',
      'status': 'Active',
    },
  };

  @override
  void initState() {
    super.initState();

    _scannerController = MobileScannerController(
      formats: const [
        BarcodeFormat.code128,
      ],
    );
  }

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
      return;
    }

    final String? rawValue =
        capture.barcodes.first.rawValue;

    if (rawValue == null || rawValue.trim().isEmpty) {
      return;
    }

    final String code = rawValue.trim().toUpperCase();

    setState(() {
      _isProcessing = true;
      _lastScannedCode = code;
    });

    await _scannerController.stop();

    if (!mounted) {
      return;
    }

    _findTree(code);
  }

  // ==============================================================
  // FIND TREE
  // ==============================================================
  void _findTree(String code) {
    final tree = _demoTrees[code];

    if (tree == null) {
      _showTreeNotFound(code);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => TreeDetailsPage(
          farmId: tree['farmId']!,
          blockId: tree['blockId']!,
          treeId: code,
          variety: tree['variety']!,
          age: tree['age']!,
          status: tree['status']!,
        ),
      ),
    );
  }

  // ==============================================================
  // TREE NOT FOUND
  // ==============================================================
  Future<void> _showTreeNotFound(
    String code,
  ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 22,
              ),
              SizedBox(width: 9),
              Text(
                'Tree Not Found',
                style: TextStyle(
                  color: textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          content: Text(
            'No tree was found with barcode:\n\n$code',
            style: const TextStyle(
              color: textGrey,
              fontSize: 10,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Scan Again',
                style: TextStyle(
                  color: primaryGreen,
                  fontSize: 10,
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
          title: const Text(
            'Enter Tree Code',
            style: TextStyle(
              color: textDark,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              color: textDark,
              fontSize: 11,
            ),
            decoration: InputDecoration(
              hintText: 'Example: TR-0001',
              hintStyle: const TextStyle(
                color: textGrey,
                fontSize: 10,
              ),
              filled: true,
              fillColor: backgroundColor,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: borderColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
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
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: textGrey,
                  fontSize: 10,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final value =
                    controller.text.trim().toUpperCase();

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
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Find Tree',
                style: TextStyle(
                  fontSize: 9,
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

    _findTree(result);
  }

  // ==============================================================
  // BUILD
  // ==============================================================
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

                  const Expanded(
                    child: Text(
                      'Scan Tree Barcode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: _toggleFlash,
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

            // =====================================================
            // PAGE CONTENT
            // =====================================================
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
                    // =============================================
                    // INTRODUCTION
                    // =============================================
                    const Text(
                      'Scan Tree Barcode',
                      style: TextStyle(
                        color: textDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 7),

                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 25,
                      ),
                      child: Text(
                        'Position the barcode attached to the tree inside the scanning frame.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textGrey,
                          fontSize: 9,
                          height: 1.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =============================================
                    // SCANNER
                    // =============================================
                    _scannerCard(),

                    const SizedBox(height: 18),

                    // =============================================
                    // STATUS
                    // =============================================
                    _scannerStatus(),

                    const SizedBox(height: 18),

                    // =============================================
                    // MANUAL ENTRY
                    // =============================================
                    _manualEntryButton(),

                    const SizedBox(height: 18),

                    // =============================================
                    // INFORMATION
                    // =============================================
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
            // CAMERA
            Positioned.fill(
              child: MobileScanner(
                controller: _scannerController,
                onDetect: _onBarcodeDetected,
              ),
            ),

            // DARK OVERLAY
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.18,
                  ),
                ),
              ),
            ),

            // BARCODE SCAN AREA
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

            // TOP LEFT
            Positioned(
              left: 28,
              top: 88,
              child: _corner(
                top: true,
                left: true,
              ),
            ),

            // TOP RIGHT
            Positioned(
              right: 28,
              top: 88,
              child: _corner(
                top: true,
                left: false,
              ),
            ),

            // BOTTOM LEFT
            Positioned(
              left: 28,
              bottom: 88,
              child: _corner(
                top: false,
                left: true,
              ),
            ),

            // BOTTOM RIGHT
            Positioned(
              right: 28,
              bottom: 88,
              child: _corner(
                top: false,
                left: false,
              ),
            ),

            // SCAN LINE
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

            // INSTRUCTION
            const Positioned(
              bottom: 24,
              left: 20,
              right: 20,
              child: Text(
                'Keep the barcode steady inside the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isProcessing
                      ? 'Barcode detected'
                      : 'Scanner Ready',
                  style: const TextStyle(
                    color: textDark,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _lastScannedCode != null
                      ? 'Reading $_lastScannedCode'
                      : 'Waiting for a tree barcode...',
                  style: const TextStyle(
                    color: textGrey,
                    fontSize: 8,
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
    return SizedBox(
      width: double.infinity,
      height: 43,
      child: OutlinedButton.icon(
        onPressed: _manualTreeCode,
        icon: const Icon(
          Icons.keyboard_alt_outlined,
          size: 17,
        ),
        label: const Text(
          'Enter Tree Code Manually',
          style: TextStyle(
            fontSize: 9,
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
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: primaryGreen,
            size: 18,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'Each registered cashew tree has a unique barcode. '
              'Scan the barcode to quickly open the tree information.',
              style: TextStyle(
                color: textGrey,
                fontSize: 8,
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