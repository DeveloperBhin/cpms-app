import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../services/api_services/api_services.dart';
import '../theme/app_text_styles.dart';
import 'register_page.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  static const Color primaryGreen = Color(0xFF087A2F);
  static const Color fieldBackground = Color(0xFFEAF4EE);
  static const Color titleColor = Color(0xFF173D27);

  AppLocalizations get _l10n =>
      AppLocalizations.of(context)!;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await ApiServices.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['message']?.toString() ??
                _l10n.loginSuccessful,
          ),
          backgroundColor: primaryGreen,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MainPage(),
        ),
      );
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
        child: Column(
          children: [
            // ==================================================
            // GREEN TOP SECTION
            // ==================================================

            SizedBox(
              height: 190,
              width: double.infinity,
              child: Center(
                child: Container(
                  width: 74,
                  height: 74,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 52,
                      height: 52,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // WHITE LOGIN AREA
            // ==================================================

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 18),

                        // ======================================
                        // TITLE
                        // ======================================

                        Text(
                          l10n.cashewProductionManagementSystem,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
fontSize: AppTextStyles.heading,                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          l10n.signInToContinue,
                          style: TextStyle(
                            fontSize: AppTextStyles.bodySmall,
                            color: Colors.grey.shade500,
                          ),
                        ),

                        const SizedBox(height: 34),

                        // ======================================
                        // USERNAME
                        // ======================================

                        TextFormField(
                          controller:
                              _usernameController,
                          keyboardType:
                              TextInputType.text,
                          textInputAction:
                              TextInputAction.next,
                          style: const TextStyle(
fontSize: AppTextStyles.bodySmall,                            color: titleColor,
                          ),
                          decoration:
                              _inputDecoration(
                            hintText: l10n.username,
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return l10n
                                  .pleaseEnterUsername;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ======================================
                        // PASSWORD
                        // ======================================

                        TextFormField(
                          controller:
                              _passwordController,
                          obscureText:
                              _obscurePassword,
                          textInputAction:
                              TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (!_isLoading) {
                              _login();
                            }
                          },
                          style: const TextStyle(
                            fontSize: AppTextStyles.bodySmall,
                            color: titleColor,
                          ),
                          decoration:
                              _inputDecoration(
                            hintText: l10n.password,
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },
                              tooltip:
                                  _obscurePassword
                                      ? l10n.showPassword
                                      : l10n.hidePassword,
                              icon: Icon(
                                _obscurePassword
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,
                                size: 18,
                                color: Colors
                                    .grey.shade500,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return l10n
                                  .pleaseEnterPassword;
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 27),

                        // ======================================
                        // LOGIN BUTTON
                        // ======================================

                        SizedBox(
                          width: double.infinity,
                          height: 47,
                          child: ElevatedButton(
                            onPressed: _isLoading
                                ? null
                                : _login,
                            style:
                                ElevatedButton.styleFrom(
                              backgroundColor:
                                  primaryGreen,
                              foregroundColor:
                                  Colors.white,
                              disabledBackgroundColor:
                                  primaryGreen
                                      .withOpacity(0.65),
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
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    l10n.login,
                                    style:
                                        const TextStyle(
                                      fontSize: AppTextStyles.small,
                                      fontWeight:
                                          FontWeight.w700,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        // ======================================
                        // REGISTER
                        // ======================================

                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(
                              '${l10n.dontHaveAccount} ',
                              style:
                                  const TextStyle(
                                color: primaryGreen,
fontSize: AppTextStyles.small,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const RegisterPage(),
                                  ),
                                );
                              },
                              child: Text(
                                l10n.register,
                                style:
                                    const TextStyle(
                                  color: primaryGreen,
                                  fontSize: AppTextStyles.small,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // BOTTOM GREEN LINE
            // ==================================================

            Container(
              height: 10,
              color: primaryGreen,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade500,
        fontSize: AppTextStyles.tiny,
      ),
      filled: true,
      fillColor: fieldBackground,
      isDense: true,
      suffixIcon: suffixIcon,
      contentPadding:
          const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Color(0xFFD9EADF),
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.3,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.3,
        ),
      ),
    );
  }
}