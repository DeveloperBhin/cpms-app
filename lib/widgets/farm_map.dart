import 'dart:math' as math;

import 'package:flutter/material.dart';

class FarmMap extends StatelessWidget {
  final Map<String, dynamic> farm;
  final List<Map<String, dynamic>> trees;

  /// true  = smaller dashboard version
  /// false = larger FarmDetails version
  final bool compact;

  final void Function(Map<String, dynamic> tree)? onTreeTap;

  const FarmMap({
    super.key,
    required this.farm,
    required this.trees,
    this.compact = false,
    this.onTreeTap,
  });

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color background = Color(0xFFF7FAF5);
  static const Color healthyColor = Color(0xFF16803A);
  static const Color diseasedColor = Color(0xFFE59A18);
  static const Color deadColor = Color(0xFFC62828);

  String get _farmName {
    final value = farm['name']?.toString().trim();

    if (value == null || value.isEmpty) {
      return 'Farm';
    }

    return value;
  }

  String get _farmId {
    return farm['id']?.toString() ?? '';
  }

  List<Map<String, dynamic>> get _farmTrees {
    if (_farmId.isEmpty) {
      return trees;
    }

    return trees.where((tree) {
      return tree['farmId']?.toString() == _farmId;
    }).toList();
  }

  String? get _farmGeometry {
    final dynamic raw =
        farm['geometry'] ??
        farm['farmGeometry'] ??
        farm['boundary'];

    if (raw == null) {
      return null;
    }

    final value = raw.toString().trim();

    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    final farmTrees = _farmTrees;

    final healthy = farmTrees.where((tree) {
      return tree['status']?.toString().toUpperCase() == 'HEALTHY';
    }).length;

    final diseased = farmTrees.where((tree) {
      return tree['status']?.toString().toUpperCase() == 'DISEASED';
    }).length;

    final dead = farmTrees.where((tree) {
      return tree['status']?.toString().toUpperCase() == 'DEAD';
    }).length;

    final polygon = _parsePolygon(_farmGeometry);

    final treePoints = <_TreeMapPoint>[];

    for (final tree in farmTrees) {
      final point = _treePoint(tree);

      if (point != null) {
        treePoints.add(
          _TreeMapPoint(
            tree: tree,
            point: point,
          ),
        );
      }
    }

    final bool hasMapData =
        polygon.length >= 3 || treePoints.isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          compact ? 12 : 15,
        ),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(
            healthy: healthy,
            diseased: diseased,
            dead: dead,
          ),

