import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../services/local_data_service.dart';
import '../services/api_services/api_services.dart';
import '../theme/app_text_styles.dart';
import '../l10n/app_localizations.dart';

class AddFarmPage extends StatefulWidget {
  const AddFarmPage({
    super.key,
  });

  @override
  State<AddFarmPage> createState() =>
      _AddFarmPageState();
}

class _AddFarmPageState extends State<AddFarmPage> {
  final _formKey =
      GlobalKey<FormState>();

  final _farmNameController =
      TextEditingController();

  final _farmTypeController =
      TextEditingController();

  final _farmSizeController =
      TextEditingController();

  final _plantingDateController =
      TextEditingController();

  final _notesController =
      TextEditingController();

  bool _isLoading = false;

  final List<LatLng> _farmBoundary = [];

  String? _farmBoundaryWkt;

  LatLng? _currentLocation;

  static const Color primaryGreen =
      Color(0xFF087A2F);

  static const Color fieldBackground =
      Color(0xFFEAF4EE);

  static const Color fieldBorder =
      Color(0xFFD7E9DD);

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
    final date =
        await showDatePicker(
      context: context,
      initialDate:
          DateTime.now(),
      firstDate:
          DateTime(1990),
      lastDate:
          DateTime.now(),
      locale:
          Localizations.localeOf(
        context,
      ),
    );

    if (date == null) {
      return;
    }

