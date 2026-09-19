import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../l10n/app_localizations.dart';
import '../services/api_services/api_services.dart';
import '../services/api_services/farm_api_services.dart';
import '../theme/app_text_styles.dart';

class AddFarmPage extends StatefulWidget {
  const AddFarmPage({super.key});

  @override
  State<AddFarmPage> createState() => _AddFarmPageState();
}

class _AddFarmPageState extends State<AddFarmPage> {
  final _formKey = GlobalKey<FormState>();

  final _farmNameController = TextEditingController();

  final _farmTypeController = TextEditingController();

  final _farmSizeController = TextEditingController();

  final _plantingDateController = TextEditingController();

  final _notesController = TextEditingController();

  bool _isLoading = false;
  final List<LatLng> _farmBoundary = [];
  String? _farmBoundaryWkt;

  static const Color primaryGreen = Color(0xFF087A2F);

  static const Color fieldBackground = Color(0xFFEAF4EE);

  static const Color fieldBorder = Color(0xFFD7E9DD);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _farmNameController.dispose();
    _farmTypeController.dispose();
    _farmSizeController.dispose();
    _plantingDateController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // SELECT PLANTING DATE
  // ============================================================

  Future<void> _selectPlantingDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),

      // Flutter's date picker automatically follows
      // MaterialApp's current locale.
      locale: Localizations.localeOf(context),
    );

    if (date == null) {
      return;
    }

    setState(() {
      // Keep API date in yyyy-MM-dd format.
      _plantingDateController.text =
          '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    });
  }

  // ============================================================
  // FARM BOUNDARY (GPS)
  // ============================================================

  /// Opens the full-screen boundary page. The user walks around the farm
  /// and taps "Add my current location" at every corner. On save, we get
  /// back the points, the WKT polygon and the computed area.
  Future<void> _startFarmMapping() async {
    final result = await Navigator.push<_FarmBoundaryResult>(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) =>
            _FarmBoundaryPage(initialPoints: List<LatLng>.of(_farmBoundary)),
      ),
    );

    // Null means the user backed out: keep whatever we had before.
    if (result == null || !mounted) return;

    setState(() {
      _farmBoundary
        ..clear()
        ..addAll(result.points);
      _farmBoundaryWkt = result.wkt;
      _farmSizeController.text = result.acres.toStringAsFixed(2);
    });
  }

  bool _isPolygonWkt(String value) {
    return RegExp(
      r'^POLYGON\s*\(\(\s*-?\d+(?:\.\d+)?\s+-?\d+(?:\.\d+)?(?:\s*,\s*-?\d+(?:\.\d+)?\s+-?\d+(?:\.\d+)?){3,}\s*\)\)$',
      caseSensitive: false,
    ).hasMatch(value);
  }

  // ============================================================
  // SUBMIT FARM
  // ============================================================

  Future<void> _submitFarm() async {
    final l10n = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final acreage = double.tryParse(_farmSizeController.text.trim());

    if (acreage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.validFarmSizeRequired),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    final geometry = _farmBoundaryWkt?.trim();
    if (geometry == null || !_isPolygonWkt(geometry)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.drawValidBoundary),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // ========================================================
      // GET LOGGED-IN USER
      //
      // We only need the user's profile location.
      // We DO NOT extract or send farmerId.
      // Farm ownership is determined by the JWT/backend.
      // ========================================================

      final currentUserResponse = await ApiServices.getCurrentUser();
      // ==========================================
      // 1. GET ACTUAL LOGGED-IN USER
      // ==========================================
      debugPrint(
        'CURRENT USER RESPONSE: '
        '$currentUserResponse',
      );

      // Support either:
      // { "data": {...} }
      // or:
      // { ...user fields... }

      final dynamic rawUser = currentUserResponse['data'];

      final Map<String, dynamic> user;

      if (rawUser is Map) {
        user = Map<String, dynamic>.from(rawUser);
      } else {
        user = currentUserResponse;
      }

      // ========================================================
      // PROFILE LOCATION
      // ========================================================

      final region = user['region']?.toString().trim() ?? '';

      final district = user['district']?.toString().trim() ?? '';

      final ward = user['ward']?.toString().trim() ?? '';

      final village = user['village']?.toString().trim() ?? '';

      if (region.isEmpty ||
          district.isEmpty ||
          ward.isEmpty ||
          village.isEmpty) {
        throw Exception(l10n.profileLocationIncomplete);
      }

      // ========================================================
      // CREATE FARM
      // ========================================================

      final result = await FarmApiServices.createFarm(
        name: _farmNameController.text.trim(),

        acreage: acreage,

        plantingDate: _plantingDateController.text.trim(),

        farmType: _farmTypeController.text.trim().toUpperCase(),
        geometry: geometry,
        region: region,
        district: district,
        ward: ward,
        village: village,
      );

      debugPrint(
        'CREATE FARM RESULT: '
        '$result',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.farmAddedSuccessfully),
          backgroundColor: primaryGreen,
        ),
      );
      // Tell FarmsPage to reload.
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('CREATE FARM ERROR: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: primaryGreen,

      resizeToAvoidBottomInset: true,

      body: SafeArea(
        bottom: false,

        child: Container(
          width: double.infinity,

          height: double.infinity,

          decoration: const BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),

          child: Column(
            children: [
              // =================================================
              // HEADER
              // =================================================

              Container(
                width: double.infinity,

                height: 52,

                padding: const EdgeInsets.symmetric(horizontal: 14),

                decoration: const BoxDecoration(
                  color: primaryGreen,

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(18),
                    bottomRight: Radius.circular(18),
                  ),
                ),

                alignment: Alignment.centerLeft,

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

                    Text(
                      l10n.addFarm,

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: AppTextStyles.body,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // FORM
              // =================================================
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,

                  padding: const EdgeInsets.fromLTRB(18, 42, 18, 30),

                  child: Form(
                    key: _formKey,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // =======================================
                        // FARM NAME
                        // =======================================

                        _buildLabel(l10n.farmName),

                        const SizedBox(height: 7),

                        _buildField(
                          controller: _farmNameController,

                          hint: l10n.farmName,

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.farmNameRequired;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // =======================================
                        // PLANTING DATE
                        // =======================================
                        _buildLabel(l10n.plantingDate),

                        const SizedBox(height: 7),

                        _buildField(
                          controller: _plantingDateController,

                          hint: l10n.plantingDate,

                          readOnly: true,

                          onTap: _selectPlantingDate,

                          suffixIcon: const Icon(
                            Icons.calendar_today_outlined,
                            size: 18,
                            color: primaryGreen,
                          ),

                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.plantingDateRequired;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // =======================================
                        // FARM TYPE
                        // =======================================
                        _buildLabel(l10n.farmType),

                        const SizedBox(height: 7),

                        _buildFarmTypeDropdown(context),

                        const SizedBox(height: 18),

                        // =======================================
                        // FARM SIZE (from GPS boundary)
                        // =======================================
                        _buildLabel(l10n.farmSize),

                        const SizedBox(height: 7),

                        SizedBox(
                          width: double.infinity,
                          height: 42,
                          child: OutlinedButton.icon(
                            onPressed: _isLoading ? null : _startFarmMapping,
                            icon: const Icon(Icons.my_location, size: 18),
                            label: Text(
                                _farmBoundary.length >= 3
                                  ? l10n.redrawFarmBoundary
                                  : l10n.drawFarmBoundary,
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryGreen,
                              side: const BorderSide(color: primaryGreen),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 7),

                        _buildField(
                          controller: _farmSizeController,
                          hint: l10n.farmSize,
                          readOnly: true,
                          suffixText: l10n.acres,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.drawBoundaryForSize;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 24),

                        // =======================================
                        // SUBMIT
                        // =======================================
                        SizedBox(
                          width: double.infinity,

                          height: 46,

                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitFarm,

                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,

                              foregroundColor: Colors.white,

                              disabledBackgroundColor: primaryGreen.withValues(
                                alpha: 0.60,
                              ),

                              elevation: 0,

                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),

                            child: _isLoading
                                ? const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    l10n.submitFarm,
                                    style: const TextStyle(
                                      fontSize: AppTextStyles.body,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),
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

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String label) {
    return Text(
      label,

      style: const TextStyle(
        fontSize: AppTextStyles.body,
        fontWeight: FontWeight.w600,
        color: Color(0xFF304438),
      ),
    );
  }

  // ============================================================
  // FARM TYPE DROPDOWN
  // ============================================================

  Widget _buildFarmTypeDropdown(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return DropdownButtonFormField<String>(
      value: _farmTypeController.text.isEmpty ? null : _farmTypeController.text,

      isExpanded: true,

      decoration: InputDecoration(
        hintText: l10n.selectFarmType,

        hintStyle: TextStyle(
          fontSize: AppTextStyles.bodySmall,
          color: Colors.grey.shade500,
        ),

        filled: true,

        fillColor: fieldBackground,

        isDense: true,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 14,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: fieldBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 1.2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),

        errorStyle: const TextStyle(fontSize: AppTextStyles.bodySmall),
      ),

      // IMPORTANT:
      // Values remain backend enum values.
      // Only labels are translated.
      items: [
        DropdownMenuItem(
          value: 'NEW',
          child: Text(
            l10n.newFarm,
            style: const TextStyle(fontSize: AppTextStyles.body),
          ),
        ),

        DropdownMenuItem(
          value: 'PRODUCTION',
          child: Text(
            l10n.productionFarm,
            style: const TextStyle(fontSize: AppTextStyles.body),
          ),
        ),
      ],

      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _farmTypeController.text = value;
        });
      },

      validator: (value) {
        if (value == null || value.isEmpty) {
          return l10n.farmTypeRequired;
        }

        return null;
      },
    );
  }

  // ============================================================
  // FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    int minLines = 1,
    String? suffixText,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,

      keyboardType: keyboardType,

      validator: validator,

      readOnly: readOnly,

      onTap: onTap,

      maxLines: maxLines,

      minLines: minLines,

      style: const TextStyle(
        fontSize: AppTextStyles.bodySmall,
        color: Color(0xFF304438),
      ),

      decoration: InputDecoration(
        hintText: hint,

        hintStyle: TextStyle(
          fontSize: AppTextStyles.bodySmall,
          color: Colors.grey.shade500,
        ),

        suffixText: suffixText,

        suffixIcon: suffixIcon,

        suffixStyle: const TextStyle(
          fontSize: AppTextStyles.bodySmall,
          fontWeight: FontWeight.w600,
          color: Color(0xFF687A70),
        ),

        filled: true,

        fillColor: fieldBackground,

        isDense: true,

        contentPadding: EdgeInsets.symmetric(
          horizontal: 13,
          vertical: maxLines > 1 ? 15 : 14,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: fieldBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 1.2),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),

        errorStyle: const TextStyle(fontSize: AppTextStyles.bodySmall),
      ),
    );
  }
}

// ==================================================================
// GEOMETRY / GPS HELPERS
// ==================================================================

/// Ensures GPS is on and permission is granted, otherwise throws an
/// [Exception] with a user-friendly message.
Future<void> _ensureLocationReady(AppLocalizations l10n) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw Exception(l10n.gpsServicesRequired);
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.deniedForever) {
    throw Exception(l10n.gpsPermissionPermanentlyDenied);
  }
  if (permission == LocationPermission.denied) {
    throw Exception(l10n.gpsPermissionRequired);
  }
}