          Container(
            height: compact ? 210 : 360,
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(
              compact ? 8 : 12,
              0,
              compact ? 8 : 12,
              10,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: borderColor,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: hasMapData
                  ? LayoutBuilder(
                      builder: (context, constraints) {
                        final transform = _MapTransform.fromData(
                          polygon: polygon,
                          trees: treePoints,
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          padding: compact ? 20 : 32,
                        );

                        return Stack(
                          children: [
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _FarmBoundaryPainter(
                                  polygon: polygon,
                                  transform: transform,
                                ),
                              ),
                            ),

                            ...treePoints.map(
                              (item) {
                                final offset = transform.project(
                                  item.point,
                                );

                                return Positioned(
                                  left:
                                      offset.dx -
                                      (compact ? 8 : 11),
                                  top:
                                      offset.dy -
                                      (compact ? 8 : 11),
                                  child: _treeMarker(
                                    context,
                                    item.tree,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    )
                  : _emptyMap(),
            ),
          ),

          _legend(
            healthy: healthy,
            diseased: diseased,
            dead: dead,
          ),

          SizedBox(
            height: compact ? 10 : 14,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader({
    required int healthy,
    required int diseased,
    required int dead,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        compact ? 12 : 16,
        compact ? 11 : 15,
        compact ? 12 : 16,
        compact ? 9 : 12,
      ),
      child: Row(
        children: [
          Container(
            width: compact ? 32 : 38,
            height: compact ? 32 : 38,
            decoration: const BoxDecoration(
              color: Color(0xFFE7F3EB),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.map_outlined,
              color: primaryGreen,
              size: compact ? 17 : 20,
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _farmName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF25402D),
                    fontSize: compact ? 13 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '${_farmTrees.length} trees mapped',
                  style: TextStyle(
                    color: const Color(0xFF718078),
                    fontSize: compact ? 10 : 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _treeMarker(
    BuildContext context,
    Map<String, dynamic> tree,
  ) {
    final status =
        tree['status']?.toString().toUpperCase() ?? '';

    final color = _statusColor(status);

    final size = compact ? 16.0 : 22.0;

    return GestureDetector(
      onTap: compact
          ? null
          : () {
              _showTreeInformation(
                context,
                tree,
              );
            },
      child: Tooltip(
        message:
            tree['treeCode']?.toString() ??
            'Tree ${tree['id'] ?? ''}',
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: color,
              width: compact ? 2 : 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.12,
                ),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Icon(
            Icons.park,
            color: color,
            size: compact ? 10 : 14,
          ),
        ),
      ),
    );
  }

  void _showTreeInformation(
    BuildContext context,
    Map<String, dynamic> tree,
  ) {
    final code =
        tree['treeCode']?.toString() ??
        'TR-${tree['id']?.toString().padLeft(6, '0') ?? ''}';

    final variety =
        tree['variety']?.toString() ?? '-';

    final status =
        tree['status']?.toString() ?? '-';

    final block =
        tree['blockName']?.toString() ?? '-';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              5,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _statusColor(
                          status.toUpperCase(),
                        ).withValues(
                          alpha: 0.12,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.park,
                        color: _statusColor(
                          status.toUpperCase(),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        code,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF25402D),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                _infoRow(
                  'Variety',
                  variety,
                ),

                const SizedBox(height: 9),

                _infoRow(
                  'Status',
                  status,
                ),

                const SizedBox(height: 9),

                _infoRow(
                  'Block',
                  block,
                ),

                if (onTreeTap != null) ...[
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          sheetContext,
                        );

                        onTreeTap!(tree);
                      },
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'View Tree',
                      ),
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryGreen,
                        foregroundColor:
                            Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoRow(
    String label,
    String value,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFF718078),
              fontSize: 12,
            ),
          ),
        ),

        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF25402D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _legend({
    required int healthy,
    required int diseased,
    required int dead,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 15,
      ),
      child: Wrap(
        spacing: compact ? 10 : 16,
        runSpacing: 7,
        children: [
          _legendItem(
            healthyColor,
            compact
                ? 'Healthy $healthy'
                : 'Healthy: $healthy',
          ),
          _legendItem(
            diseasedColor,
            compact
                ? 'Diseased $diseased'
                : 'Diseased: $diseased',
          ),
          _legendItem(
            deadColor,
            compact
                ? 'Dead $dead'
                : 'Dead: $dead',
          ),
        ],
      ),
    );
  }

  Widget _legendItem(
    Color color,
    String text,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 5),

        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF718078),
            fontSize: compact ? 9 : 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _emptyMap() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.map_outlined,
              size: 35,
              color: Color(0xFF9AA7A0),
            ),
            SizedBox(height: 8),
            Text(
              'No farm coordinates available',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718078),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toUpperCase()) {
      case 'HEALTHY':
        return healthyColor;

      case 'DISEASED':
        return diseasedColor;

      case 'DEAD':
        return deadColor;

      default:
        return const Color(0xFF718078);
    }
  }

  // ============================================================
  // TREE POINT
  // ============================================================

  _GeoPoint? _treePoint(
    Map<String, dynamic> tree,
  ) {
    // Preferred source:
    // geometry = POINT(longitude latitude)
    final geometry =
        tree['geometry']?.toString();

    final fromGeometry =
        _parsePoint(geometry);

    if (fromGeometry != null) {
      return fromGeometry;
    }

    // Compatibility with locally cached trees.
    final latitude =
        double.tryParse(
          tree['latitude']?.toString() ?? '',
        );

    final longitude =
        double.tryParse(
          tree['longitude']?.toString() ?? '',
        );

    if (latitude == null ||
        longitude == null) {
      return null;
    }

    return _GeoPoint(
      latitude: latitude,
      longitude: longitude,
    );
  }

  // ============================================================
  // WKT POINT
  // ============================================================

  _GeoPoint? _parsePoint(
    String? wkt,
  ) {
    if (wkt == null ||
        wkt.trim().isEmpty) {
      return null;
    }

    final cleaned = wkt
        .trim()
        .replaceFirst(
          RegExp(
            r'^SRID=\d+;',
            caseSensitive: false,
          ),
          '',
        );

    final match = RegExp(
      r'POINT\s*\(\s*([+-]?(?:\d+(?:\.\d+)?|\.\d+))\s+([+-]?(?:\d+(?:\.\d+)?|\.\d+))\s*\)',
      caseSensitive: false,
    ).firstMatch(cleaned);

    if (match == null) {
      return null;
    }

    final longitude =
        double.tryParse(match.group(1)!);

    final latitude =
        double.tryParse(match.group(2)!);

    if (latitude == null ||
        longitude == null) {
      return null;
    }

    return _GeoPoint(
      latitude: latitude,
      longitude: longitude,
    );
  }

  // ============================================================
  // WKT POLYGON
  // ============================================================

  List<_GeoPoint> _parsePolygon(
    String? wkt,
  ) {
    if (wkt == null ||
        wkt.trim().isEmpty) {
      return const [];
    }

    var cleaned = wkt
        .trim()
        .replaceFirst(
          RegExp(
            r'^SRID=\d+;',
            caseSensitive: false,
          ),
          '',
        );

    final upper =
        cleaned.toUpperCase();

    if (!upper.startsWith('POLYGON')) {
      return const [];
    }

    final first =
        cleaned.indexOf('((');

    final last =
        cleaned.lastIndexOf('))');

    if (first < 0 ||
        last <= first + 2) {
      return const [];
    }

    cleaned = cleaned.substring(
      first + 2,
      last,
    );

    // Only use the exterior ring.
    final holeIndex =
        cleaned.indexOf('),(');

    if (holeIndex >= 0) {
      cleaned = cleaned.substring(
        0,
        holeIndex,
      );
    }

    final result = <_GeoPoint>[];

    for (final pair
        in cleaned.split(',')) {
      final values = pair
          .trim()
          .split(
            RegExp(r'\s+'),
          );

      if (values.length < 2) {
        continue;
      }

      final longitude =
          double.tryParse(values[0]);

      final latitude =
          double.tryParse(values[1]);

      if (latitude == null ||
          longitude == null) {
        continue;
      }

      result.add(
        _GeoPoint(
          latitude: latitude,
          longitude: longitude,
        ),
      );
    }

    return result;
  }
}

// ===============================================================
// DATA TYPES
// ===============================================================

class _GeoPoint {
  final double latitude;
  final double longitude;

