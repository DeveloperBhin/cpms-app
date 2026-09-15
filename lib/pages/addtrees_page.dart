import 'package:flutter/material.dart';

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
  State<AddTreePage> createState() => _AddTreePageState();
}

class _AddTreePageState extends State<AddTreePage> {
  final _formKey = GlobalKey<FormState>();

  final _varietyController = TextEditingController();
  final _plantingYearController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  String _status = 'Active';

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color fieldBackground = Color(0xFFEAF4EE);
  static const Color fieldBorder = Color(0xFFD7E9DD);
  static const Color textDark = Color(0xFF304438);
  static const Color textGrey = Color(0xFF718078);

  final List<String> statuses = [
    'Active',
    'Inactive',
    'Dead',
    'Removed',
  ];

  @override
  void dispose() {
    _varietyController.dispose();
    _plantingYearController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ==============================================================
  // SELECT PLANTING YEAR
  // ==============================================================
  Future<void> _selectPlantingYear() async {
    final currentYear = DateTime.now().year;

    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(currentYear),
      firstDate: DateTime(1950),
      lastDate: DateTime(currentYear),
    );

    if (date != null) {
      setState(() {
        _plantingYearController.text =
            date.year.toString();
      });
    }
  }

  // ==============================================================
  // SUBMIT TREE
  // ==============================================================
  Future<void> _submitTree() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final treeData = {
        'farmId': widget.farmId,
        'blockId': widget.blockId,
        'variety': _varietyController.text.trim(),
        'plantingYear':
            _plantingYearController.text.trim(),
        'status': _status,
        'latitude': _latitudeController.text.trim(),
        'longitude': _longitudeController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      debugPrint('ADD TREE: $treeData');

      // TODO:
      // Connect this to ApiServices.addTree()

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tree added successfully',
          ),
          backgroundColor: primaryGreen,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
                  'Exception: ',
                  '',
                ),
          ),
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

  // ==============================================================
  // BUILD
  // ==============================================================
  @override
  Widget build(BuildContext context) {
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
              // ====================================================
              // HEADER
              // ====================================================
              Container(
                width: double.infinity,
                height: 52,
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
                        padding: EdgeInsets.all(3),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),

                    const SizedBox(width: 7),

                    const Text(
                      'Add Tree',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              // ====================================================
              // CONTENT
              // ====================================================
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    25,
                    18,
                    30,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // ==========================================
                        // BLOCK INFORMATION
                        // ==========================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF4F9F5),
                            borderRadius:
                                BorderRadius.circular(8),
                            border: Border.all(
                              color: fieldBorder,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Adding tree to',
                                style: TextStyle(
                                  color: textGrey,
                                  fontSize: 8,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                widget.blockName,
                                style: const TextStyle(
                                  color: textDark,
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Block ID: ${widget.blockId}',
                                style: const TextStyle(
                                  color: textGrey,
                                  fontSize: 8,
                                ),
                              ),

                              const SizedBox(height: 2),

                              Text(
                                'Farm ID: ${widget.farmId}',
                                style: const TextStyle(
                                  color: textGrey,
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ==========================================
                        // TREE CODE
                        // ==========================================
                     

                        _gap(),

                        // ==========================================
                        // VARIETY
                        // ==========================================
                        _buildField(
                          controller:
                              _varietyController,
                          hint: 'Cashew variety',
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Cashew variety is required';
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // ==========================================
                        // PLANTING YEAR
                        // ==========================================
                        _buildField(
                          controller:
                              _plantingYearController,
                          hint: 'Planting year',
                          readOnly: true,
                          onTap: _selectPlantingYear,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Planting year is required';
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // ==========================================
                        // STATUS
                        // ==========================================
                        DropdownButtonFormField<String>(
                          value: _status,
                          isExpanded: true,
                          decoration: _fieldDecoration(
                            'Tree status',
                          ),
                          items: statuses
                              .map(
                                (status) =>
                                    DropdownMenuItem(
                                  value: status,
                                  child: Text(
                                    status,
                                    style:
                                        const TextStyle(
                                      fontSize: 10,
                                      color: textDark,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _status = value;
                            });
                          },
                        ),

                        const SizedBox(height: 22),

                        // ==========================================
                        // LOCATION TITLE
                        // ==========================================
                        const Text(
                          'Tree Location',
                          style: TextStyle(
                            color: primaryGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          'Optional GPS coordinates for this tree.',
                          style: TextStyle(
                            color: textGrey,
                            fontSize: 8,
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ==========================================
                        // LATITUDE / LONGITUDE
                        // ==========================================
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                controller:
                                    _latitudeController,
                                hint: 'Latitude',
                                keyboardType:
                                    const TextInputType
                                        .numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: _buildField(
                                controller:
                                    _longitudeController,
                                hint: 'Longitude',
                                keyboardType:
                                    const TextInputType
                                        .numberWithOptions(
                                  decimal: true,
                                  signed: true,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // ==========================================
                        // NOTES
                        // ==========================================
                        _buildField(
                          controller: _notesController,
                          hint:
                              'Notes / tree description',
                          minLines: 4,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 45),

                        // ==========================================
                        // SUBMIT
                        // ==========================================
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: _isLoading
                                ? null
                                : _submitTree,
                            icon: _isLoading
                                ? const SizedBox.shrink()
                                : const Icon(
                                    Icons.park_outlined,
                                    size: 16,
                                  ),
                            label: _isLoading
                                ? const SizedBox(
                                    width: 19,
                                    height: 19,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Add Tree',
                                    style: TextStyle(
                                      fontSize: 11,
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
                                      .withOpacity(0.6),
                              elevation: 0,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(
                                  8,
                                ),
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

  // ==============================================================
  // FIELD
  // ==============================================================
  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
    int minLines = 1,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      onTap: onTap,
      minLines: minLines,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 11,
        color: textDark,
      ),
      decoration: _fieldDecoration(hint).copyWith(
        contentPadding: EdgeInsets.symmetric(
          horizontal: 13,
          vertical: maxLines > 1 ? 15 : 14,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    String hint,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 10,
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
        borderSide: const BorderSide(
          color: fieldBorder,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      errorStyle: const TextStyle(
        fontSize: 9,
      ),
    );
  }

  Widget _gap() {
    return const SizedBox(height: 12);
  }
}