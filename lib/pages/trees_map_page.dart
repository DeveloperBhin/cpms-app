import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../l10n/app_localizations.dart';
import '../services/api_services/farm_api_services.dart';
import '../services/api_services/tree_api_services.dart';
import '../theme/app_text_styles.dart';

import 'farmdetails_page.dart';
import 'treesdetails_page.dart';

class TreesMapPage extends StatefulWidget {
  const TreesMapPage({super.key});

  @override
  State<TreesMapPage> createState() => _TreesMapPageState();
}

class _TreesMapPageState extends State<TreesMapPage> {
  static const primaryGreen = Color(0xFF087A2F);
  static const backgroundColor = Color(0xFFF8FAF8);
  static const borderColor = Color(0xFFDCE8DF);
  static const lightGreen = Color(0xFFE7F3EB);
  static const textDark = Color(0xFF25402D);
  static const textGrey = Color(0xFF718078);

  List<Map<String, dynamic>> _trees = [];
  List<Map<String, dynamic>> _farms = [];
  Map<String, dynamic>? _selectedTree;
  Map<String, dynamic>? _selectedFarm;
  BitmapDescriptor? _treeIcon;
  GoogleMapController? _mapController;
  MapType _mapType = MapType.normal;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
    _createTreeIcon();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        TreeApiServices.getMyTrees(),
        FarmApiServices.getMyFarms(),
      ]);

      if (!mounted) return;
      setState(() {
        _trees = results[0];
        _farms = results[1];
        _isLoading = false;
      });

      await _zoomToFeatures();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _createTreeIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..isAntiAlias = true;

    paint.color = Colors.white;
    canvas.drawCircle(const Offset(48, 48), 44, paint);
    paint.color = primaryGreen;
    canvas.drawCircle(const Offset(48, 32), 20, paint);
    canvas.drawCircle(const Offset(33, 42), 15, paint);
    canvas.drawCircle(const Offset(63, 42), 15, paint);
    paint.color = const Color(0xFF7A4B2A);
    canvas.drawRect(const Rect.fromLTWH(43, 42, 10, 32), paint);

    final image = await recorder.endRecording().toImage(96, 96);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    if (!mounted || data == null) return;

    setState(() {
      _treeIcon = BitmapDescriptor.bytes(
        data.buffer.asUint8List(),
        width: 36,
        height: 36,
      );
    });
  }

  _GeoPoint? _treePoint(Map<String, dynamic> tree) {
    final geometry = tree['geometry']?.toString().trim();
    if (geometry != null) {
      final match =
          RegExp(
            r'POINT\s*\(\s*([+-]?(?:\d+(?:\.\d+)?|\.\d+))\s+'
            r'([+-]?(?:\d+(?:\.\d+)?|\.\d+))\s*\)',
            caseSensitive: false,
          ).firstMatch(
            geometry.replaceFirst(
              RegExp(r'^SRID=\d+;', caseSensitive: false),
              '',
            ),
          );

      if (match != null) {
        final longitude = double.tryParse(match.group(1)!);
        final latitude = double.tryParse(match.group(2)!);
        if (longitude != null && latitude != null) {
          return _GeoPoint(latitude, longitude);
        }
      }
    }

    final latitude = double.tryParse(tree['latitude']?.toString() ?? '');
    final longitude = double.tryParse(tree['longitude']?.toString() ?? '');
    if (latitude == null || longitude == null) return null;
    return _GeoPoint(latitude, longitude);
  }

  List<_GeoPoint> _farmPolygon(Map<String, dynamic> farm) {
    final raw = farm['geometry'] ?? farm['farmGeometry'] ?? farm['boundary'];
    if (raw == null) return const [];

    var value = raw.toString().trim().replaceFirst(
      RegExp(r'^SRID=\d+;', caseSensitive: false),
      '',
    );
    if (!value.toUpperCase().startsWith('POLYGON')) return const [];

    final start = value.indexOf('((');
    final end = value.lastIndexOf('))');
    if (start < 0 || end <= start) return const [];

    value = value.substring(start + 2, end);
    final hole = value.indexOf('),(');
    if (hole >= 0) value = value.substring(0, hole);

    return value
        .split(',')
        .map((pair) {
          final values = pair.trim().split(RegExp(r'\s+'));
          if (values.length < 2) return null;
          final longitude = double.tryParse(values[0]);
          final latitude = double.tryParse(values[1]);
          if (longitude == null || latitude == null) return null;
          return _GeoPoint(latitude, longitude);
        })
        .whereType<_GeoPoint>()
        .toList();
  }

  LatLng get _initialCenter => const LatLng(-6.7924, 39.2083);

  LatLngBounds? get _featureBounds {
    final points = <LatLng>[];

    for (final tree in _trees) {
      final point = _treePoint(tree);
      if (point != null) {
        points.add(LatLng(point.latitude, point.longitude));
      }
    }

    for (final farm in _farms) {
      for (final point in _farmPolygon(farm)) {
        points.add(LatLng(point.latitude, point.longitude));
      }
    }

    if (points.isEmpty) return null;

    var minLatitude = points.first.latitude;
    var maxLatitude = points.first.latitude;
    var minLongitude = points.first.longitude;
    var maxLongitude = points.first.longitude;

    for (final point in points.skip(1)) {
      minLatitude = math.min(minLatitude, point.latitude);
      maxLatitude = math.max(maxLatitude, point.latitude);
      minLongitude = math.min(minLongitude, point.longitude);
      maxLongitude = math.max(maxLongitude, point.longitude);
    }

    // Google Maps needs a non-zero viewport even when there is one point.
    const minimumSpan = 0.001;
    if (maxLatitude - minLatitude < minimumSpan) {
      minLatitude -= minimumSpan;
      maxLatitude += minimumSpan;
    }
    if (maxLongitude - minLongitude < minimumSpan) {
      minLongitude -= minimumSpan;
      maxLongitude += minimumSpan;
    }

    return LatLngBounds(
      southwest: LatLng(minLatitude, minLongitude),
      northeast: LatLng(maxLatitude, maxLongitude),
    );
  }

  Future<void> _zoomToFeatures() async {
    final controller = _mapController;
    final bounds = _featureBounds;
    if (controller == null || bounds == null) return;

    await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 56));
  }

  Set<Marker> get _markers {
    return _trees
        .map((tree) {
          final point = _treePoint(tree);
          if (point == null) return null;
          return Marker(
            markerId: MarkerId('tree-${tree['id']}'),
            position: LatLng(point.latitude, point.longitude),
            icon:
                _treeIcon ??
                BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueGreen,
                ),
            onTap: () {
              setState(() {
                _selectedTree = tree;
                _selectedFarm = null;
              });
            },
          );
        })
        .whereType<Marker>()
        .toSet();
  }

  Set<Polygon> get _polygons {
    return _farms
        .map((farm) {
          final points = _farmPolygon(farm);
          if (points.length < 3) return null;
          return Polygon(
            polygonId: PolygonId('farm-${farm['id']}'),
            points: points.map((point) {
              return LatLng(point.latitude, point.longitude);
            }).toList(),
            fillColor: primaryGreen.withValues(alpha: 0.18),
            strokeColor: primaryGreen,
            strokeWidth: 2,
            consumeTapEvents: true,
            onTap: () {
              setState(() {
                _selectedFarm = farm;
                _selectedTree = null;
              });
            },
          );
        })
        .whereType<Polygon>()
        .toSet();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialCenter,
              zoom: 3,
            ),
            mapType: _mapType,
            onMapCreated: (controller) {
              _mapController = controller;
              _zoomToFeatures();
            },
            markers: _markers,
            polygons: _polygons,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  _mapTypeButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: const [
                          BoxShadow(color: Color(0x22000000), blurRadius: 8),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: textGrey, size: 19),
                          const SizedBox(width: 8),
                          Text(
                            l10n.searchTreeHint,
                            style: const TextStyle(
                              color: textGrey,
                              fontSize: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _roundButton(Icons.refresh, _loadData),
                ],
              ),
            ),
          ),
          _bottomSheet(context),
        ],
      ),
    );
  }

  Widget _roundButton(IconData icon, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: textDark, size: 17),
        ),
      ),
    );
  }

  Widget _mapTypeButton() {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: PopupMenuButton<MapType>(
        initialValue: _mapType,
        tooltip: 'Change map style',
        onSelected: (mapType) {
          setState(() {
            _mapType = mapType;
          });
        },
        itemBuilder: (context) {
          return const [
            PopupMenuItem(value: MapType.normal, child: Text('Standard')),
            PopupMenuItem(value: MapType.satellite, child: Text('Satellite')),
            PopupMenuItem(value: MapType.terrain, child: Text('Terrain')),
            PopupMenuItem(value: MapType.hybrid, child: Text('Hybrid')),
          ];
        },
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.layers_outlined, color: textDark, size: 18),
        ),
      ),
    );
  }

  Widget _bottomSheet(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.18,
      minChildSize: 0.14,
      maxChildSize: 0.78,
      snap: true,
      snapSizes: const [0.18, 0.45, 0.78],
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            boxShadow: [BoxShadow(color: Color(0x26000000), blurRadius: 14)],
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 26),
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: borderColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_selectedTree != null)
                _treePreview(context, _selectedTree!)
              else if (_selectedFarm != null)
                _farmPreview(context, _selectedFarm!)
              else
                _treeListPreview(),
            ],
          ),
        );
      },
    );
  }

  Widget _treeListPreview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.park_outlined, color: primaryGreen, size: 22),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Trees on the map',
                style: TextStyle(
                  color: textDark,
                  fontSize: AppTextStyles.bodyLarge,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text('${_trees.length}', style: const TextStyle(color: textGrey)),
          ],
        ),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(color: primaryGreen),
            ),
          )
        else if (_error != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(_error!, style: const TextStyle(color: textGrey)),
          )
        else if (_trees.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              'No trees registered',
              style: TextStyle(color: textGrey),
            ),
          )
        else
          ..._trees.take(8).map(_treeListTile),
      ],
    );
  }

  Widget _treeListTile(Map<String, dynamic> tree) {
    final code = tree['treeCode']?.toString() ?? 'Tree ${tree['id'] ?? ''}';
    final status = tree['status']?.toString() ?? '-';
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: lightGreen,
        child: Icon(Icons.park, color: primaryGreen, size: 18),
      ),
      title: Text(
        code,
        style: const TextStyle(color: textDark, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '${tree['variety'] ?? '-'}  •  ${tree['blockName'] ?? '-'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: textGrey, fontSize: 12),
      ),
      trailing: Text(
        status,
        style: TextStyle(
          color: _statusColor(status),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
      onTap: () => setState(() {
        _selectedTree = tree;
        _selectedFarm = null;
      }),
    );
  }

  Widget _treePreview(BuildContext context, Map<String, dynamic> tree) {
    final code = tree['treeCode']?.toString() ?? 'Tree ${tree['id'] ?? ''}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _previewHeader(Icons.park, code),
        _infoRow('Variety', tree['variety']?.toString() ?? '-'),
        _infoRow('Status', tree['status']?.toString() ?? '-'),
        _infoRow(
          'Farm / block',
          '${tree['farmName'] ?? '-'} / ${tree['blockName'] ?? '-'}',
        ),
        const SizedBox(height: 12),
        Center(
          child: BarcodeWidget(
            barcode: Barcode.qrCode(),
            data: code,
            width: 118,
            height: 118,
            drawText: false,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () => _openTree(tree),
            icon: const Icon(Icons.visibility_outlined, size: 17),
            label: const Text('View tree details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _farmPreview(BuildContext context, Map<String, dynamic> farm) {
    final farmId = farm['id']?.toString();
    final farmTrees = _trees.where((tree) {
      return tree['farmId']?.toString() == farmId;
    }).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _previewHeader(
          Icons.agriculture_outlined,
          farm['name']?.toString() ?? 'Farm',
        ),
        _infoRow('Location', farm['village']?.toString() ?? '-'),
        _infoRow('Acreage', '${farm['acreage'] ?? '-'} acres'),
        _infoRow('Trees', '$farmTrees'),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 42,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FarmDetailsPage(farm: farm)),
              );
            },
            icon: const Icon(Icons.visibility_outlined, size: 17),
            label: const Text('View farm details'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _previewHeader(IconData icon, String title) {
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() {
            _selectedTree = null;
            _selectedFarm = null;
          }),
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
          color: textDark,
          tooltip: 'Back to trees',
        ),
        Icon(icon, color: primaryGreen),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodyLarge,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(color: textGrey, fontSize: 12),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: textDark,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

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

  Future<void> _openTree(Map<String, dynamic> tree) async {
    final farmId = tree['farmId']?.toString() ?? '';
    final blockId = tree['blockId']?.toString() ?? '';
    final treeId = tree['id']?.toString() ?? '';
    if (farmId.isEmpty || blockId.isEmpty || treeId.isEmpty) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TreeDetailsPage(farmId: farmId, blockId: blockId, treeId: treeId),
      ),
    );
  }
}

class _GeoPoint {
  final double latitude;
  final double longitude;

  const _GeoPoint(this.latitude, this.longitude);
}
