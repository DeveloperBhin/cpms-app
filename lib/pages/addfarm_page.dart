import 'package:flutter/material.dart';

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

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color fieldBackground = Color(0xFFEAF4EE);
  static const Color fieldBorder = Color(0xFFD7E9DD);

  @override
  void dispose() {
    _farmNameController.dispose();
    _farmTypeController.dispose();
    _farmSizeController.dispose();
    _plantingDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // ==============================================================
  // SELECT PLANTING DATE
  // ==============================================================
  Future<void> _selectPlantingDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _plantingDateController.text =
            '${date.day.toString().padLeft(2, '0')}/'
            '${date.month.toString().padLeft(2, '0')}/'
            '${date.year}';
      });
    }
  }

  // ==============================================================
  // SUBMIT FARM
  // ==============================================================
  Future<void> _submitFarm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Connect this to ApiServices.addFarm()

      debugPrint('Farm Name: ${_farmNameController.text}');
      debugPrint('Farm Type: ${_farmTypeController.text}');
      debugPrint('Farm Size: ${_farmSizeController.text}');
      debugPrint('Planting Date: ${_plantingDateController.text}');
      debugPrint('Notes: ${_notesController.text}');

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Farm added successfully'),
          backgroundColor: primaryGreen,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
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

                    const Text(
                      'Add Farm',
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
              // FORM
              // ====================================================
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    18,
                    42,
                    18,
                    30,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // FARM NAME
                        _buildField(
                          controller: _farmNameController,
                          hint: 'Farm name',
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Farm name is required';
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // FARM TYPE
                        _buildField(
                          controller: _farmTypeController,
                          hint: 'Farm type',
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Farm type is required';
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // FARM SIZE
                        _buildField(
                          controller: _farmSizeController,
                          hint: 'Farm size / acres',
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Farm size is required';
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // PLANTING DATE
                        _buildField(
                          controller: _plantingDateController,
                          hint: 'Planting date',
                          readOnly: true,
                          onTap: _selectPlantingDate,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Planting date is required';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        // NOTES / LOCATION
                        _buildField(
                          controller: _notesController,
                          hint: 'Notes / location description',
                          maxLines: 5,
                          minLines: 5,
                        ),

                        const SizedBox(height: 72),

                        // ==========================================
                        // SUBMIT
                        // ==========================================
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _submitFarm,
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
                                    'Submit Farm',
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
    int maxLines = 1,
    int minLines = 1,
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