    setState(() {
      _plantingDateController.text =
          '${date.year}-'
          '${date.month.toString().padLeft(2, '0')}-'
          '${date.day.toString().padLeft(2, '0')}';
    });
  }

  // ============================================================
  // CREATE WKT POLYGON
  // ============================================================

  String _pointsToWktPolygon(
    List<LatLng> points,
  ) {
    if (points.length < 3) {
      throw Exception(
        'At least three farm boundary points are required.',
      );
    }

    final closedPoints =
        List<LatLng>.from(
      points,
    );

    final first =
        closedPoints.first;

    final last =
        closedPoints.last;

    // A WKT polygon must be closed.
    if (first.latitude != last.latitude ||
        first.longitude != last.longitude) {
      closedPoints.add(
        first,
      );
    }

    // IMPORTANT:
    //
    // PostGIS / WKT:
    //
    // X = longitude
    // Y = latitude

    final coordinates =
        closedPoints
            .map(
              (point) =>
                  '${point.longitude} ${point.latitude}',
            )
            .join(', ');

    return 'POLYGON (($coordinates))';
  }

  // ============================================================
  // START FARM MAPPING
  // ============================================================

  Future<void> _startFarmMapping() async {
    try {
      // ========================================================
      // CHECK LOCATION SERVICE
      // ========================================================

      final serviceEnabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Please enable GPS location services',
        );
      }

      // ========================================================
      // CHECK LOCATION PERMISSION
      // ========================================================

      var permission =
          await Geolocator
              .checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator
                .requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is required to map the farm',
        );
      }

      // ========================================================
      // GET CURRENT LOCATION
      // ========================================================

      final position =
          await Geolocator
              .getCurrentPosition();

      final location =
          LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _currentLocation =
            location;

        // Starting a new/redrawn polygon.
        _farmBoundary.clear();
        _farmBoundaryWkt =
            null;
        _farmSizeController.clear();
      });

      // ========================================================
      // OPEN MAP
      // ========================================================

      final boundaryWkt =
          await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        builder: (_) {
          return _FarmMapSheet(
            initialLocation:
                location,

            onBoundaryChanged:
                (points) {
              if (!mounted) {
                return;
              }

              setState(() {
                // ==============================================
                // SAVE POINTS
                // ==============================================

                _farmBoundary
                  ..clear()
                  ..addAll(
                    points,
                  );

                // ==============================================
                // CREATE GEOMETRY IMMEDIATELY
                // ==============================================

                if (points.length >= 3) {
                  final acreage =
                      _areaInAcres(
                    points,
                  );

                  _farmSizeController.text =
                      acreage
                          .toStringAsFixed(
                    2,
                  );

                  // THIS WAS THE IMPORTANT MISSING PART.
                  //
                  // The WKT is now stored as soon as the
                  // polygon contains at least 3 points.

                  _farmBoundaryWkt =
                      _pointsToWktPolygon(
                    points,
                  );

                  debugPrint(
                    '========================================',
                  );

                  debugPrint(
                    'FARM BOUNDARY UPDATED',
                  );

                  debugPrint(
                    'BOUNDARY POINTS: ${points.length}',
                  );

                  debugPrint(
                    'FARM ACREAGE: ${_farmSizeController.text}',
                  );

                  debugPrint(
                    'FARM WKT: $_farmBoundaryWkt',
                  );

                  debugPrint(
                    '========================================',
                  );
                } else {
                  _farmSizeController
                      .clear();

                  _farmBoundaryWkt =
                      null;
                }
              });
            },
          );
        },
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // USE WKT RETURNED BY MAP SHEET
      // ========================================================

      if (boundaryWkt != null &&
          boundaryWkt
              .trim()
              .isNotEmpty) {
        setState(() {
          _farmBoundaryWkt =
              boundaryWkt.trim();
        });

        debugPrint(
          'MAP SHEET RETURNED WKT: '
          '$_farmBoundaryWkt',
        );
      }

      // ========================================================
      // FINAL FALLBACK
      // ========================================================

      if (_farmBoundary.length >= 3 &&
          (_farmBoundaryWkt == null ||
              _farmBoundaryWkt!
                  .trim()
                  .isEmpty)) {
        setState(() {
          _farmBoundaryWkt =
              _pointsToWktPolygon(
            _farmBoundary,
          );
        });
      }

      debugPrint(
        'FINAL FARM WKT: $_farmBoundaryWkt',
      );
    } catch (e) {
      debugPrint(
        'FARM MAPPING ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    }
  }

  // ============================================================
  // CALCULATE FARM AREA
  // ============================================================

  double _areaInAcres(
    List<LatLng> points,
  ) {
    if (points.length < 3) {
      return 0;
    }

    var area = 0.0;

    const earthRadius =
        6378137.0;

    const degreesToRadians =
        0.0174532925199433;

    for (var i = 0;
        i < points.length;
        i++) {
      final a =
          points[i];

      final b =
          points[
              (i + 1) %
                  points.length];

      area +=
          (b.longitude *
                  degreesToRadians) *
              (a.latitude *
                  degreesToRadians) -
          (a.longitude *
                  degreesToRadians) *
              (b.latitude *
                  degreesToRadians);
    }

    final squareMeters =
        area.abs() *
            earthRadius *
            earthRadius /
            2;

    return squareMeters /
        4046.8564224;
  }

  // ============================================================
  // SHOW ERROR
  // ============================================================

  void _showError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
              Text(message),
          backgroundColor:
              Colors.red,
        ),
      );
  }

  // ============================================================
  // SUBMIT FARM
  // ============================================================

  Future<void> _submitFarm() async {
    final l10n =
        AppLocalizations.of(
      context,
    )!;

    if (_isLoading) {
      return;
    }

    // ==========================================================
    // FORM VALIDATION
    // ==========================================================

    final valid =
        _formKey.currentState
                ?.validate() ??
            false;

    if (!valid) {
      return;
    }

    // ==========================================================
    // FARM SIZE
    // ==========================================================

    final acreage =
        double.tryParse(
      _farmSizeController.text
          .trim(),
    );

    if (acreage == null ||
        acreage <= 0) {
      _showError(
        l10n.validFarmSizeRequired,
      );

      return;
    }

    // ==========================================================
    // FARM GEOMETRY
    // ==========================================================

    String? geometry =
        _farmBoundaryWkt
            ?.trim();

    // IMPORTANT:
    //
    // If for any reason the WKT variable was lost but we still
    // have the actual polygon points, regenerate it.

    if ((geometry == null ||
            geometry.isEmpty) &&
        _farmBoundary.length >= 3) {
      geometry =
          _pointsToWktPolygon(
        _farmBoundary,
      );

      _farmBoundaryWkt =
          geometry;
    }

    if (geometry == null ||
        geometry.isEmpty) {
      _showError(
        'Farm boundary is required. '
        'Please map the farm before saving.',
      );

      return;
    }

    if (!geometry
        .toUpperCase()
        .startsWith(
          'POLYGON',
        )) {
      _showError(
        'Invalid farm boundary. '
        'Please redraw the farm boundary.',
      );

      return;
    }

    // ==========================================================
    // BASIC VALUES
    // ==========================================================

    final name =
        _farmNameController.text
            .trim();

    final plantingDate =
        _plantingDateController
            .text
            .trim();

    final farmType =
        _farmTypeController.text
            .trim()
            .toUpperCase();

    if (name.isEmpty) {
      _showError(
        l10n.farmNameRequired,
      );

      return;
    }

    if (plantingDate.isEmpty) {
      _showError(
        l10n.plantingDateRequired,
      );

      return;
    }

    if (farmType.isEmpty) {
      _showError(
        l10n.farmTypeRequired,
      );

      return;
    }

    debugPrint(
      '========================================',
    );

    debugPrint(
      'SUBMITTING FARM',
    );

    debugPrint(
      'NAME: $name',
    );

    debugPrint(
      'ACREAGE: $acreage',
    );

    debugPrint(
      'PLANTING DATE: $plantingDate',
    );

    debugPrint(
      'FARM TYPE: $farmType',
    );

    debugPrint(
      'GEOMETRY: $geometry',
    );

    debugPrint(
      '========================================',
    );

    setState(() {
      _isLoading = true;
    });

    try {
      // ========================================================
      // GET CURRENT USER
      // ========================================================

      Map<String, dynamic>
          currentUserResponse;

      try {
        currentUserResponse =
            await ApiServices
                .getCurrentUser();

        await LocalDataService
            .instance
            .cacheProfile(
          currentUserResponse,
        );

        debugPrint(
          'CURRENT USER LOADED ONLINE',
        );
      } catch (e) {
        debugPrint(
          'CURRENT USER ONLINE ERROR: $e',
        );

        final cachedProfile =
            await LocalDataService
                .instance
                .getCachedProfile();

        if (cachedProfile ==
            null) {
          throw Exception(
            'No cached profile is available offline',
          );
        }

        currentUserResponse =
            cachedProfile;

        debugPrint(
          'USING CACHED USER PROFILE',
        );
      }

      debugPrint(
        'CURRENT USER RESPONSE: '
        '$currentUserResponse',
      );

      // ========================================================
      // NORMALIZE USER RESPONSE
      // ========================================================

      final dynamic rawUser =
          currentUserResponse[
              'data'];

      final Map<String, dynamic>
          user;

      if (rawUser is Map) {
        user =
            Map<String, dynamic>.from(
          rawUser,
        );
      } else {
        user =
            Map<String, dynamic>.from(
          currentUserResponse,
        );
      }

      // ========================================================
      // PROFILE LOCATION
      // ========================================================

      final region =
          user['region']
                  ?.toString()
                  .trim() ??
              '';

      final district =
          user['district']
                  ?.toString()
                  .trim() ??
              '';

      final ward =
          user['ward']
                  ?.toString()
                  .trim() ??
              '';

      final village =
          user['village']
                  ?.toString()
                  .trim() ??
              '';

      if (region.isEmpty ||
          district.isEmpty ||
          ward.isEmpty ||
          village.isEmpty) {
        throw Exception(
          l10n.profileLocationIncomplete,
        );
      }

      debugPrint(
        '========================================',
      );

      debugPrint(
        'FARM PROFILE LOCATION',
      );

      debugPrint(
        'REGION: $region',
      );

      debugPrint(
        'DISTRICT: $district',
      );

      debugPrint(
        'WARD: $ward',
      );

      debugPrint(
        'VILLAGE: $village',
      );

      debugPrint(
        '========================================',
      );

      // ========================================================
      // CREATE FARM
      // ========================================================
      //
      // IMPORTANT:
      //
      // Do NOT send:
      //
      // farmLocation: geometry
      //
      // The current backend/API expects:
      //
      // geometry: "POLYGON ((...))"
      //
      // LocalDataService will:
      //
      // 1. Try the API first.
      // 2. Cache successful server result locally.
      // 3. Save pending only on a real network failure.

      final result =
          await LocalDataService
              .instance
              .createFarm(
        values: {
          'name':
              name,

          'acreage':
              acreage,

          'plantingDate':
              plantingDate,

          // Backend enum.
          'farmType':
              farmType,

          // PostGIS WKT polygon.
          'geometry':
              geometry,

          'region':
              region,

          'district':
              district,

          'ward':
              ward,

          'village':
              village,
        },
      );

      debugPrint(
        '========================================',
      );

      debugPrint(
        'CREATE FARM RESULT: $result',
      );

      debugPrint(
        'PENDING SYNC: '
        '${result['_pendingSync']}',
      );

      debugPrint(
        '========================================',
      );

      if (!mounted) {
        return;
      }

      // ========================================================
      // SUCCESS MESSAGE
      // ========================================================

      final pendingSync =
          result['_pendingSync'] ==
              true;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              pendingSync
                  ? 'Farm saved offline and will sync when connected'
                  : l10n
                      .farmAddedSuccessfully,
            ),
            backgroundColor:
                primaryGreen,
          ),
        );

      // Tell FarmsPage to refresh.
      Navigator.pop(
        context,
        true,
      );
    } catch (e, stackTrace) {
      debugPrint(
        '========================================',
      );

      debugPrint(
        'CREATE FARM ERROR: $e',
      );

      debugPrint(
        'STACK TRACE: $stackTrace',
      );

      debugPrint(
        '========================================',
      );

      if (!mounted) {
        return;
      }

      _showError(
        e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading =
              false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(
      context,
    )!;

    return Scaffold(
      backgroundColor:
          primaryGreen,
      resizeToAvoidBottomInset:
          true,
      body: SafeArea(
        bottom: false,
        child: Container(
          width:
              double.infinity,
          height:
              double.infinity,
          decoration:
              const BoxDecoration(
            color:
                Colors.white,
            borderRadius:
                BorderRadius.only(
              bottomLeft:
                  Radius.circular(
                28,
              ),
              bottomRight:
                  Radius.circular(
                28,
              ),
            ),
          ),
          child: Column(
            children: [
              // =================================================
              // HEADER
              // =================================================

              Container(
                width:
                    double.infinity,
                height:
                    52,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal:
                      14,
                ),
                decoration:
                    const BoxDecoration(
                  color:
                      primaryGreen,
                  // borderRadius:
                      // BorderRadius.only(
                    // bottomLeft:
                        // Radius.circular(
                      // 18,
                    // ),
                    // bottomRight:
                        // Radius.circular(
                      // 18,
                    // ),
                  // ),
                ),
                alignment:
                    Alignment
                        .centerLeft,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      borderRadius:
                          BorderRadius
                              .circular(
                        20,
                      ),
                      child:
                          const Padding(
                        padding:
                            EdgeInsets
                                .all(
                          3,
                        ),
                        child:
                            Icon(
                          Icons
                              .arrow_back_ios_new,
                          color:
                              Colors
                                  .white,
                          size:
                              14,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width:
                          7,
                    ),
                    Text(
                      l10n.addFarm,
                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                        fontSize:
                            AppTextStyles
                                .body,
                        fontWeight:
                            FontWeight
                                .w700,
                      ),
                    ),
                  ],
                ),
              ),

              // =================================================
              // FORM
              // =================================================

              Expanded(
                child:
                    SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    18,
                    42,
                    18,
                    30,
                  ),
                  child:
                      Form(
                    key:
                        _formKey,
                    child:
                        Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        // =======================================
                        // FARM NAME
                        // =======================================

                        _buildLabel(
                          l10n.farmName,
                        ),

                        const SizedBox(
                          height:
                              7,
                        ),

                        _buildField(
                          controller:
                              _farmNameController,
                          hint:
                              l10n.farmName,
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return l10n
                                  .farmNameRequired;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height:
                              18,
                        ),

                        // =======================================
                        // PLANTING DATE
                        // =======================================

                        _buildLabel(
                          l10n.plantingDate,
                        ),

                        const SizedBox(
                          height:
                              7,
                        ),

                        _buildField(
                          controller:
                              _plantingDateController,
                          hint:
                              l10n.plantingDate,
                          readOnly:
                              true,
                          onTap:
                              _selectPlantingDate,
                          suffixIcon:
                              const Icon(
                            Icons
                                .calendar_today_outlined,
                            size:
                                18,
                            color:
                                primaryGreen,
                          ),
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return l10n
                                  .plantingDateRequired;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height:
                              18,
                        ),

                        // =======================================
                        // FARM TYPE
                        // =======================================

                        _buildLabel(
                          l10n.farmType,
                        ),

                        const SizedBox(
                          height:
                              7,
                        ),

                        _buildFarmTypeDropdown(
                          context,
                        ),

                        const SizedBox(
                          height:
                              18,
                        ),

                        // =======================================
                        // FARM SIZE
                        // =======================================

                        _buildLabel(
                          l10n.farmSize,
                        ),

                        const SizedBox(
                          height:
                              7,
                        ),

                        SizedBox(
                          width:
                              double.infinity,
                          height:
                              42,
                          child:
                              OutlinedButton
                                  .icon(
                            onPressed:
                                _isLoading
                                    ? null
                                    : _startFarmMapping,
                            icon:
                                const Icon(
                              Icons
                                  .map_outlined,
                              size:
                                  18,
                            ),
                            label:
                                Text(
                              _farmBoundary
                                          .length >=
                                      3
                                  ? 'Redraw Farm Boundary'
                                  : 'Draw Farm Boundary on Map',
                            ),
                            style:
                                OutlinedButton
                                    .styleFrom(
                              foregroundColor:
                                  primaryGreen,
                              side:
                                  const BorderSide(
                                color:
                                    primaryGreen,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height:
                              7,
                        ),

                        _buildField(
                          controller:
                              _farmSizeController,
                          hint:
                              l10n.farmSize,
                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal:
                                true,
                          ),
                          readOnly:
                              true,
                          suffixText:
                              l10n.acres,
                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return l10n
                                  .farmSizeRequired;
                            }

                            final size =
                                double.tryParse(
                              value
                                  .trim(),
                            );

                            if (size ==
                                    null ||
                                size <=
                                    0) {
                              return l10n
                                  .validFarmSizeRequired;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(
                          height:
                              18,
                        ),

                        // =======================================
                        // SUBMIT
                        // =======================================

                        SizedBox(
                          width:
                              double.infinity,
                          height:
                              46,
                          child:
                              ElevatedButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : _submitFarm,
                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  primaryGreen,
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  primaryGreen
                                      .withValues(
                                alpha:
                                    0.60,
                              ),
                              elevation:
                                  0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  8,
                                ),
                              ),
                            ),
                            child:
                                _isLoading
                                    ? const SizedBox(
                                        width:
                                            19,
                                        height:
                                            19,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2,
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : Text(
                                        l10n
                                            .submitFarm,
                                        style:
                                            const TextStyle(
                                          fontSize:
                                              AppTextStyles.body,
                                          fontWeight:
                                              FontWeight.w700,
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

  Widget _buildLabel(
    String label,
  ) {
    return Text(
      label,
      style:
          const TextStyle(
        fontSize:
            AppTextStyles.body,
        fontWeight:
            FontWeight.w600,
        color:
            Color(
          0xFF304438,
        ),
      ),
    );
  }

  // ============================================================
  // FARM TYPE DROPDOWN
  // ============================================================

  Widget _buildFarmTypeDropdown(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(
      context,
    )!;

    return DropdownButtonFormField<String>(
      value:
          _farmTypeController
                  .text
                  .isEmpty
              ? null
              : _farmTypeController
                  .text,
      isExpanded:
          true,
      decoration:
          InputDecoration(
        hintText:
            l10n.selectFarmType,
        hintStyle:
            TextStyle(
          fontSize:
              AppTextStyles.bodySmall,
          color:
              Colors.grey.shade500,
        ),
        filled:
            true,
        fillColor:
            fieldBackground,
        isDense:
            true,
        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal:
              13,
          vertical:
              14,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          borderSide:
              const BorderSide(
            color:
                fieldBorder,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          borderSide:
              const BorderSide(
            color:
                primaryGreen,
            width:
                1.2,
          ),
        ),
        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          borderSide:
              const BorderSide(
            color:
                Colors.red,
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          borderSide:
              const BorderSide(
            color:
                Colors.red,
          ),
        ),
        errorStyle:
            const TextStyle(
          fontSize:
              AppTextStyles.bodySmall,
        ),
      ),

      // Backend enum values remain unchanged.
      // Only labels are translated.

      items: [
        DropdownMenuItem(
          value:
              'NEW',
          child:
              Text(
            l10n.newFarm,
            style:
                const TextStyle(
              fontSize:
                  AppTextStyles.body,
            ),
          ),
        ),
        DropdownMenuItem(
          value:
              'PRODUCTION',
          child:
              Text(
            l10n.productionFarm,
            style:
                const TextStyle(
              fontSize:
                  AppTextStyles.body,
            ),
          ),
        ),
      ],
      onChanged:
          (value) {
        if (value ==
            null) {
          return;
        }

        setState(() {
          _farmTypeController
                  .text =
              value;
        });
      },
      validator:
          (value) {
        if (value ==
                null ||
            value.isEmpty) {
          return l10n
              .farmTypeRequired;
        }

        return null;
      },
    );
  }

  // ============================================================
  // FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController
        controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)?
        validator,
    bool readOnly =
        false,
    VoidCallback? onTap,
    int maxLines =
        1,
    int minLines =
        1,
    String? suffixText,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller:
          controller,
      keyboardType:
          keyboardType,
      validator:
          validator,
      readOnly:
          readOnly,
      onTap:
          onTap,
      maxLines:
          maxLines,
      minLines:
          minLines,
      style:
          const TextStyle(
        fontSize:
            AppTextStyles.bodySmall,
        color:
            Color(
          0xFF304438,
        ),
      ),
      decoration:
          InputDecoration(
        hintText:
            hint,
        hintStyle:
            TextStyle(
          fontSize:
              AppTextStyles.bodySmall,
          color:
              Colors.grey.shade500,
        ),
        suffixText:
            suffixText,
        suffixIcon:
            suffixIcon,
        suffixStyle:
            const TextStyle(
          fontSize:
              AppTextStyles.bodySmall,
          fontWeight:
              FontWeight.w600,
          color:
              Color(
            0xFF687A70,
          ),
        ),
        filled:
            true,
        fillColor:
            fieldBackground,
        isDense:
            true,
        contentPadding:
            EdgeInsets.symmetric(
          horizontal:
              13,
          vertical:
              maxLines > 1
                  ? 15
                  : 14,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          borderSide:
              const BorderSide(
            color:
                fieldBorder,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          borderSide:
              const BorderSide(
            color:
                primaryGreen,
            width:
                1.2,
          ),
        ),
        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          borderSide:
              const BorderSide(
            color:
                Colors.red,
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(
            8,
          ),
          borderSide:
              const BorderSide(
            color:
                Colors.red,
          ),
        ),
        errorStyle:
            const TextStyle(
          fontSize:
              AppTextStyles.bodySmall,
        ),
      ),
    );
  }
}

// ==================================================================
// FARM MAP SHEET
// ==================================================================

class _FarmMapSheet
    extends StatefulWidget {
  const _FarmMapSheet({
    required this.initialLocation,
    required this.onBoundaryChanged,
  });

  final LatLng initialLocation;

  final ValueChanged<List<LatLng>>
      onBoundaryChanged;

  @override
  State<_FarmMapSheet>
      createState() =>
          _FarmMapSheetState();
}

class _FarmMapSheetState
    extends State<_FarmMapSheet> {
  static const Color primaryGreen =
      Color(0xFF087A2F);

  final List<LatLng> _points =
      [];

  GoogleMapController?
      _mapController;

  LatLng? _gpsLocation;

  bool _isLocating =
      false;

  // ============================================================
  // ADD BOUNDARY POINT
  // ============================================================

  void _addPoint(
    LatLng point,
  ) {
    setState(() {
      _points.add(
        point,
      );
    });

    widget.onBoundaryChanged(
      List<LatLng>.from(
        _points,
      ),
    );
  }

  // ============================================================
  // CLEAR BOUNDARY
  // ============================================================

  void _clearPoints() {
    setState(() {
      _points.clear();
    });

    widget.onBoundaryChanged(
      const [],
    );
  }

  // ============================================================
  // GET GPS LOCATION
  // ============================================================

  Future<void> _pickGpsLocation() async {
    setState(() {
      _isLocating =
          true;
    });

    try {
      final enabled =
          await Geolocator
              .isLocationServiceEnabled();

      if (!enabled) {
        throw Exception(
          'Please enable GPS location services',
        );
      }

      var permission =
          await Geolocator
              .checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
            await Geolocator
                .requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is required',
        );
      }

      final position =
          await Geolocator
              .getCurrentPosition();

      final location =
          LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _gpsLocation =
            location;
      });

      await _mapController
          ?.animateCamera(
        CameraUpdate
            .newLatLngZoom(
          location,
          18,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text(
            e
                .toString()
                .replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
          backgroundColor:
              Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLocating =
              false;
        });
      }
    }
  }

  // ============================================================
  // CONVERT TO WKT
  // ============================================================

  String _toWktPolygon() {
    if (_points.length < 3) {
      throw Exception(
        'At least three boundary points are required',
      );
    }

    final closedPoints =
        List<LatLng>.from(
      _points,
    );

    final first =
        closedPoints.first;

    final last =
        closedPoints.last;

    if (first.latitude != last.latitude ||
        first.longitude != last.longitude) {
      closedPoints.add(
        first,
      );
    }

    final coordinates =
        closedPoints
            .map(
              (point) =>
                  '${point.longitude} ${point.latitude}',
            )
            .join(', ');

    return 'POLYGON (($coordinates))';
  }

  // ============================================================
  // FINISH MAPPING
  // ============================================================

  void _finish() {
    if (_points.length < 3) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text(
            'Tap at least three points on the map',
          ),
          backgroundColor:
              Colors.red,
        ),
      );

      return;
    }

    final wkt =
        _toWktPolygon();

    // Send the points to AddFarmPage one last time.
    widget.onBoundaryChanged(
      List<LatLng>.from(
        _points,
      ),
    );

    debugPrint(
      '========================================',
    );

    debugPrint(
      'FARM MAP FINISHED',
    );

    debugPrint(
      'POINTS: ${_points.length}',
    );

    debugPrint(
      'WKT: $wkt',
    );

    debugPrint(
      '========================================',
    );

    Navigator.pop(
      context,
      wkt,
    );
  }

  // ============================================================
  // BUILD MAP
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final polygon =
        _points.length >= 3
            ? <Polygon>{
                Polygon(
                  polygonId:
                      const PolygonId(
                    'farm-boundary',
                  ),
                  points:
                      _points,
                  fillColor:
                      primaryGreen
                          .withOpacity(
                    0.20,
                  ),
                  strokeColor:
                      primaryGreen,
                  strokeWidth:
                      2,
                ),
              }
            : <Polygon>{};

    return SafeArea(
      child:
          SizedBox(
        height:
            MediaQuery.sizeOf(
                  context,
                ).height *
                0.78,
        child:
            Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                16,
                10,
                8,
                8,
              ),
              child:
                  Row(
                children: [
                  const Expanded(
                    child:
                        Text(
                      'Draw Farm Boundary',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  // GPS
                  IconButton(
                    onPressed:
                        _isLocating
                            ? null
                            : _pickGpsLocation,
                    tooltip:
                        'Use GPS location',
                    icon:
                        _isLocating
                            ? const SizedBox(
                                width:
                                    18,
                                height:
                                    18,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .my_location,
                              ),
                  ),

                  // CLEAR
                  TextButton(
                    onPressed:
                        _clearPoints,
                    child:
                        const Text(
                      'Clear',
                    ),
                  ),

                  // DONE
                  ElevatedButton(
                    onPressed:
                        _finish,
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          primaryGreen,
                      foregroundColor:
                          Colors.white,
                    ),
                    child:
                        const Text(
                      'Done',
                    ),
                  ),
                ],
              ),
            ),

            // ===================================================
            // MAP
            // ===================================================

            Expanded(
              child:
                  GoogleMap(
                initialCameraPosition:
                    CameraPosition(
                  target:
                      widget.initialLocation,
                  zoom:
                      17,
                ),

                myLocationEnabled:
                    true,

                myLocationButtonEnabled:
                    true,

                onMapCreated:
                    (controller) {
                  _mapController =
                      controller;
                },

                polygons:
                    polygon,

                markers: {
                  // Current GPS marker.
                  if (_gpsLocation !=
                      null)
                    Marker(
                      markerId:
                          const MarkerId(
                        'selected-gps-location',
                      ),
                      position:
                          _gpsLocation!,
                      icon:
                          BitmapDescriptor
                              .defaultMarkerWithHue(
                        BitmapDescriptor
                            .hueAzure,
                      ),
                    ),

                  // Boundary points.
                  for (var i = 0;
                      i <
                          _points
                              .length;
                      i++)
                    Marker(
                      markerId:
                          MarkerId(
                        'boundary-$i',
                      ),
                      position:
                          _points[i],
                    ),
                },

                // Tap map to add polygon points.
                onTap:
                    _addPoint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}