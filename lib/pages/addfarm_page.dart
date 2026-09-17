import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../l10n/app_localizations.dart';
import '../services/api_services/api_services.dart';
import '../services/api_services/farm_api_services.dart';

class AddFarmPage extends StatefulWidget {
  const AddFarmPage({
    super.key,
  });

  @override
  State<AddFarmPage> createState() =>
      _AddFarmPageState();
}

class _AddFarmPageState
    extends State<AddFarmPage> {
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

      // Flutter's date picker automatically follows
      // MaterialApp's current locale.
      locale:
          Localizations.localeOf(
        context,
      ),
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
  // SUBMIT FARM
  // ============================================================

  Future<void> _submitFarm() async {
    final l10n =
        AppLocalizations.of(context)!;

    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final acreage =
        double.tryParse(
      _farmSizeController.text
          .trim(),
    );

    if (acreage == null ||
        acreage <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .validFarmSizeRequired,
          ),
          backgroundColor:
              Colors.red,
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

      final currentUserResponse =
          await ApiServices
              .getCurrentUser();

      debugPrint(
        'CURRENT USER RESPONSE: '
        '$currentUserResponse',
      );

      // Support either:
      // { "data": {...} }
      // or:
      // { ...user fields... }

      final dynamic rawUser =
          currentUserResponse[
              'data'];

      final Map<String, dynamic>
          user;

      if (rawUser is Map) {
        user =
            Map<String, dynamic>
                .from(
          rawUser,
        );
      } else {
        user =
            currentUserResponse;
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
          l10n
              .profileLocationIncomplete,
        );
      }

      // ========================================================
      // CREATE FARM
      // ========================================================

      final result =
          await FarmApiServices
              .createFarm(
        name:
            _farmNameController
                .text
                .trim(),

        acreage: acreage,

        plantingDate:
            _plantingDateController
                .text
                .trim(),

        farmType:
            _farmTypeController
                .text
                .trim()
                .toUpperCase(),

        farmLocation:
            _notesController
                .text
                .trim(),

        region: region,
        district: district,
        ward: ward,
        village: village,

        // Keep these only if your current
        // FarmApiServices signature still requires them.
        latitude: 0.0,
        longitude: 0.0,
      );

      debugPrint(
        'CREATE FARM RESULT: '
        '$result',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .farmAddedSuccessfully,
          ),
          backgroundColor:
              primaryGreen,
        ),
      );

      // Tell FarmsPage to reload.
      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      debugPrint(
        'CREATE FARM ERROR: $e',
      );

      if (!mounted) return;

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

                height: 52,

                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 14,
                ),

                decoration:
                    const BoxDecoration(
                  color:
                      primaryGreen,

                  borderRadius:
                      BorderRadius.only(
                    bottomLeft:
                        Radius.circular(
                      18,
                    ),
                    bottomRight:
                        Radius.circular(
                      18,
                    ),
                  ),
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

                        child: Icon(
                          Icons
                              .arrow_back_ios_new,
                          color:
                              Colors
                                  .white,
                          size: 14,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 7,
                    ),

                    Text(
                      l10n.addFarm,

                      style:
                          const TextStyle(
                        color:
                            Colors
                                .white,
                        fontSize:
                            AppTextStyles.body,
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

                  child: Form(
                    key:
                        _formKey,

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        // =======================================
                        // FARM NAME
                        // =======================================

                        _buildLabel(
                          l10n
                              .farmName,
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        _buildField(
                          controller:
                              _farmNameController,

                          hint:
                              l10n
                                  .farmName,

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
                          height: 18,
                        ),

                        // =======================================
                        // PLANTING DATE
                        // =======================================

                        _buildLabel(
                          l10n
                              .plantingDate,
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        _buildField(
                          controller:
                              _plantingDateController,

                          hint:
                              l10n
                                  .plantingDate,

                          readOnly:
                              true,

                          onTap:
                              _selectPlantingDate,

                          suffixIcon:
                              const Icon(
                            Icons
                                .calendar_today_outlined,
                            size: 18,
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
                          height: 18,
                        ),

                        // =======================================
                        // FARM TYPE
                        // =======================================

                        _buildLabel(
                          l10n
                              .farmType,
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        _buildFarmTypeDropdown(
                          context,
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // =======================================
                        // FARM SIZE
                        // =======================================

                        _buildLabel(
                          l10n
                              .farmSize,
                        ),

                        const SizedBox(
                          height: 7,
                        ),

                        _buildField(
                          controller:
                              _farmSizeController,

                          hint:
                              l10n
                                  .farmSize,

                          keyboardType:
                              const TextInputType
                                  .numberWithOptions(
                            decimal:
                                true,
                          ),

                          suffixText:
                              l10n
                                  .acres,

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
                                double
                                    .tryParse(
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
                          height: 40,
                        ),

                        // =======================================
                        // SUBMIT
                        // =======================================

                        SizedBox(
                          width:
                              double
                                  .infinity,

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
                                  Colors
                                      .white,

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
        fontSize: AppTextStyles.body,
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
        AppLocalizations.of(context)!;

    return DropdownButtonFormField<
        String>(
      value:
          _farmTypeController
                  .text
                  .isEmpty
              ? null
              : _farmTypeController
                  .text,

      isExpanded: true,

      decoration:
          InputDecoration(
        hintText:
            l10n.selectFarmType,

        hintStyle:
            TextStyle(
          fontSize: AppTextStyles.bodySmall,
          color:
              Colors.grey.shade500,
        ),

        filled: true,

        fillColor:
            fieldBackground,

        isDense: true,

        contentPadding:
            const EdgeInsets
                .symmetric(
          horizontal: 13,
          vertical: 14,
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
            width: 1.2,
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
          fontSize: AppTextStyles.bodySmall,
        ),
      ),

      // IMPORTANT:
      // Values remain backend enum values.
      // Only labels are translated.
      items: [
        DropdownMenuItem(
          value: 'NEW',
          child: Text(
            l10n.newFarm,
            style:
                const TextStyle(
              fontSize: AppTextStyles.body,
            ),
          ),
        ),

        DropdownMenuItem(
          value:
              'PRODUCTION',
          child: Text(
            l10n
                .productionFarm,
            style:
                const TextStyle(
              fontSize: AppTextStyles.body,
            ),
          ),
        ),
      ],

      onChanged: (value) {
        if (value == null) {
          return;
        }

        setState(() {
          _farmTypeController
                  .text =
              value;
        });
      },

      validator: (value) {
        if (value == null ||
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
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    int minLines = 1,
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
        fontSize: AppTextStyles.bodySmall,
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
          fontSize: AppTextStyles.bodySmall,
          color:
              Colors.grey.shade500,
        ),

        suffixText:
            suffixText,

        suffixIcon:
            suffixIcon,

        suffixStyle:
            const TextStyle(
          fontSize: AppTextStyles.bodySmall,
          fontWeight:
              FontWeight.w600,
          color:
              Color(
            0xFF687A70,
          ),
        ),

        filled: true,

        fillColor:
            fieldBackground,

        isDense: true,

        contentPadding:
            EdgeInsets.symmetric(
          horizontal: 13,
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
            width: 1.2,
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
          fontSize: AppTextStyles.bodySmall,
        ),
      ),
    );
  }

  // ============================================================
  // GAP
  // ============================================================

  Widget _gap() {
    return const SizedBox(
      height: 12,
    );
  }
}