import 'package:flutter/material.dart';

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
  // ACTIVITY TYPES
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
  // PAGE TITLE
  // ============================================================

  String get _title {
    switch (widget.mode) {
      case AddActivityMode.treeActivity:
        return 'Add Tree Activity';

      case AddActivityMode.farmHarvest:
        return 'Farm Harvesting';

      case AddActivityMode.treeHarvest:
        return 'Tree Harvesting';
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
      final result =
          await FarmApiServices.getMyFarms();

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
        'Unable to load blocks: $e',
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
        'Unable to load trees: $e',
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
    if (_isSaving) {
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFarmId == null) {
      _showMessage(
        'Please select a farm.',
        error: true,
      );

      return;
    }

    if (widget.mode !=
        AddActivityMode.farmHarvest) {
      if (_selectedBlockId == null) {
        _showMessage(
          'Please select a block.',
          error: true,
        );

        return;
      }

      if (_selectedTreeId == null) {
        _showMessage(
          'Please select a tree.',
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
        _successMessage(),
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
    if (_selectedFarmId == null ||
        _selectedBlockId == null ||
        _selectedTreeId == null ||
        _selectedActivityType == null) {
      throw Exception(
        'Farm, block, tree and activity type are required.',
      );
    }

    final cost = double.tryParse(
          _costController.text.trim(),
        ) ??
        0;

    if (cost < 0) {
      throw Exception(
        'Cost cannot be negative.',
      );
    }

    await TreeActivityApiServices.createActivity(
      farmId: _selectedFarmId!,
      blockId: _selectedBlockId!,
      treeId: _selectedTreeId!,
      activityType: _selectedActivityType!,
      activityDate: _formattedDate,
      description:
          _descriptionController.text.trim(),
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
    if (_selectedFarmId == null ||
        _selectedBlockId == null ||
        _selectedTreeId == null) {
      throw Exception(
        'Farm, block and tree are required.',
      );
    }

    final harvestedKg = double.tryParse(
      _harvestedKgController.text.trim(),
    );

    if (harvestedKg == null ||
        harvestedKg <= 0) {
      throw Exception(
        'Harvested kilograms must be greater than zero.',
      );
    }

    final cost = double.tryParse(
          _costController.text.trim(),
        ) ??
        0;

    if (cost < 0) {
      throw Exception(
        'Cost cannot be negative.',
      );
    }

    await TreeActivityApiServices.createActivity(
      farmId: _selectedFarmId!,
      blockId: _selectedBlockId!,
      treeId: _selectedTreeId!,
      activityType: 'HARVESTING',
      activityDate: _formattedDate,
      description:
          _descriptionController.text.trim(),
      status: 'COMPLETED',
      cost: cost,
      harvestMethod: 'TREE',
      harvestedKg: harvestedKg,
    );
  }

  // ============================================================
  // SAVE FARM HARVEST
  // ============================================================

  Future<void> _saveFarmHarvest() async {
    if (_selectedFarmId == null) {
      throw Exception(
        'Please select a farm.',
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
        'Number of buckets must be greater than zero.',
      );
    }

    if (kgPerBucket == null ||
        kgPerBucket <= 0) {
      throw Exception(
        'Kg per bucket must be greater than zero.',
      );
    }

    if (cost < 0) {
      throw Exception(
        'Cost cannot be negative.',
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

  String _successMessage() {
    switch (widget.mode) {
      case AddActivityMode.treeActivity:
        return 'Tree activity saved successfully.';

      case AddActivityMode.farmHarvest:
        return 'Farm harvest saved successfully.';

      case AddActivityMode.treeHarvest:
        return 'Tree harvest saved successfully.';
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
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
          _title,
          style: const TextStyle(
            fontSize: 15,
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
                    // ============================================
                    // INTRO
                    // ============================================

                    Text(
                      _title,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      _subtitle(),
                      style: const TextStyle(
                        color: textGrey,
                        fontSize: 9,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 22),

                    // ============================================
                    // LOCATION
                    // ============================================

                    _sectionTitle(
                      widget.mode ==
                              AddActivityMode
                                  .farmHarvest
                          ? 'Farm'
                          : 'Tree Location',
                    ),

                    const SizedBox(height: 10),

                    // ============================================
                    // FARM DROPDOWN
                    // ============================================

                    _farmDropdown(),

                    // ============================================
                    // BLOCK + TREE
                    // ============================================

                    if (widget.mode !=
                        AddActivityMode
                            .farmHarvest) ...[
                      const SizedBox(height: 14),

                      _blockDropdown(),

                      const SizedBox(height: 14),

                      _treeDropdown(),
                    ],

                    const SizedBox(height: 24),

                    // ============================================
                    // ACTIVITY / HARVEST INFORMATION
                    // ============================================

                    _sectionTitle(
                      widget.mode ==
                              AddActivityMode
                                  .treeActivity
                          ? 'Activity Information'
                          : 'Harvest Information',
                    ),

                    const SizedBox(height: 10),

                    // ============================================
                    // NORMAL TREE ACTIVITY
                    // ============================================

                    if (widget.mode ==
                        AddActivityMode
                            .treeActivity) ...[
                      _activityTypeDropdown(),

                      const SizedBox(height: 14),
                    ],

                    // ============================================
                    // FARM HARVEST
                    // ============================================

                    if (widget.mode ==
                        AddActivityMode
                            .farmHarvest) ...[
                      _numberField(
                        controller:
                            _bucketController,
                        label:
                            'Number of Buckets',
                        hint: 'Example: 20',
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
                        label: 'Kg per Bucket',
                        hint: 'Example: 15',
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

                    // ============================================
                    // TREE HARVEST
                    // ============================================

                    if (widget.mode ==
                        AddActivityMode
                            .treeHarvest) ...[
                      _treeHarvestMethod(),

                      const SizedBox(height: 14),

                      _numberField(
                        controller:
                            _harvestedKgController,
                        label:
                            'Harvested Weight (Kg)',
                        hint: 'Example: 18.5',
                        requiredField: true,
                        decimal: true,
                      ),

                      const SizedBox(height: 14),
                    ],

                    // ============================================
                    // DATE
                    // ============================================

                    _dateField(),

                    const SizedBox(height: 14),

                    // ============================================
                    // COST
                    // ============================================

                    _numberField(
                      controller:
                          _costController,
                      label: 'Cost (TZS)',
                      hint: 'Example: 25000',
                      decimal: true,
                      allowZero: true,
                    ),

                    const SizedBox(height: 14),

                    // ============================================
                    // DESCRIPTION
                    // ============================================

                    TextFormField(
                      controller:
                          _descriptionController,
                      minLines: 3,
                      maxLines: 5,
                      style: const TextStyle(
                        color: textDark,
                        fontSize: 10,
                      ),
                      decoration:
                          _inputDecoration(
                        'Description',
                      ).copyWith(
                        hintText:
                            'Enter description...',
                        hintStyle:
                            const TextStyle(
                          color: textGrey,
                          fontSize: 9,
                        ),
                      ),
                    ),

                    const SizedBox(height: 26),

                    // ============================================
                    // SAVE
                    // ============================================

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child:
                          ElevatedButton.icon(
                        onPressed:
                            _isSaving
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
                              ? 'Saving...'
                              : _saveButtonText(),
                          style:
                              const TextStyle(
                            fontSize: 10,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        style: ElevatedButton
                            .styleFrom(
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
    if (_loadingFarms) {
      return _loadingInput(
        'Loading farms...',
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedFarmId,
      isExpanded: true,
      decoration:
          _inputDecoration('Farm'),
      hint: const Text(
        'Select farm',
        style: TextStyle(
          color: textGrey,
          fontSize: 10,
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
              fontSize: 10,
            ),
          ),
        );
      }).toList(),
      onChanged: _onFarmChanged,
      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return 'Farm is required';
        }

        return null;
      },
    );
  }

  // ============================================================
  // BLOCK DROPDOWN
  // ============================================================

  Widget _blockDropdown() {
    if (_selectedFarmId == null) {
      return _disabledInput(
        label: 'Block',
        text: 'Select farm first',
      );
    }

    if (_loadingBlocks) {
      return _loadingInput(
        'Loading blocks...',
        label: 'Block',
      );
    }

    if (_blocks.isEmpty) {
      return _disabledInput(
        label: 'Block',
        text:
            'No blocks found for this farm',
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedBlockId,
      isExpanded: true,
      decoration:
          _inputDecoration('Block'),
      hint: const Text(
        'Select block',
        style: TextStyle(
          color: textGrey,
          fontSize: 10,
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
              fontSize: 10,
            ),
          ),
        );
      }).toList(),
      onChanged: _onBlockChanged,
      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return 'Block is required';
        }

        return null;
      },
    );
  }

  // ============================================================
  // TREE DROPDOWN
  // ============================================================

  Widget _treeDropdown() {
    if (_selectedBlockId == null) {
      return _disabledInput(
        label: 'Cashew Tree',
        text: 'Select block first',
      );
    }

    if (_loadingTrees) {
      return _loadingInput(
        'Loading trees...',
        label: 'Cashew Tree',
      );
    }

    if (_trees.isEmpty) {
      return _disabledInput(
        label: 'Cashew Tree',
        text:
            'No trees found for this block',
      );
    }

    return DropdownButtonFormField<String>(
      value: _selectedTreeId,
      isExpanded: true,
      decoration:
          _inputDecoration(
        'Cashew Tree',
      ),
      hint: const Text(
        'Select tree',
        style: TextStyle(
          color: textGrey,
          fontSize: 10,
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
              fontSize: 10,
            ),
          ),
        );
      }).toList(),
      onChanged: _onTreeChanged,
      validator: (value) {
        if (value == null ||
            value.isEmpty) {
          return 'Tree is required';
        }

        return null;
      },
    );
  }

  // ============================================================
  // ACTIVITY TYPE
  // ============================================================

  Widget _activityTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedActivityType,
      isExpanded: true,
      decoration:
          _inputDecoration(
        'Activity Type',
      ),
      hint: const Text(
        'Select activity',
        style: TextStyle(
          color: textGrey,
          fontSize: 10,
        ),
      ),
      items: _activityTypes
          .map(
            (type) =>
                DropdownMenuItem<String>(
              value: type,
              child: Text(
                _activityName(type),
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
          return 'Activity type is required';
        }

        return null;
      },
    );
  }

  // ============================================================
  // TREE HARVEST METHOD
  // ============================================================

  Widget _treeHarvestMethod() {
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
      child: const Row(
        children: [
          Icon(
            Icons.park_outlined,
            color: primaryGreen,
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Tree Harvesting',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 10,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Harvest will be recorded in kilograms for the selected tree.',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 8,
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

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Harvest',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 9,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Buckets × Kg per bucket',
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ),

          Text(
            '${total.toStringAsFixed(2)} Kg',
            style: const TextStyle(
              color: primaryGreen,
              fontSize: 13,
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
              ? 'Activity Date'
              : 'Harvest Date',
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
              style: const TextStyle(
                color: textDark,
                fontSize: 10,
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
        fontSize: 10,
      ),
      decoration:
          _inputDecoration(label).copyWith(
        hintText: hint,
        hintStyle: const TextStyle(
          color: textGrey,
          fontSize: 9,
        ),
      ),
      validator: (value) {
        final text =
            value?.trim() ?? '';

        if (requiredField &&
            text.isEmpty) {
          return '$label is required';
        }

        if (text.isEmpty) {
          return null;
        }

        if (integerOnly) {
          final number =
              int.tryParse(text);

          if (number == null) {
            return 'Enter a valid whole number';
          }

          if (allowZero) {
            if (number < 0) {
              return 'Value cannot be negative';
            }
          } else if (number <= 0) {
            return 'Value must be greater than zero';
          }

          return null;
        }

        final number =
            double.tryParse(text);

        if (number == null) {
          return 'Enter a valid number';
        }

        if (allowZero) {
          if (number < 0) {
            return 'Value cannot be negative';
          }
        } else if (requiredField &&
            number <= 0) {
          return 'Value must be greater than zero';
        } else if (number < 0) {
          return 'Value cannot be negative';
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
    String label = 'Farm',
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
              fontSize: 9,
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
          fontSize: 9,
        ),
      ),
    );
  }

  // ============================================================
  // FARM ERROR
  // ============================================================

  Widget _buildFarmError() {
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

            const Text(
              'Unable to load farms',
              style: TextStyle(
                color: textDark,
                fontSize: 13,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              _farmError ?? '',
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color: textGrey,
                fontSize: 9,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _loadFarms,
              icon: const Icon(
                Icons.refresh,
                size: 16,
              ),
              label: const Text(
                'Retry',
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
        fontSize: 9,
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
        fontSize: 12,
        fontWeight:
            FontWeight.w800,
      ),
    );
  }

  // ============================================================
  // ACTIVITY NAME
  // ============================================================

  String _activityName(
    String value,
  ) {
    switch (value) {
      case 'WEEDING':
        return 'Weeding';

      case 'PRUNING':
        return 'Pruning';

      case 'PESTICIDE_APPLICATION':
        return 'Pesticide Application';

      case 'FERTILIZER_APPLICATION':
        return 'Fertilizer Application';

      case 'OTHER':
        return 'Other';

      default:
        return value;
    }
  }

  // ============================================================
  // SUBTITLE
  // ============================================================

  String _subtitle() {
    switch (widget.mode) {
      case AddActivityMode.treeActivity:
        return 'Select a farm, block and cashew tree, then record the activity and its cost.';

      case AddActivityMode.farmHarvest:
        return 'Select a farm and record the number of buckets, kilograms per bucket and harvesting cost.';

      case AddActivityMode.treeHarvest:
        return 'Select a farm, block and cashew tree, then record the kilograms harvested from the tree.';
    }
  }

  // ============================================================
  // SAVE BUTTON TEXT
  // ============================================================

  String _saveButtonText() {
    switch (widget.mode) {
      case AddActivityMode.treeActivity:
        return 'Save Activity';

      case AddActivityMode.farmHarvest:
        return 'Save Farm Harvest';

      case AddActivityMode.treeHarvest:
        return 'Save Tree Harvest';
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