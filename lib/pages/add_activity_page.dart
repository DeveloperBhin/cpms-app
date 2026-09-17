
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_text_styles.dart';
import '../services/api_services/farm_api_services.dart';
import '../services/api_services/block_api_services.dart';
import '../services/api_services/tree_api_services.dart';
import '../services/api_services/tree_activity_api_services.dart';
import '../services/api_services/farm_harvest_api_services.dart';

// ============================================================
// ADD ACTIVITY MODE
// ============================================================

enum AddActivityMode {
  treeActivity,
  farmHarvest,
  treeHarvest,
}

// ============================================================
// ADD ACTIVITY PAGE
// ============================================================

class AddActivityPage extends StatefulWidget {
  final AddActivityMode mode;

  const AddActivityPage({
    super.key,
    required this.mode,
  });

  @override
  State<AddActivityPage> createState() =>
      _AddActivityPageState();
}

class _AddActivityPageState extends State<AddActivityPage> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color backgroundColor = Color(0xFFF8FAF8);
  static const Color borderColor = Color(0xFFDCE8DF);
  static const Color lightGreen = Color(0xFFE7F3EB);
  static const Color textDark = Color(0xFF25402D);
  static const Color textGrey = Color(0xFF718078);

  // ============================================================
  // FORM
  // ============================================================

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _costController =
      TextEditingController();

  final TextEditingController _descriptionController =
      TextEditingController();

  final TextEditingController _bucketController =
      TextEditingController();

  final TextEditingController _kgPerBucketController =
      TextEditingController();

  final TextEditingController _harvestedKgController =
      TextEditingController();

  // ============================================================
  // API DATA
  // ============================================================

  List<Map<String, dynamic>> _farms = [];
  List<Map<String, dynamic>> _blocks = [];
  List<Map<String, dynamic>> _trees = [];

  // ============================================================
  // SELECTED DATA
  // ============================================================

  String? _selectedFarmId;
  String? _selectedBlockId;
  String? _selectedTreeId;
  String? _selectedActivityType;

  DateTime _selectedDate = DateTime.now();

  // ============================================================
  // LOADING STATES
  // ============================================================

  bool _loadingFarms = false;
  bool _loadingBlocks = false;
  bool _loadingTrees = false;
  bool _isSaving = false;

  // ============================================================
  // ERRORS
  // ============================================================

  String? _farmError;

  // ============================================================
  // BACKEND ACTIVITY TYPES
  //
  // IMPORTANT:
  // DO NOT TRANSLATE THESE VALUES.
  // They are sent directly to the backend.
  // ============================================================

  final List<String> _activityTypes = [
    'WEEDING',
    'PRUNING',
    'PESTICIDE_APPLICATION',
    'FERTILIZER_APPLICATION',
    'OTHER',
  ];

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadFarms();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _costController.dispose();
    _descriptionController.dispose();
    _bucketController.dispose();
    _kgPerBucketController.dispose();
    _harvestedKgController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOCALIZATION
  // ============================================================

  AppLocalizations get _l10n =>
      AppLocalizations.of(context)!;

  // ============================================================
  // PAGE TITLE
  // ============================================================

  String _title(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (widget.mode) {
      case AddActivityMode.treeActivity:
        return l10n.addTreeActivity;

      case AddActivityMode.farmHarvest:
        return l10n.farmHarvesting;

      case AddActivityMode.treeHarvest:
        return l10n.treeHarvesting;
    }
  }

  // ============================================================
  // SUBTITLE
  // ============================================================

  String _subtitle(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (widget.mode) {
      case AddActivityMode.treeActivity:
        return l10n.treeActivitySubtitle;

      case AddActivityMode.farmHarvest:
        return l10n.farmHarvestSubtitle;

      case AddActivityMode.treeHarvest:
        return l10n.treeHarvestSubtitle;
    }
  }

  // ============================================================
  // LOAD FARMS
  // ============================================================

  Future<void> _loadFarms() async {
    if (mounted) {
      setState(() {
        _loadingFarms = true;
        _farmError = null;
      });
    }

    try {
      final result = await FarmApiServices.getMyFarms();

      if (!mounted) {
        return;
      }

      setState(() {
        _farms = result;
        _loadingFarms = false;
      });
    } catch (e) {
      debugPrint(
        'LOAD FARMS ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loadingFarms = false;
        _farmError = e.toString();
      });
    }
  }

  // ============================================================
  // LOAD BLOCKS
  // ============================================================

  Future<void> _loadBlocks(
    String farmId,
  ) async {
    if (mounted) {
      setState(() {
        _loadingBlocks = true;

        _blocks = [];
        _trees = [];

        _selectedBlockId = null;
        _selectedTreeId = null;
      });
    }

    try {
      final result =
          await BlockApiServices.getBlocksByFarm(
        farmId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _blocks = result;
        _loadingBlocks = false;
      });
    } catch (e) {
      debugPrint(
        'LOAD BLOCKS ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loadingBlocks = false;
      });

      _showMessage(
        '${_l10n.unableToLoadBlocks}: ${_cleanError(e)}',
        error: true,
      );
    }
  }

  // ============================================================
  // LOAD TREES
  // ============================================================

  Future<void> _loadTrees({
    required String farmId,
    required String blockId,
  }) async {
    if (mounted) {
      setState(() {
        _loadingTrees = true;

        _trees = [];

        _selectedTreeId = null;
      });
    }

    try {
      final result =
          await TreeApiServices.getTreesByBlock(
        farmId: farmId,
        blockId: blockId,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _trees = result;
        _loadingTrees = false;
      });
    } catch (e) {
      debugPrint(
        'LOAD TREES ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _loadingTrees = false;
      });

      _showMessage(
        '${_l10n.unableToLoadTrees}: ${_cleanError(e)}',
        error: true,
      );
    }
  }

  // ============================================================
  // FARM SELECTED
  // ============================================================

  Future<void> _onFarmChanged(
    String? farmId,
  ) async {
    if (farmId == null) {
      return;
    }

    setState(() {
      _selectedFarmId = farmId;

      _selectedBlockId = null;
      _selectedTreeId = null;

      _blocks = [];
      _trees = [];
    });

    // Farm harvesting does not require
    // block or tree.
    if (widget.mode ==
        AddActivityMode.farmHarvest) {
      return;
    }

    await _loadBlocks(farmId);
  }

  // ============================================================
  // BLOCK SELECTED
  // ============================================================

  Future<void> _onBlockChanged(
    String? blockId,
  ) async {
    if (blockId == null ||
        _selectedFarmId == null) {
      return;
    }

    setState(() {
      _selectedBlockId = blockId;

      _selectedTreeId = null;
      _trees = [];
    });

    await _loadTrees(
      farmId: _selectedFarmId!,
      blockId: blockId,
    );
  }

  // ============================================================
  // TREE SELECTED
  // ============================================================

  void _onTreeChanged(
    String? treeId,
  ) {
    setState(() {
      _selectedTreeId = treeId;
    });
  }

  // ============================================================
  // DATE
  // ============================================================

  Future<void> _selectDate() async {
    final result = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (result == null) {
      return;
    }

    setState(() {
      _selectedDate = result;
    });
  }

  String get _formattedDate {
    return '${_selectedDate.year}-'
        '${_selectedDate.month.toString().padLeft(2, '0')}-'
        '${_selectedDate.day.toString().padLeft(2, '0')}';
  }

  // ============================================================
  // SAVE
  // ============================================================

  Future<void> _save() async {
    final l10n = _l10n;

    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFarmId == null) {
      _showMessage(
        l10n.pleaseSelectFarm,
        error: true,
      );

      return;
    }

    if (widget.mode !=
        AddActivityMode.farmHarvest) {
      if (_selectedBlockId == null) {
        _showMessage(
          l10n.pleaseSelectBlock,
          error: true,
        );

        return;
      }

      if (_selectedTreeId == null) {
        _showMessage(
          l10n.pleaseSelectTree,
          error: true,
        );

        return;
      }
    }

    setState(() {
      _isSaving = true;
    });

    try {
      switch (widget.mode) {
        case AddActivityMode.treeActivity:
          await _saveTreeActivity();
          break;

        case AddActivityMode.farmHarvest:
          await _saveFarmHarvest();
          break;

        case AddActivityMode.treeHarvest:
          await _saveTreeHarvest();
          break;
      }

      if (!mounted) {
        return;
      }

      _showMessage(
        _successMessage(context),
      );

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      debugPrint(
        'SAVE ACTIVITY ERROR: $e',
      );

      if (!mounted) {
        return;
      }

      _showMessage(
        _cleanError(e),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // SAVE NORMAL TREE ACTIVITY
  // ============================================================

  Future<void> _saveTreeActivity() async {
    final l10n = _l10n;

    if (_selectedFarmId == null ||
        _selectedBlockId == null ||
        _selectedTreeId == null ||
        _selectedActivityType == null) {
      throw Exception(
        l10n.farmBlockTreeActivityRequired,
      );
    }

    final cost = double.tryParse(
          _costController.text.trim(),
        ) ??
        0;

    if (cost < 0) {
      throw Exception(
        l10n.costCannotBeNegative,
      );
    }

    await TreeActivityApiServices.createActivity(
      farmId: _selectedFarmId!,
      blockId: _selectedBlockId!,
      treeId: _selectedTreeId!,

      // Backend enum value.
      // DO NOT TRANSLATE.
      activityType: _selectedActivityType!,

      activityDate: _formattedDate,

      description:
          _descriptionController.text.trim(),

      // Backend enum value.
      // DO NOT TRANSLATE.
      status: 'COMPLETED',

      cost: cost,
      harvestMethod: null,
      harvestedKg: null,
    );
  }

  // ============================================================
  // SAVE TREE HARVEST
  // ============================================================

  Future<void> _saveTreeHarvest() async {
    final l10n = _l10n;

    if (_selectedFarmId == null ||
        _selectedBlockId == null ||
        _selectedTreeId == null) {
      throw Exception(
        l10n.farmBlockTreeRequired,
      );
    }

    final harvestedKg = double.tryParse(
      _harvestedKgController.text.trim(),
    );

    if (harvestedKg == null ||
        harvestedKg <= 0) {
      throw Exception(
        l10n.harvestKgGreaterThanZero,
      );
    }

    final cost = double.tryParse(
          _costController.text.trim(),
        ) ??
        0;

    if (cost < 0) {
      throw Exception(
        l10n.costCannotBeNegative,
      );
    }

    await TreeActivityApiServices.createActivity(
      farmId: _selectedFarmId!,
      blockId: _selectedBlockId!,
      treeId: _selectedTreeId!,

      // Backend enum value.
      // DO NOT TRANSLATE.
      activityType: 'HARVESTING',

      activityDate: _formattedDate,

      description:
          _descriptionController.text.trim(),

      // Backend enum value.
      // DO NOT TRANSLATE.
      status: 'COMPLETED',

      cost: cost,

      // Backend enum value.
      // DO NOT TRANSLATE.
      harvestMethod: 'TREE',

      harvestedKg: harvestedKg,
    );
  }

  // ============================================================
  // SAVE FARM HARVEST
  // ============================================================

  Future<void> _saveFarmHarvest() async {
    final l10n = _l10n;

    if (_selectedFarmId == null) {
      throw Exception(
        l10n.pleaseSelectFarm,
      );
    }

    final bucketCount = int.tryParse(
      _bucketController.text.trim(),
    );

    final kgPerBucket = double.tryParse(
      _kgPerBucketController.text.trim(),
    );

    final cost = double.tryParse(
          _costController.text.trim(),
        ) ??
        0;

    if (bucketCount == null ||
        bucketCount <= 0) {
      throw Exception(
        l10n.bucketCountGreaterThanZero,
      );
    }

    if (kgPerBucket == null ||
        kgPerBucket <= 0) {
      throw Exception(
        l10n.kgPerBucketGreaterThanZero,
      );
    }

    if (cost < 0) {
      throw Exception(
        l10n.costCannotBeNegative,
      );
    }

    await FarmHarvestApiServices.createHarvest(
      farmId: _selectedFarmId!,
      harvestDate: _formattedDate,
      bucketCount: bucketCount,
      kgPerBucket: kgPerBucket,
      cost: cost,
      description:
          _descriptionController.text.trim(),
    );
  }

  // ============================================================
  // SUCCESS MESSAGE
  // ============================================================

  String _successMessage(
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;

    switch (widget.mode) {
      case AddActivityMode.treeActivity:
        return l10n.treeActivitySaved;

      case AddActivityMode.farmHarvest:
        return l10n.farmHarvestSaved;

      case AddActivityMode.treeHarvest:
        return l10n.treeHarvestSaved;
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _title(context),
          style: const TextStyle(
            fontSize: AppTextStyles.bodyLarge,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: _farmError != null &&
                _farms.isEmpty
            ? _buildFarmError()
            : Form(
                key: _formKey,
                child: ListView(
                  padding:
                      const EdgeInsets.fromLTRB(
                    16,
                    18,
                    16,
                    30,
                  ),
                  children: [
                    // ==========================================
                    // INTRO
                    // ==========================================

                    Text(
                      _title(context),
                      style: const TextStyle(
                        color: textDark,
                        fontSize: AppTextStyles.bodyLarge,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _subtitle(context),
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: AppTextStyles.bodySmall,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ==========================================
                    // LOCATION
                    // ==========================================

                    _sectionTitle(
                      widget.mode ==
                              AddActivityMode
                                  .farmHarvest
                          ? l10n.farm
                          : l10n.treeLocation,
                    ),

                    const SizedBox(height: 10),

                    // ==========================================
                    // FARM
                    // ==========================================

                    _farmDropdown(),

                    // ==========================================
                    // BLOCK + TREE
                    // ==========================================

                    if (widget.mode !=
                        AddActivityMode
                            .farmHarvest) ...[
                      const SizedBox(height: 14),
                      _blockDropdown(),
                      const SizedBox(height: 14),
                      _treeDropdown(),
                    ],

                    const SizedBox(height: 24),

                    // ==========================================
                    // ACTIVITY / HARVEST INFORMATION
                    // ==========================================

                    _sectionTitle(
                      widget.mode ==
                              AddActivityMode
                                  .treeActivity
                          ? l10n.activityInformation
                          : l10n.harvestInformation,
                    ),

                    const SizedBox(height: 10),

                    // ==========================================
                    // NORMAL TREE ACTIVITY
                    // ==========================================

                    if (widget.mode ==
                        AddActivityMode
                            .treeActivity) ...[
                      _activityTypeDropdown(),
                      const SizedBox(height: 14),
                    ],

                    // ==========================================
                    // FARM HARVEST
                    // ==========================================

                    if (widget.mode ==
                        AddActivityMode
                            .farmHarvest) ...[
                      _numberField(
                        controller:
                            _bucketController,
                        label:
                            l10n.numberOfBuckets,
                        hint: l10n.example20,
                        requiredField: true,
                        integerOnly: true,
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 14),

                      _numberField(
                        controller:
                            _kgPerBucketController,
                        label:
                            l10n.kgPerBucket,
                        hint: l10n.example15,
                        requiredField: true,
                        decimal: true,
                        onChanged: (_) {
                          setState(() {});
                        },
                      ),

                      const SizedBox(height: 14),

                      _farmHarvestTotal(),

                      const SizedBox(height: 14),
                    ],

                    // ==========================================
                    // TREE HARVEST
                    // ==========================================

                    if (widget.mode ==
                        AddActivityMode
                            .treeHarvest) ...[
                      _treeHarvestMethod(),

                      const SizedBox(height: 14),

                      _numberField(
                        controller:
                            _harvestedKgController,
                        label:
                            l10n.harvestedWeightKg,
                        hint: l10n
                            .exampleHarvestWeight,
                        requiredField: true,
                        decimal: true,
                      ),

                      const SizedBox(height: 14),
                    ],

                    // ==========================================
                    // DATE
                    // ==========================================

                    _dateField(),

                    const SizedBox(height: 14),

                    // ==========================================
                    // COST
                    // ==========================================

                    _numberField(
                      controller:
                          _costController,
                      label: l10n.costTzs,
                      hint: l10n.exampleCost,
                      decimal: true,
                      allowZero: true,
                    ),

                    const SizedBox(height: 14),

                    // ==========================================
                    // DESCRIPTION
                    // ==========================================

                    TextFormField(
                      controller:
                          _descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: AppTextStyles.bodySmall,
                      ),
                      decoration:
                          _inputDecoration(
                        l10n.description,
                      ).copyWith(
                        hintText:
                            l10n.enterDescription,
                        hintStyle:
                            const TextStyle(
                          color: textGrey,
                          fontSize: AppTextStyles.bodySmall,
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ==========================================
                    // SAVE
                    // ==========================================

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving
                            ? null
                            : _save,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 17,
                                height: 17,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons
                                    .save_outlined,
                                size: 18,
                              ),
                        label: Text(
                          _isSaving
                              ? l10n.saving
                              : _saveButtonText(
                                  context,
                                ),
                          style:
                              const TextStyle(
                            fontSize: AppTextStyles.bodySmall,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        style:
                            ElevatedButton.styleFrom(
                          backgroundColor:
                              primaryGreen,
                          foregroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              primaryGreen
                                  .withValues(
                            alpha: 0.5,
                          ),
                          disabledForegroundColor:
                              Colors.white,
                          elevation: 0,
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(10),
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
  // FARM DROPDOWN
  // ============================================================

  Widget _farmDropdown() {
    final l10n = _l10n;

    if (_loadingFarms) {
      return _loadingInput(
        l10n.loadingFarms,
        label: l10n.farm,
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedFarmId,
      isExpanded: true,
      decoration:
          _inputDecoration(l10n.farm),
      hint: Text(
        l10n.selectFarm,
        style: const TextStyle(
          color: textGrey,
          fontSize: AppTextStyles.bodySmall,
        ),
      ),
      items: _farms.map((farm) {
        final id =
            farm['id']?.toString() ?? '';

        final name =
            farm['name']
                    ?.toString()
                    .trim() ??
                '';

        return DropdownMenuItem<String>(
          value: id,
          child: Text(
            name.isEmpty
                ? _displayFarmId(id)
                : name,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodySmall,
            ),
          ),
        );
      }).toList(),
      onChanged: _onFarmChanged,
      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return l10n.farmRequired;
        }

        return null;
      },
    );
  }

  // ============================================================
  // BLOCK DROPDOWN
  // ============================================================

  Widget _blockDropdown() {
    final l10n = _l10n;

    if (_selectedFarmId == null) {
      return _disabledInput(
        label: l10n.block,
        text: l10n.selectFarmFirst,
      );
    }

    if (_loadingBlocks) {
      return _loadingInput(
        l10n.loadingBlocks,
        label: l10n.block,
      );
    }

    if (_blocks.isEmpty) {
      return _disabledInput(
        label: l10n.block,
        text: l10n.noBlocksForFarm,
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedBlockId,
      isExpanded: true,
      decoration:
          _inputDecoration(l10n.block),
      hint: Text(
        l10n.selectBlock,
        style: const TextStyle(
          color: textGrey,
          fontSize: AppTextStyles.bodySmall,
        ),
      ),
      items: _blocks.map((block) {
        final id =
            block['id']?.toString() ?? '';

        final name =
            block['name']
                    ?.toString()
                    .trim() ??
                '';

        return DropdownMenuItem<String>(
          value: id,
          child: Text(
            name.isEmpty
                ? _displayBlockId(id)
                : name,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodySmall,
            ),
          ),
        );
      }).toList(),
      onChanged: _onBlockChanged,
      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return l10n.blockRequired;
        }

        return null;
      },
    );
  }

  // ============================================================
  // TREE DROPDOWN
  // ============================================================

  Widget _treeDropdown() {
    final l10n = _l10n;

    if (_selectedBlockId == null) {
      return _disabledInput(
        label: l10n.cashewTree,
        text: l10n.selectBlockFirst,
      );
    }

    if (_loadingTrees) {
      return _loadingInput(
        l10n.loadingTrees,
        label: l10n.cashewTree,
      );
    }

    if (_trees.isEmpty) {
      return _disabledInput(
        label: l10n.cashewTree,
        text: l10n.noTreesForBlock,
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedTreeId,
      isExpanded: true,
      decoration: _inputDecoration(
        l10n.cashewTree,
      ),
      hint: Text(
        l10n.selectTree,
        style: const TextStyle(
          color: textGrey,
          fontSize: AppTextStyles.bodySmall,
        ),
      ),
      items: _trees.map((tree) {
        final id =
            tree['id']?.toString() ?? '';

        final code =
            tree['treeCode']
                    ?.toString()
                    .trim() ??
                '';

        final variety =
            tree['variety']
                    ?.toString()
                    .trim() ??
                '';

        final treeCode =
            code.isNotEmpty
                ? code
                : _displayTreeId(id);

        final label =
            variety.isEmpty
                ? treeCode
                : '$treeCode • $variety';

        return DropdownMenuItem<String>(
          value: id,
          child: Text(
            label,
            overflow:
                TextOverflow.ellipsis,
            style: const TextStyle(
              color: textDark,
              fontSize: AppTextStyles.bodySmall,
            ),
          ),
        );
      }).toList(),
      onChanged: _onTreeChanged,
      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return l10n.treeRequired;
        }

        return null;
      },
    );
  }

  // ============================================================
  // ACTIVITY TYPE
  // ============================================================

  Widget _activityTypeDropdown() {
    final l10n = _l10n;

    return DropdownButtonFormField<String>(
      value: _selectedActivityType,
      isExpanded: true,
      decoration: _inputDecoration(
        l10n.activityType,
      ),
      hint: Text(
        l10n.selectActivity,
        style: const TextStyle(
          color: textGrey,
          fontSize: 10,
        ),
      ),
      items: _activityTypes
          .map(
            (type) =>
                DropdownMenuItem<String>(
              // Backend value.
              value: type,
              child: Text(
                _activityName(
                  context,
                  type,
                ),
                style: const TextStyle(
                  color: textDark,
                  fontSize: 10,
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        setState(() {
          _selectedActivityType =
              value;
        });
      },
      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return l10n
              .activityTypeRequired;
        }

        return null;
      },
    );
  }

  // ============================================================
  // TREE HARVEST METHOD
  // ============================================================

  Widget _treeHarvestMethod() {
    final l10n = _l10n;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.park_outlined,
            color: primaryGreen,
            size: 20,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.treeHarvesting,
                  style:
                      const TextStyle(
                    color: textDark,
                    fontSize: AppTextStyles.bodySmall,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  l10n
                      .treeHarvestRecordDescription,
                  style:
                      const TextStyle(
                    color: textGrey,
                    fontSize: AppTextStyles.bodySmall,
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
  // FARM HARVEST TOTAL
  // ============================================================

  Widget _farmHarvestTotal() {
    final l10n = _l10n;

    final bucketCount = int.tryParse(
          _bucketController.text.trim(),
        ) ??
        0;

    final kgPerBucket =
        double.tryParse(
          _kgPerBucketController.text
              .trim(),
        ) ??
        0;

    // Application calculation.
    // Language does not affect this.
    final total =
        bucketCount * kgPerBucket;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightGreen,
        borderRadius:
            BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.scale_outlined,
              color: primaryGreen,
              size: 19,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.totalHarvest,
                  style:
                      const TextStyle(
                    color: textDark,
                    fontSize: AppTextStyles.bodySmall,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  l10n.bucketsTimesKg,
                  style:
                      const TextStyle(
                    color: textGrey,
                    fontSize: AppTextStyles.bodySmall,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${total.toStringAsFixed(2)} Kg',
            style: const TextStyle(
              color: primaryGreen,
              fontSize: AppTextStyles.bodySmall,
              fontWeight:
                  FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE FIELD
  // ============================================================

  Widget _dateField() {
    final l10n = _l10n;

    return InkWell(
      onTap: _selectDate,
      borderRadius:
          BorderRadius.circular(10),
      child: InputDecorator(
        decoration:
            _inputDecoration(
          widget.mode ==
                  AddActivityMode
                      .treeActivity
              ? l10n.activityDate
              : l10n.harvestDate,
        ),
        child: Row(
          children: [
            const Icon(
              Icons
                  .calendar_today_outlined,
              color: primaryGreen,
              size: 17,
            ),

            const SizedBox(width: 10),

            Text(
              _formattedDate,
              style:
                  const TextStyle(
                color: textDark,
                fontSize: AppTextStyles.bodySmall,
                fontWeight:
                    FontWeight.w600,
              ),
            ),

            const Spacer(),

            const Icon(
              Icons.arrow_drop_down,
              color: textGrey,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NUMBER FIELD
  // ============================================================

  Widget _numberField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool requiredField = false,
    bool decimal = false,
    bool integerOnly = false,
    bool allowZero = false,
    ValueChanged<String>? onChanged,
  }) {
    final l10n = _l10n;

    return TextFormField(
      controller: controller,
      keyboardType:
          TextInputType.numberWithOptions(
        decimal:
            integerOnly ? false : decimal,
      ),
      onChanged: onChanged,
      style: const TextStyle(
        color: textDark,
        fontSize: AppTextStyles.bodySmall,
      ),
      decoration:
          _inputDecoration(label).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(
          color: textGrey,
          fontSize: AppTextStyles.bodySmall,
        ),
      ),
      validator: (value) {
        final text =
            value?.trim() ?? '';

        if (requiredField &&
            text.isEmpty) {
          return l10n.fieldRequired(
            label,
          );
        }

        if (text.isEmpty) {
          return null;
        }

        if (integerOnly) {
          final number =
              int.tryParse(text);

          if (number == null) {
            return l10n
                .enterValidWholeNumber;
          }

          if (allowZero) {
            if (number < 0) {
              return l10n
                  .valueCannotBeNegative;
            }
          } else if (number <= 0) {
            return l10n
                .valueGreaterThanZero;
          }

          return null;
        }

        final number =
            double.tryParse(text);

        if (number == null) {
          return l10n.enterValidNumber;
        }

        if (allowZero) {
          if (number < 0) {
            return l10n
                .valueCannotBeNegative;
          }
        } else if (requiredField &&
            number <= 0) {
          return l10n
              .valueGreaterThanZero;
        } else if (number < 0) {
          return l10n
              .valueCannotBeNegative;
        }

        return null;
      },
    );
  }

  // ============================================================
  // LOADING INPUT
  // ============================================================

  Widget _loadingInput(
    String text, {
    required String label,
  }) {
    return InputDecorator(
      decoration:
          _inputDecoration(label),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child:
                CircularProgressIndicator(
              strokeWidth: 2,
              color: primaryGreen,
            ),
          ),

          const SizedBox(width: 10),

          Text(
            text,
            style: const TextStyle(
              color: textGrey,
              fontSize: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DISABLED INPUT
  // ============================================================

  Widget _disabledInput({
    required String label,
    required String text,
  }) {
    return InputDecorator(
      decoration:
          _inputDecoration(label)
              .copyWith(
        fillColor:
            const Color(0xFFF2F5F3),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: textGrey,
          fontSize: AppTextStyles.bodySmall,
        ),
      ),
    );
  }

  // ============================================================
  // FARM ERROR
  // ============================================================

  Widget _buildFarmError() {
    final l10n = _l10n;

    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(25),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 42,
            ),

            const SizedBox(height: 12),

            Text(
              l10n.unableToLoadFarms,
              style:
                  const TextStyle(
                color: textDark,
                fontSize: AppTextStyles.bodySmall,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _farmError ?? '',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color: textGrey,
                fontSize: AppTextStyles.bodySmall,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _loadFarms,
              icon: const Icon(
                Icons.refresh,
                size: 16,
              ),
              label: Text(
                l10n.retry,
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryGreen,
                foregroundColor:
                    Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
    String label,
  ) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(
        color: textGrey,
        fontSize: AppTextStyles.bodySmall,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: 13,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide:
            const BorderSide(
          color: borderColor,
        ),
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide:
            const BorderSide(
          color: primaryGreen,
          width: 1.3,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(10),
        borderSide:
            const BorderSide(
          color: Colors.red,
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: const TextStyle(
        color: textDark,
        fontSize: AppTextStyles.bodySmall,
        fontWeight:
            FontWeight.w800,
      ),
    );
  }

  // ============================================================
  // ACTIVITY DISPLAY NAME
  //
  // Translate display labels only.
  // The original enum value remains unchanged.
  // ============================================================

  String _activityName(
    BuildContext context,
    String value,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    switch (value) {
      case 'WEEDING':
        return l10n.weeding;

      case 'PRUNING':
        return l10n.pruning;

      case 'PESTICIDE_APPLICATION':
        return l10n
            .pesticideApplication;

      case 'FERTILIZER_APPLICATION':
        return l10n
            .fertilizerApplication;

      case 'OTHER':
        return l10n.other;

      default:
        return value;
    }
  }

  // ============================================================
  // SAVE BUTTON TEXT
  // ============================================================

  String _saveButtonText(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    switch (widget.mode) {
      case AddActivityMode.treeActivity:
        return l10n.saveActivity;

      case AddActivityMode.farmHarvest:
        return l10n.saveFarmHarvest;

      case AddActivityMode.treeHarvest:
        return l10n.saveTreeHarvest;
    }
  }

  // ============================================================
  // DISPLAY FARM ID
  // ============================================================

  String _displayFarmId(
    String id,
  ) {
    final number =
        int.tryParse(id);

    if (number == null) {
      return id;
    }

    return 'FM-${number.toString().padLeft(4, '0')}';
  }

  // ============================================================
  // DISPLAY BLOCK ID
  // ============================================================

  String _displayBlockId(
    String id,
  ) {
    final number =
        int.tryParse(id);

    if (number == null) {
      return id;
    }

    return 'BL-${number.toString().padLeft(4, '0')}';
  }

  // ============================================================
  // DISPLAY TREE ID
  // ============================================================

  String _displayTreeId(
    String id,
  ) {
    final number =
        int.tryParse(id);

    if (number == null) {
      return id;
    }

    return 'TR-${number.toString().padLeft(6, '0')}';
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool error = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            error
                ? Colors.red
                : primaryGreen,
      ),
    );
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(
    Object error,
  ) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );
  }
}