/// Area of the polygon in acres.
///
/// Points are projected to a local flat plane (meters) around the polygon's
/// centre, then the shoelace formula is applied. This is accurate for farm
/// sized areas.
double _polygonAreaInAcres(List<LatLng> points) {
  if (points.length < 3) return 0;

  const earthRadius = 6371008.8; // meters
  const degToRad = math.pi / 180.0;

  final lat0 =
      points.fold<double>(0, (sum, p) => sum + p.latitude) / points.length;
  final lng0 =
      points.fold<double>(0, (sum, p) => sum + p.longitude) / points.length;
  final cosLat0 = math.cos(lat0 * degToRad);

  final xs = <double>[];
  final ys = <double>[];
  for (final p in points) {
    xs.add((p.longitude - lng0) * degToRad * earthRadius * cosLat0);
    ys.add((p.latitude - lat0) * degToRad * earthRadius);
  }

  var twiceArea = 0.0;
  for (var i = 0; i < points.length; i++) {
    final j = (i + 1) % points.length;
    twiceArea += xs[i] * ys[j] - xs[j] * ys[i];
  }

  final squareMeters = twiceArea.abs() / 2;
  return squareMeters / 4046.8564224;
}

/// Builds a closed WKT polygon: POLYGON ((lng lat, lng lat, ...)).
String _toWktPolygon(List<LatLng> points) {
  final ring = [...points, points.first];
  final coordinates = ring
      .map(
        (p) =>
            '${p.longitude.toStringAsFixed(7)} ${p.latitude.toStringAsFixed(7)}',
      )
      .join(', ');
  return 'POLYGON (($coordinates))';
}

