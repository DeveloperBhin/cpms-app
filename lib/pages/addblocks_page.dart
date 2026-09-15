import 'package:flutter/material.dart';

class AddBlockPage extends StatefulWidget {
  final String farmId;
  final String farmName;

  const AddBlockPage({
    super.key,
    required this.farmId,
    required this.farmName,
  });

  @override
  State<AddBlockPage> createState() => _AddBlockPageState();
}

class _AddBlockPageState extends State<AddBlockPage> {
  final _formKey = GlobalKey<FormState>();

  final _blockNameController = TextEditingController();
  final _blockSizeController = TextEditingController();
  final _numberOfTreesController = TextEditingController();
  final _varietyController = TextEditingController();
  final _plantingYearController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isLoading = false;

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color fieldBackground = Color(0xFFEAF4EE);
  static const Color fieldBorder = Color(0xFFD7E9DD);

  @override
  void dispose() {
    _blockNameController.dispose();
    _blockSizeController.dispose();
    _numberOfTreesController.dispose();
    _varietyController.dispose();
    _plantingYearController.dispose();
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
        _plantingYearController.text = date.year.toString();
      });
    }
  }

  // ==============================================================
  // SUBMIT BLOCK
  // ==============================================================
  Future<void> _submitBlock() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final blockData = {
        'farmId': widget.farmId,
        'blockName': _blockNameController.text.trim(),
        'size': _blockSizeController.text.trim(),
        'numberOfTrees': _numberOfTreesController.text.trim(),
        'variety': _varietyController.text.trim(),
        'plantingYear': _plantingYearController.text.trim(),
        'notes': _notesController.text.trim(),
      };

      debugPrint('ADD BLOCK: $blockData');

      // TODO:
      // final result = await ApiServices.addBlock(...);

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Block added successfully',
          ),
          backgroundColor: primaryGreen,
        ),
      );

      // Return true so BlocksPage knows something was added.
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

                    const Expanded(
                      child: Text(
                        'Add Block',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ====================================================
              // FORM
              // ====================================================
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    30,
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
                        // FARM
                        // ==========================================
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(13),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF4F9F5),
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
                                'Farm',
                                style: TextStyle(
                                  color: Color(0xFF718078),
                                  fontSize: 8,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                widget.farmName,
                                style: const TextStyle(
                                  color: Color(0xFF304438),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),

                              const SizedBox(height: 3),

                              Text(
                                'Farm ID: ${widget.farmId}',
                                style: const TextStyle(
                                  color: Color(0xFF718078),
                                  fontSize: 8,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ==========================================
                        // BLOCK NAME
                        // ==========================================
                        _buildField(
                          controller: _blockNameController,
                          hint: 'Block name',
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Block name is required';
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // ==========================================
                        // BLOCK SIZE
                        // ==========================================
                        _buildField(
                          controller: _blockSizeController,
                          hint: 'Block size / acres',
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Block size is required';
                            }

                            final size = double.tryParse(
                              value.trim(),
                            );

                            if (size == null || size <= 0) {
                              return 'Enter a valid block size';
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // ==========================================
                        // NUMBER OF TREES
                        // ==========================================
                        _buildField(
                          controller:
                              _numberOfTreesController,
                          hint: 'Number of trees',
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Number of trees is required';
                            }

                            final trees = int.tryParse(
                              value.trim(),
                            );

                            if (trees == null || trees < 0) {
                              return 'Enter a valid number of trees';
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // ==========================================
                        // CASHEW VARIETY
                        // ==========================================
                        _buildField(
                          controller: _varietyController,
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

                        const SizedBox(height: 24),

                        // ==========================================
                        // NOTES
                        // ==========================================
                        _buildField(
                          controller: _notesController,
                          hint: 'Notes / block description',
                          minLines: 4,
                          maxLines: 4,
                        ),

                        const SizedBox(height: 50),

                        // ==========================================
                        // SUBMIT BUTTON
                        // ==========================================
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _submitBlock,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              foregroundColor: Colors.white,
                              disabledBackgroundColor:
                                  primaryGreen.withOpacity(0.6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
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
                                    'Submit Block',
                                    style: TextStyle(
                                      fontSize: 11,
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
        color: Color(0xFF304438),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: 10,
          color: Colors.grey.shade500,
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
      ),
    );
  }

  Widget _gap() {
    return const SizedBox(height: 12);
  }
}