  const _GeoPoint({
    required this.latitude,
    required this.longitude,
  });
}

class _TreeMapPoint {
  final Map<String, dynamic> tree;
  final _GeoPoint point;

  const _TreeMapPoint({
    required this.tree,
    required this.point,
  });
}

// ===============================================================
// MAP TRANSFORM
// ===============================================================

class _MapTransform {
  final double minLatitude;
  final double maxLatitude;
  final double minLongitude;
  final double maxLongitude;

  final double width;
  final double height;
  final double padding;

  const _MapTransform({
    required this.minLatitude,
    required this.maxLatitude,
    required this.minLongitude,
    required this.maxLongitude,
    required this.width,
    required this.height,
    required this.padding,
  });

  factory _MapTransform.fromData({
    required List<_GeoPoint> polygon,
    required List<_TreeMapPoint> trees,
    required double width,
    required double height,
    required double padding,
  }) {
    final points = <_GeoPoint>[
      ...polygon,
      ...trees.map(
        (tree) => tree.point,
      ),
    ];

    if (points.isEmpty) {
      return _MapTransform(
        minLatitude: 0,
        maxLatitude: 1,
        minLongitude: 0,
        maxLongitude: 1,
        width: width,
        height: height,
        padding: padding,
      );
    }

    double minLat =
        points.first.latitude;

    double maxLat =
        points.first.latitude;

    double minLng =
        points.first.longitude;

    double maxLng =
        points.first.longitude;

    for (final point in points) {
      minLat =
          math.min(
            minLat,
            point.latitude,
          );

      maxLat =
          math.max(
            maxLat,
            point.latitude,
          );

      minLng =
          math.min(
            minLng,
            point.longitude,
          );

      maxLng =
          math.max(
            maxLng,
            point.longitude,
          );
    }

    // Prevent division by zero for tiny datasets.
    if ((maxLat - minLat).abs() <
        0.0000001) {
      minLat -= 0.00001;
      maxLat += 0.00001;
    }

    if ((maxLng - minLng).abs() <
        0.0000001) {
      minLng -= 0.00001;
      maxLng += 0.00001;
    }

    return _MapTransform(
      minLatitude: minLat,
      maxLatitude: maxLat,
      minLongitude: minLng,
      maxLongitude: maxLng,
      width: width,
      height: height,
      padding: padding,
    );
  }