bool _segmentsIntersect(LatLng a, LatLng b, LatLng c, LatLng d) {
  double cross(LatLng o, LatLng p, LatLng q) {
    return (p.longitude - o.longitude) * (q.latitude - o.latitude) -
        (p.latitude - o.latitude) * (q.longitude - o.longitude);
  }

  final d1 = cross(a, b, c);
  final d2 = cross(a, b, d);
  final d3 = cross(c, d, a);
  final d4 = cross(c, d, b);

  return ((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
      ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0));
}

/// True if any two non-adjacent edges of the polygon cross each other
/// (a "bow-tie" shape), which would be an invalid polygon.
bool _hasSelfIntersection(List<LatLng> points) {
  final n = points.length;
  if (n < 4) return false;

  for (var i = 0; i < n; i++) {
    final a = points[i];
    final b = points[(i + 1) % n];

    for (var j = i + 1; j < n; j++) {
      // Skip edges that share a vertex.
      if (j == i + 1) continue;
      if (i == 0 && j == n - 1) continue;

      final c = points[j];
      final d = points[(j + 1) % n];

      if (_segmentsIntersect(a, b, c, d)) return true;
    }
  }
  return false;
}

// ==================================================================
// FARM BOUNDARY (GPS) PAGE
// ==================================================================

class _FarmBoundaryResult {
  const _FarmBoundaryResult({
    required this.points,
    required this.wkt,
    required this.acres,
  });

