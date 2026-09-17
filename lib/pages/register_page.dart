import 'package:flutter/material.dart';
import '../theme/app_text_styles.dart';
import '../l10n/app_localizations.dart';
import '../services/api_services/api_services.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _regionController = TextEditingController();
  final _districtController = TextEditingController();
  final _wardController = TextEditingController();
  final _villageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color fieldBackground = Color(0xFFEAF4EE);
  static const Color fieldBorder = Color(0xFFD7E9DD);

  AppLocalizations get _l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _regionController.dispose();
    _districtController.dispose();
    _wardController.dispose();
    _villageController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiServices.register(
        fullName: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        region: _regionController.text.trim(),
        district: _districtController.text.trim(),
        ward: _wardController.text.trim(),
        village: _villageController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                _l10n.registrationSuccessful,
          ),
          backgroundColor: primaryGreen,
        ),
      );

      Navigator.pop(context);
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final l10n = _l10n;

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
                height: 68,
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(35),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 15,
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.createAccount,
                            style: const TextStyle(
                              color: Colors.white,
  fontSize: AppTextStyles.bodyLarge,
                              fontWeight:
                                  FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.registerFarmerOrStaff,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: AppTextStyles.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    ),

                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
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
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    20,
                    22,
                    20,
                    30,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // =========================================
                        // FULL NAME
                        // =========================================

                        _buildField(
                          controller: _nameController,
                          hint: l10n.fullName,
                          keyboardType:
                              TextInputType.name,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return l10n
                                  .fullNameRequired;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =========================================
                        // USERNAME
                        // =========================================

                        _buildField(
                          controller:
                              _usernameController,
                          hint: l10n.username,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return l10n
                                  .usernameRequired;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =========================================
                        // REGION
                        // =========================================

                        _buildField(
                          controller:
                              _regionController,
                          hint: l10n.region,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return l10n
                                  .regionRequired;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =========================================
                        // DISTRICT
                        // =========================================

                        _buildField(
                          controller:
                              _districtController,
                          hint: l10n.district,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return l10n
                                  .districtRequired;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =========================================
                        // WARD
                        // =========================================

                        _buildField(
                          controller: _wardController,
                          hint: l10n.ward,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return l10n.wardRequired;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =========================================
                        // VILLAGE
                        // =========================================

                        _buildField(
                          controller:
                              _villageController,
                          hint: l10n.village,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return l10n
                                  .villageRequired;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =========================================
                        // PHONE NUMBER
                        // =========================================

                        _buildField(
                          controller:
                              _phoneController,
                          hint: l10n.phoneNumber,
                          keyboardType:
                              TextInputType.phone,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return l10n
                                  .phoneNumberRequired;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =========================================
                        // PASSWORD
                        // =========================================

                        _buildField(
                          controller:
                              _passwordController,
                          hint: l10n.password,
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return l10n
                                  .passwordRequired;
                            }

                            if (value.length < 6) {
                              return l10n
                                  .minimumSixCharacters;
                            }

                            return null;
                          },
                        ),

                        _gap(),

                        // =========================================
                        // CONFIRM PASSWORD
                        // =========================================

                        _buildField(
                          controller:
                              _confirmPasswordController,
                          hint: l10n.confirmPassword,
                          obscureText: true,
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return l10n
                                  .confirmPasswordRequired;
                            }

                            if (value !=
                                _passwordController
                                    .text) {
                              return l10n
                                  .passwordsDoNotMatch;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 42),

                        // =========================================
                        // REGISTER BUTTON
                        // =========================================

                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _register,
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
                                : Text(
                                    l10n.register,
                                    style:
                                        const TextStyle(
                                      fontSize: AppTextStyles.body,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 20),
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
  // FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(
  fontSize: AppTextStyles.body,
        color: Color(0xFF304438),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontSize: AppTextStyles.bodySmall,
          color: Colors.grey.shade500,
        ),
        filled: true,
        fillColor: fieldBackground,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: fieldBorder,
            width: 1,
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
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: AppTextStyles.bodySmall,
        ),
      ),
      validator: validator,
    );
  }

  Widget _gap() {
    return const SizedBox(height: 12);
  }
}