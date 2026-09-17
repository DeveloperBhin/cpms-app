import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../l10n/app_localizations.dart';
import '../services/api_services/tree_api_services.dart';

class AddTreePage extends StatefulWidget {
  final String farmId;
  final String blockId;
  final String blockName;

  const AddTreePage({
    super.key,
    required this.farmId,
    required this.blockId,
    required this.blockName,
  });

  @override
  State<AddTreePage> createState() =>
      _AddTreePageState();
}

class _AddTreePageState extends State<AddTreePage> {
  final _formKey = GlobalKey<FormState>();

  final _varietyController =
      TextEditingController();

  final _plantingYearController =
      TextEditingController();

  final _latitudeController =
      TextEditingController();

  final _longitudeController =
      TextEditingController();

  final _notesController =
      TextEditingController();

  bool _isLoading = false;

  // Keep backend enum values here.
  String _status = 'HEALTHY';

  static const Color primaryGreen =
      Color(0xFF087A2F);

  static const Color fieldBackground =
      Color(0xFFEAF4EE);

  static const Color fieldBorder =
      Color(0xFFD7E9DD);

  static const Color textDark =
      Color(0xFF304438);

  static const Color textGrey =
      Color(0xFF718078);

  static const List<String> statuses = [
    'HEALTHY',
    'DISEASED',
    'DEAD',
  ];

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _varietyController.dispose();
    _plantingYearController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();