  final List<LatLng> points;
  final String wkt;
  final double acres;
}

/// Full-screen page where the user walks around the farm and taps a button
/// at each corner. Every tap reads the device GPS and adds that coordinate
/// as a vertex of the farm polygon.
class _FarmBoundaryPage extends StatefulWidget {
  const _FarmBoundaryPage({required this.initialPoints});

  final List<LatLng> initialPoints;

  @override
  State<_FarmBoundaryPage> createState() => _FarmBoundaryPageState();
}

class _FarmBoundaryPageState extends State<_FarmBoundaryPage> {
  static const Color primaryGreen = Color(0xFF087A2F);

  // Centre of Tanzania, used until the first GPS fix arrives.
  static const LatLng _defaultCenter = LatLng(-6.369028, 34.888822);

  static const double _goodAccuracyMeters = 10;
  static const double _acceptableAccuracyMeters = 25;
  static const double _minPointSpacingMeters = 3;

  late final List<LatLng> _points = List<LatLng>.of(widget.initialPoints);

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _positionSub;

  Position? _currentPosition;
  String? _gpsError;
  bool _locationGranted = false;
  bool _isCapturing = false;
  bool _hasCentered = false;

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void initState() {
    super.initState();
    // If we are editing an existing boundary, the camera starts on it.
    _hasCentered = _points.isNotEmpty;
    unawaited(_initGps());
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  // ============================================================
  // LIVE GPS (shows accuracy + centres the map on the user)
  // ============================================================

  Future<void> _initGps() async {
    final l10n = AppLocalizations.of(context)!;
    await _positionSub?.cancel();
    _positionSub = null;

    if (mounted) {
      setState(() {
        _gpsError = null;
      });
    }

    try {
      await _ensureLocationReady(l10n);
      if (!mounted) return;

      setState(() {
        _locationGranted = true;
      });

      _positionSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
            ),
          ).listen(
            _onPosition,
            onError: (Object error) {
              if (!mounted) return;
              setState(() {
                _gpsError = l10n.gpsUnavailableRetry;
              });
            },
          );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _gpsError = '${_cleanError(e)} (tap to retry)';
      });
    }
  }

  void _onPosition(Position position) {
    if (!mounted) return;

    setState(() {
      _currentPosition = position;
      _gpsError = null;
    });

    if (!_hasCentered) {
      _centerOnCurrentPosition();
    }
  }

  void _centerOnCurrentPosition() {
    final position = _currentPosition;
    final controller = _mapController;
    if (position == null || controller == null) return;

    _hasCentered = true;
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.latitude, position.longitude),
        19,
      ),
    );
  }

  // ============================================================
  // BOUNDARY ACTIONS
  // ============================================================

  /// Reads the device's current GPS position and adds it as the next
  /// vertex of the boundary polygon.
  Future<void> _addCurrentLocationPoint() async {
    if (_isCapturing) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isCapturing = true;
    });

    try {
      await _ensureLocationReady(l10n);

      // Permission may have just been granted: start live GPS + blue dot.
      if (_positionSub == null) {
        unawaited(_initGps());
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;

      final point = LatLng(position.latitude, position.longitude);

      // Ignore accidental double taps at the same spot.
      if (_points.isNotEmpty) {
        final last = _points.last;
        final distance = Geolocator.distanceBetween(
          last.latitude,
          last.longitude,
          point.latitude,
          point.longitude,
        );
        if (distance < _minPointSpacingMeters) {
          _showMessage(l10n.gpsPointTooClose);
          return;
        }
      }

      setState(() {
        _points.add(point);
        _currentPosition = position;
      });

      await _mapController?.animateCamera(CameraUpdate.newLatLng(point));

      if (position.accuracy > _acceptableAccuracyMeters) {
        _showMessage(
          l10n.gpsLowAccuracy(_points.length, position.accuracy.round()),
          color: Colors.orange.shade800,
        );
      }
    } on TimeoutException {
      _showMessage(l10n.gpsFixUnavailable, color: Colors.red);
    } catch (e) {
      _showMessage(_cleanError(e), color: Colors.red);
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  void _undoPoint() {
    if (_points.isEmpty) return;
    setState(() {
      _points.removeLast();
    });
  }

  void _clearPoints() {
    if (_points.isEmpty) return;
    setState(() {
      _points.clear();
    });
  }

  void _save() {
    final l10n = AppLocalizations.of(context)!;
    if (_points.length < 3) {
      _showMessage(l10n.addThreeBoundaryPoints, color: Colors.red);
      return;
    }

    if (_hasSelfIntersection(_points)) {
      _showMessage(l10n.boundarySelfIntersecting, color: Colors.red);
      return;
    }

    final points = List<LatLng>.unmodifiable(_points);

    Navigator.pop(
      context,
      _FarmBoundaryResult(
        points: points,
        wkt: _toWktPolygon(points),
        acres: _polygonAreaInAcres(points),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _cleanError(Object e) => e.toString().replaceFirst('Exception: ', '');

  void _showMessage(String message, {Color? color}) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPolygon = _points.length >= 3;
    final selfIntersecting = _hasSelfIntersection(_points);
    final areaAcres = hasPolygon ? _polygonAreaInAcres(_points) : 0.0;
    final canSave = hasPolygon && !selfIntersecting && !_isCapturing;
    final strokeColor = selfIntersecting ? Colors.red : primaryGreen;

    final polygons = <Polygon>{
      if (hasPolygon)
        Polygon(
          polygonId: const PolygonId('farm-boundary'),
          points: List<LatLng>.of(_points),
          fillColor: strokeColor.withValues(alpha: 0.25),
          strokeColor: strokeColor,
          strokeWidth: 3,
        ),
    };

    final polylines = <Polyline>{
      if (_points.length == 2)
        Polyline(
          polylineId: const PolylineId('farm-boundary-preview'),
          points: List<LatLng>.of(_points),
          color: primaryGreen,
          width: 3,
        ),
    };

    final markers = <Marker>{
      for (var i = 0; i < _points.length; i++)
        Marker(
          markerId: MarkerId('boundary-$i'),
          position: _points[i],
          infoWindow: InfoWindow(title: l10n.mapPoint(i + 1)),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
          ),
        ),
    };

    final initialTarget = _points.isNotEmpty ? _points.last : _defaultCenter;
    final initialZoom = _points.isNotEmpty ? 18.0 : 5.0;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.farmBoundary,
          style: TextStyle(
            fontSize: AppTextStyles.body,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: l10n.undoLastPoint,
            color: Colors.white,
            disabledColor: Colors.white38,
            onPressed: _points.isEmpty || _isCapturing ? null : _undoPoint,
            icon: const Icon(Icons.undo),
          ),
          IconButton(
            tooltip: l10n.clearAllPoints,
            color: Colors.white,
            disabledColor: Colors.white38,
            onPressed: _points.isEmpty || _isCapturing ? null : _clearPoints,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialTarget,
                    zoom: initialZoom,
                  ),
                  mapType: MapType.hybrid,
                  myLocationEnabled: _locationGranted,
                  myLocationButtonEnabled: _locationGranted,
                  zoomControlsEnabled: false,
                  mapToolbarEnabled: false,
                  tiltGesturesEnabled: false,
                  polygons: polygons,
                  polylines: polylines,
                  markers: markers,
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (!_hasCentered) {
                      _centerOnCurrentPosition();
                    }
                  },
                ),
                Positioned(top: 12, left: 12, child: _buildGpsChip(context)),
              ],
            ),
          ),
          _buildBottomPanel(
            hasPolygon: hasPolygon,
            selfIntersecting: selfIntersecting,
            areaAcres: areaAcres,
            canSave: canSave,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // GPS STATUS CHIP
  // ============================================================

  Widget _buildGpsChip(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final Color color;
    final String text;

    final error = _gpsError;
    final position = _currentPosition;

    if (error != null) {
      color = Colors.red;
      text = error;
    } else if (position == null) {
      color = Colors.orange.shade800;
      text = l10n.waitingForGps;
    } else {
      final accuracy = position.accuracy;
      if (accuracy <= _goodAccuracyMeters) {
        color = primaryGreen;
      } else if (accuracy <= _acceptableAccuracyMeters) {
        color = Colors.orange.shade800;
      } else {
        color = Colors.red;
      }
      text = 'GPS ±${accuracy.round()} m';
    }

    return GestureDetector(
      onTap: error != null ? _initGps : null,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.65,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.gps_fixed, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
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
  // BOTTOM PANEL
  // ============================================================

  Widget _buildBottomPanel({
    required bool hasPolygon,
    required bool selfIntersecting,
    required double areaAcres,
    required bool canSave,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final count = _points.length;

    String info;
    Color infoColor = const Color(0xFF304438);

    if (count == 0) {
      info = l10n.boundaryStartInstructions;
    } else if (count < 3) {
      info = l10n.boundaryPointsAdded(count, 3 - count);
    } else if (selfIntersecting) {
      info = l10n.boundarySelfIntersecting;
      infoColor = Colors.red;
    } else {
      info = l10n.boundaryArea(count, areaAcres.toStringAsFixed(2));
      infoColor = primaryGreen;
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                info,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppTextStyles.bodySmall,
                  fontWeight: FontWeight.w600,
                  color: infoColor,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 46,
                child: ElevatedButton.icon(
                  onPressed: _isCapturing ? null : _addCurrentLocationPoint,
                  icon: _isCapturing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.add_location_alt_outlined, size: 20),
                  label: Text(
                    _isCapturing
                      ? l10n.gettingGpsLocation
                      : l10n.addCurrentLocation,
                    style: const TextStyle(
                      fontSize: AppTextStyles.body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: primaryGreen.withValues(
                      alpha: 0.60,
                    ),
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 46,
                child: OutlinedButton.icon(
                  onPressed: canSave ? _save : null,
                  icon: const Icon(Icons.check, size: 20),
                  label: Text(
                    l10n.saveBoundary,
                    style: TextStyle(
                      fontSize: AppTextStyles.body,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryGreen,
                    side: BorderSide(
                      color: canSave ? primaryGreen : Colors.grey.shade400,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
}