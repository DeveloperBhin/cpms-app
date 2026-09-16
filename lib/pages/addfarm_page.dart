import 'package:flutter/material.dart';
import '../services/api_services/farm_api_services.dart';
import 'package:flutter/foundation.dart';
import '../services/api_services/api_services.dart';


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
    '${date.year}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';
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

  final acreage = double.tryParse(
    _farmSizeController.text.trim(),
  );

  if (acreage == null || acreage <= 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please enter a valid farm size'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
    _isLoading = true;
  });

  try {
    // ==========================================
    // 1. GET ACTUAL LOGGED-IN USER
    // ==========================================
    final currentUserResponse =
        await ApiServices.getCurrentUser();

    debugPrint(
      'CURRENT USER RESPONSE: $currentUserResponse',
    );

    // Support:
    // { "data": {...} }
    // OR
    // { ...user fields... }

    final dynamic rawUser =
        currentUserResponse['data'];

    final Map<String, dynamic> user;

    if (rawUser is Map) {
      user = Map<String, dynamic>.from(rawUser);
    } else {
      user = currentUserResponse;
    }

    // ==========================================
    // 2. GET ACTUAL FARMER ID
    // ==========================================
    final dynamic rawFarmerId =
        user['farmerId'] ?? user['id'];

    final farmerId = int.tryParse(
      rawFarmerId?.toString() ?? '',
    );

    if (farmerId == null) {
      throw Exception(
        'Farmer ID was not returned by the server',
      );
    }

    // ==========================================
    // 3. GET ACTUAL PROFILE LOCATION
    // ==========================================
    final region =
        user['region']?.toString().trim() ?? '';

    final district =
        user['district']?.toString().trim() ?? '';

    final ward =
        user['ward']?.toString().trim() ?? '';

    final village =
        user['village']?.toString().trim() ?? '';

    if (region.isEmpty ||
        district.isEmpty ||
        ward.isEmpty ||
        village.isEmpty) {
      throw Exception(
        'Your profile location information is incomplete',
      );
    }

    // ==========================================
    // 4. CREATE FARM
    // ==========================================
    final result =
        await FarmApiServices.createFarm(
      name: _farmNameController.text.trim(),
      farmerId: farmerId,
      acreage: acreage,
      plantingDate:
          _plantingDateController.text.trim(),
      farmType:
          _farmTypeController.text
              .trim()
              .toUpperCase(),

      farmLocation:
          _notesController.text.trim(),

      region: region,
      district: district,
      ward: ward,
      village: village,

      // GPS will be connected next.
      latitude: 0.0,
      longitude: 0.0,
    );

    debugPrint(
      'CREATE FARM RESULT: $result',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Farm added successfully',
        ),
        backgroundColor: primaryGreen,
      ),
    );

    // true tells FarmsPage that data changed.
    Navigator.pop(context, true);
  } catch (e) {
    debugPrint(
      'CREATE FARM ERROR: $e',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          e
              .toString()
              .replaceFirst(
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
                  padding: const EdgeInsets.fromLTRB(18, 42, 18, 30),
                 child: Form(
  key: _formKey,
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // FARM NAME
      _buildLabel('Farm Name'),
      const SizedBox(height: 7),

      _buildField(
        controller: _farmNameController,
        hint: 'Farm Name',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Farm name is required';
          }
          return null;
        },
      ),

      const SizedBox(height: 18),

      // PLANTING DATE
      _buildLabel('Planting Date'),
      const SizedBox(height: 7),

      _buildField(
        controller: _plantingDateController,
        hint: 'Planting Date',
        readOnly: true,
        onTap: _selectPlantingDate,
        suffixIcon: const Icon(
          Icons.calendar_today_outlined,
          size: 18,
          color: Color(0xFF087A2F),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Planting date is required';
          }
          return null;
        },
      ),

      const SizedBox(height: 18),

      // FARM TYPE
      _buildLabel('Farm Type'),
      const SizedBox(height: 7),

      _buildFarmTypeDropdown(),

      const SizedBox(height: 18),

      // FARM SIZE
      _buildLabel('Farm Size'),
      const SizedBox(height: 7),

      _buildField(
        controller: _farmSizeController,
        hint: 'Farm Size',
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
        ),
        suffixText: 'Acres',
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Farm size is required';
          }

          final size = double.tryParse(value.trim());

          if (size == null || size <= 0) {
            return 'Enter a valid farm size';
          }

          return null;
        },
      ),

      const SizedBox(height: 40),

      // SUBMIT
      SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitFarm,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            disabledBackgroundColor:
                primaryGreen.withOpacity(0.6),
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
              : const Text(
                  'Submit Farm',
                  style: TextStyle(
                    fontSize: 12,
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

  // ==============================================================
  // FIELD
  // ==============================================================

  Widget _buildLabel(String label) {
  return Text(
    label,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF304438),
    ),
  );
}

Widget _buildFarmTypeDropdown() {
  return DropdownButtonFormField<String>(
    value: _farmTypeController.text.isEmpty
        ? null
        : _farmTypeController.text,
    isExpanded: true,
    decoration: InputDecoration(
      hintText: 'Select Farm Type',
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
      errorStyle: const TextStyle(fontSize: 9),
    ),
    items: const [
      DropdownMenuItem(
        value: 'NEW',
        child: Text(
          'New Farm',
          style: TextStyle(fontSize: 11),
        ),
      ),
      DropdownMenuItem(
        value: 'PRODUCTION',
        child: Text(
          'Production Farm',
          style: TextStyle(fontSize: 11),
        ),
      ),
    ],
    onChanged: (value) {
      if (value != null) {
        setState(() {
          _farmTypeController.text = value;
        });
      }
    },
    validator: (value) {
      if (value == null || value.isEmpty) {
        return 'Farm type is required';
      }
      return null;
    },
  );
}
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
      fontSize: 11,
      color: Color(0xFF304438),
    ),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 10,
        color: Colors.grey.shade500,
      ),

      suffixText: suffixText,
      suffixIcon: suffixIcon,

      suffixStyle: const TextStyle(
        fontSize: 10,
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

      errorStyle: const TextStyle(fontSize: 9),
    ),
  );
}

  Widget _gap() {
    return const SizedBox(height: 12);
  }
}