    super.dispose();
  }

  // ============================================================
  // DISPLAY IDS
  // ============================================================

  String get _farmDisplayId {
    final id =
        int.tryParse(widget.farmId);

    if (id == null) {
      return widget.farmId;
    }

    return 'FM-${id.toString().padLeft(4, '0')}';
  }

  String get _blockDisplayId {
    final id =
        int.tryParse(widget.blockId);

    if (id == null) {
      return widget.blockId;
    }

    return 'BL-${id.toString().padLeft(4, '0')}';
  }

  // ============================================================
  // LOCALIZED STATUS
  // ============================================================

  String _statusLabel(
    BuildContext context,
    String status,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    switch (status.toUpperCase()) {
      case 'HEALTHY':
        return l10n.healthy;

      case 'DISEASED':
        return l10n.diseased;

      case 'DEAD':
        return l10n.dead;

      default:
        return status;
    }
  }

  // ============================================================
  // SELECT PLANTING YEAR
  // ============================================================

  Future<void> _selectPlantingYear() async {
    final l10n =
        AppLocalizations.of(context)!;

    final currentYear =
        DateTime.now().year;

    final DateTime? date =
        await showDatePicker(
      context: context,
      initialDate:
          DateTime(currentYear),
      firstDate:
          DateTime(1950),
      lastDate:
          DateTime(currentYear),
      helpText:
          l10n.selectPlantingYear,
    );

    if (date == null ||
        !mounted) {
      return;
    }

    setState(() {
      _plantingYearController.text =
          date.year.toString();
    });
  }

  // ============================================================
  // SUBMIT TREE
  // ============================================================

  Future<void> _submitTree() async {
    final l10n =
        AppLocalizations.of(context)!;

    if (_isLoading) {
      return;
    }

    final valid =
        _formKey.currentState
                ?.validate() ??
            false;

    if (!valid) {
      return;
    }

    final plantingYear =
        int.tryParse(
      _plantingYearController.text
          .trim(),
    );

    if (plantingYear == null) {
      _showError(
        l10n.validPlantingYearRequired,
      );
      return;
    }

    final latitudeText =
        _latitudeController.text
            .trim();

    final longitudeText =
        _longitudeController.text
            .trim();

    double? latitude;
    double? longitude;

    // ============================================================
    // LATITUDE
    // ============================================================

    if (latitudeText.isNotEmpty) {
      latitude =
          double.tryParse(
        latitudeText,
      );

      if (latitude == null ||
          latitude < -90 ||
          latitude > 90) {
        _showError(
          l10n.validLatitudeRequired,
        );
        return;
      }
    }

    // ============================================================
    // LONGITUDE
    // ============================================================

    if (longitudeText.isNotEmpty) {
      longitude =
          double.tryParse(
        longitudeText,
      );

      if (longitude == null ||
          longitude < -180 ||
          longitude > 180) {
        _showError(
          l10n.validLongitudeRequired,
        );
        return;
      }
    }

    // Require both coordinates or neither.
    if ((latitude == null &&
            longitude != null) ||
        (latitude != null &&
            longitude == null)) {
      _showError(
        l10n.bothCoordinatesRequired,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result =
          await TreeApiServices.createTree(
        farmId:
            widget.farmId,

        blockId:
            widget.blockId,

        variety:
            _varietyController.text
                .trim(),

        plantingYear:
            plantingYear,

        // Already the exact backend enum.
        status:
            _status,

        latitude:
            latitude,

        longitude:
            longitude,

        notes:
            _notesController.text
                .trim(),
      );

      debugPrint(
        'TREE CREATED SUCCESSFULLY: $result',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n.treeAddedSuccessfully,
          ),
          backgroundColor:
              primaryGreen,
        ),
      );

      // Return true so BlockDetailsPage reloads trees.
      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      debugPrint(
        'CREATE TREE ERROR: $e',
      );

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
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _showError(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        backgroundColor:
            Colors.red,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

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
            color: Colors.white,

            borderRadius:
                BorderRadius.only(
              bottomLeft:
                  Radius.circular(28),
              bottomRight:
                  Radius.circular(28),
            ),
          ),

          child: Column(
            children: [
              _buildHeader(),

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
                    25,
                    18,
                    30,
                  ),

                  child: Form(
                    key:
                        _formKey,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        _buildBlockInformation(),

                        const SizedBox(
                          height: 22,
                        ),

                        // =======================================
                        // VARIETY
                        // =======================================

                        _fieldLabel(
                          l10n.cashewVariety,
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        _buildField(
                          controller:
                              _varietyController,

                          hint:
                              l10n.cashewVarietyHint,

                          textInputAction:
                              TextInputAction.next,

                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return l10n
                                  .cashewVarietyRequired;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =======================================
                        // PLANTING YEAR
                        // =======================================

                        _fieldLabel(
                          l10n.plantingYear,
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        _buildField(
                          controller:
                              _plantingYearController,

                          hint:
                              l10n.plantingYearHint,

                          readOnly:
                              true,

                          onTap:
                              _isLoading
                                  ? null
                                  : _selectPlantingYear,

                          suffixIcon:
                              Icons.calendar_month_outlined,

                          validator:
                              (value) {
                            if (value ==
                                    null ||
                                value
                                    .trim()
                                    .isEmpty) {
                              return l10n
                                  .plantingYearRequired;
                            }

                            final year =
                                int.tryParse(
                              value
                                  .trim(),
                            );

                            if (year ==
                                null) {
                              return l10n
                                  .invalidPlantingYear;
                            }

                            final currentYear =
                                DateTime.now()
                                    .year;

                            if (year <
                                    1950 ||
                                year >
                                    currentYear) {
                              return l10n
                                  .validPlantingYearRequired;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =======================================
                        // STATUS
                        // =======================================

                        _fieldLabel(
                          l10n.treeStatus,
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        DropdownButtonFormField<
                            String>(
                          value:
                              _status,

                          isExpanded:
                              true,

                          decoration:
                              _fieldDecoration(
                            l10n.treeStatusHint,
                          ),

                          items: statuses
                              .map(
                                (status) =>
                                    DropdownMenuItem<
                                        String>(
                                  value:
                                      status,

                                  child:
                                      Text(
                                    _statusLabel(
                                      context,
                                      status,
                                    ),

                                    style:
                                        const TextStyle(
                                    fontSize: AppTextStyles.bodySmall,

                                      color:
                                          textDark,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),

                          onChanged:
                              _isLoading
                                  ? null
                                  : (value) {
                                      if (value ==
                                          null) {
                                        return;
                                      }

                                      setState(
                                        () {
                                          _status =
                                              value;
                                        },
                                      );
                                    },
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // =======================================
                        // LOCATION
                        // =======================================

                        Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,

                              decoration:
                                  BoxDecoration(
                                color:
                                    primaryGreen
                                        .withOpacity(
                                  0.10,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  7,
                                ),
                              ),

                              child:
                                  const Icon(
                                Icons
                                    .location_on_outlined,
                                color:
                                    primaryGreen,
                                size: 17,
                              ),
                            ),

                            const SizedBox(
                              width: 9,
                            ),

                            Expanded(
                              child:
                                  Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [
                                  Text(
                                    l10n.treeLocation,

                                    style:
                                        const TextStyle(
                                      color:
                                          primaryGreen,
                                      fontSize:
                                          AppTextStyles.body,
                                      fontWeight:
                                          FontWeight
                                              .w700,
                                    ),
                                  ),

                                  const SizedBox(
                                    height:
                                        2,
                                  ),

                                  Text(
                                    l10n.treeLocationDescription,

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
                          ],
                        ),

                        const SizedBox(
                          height: 13,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child:
                                  _buildField(
                                controller:
                                    _latitudeController,

                                hint:
                                    l10n.latitude,

                                keyboardType:
                                    const TextInputType
                                        .numberWithOptions(
                                  decimal:
                                      true,
                                  signed:
                                      true,
                                ),

                                textInputAction:
                                    TextInputAction
                                        .next,

                                validator:
                                    _latitudeValidator,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Expanded(
                              child:
                                  _buildField(
                                controller:
                                    _longitudeController,

                                hint:
                                    l10n.longitude,

                                keyboardType:
                                    const TextInputType
                                        .numberWithOptions(
                                  decimal:
                                      true,
                                  signed:
                                      true,
                                ),

                                textInputAction:
                                    TextInputAction
                                        .next,

                                validator:
                                    _longitudeValidator,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // =======================================
                        // NOTES
                        // =======================================

                        _fieldLabel(
                          l10n.notes,
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        _buildField(
                          controller:
                              _notesController,

                          hint:
                              l10n.treeNotesHint,

                          minLines:
                              4,

                          maxLines:
                              4,

                          textInputAction:
                              TextInputAction
                                  .newline,
                        ),

                        const SizedBox(
                          height: 40,
                        ),

                        // =======================================
                        // SUBMIT
                        // =======================================

                        SizedBox(
                          width:
                              double.infinity,
                          height: 46,

                          child:
                              ElevatedButton.icon(
                            onPressed:
                                _isLoading
                                    ? null
                                    : _submitTree,

                            icon:
                                _isLoading
                                    ? const SizedBox
                                        .shrink()
                                    : const Icon(
                                        Icons
                                            .park_outlined,
                                        size:
                                            16,
                                      ),

                            label:
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
                                        l10n.addTree,

                                        style:
                                            const TextStyle(
                                          fontSize:
                                              AppTextStyles.body,
                                          fontWeight:
                                              FontWeight.w700,
                                        ),
                                      ),

                            style:
                                ElevatedButton
                                    .styleFrom(
                              backgroundColor:
                                  primaryGreen,

                              foregroundColor:
                                  Colors.white,

                              disabledBackgroundColor:
                                  primaryGreen
                                      .withOpacity(
                                0.6,
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
                          ),
                        ),

                        const SizedBox(
                          height: 20,
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
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      height: 52,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 14,
      ),

      decoration:
          const BoxDecoration(
        color: primaryGreen,

        borderRadius:
            BorderRadius.only(
          bottomLeft:
              Radius.circular(18),
          bottomRight:
              Radius.circular(18),
        ),
      ),

      child: Row(
        children: [
          InkWell(
            onTap:
                _isLoading
                    ? null
                    : () {
                        Navigator.pop(
                          context,
                        );
                      },

            borderRadius:
                BorderRadius.circular(
              20,
            ),

            child:
                const Padding(
              padding:
                  EdgeInsets.all(3),

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
            l10n.addTree,

            style:
                const TextStyle(
              color:
                  Colors.white,
              fontSize: AppTextStyles.bodyLarge,
              fontWeight:
                  FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BLOCK INFORMATION
  // ============================================================

  Widget _buildBlockInformation() {
    final l10n =
        AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(13),

      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF4F9F5),

        borderRadius:
            BorderRadius.circular(8),

        border:
            Border.all(
          color:
              fieldBorder,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 39,
            height: 39,

            decoration:
                BoxDecoration(
              color:
                  primaryGreen
                      .withOpacity(
                0.10,
              ),

              borderRadius:
                  BorderRadius
                      .circular(
                8,
              ),
            ),

            child:
                const Icon(
              Icons.grid_view_rounded,
              color:
                  primaryGreen,
              size: 19,
            ),
          ),

          const SizedBox(
            width: 11,
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [
                Text(
                  l10n.addingTreeTo,

                  style:
                      const TextStyle(
                    color:
                        textGrey,
                    fontSize:
                        AppTextStyles.bodySmall,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  widget.blockName,

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

                const SizedBox(
                  height: 4,
                ),

                Text(
                  '${l10n.blockId}: '
                  '$_blockDisplayId',

                  style:
                      const TextStyle(
                    color:
                        textGrey,
                    fontSize:
                        AppTextStyles.bodySmall,
                  ),
                ),

                const SizedBox(
                  height: 2,
                ),

                Text(
                  '${l10n.farmId}: '
                  '$_farmDisplayId',

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
        ],
      ),
    );
  }

  // ============================================================
  // VALIDATORS
  // ============================================================

  String? _latitudeValidator(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return null;
    }

    final latitude =
        double.tryParse(
      value.trim(),
    );

    if (latitude == null ||
        latitude < -90 ||
        latitude > 90) {
      return AppLocalizations.of(
        context,
      )!
          .invalidLatitude;
    }

    return null;
  }

  String? _longitudeValidator(
    String? value,
  ) {
    if (value == null ||
        value.trim().isEmpty) {
      return null;
    }

    final longitude =
        double.tryParse(
      value.trim(),
    );

    if (longitude == null ||
        longitude < -180 ||
        longitude > 180) {
      return AppLocalizations.of(
        context,
      )!
          .invalidLongitude;
    }

    return null;
  }

  // ============================================================
  // FIELD LABEL
  // ============================================================

  Widget _fieldLabel(
    String label,
  ) {
    return Text(
      label,

      style:
          const TextStyle(
        color: textDark,
        fontSize: AppTextStyles.bodySmall,
        fontWeight:
            FontWeight.w600,
      ),
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
    bool readOnly = false,
    VoidCallback? onTap,
    int minLines = 1,
    int maxLines = 1,
    TextInputAction?
        textInputAction,
    IconData? suffixIcon,
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

      minLines:
          minLines,

      maxLines:
          maxLines,

      textInputAction:
          textInputAction,

      enabled:
          !_isLoading,

      style:
          const TextStyle(
        fontSize: AppTextStyles.body,
        color: textDark,
      ),

      decoration:
          _fieldDecoration(
        hint,
      ).copyWith(
        contentPadding:
            EdgeInsets.symmetric(
          horizontal: 13,
          vertical:
              maxLines > 1
                  ? 15
                  : 14,
        ),

        suffixIcon:
            suffixIcon == null
                ? null
                : Icon(
                    suffixIcon,
                    size: 17,
                    color:
                        textGrey,
                  ),
      ),
    );
  }

  // ============================================================
  // FIELD DECORATION
  // ============================================================

  InputDecoration _fieldDecoration(
    String hint,
  ) {
    return InputDecoration(
      hintText:
          hint,

      hintStyle:
          TextStyle(
        fontSize: AppTextStyles.bodySmall,
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
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 14,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),

        borderSide:
            const BorderSide(
          color:
              fieldBorder,
        ),
      ),

      disabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),

        borderSide:
            const BorderSide(
          color:
              fieldBorder,
        ),
      ),

      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),

        borderSide:
            const BorderSide(
          color:
              primaryGreen,
          width: 1.2,
        ),
      ),

      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),

        borderSide:
            const BorderSide(
          color:
              Colors.red,
        ),
      ),

      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(8),

        borderSide:
            const BorderSide(
          color:
              Colors.red,
        ),
      ),

      errorStyle:
          const TextStyle(
        fontSize: AppTextStyles.bodySmall,
      ),
    );
  }

  // ============================================================
  // GAP
  // ============================================================

  Widget _gap() {
    return const SizedBox(
      height: 14,
    );
  }
}