  Offset project(
    _GeoPoint point,
  ) {
    final usableWidth =
        math.max(
          1.0,
          width - (padding * 2),
        );

    final usableHeight =
        math.max(
          1.0,
          height - (padding * 2),
        );

    final x =
        padding +
        ((point.longitude -
                    minLongitude) /
                (maxLongitude -
                    minLongitude)) *
            usableWidth;

    // Latitude grows north/up, while Canvas Y grows down.
    final y =
        height -
        padding -
        ((point.latitude -
                    minLatitude) /
                (maxLatitude -
                    minLatitude)) *
            usableHeight;

    return Offset(
      x,
      y,
    );
  }
}

// ===============================================================
// FARM POLYGON PAINTER
// ===============================================================

class _FarmBoundaryPainter
    extends CustomPainter {
  final List<_GeoPoint> polygon;
  final _MapTransform transform;

  const _FarmBoundaryPainter({
    required this.polygon,
    required this.transform,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    _drawBackground(
      canvas,
      size,
    );

    if (polygon.length < 3) {
      return;
    }

    final path = Path();

    final first =
        transform.project(
          polygon.first,
        );

    path.moveTo(
      first.dx,
      first.dy,
    );

    for (var i = 1;
        i < polygon.length;
        i++) {
      final point =
          transform.project(
            polygon[i],
          );

      path.lineTo(
        point.dx,
        point.dy,
      );
    }

    path.close();

    final fillPaint = Paint()
      ..color =
          const Color(0xFFDBEAD2)
              .withValues(
        alpha: 0.72,
      )
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color =
          const Color(0xFF557A4C)
      ..style =
          PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(
      path,
      fillPaint,
    );

    canvas.drawPath(
      path,
      borderPaint,
    );
  }

  void _drawBackground(
    Canvas canvas,
    Size size,
  ) {
    final gridPaint = Paint()
      ..color =
          const Color(0xFFE8EFE4)
      ..strokeWidth = 0.7;

    const spacing = 24.0;

    for (double x = 0;
        x <= size.width;
        x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        gridPaint,
      );
    }

    for (double y = 0;
        y <= size.height;
        y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }
  }

  @override
  bool shouldRepaint(
    covariant _FarmBoundaryPainter
        oldDelegate,
  ) {
    return true;
  }
}