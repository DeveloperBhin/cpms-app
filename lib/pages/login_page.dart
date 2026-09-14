// import 'package:flutter/material.dart';

// import '../services/api_services/api_services.dart';
// import 'register_page.dart';
// import 'scan_page.dart';
// import 'me_page.dart';
// import 'main_page.dart';
// import 'index_page.dart';

// class LoginPage extends StatefulWidget {
//   const LoginPage({super.key});

//   @override
//   State<LoginPage> createState() => _LoginPageState();
// }

// class _LoginPageState extends State<LoginPage> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _emailController =
//       TextEditingController();

//   final TextEditingController _passwordController =
//       TextEditingController();

//   bool _obscurePassword = true;
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   // =========================
//   // LOGIN
//   // =========================

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final result = await ApiServices.login(
//         email: _emailController.text.trim(),
//         password: _passwordController.text,
//       );

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             result['message'] ?? 'Login successful',
//           ),
//           backgroundColor: Colors.green,
//         ),
//       );

//       // Go to MePage after successful login
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(
//           builder: (context) => const MainPage(),
//         ),
//       );
//     } catch (e) {
//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//             e.toString().replaceFirst(
//               'Exception: ',
//               '',
//             ),
//           ),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,

//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(
//           color: Colors.black,
//         ),
//       ),

//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.symmetric(
//             horizontal: 25,
//           ),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),

//                 // =========================
//                 // LOGO
//                 // =========================

//                 Center(
//                   child: Container(
//                     width: 90,
//                     height: 90,
//                     padding: const EdgeInsets.all(4),
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       border: Border.all(
//                         color: Colors.green,
//                         width: 3,
//                       ),
//                     ),
//                     child: ClipOval(
//                       child: Image.asset(
//                         'assets/images/app_icon.png',
//                         fit: BoxFit.cover,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // =========================
//                 // TITLE
//                 // =========================

//                 const Center(
//                   child: Text(
//                     'Welcome Back',
//                     style: TextStyle(
//                       fontSize: 26,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 5),

//                 const Center(
//                   child: Text(
//                     'Login to TARI Disease Detector',
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 35),

//                 // =========================
//                 // EMAIL
//                 // =========================

//                 const Text(
//                   'Email',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 TextFormField(
//                   controller: _emailController,
//                   keyboardType: TextInputType.emailAddress,
//                   decoration: InputDecoration(
//                     hintText: 'Enter your email',
//                     prefixIcon: const Icon(
//                       Icons.email_outlined,
//                       color: Colors.green,
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: Colors.green,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null ||
//                         value.trim().isEmpty) {
//                       return 'Please enter your email';
//                     }

//                     if (!value.contains('@')) {
//                       return 'Please enter a valid email';
//                     }

//                     return null;
//                   },
//                 ),

//                 const SizedBox(height: 20),

//                 // =========================
//                 // PASSWORD
//                 // =========================

//                 const Text(
//                   'Password',
//                   style: TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 TextFormField(
//                   controller: _passwordController,
//                   obscureText: _obscurePassword,
//                   decoration: InputDecoration(
//                     hintText: 'Enter your password',
//                     prefixIcon: const Icon(
//                       Icons.lock_outline,
//                       color: Colors.green,
//                     ),
//                     suffixIcon: IconButton(
//                       onPressed: () {
//                         setState(() {
//                           _obscurePassword =
//                               !_obscurePassword;
//                         });
//                       },
//                       icon: Icon(
//                         _obscurePassword
//                             ? Icons.visibility_off
//                             : Icons.visibility,
//                       ),
//                     ),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     focusedBorder: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(12),
//                       borderSide: const BorderSide(
//                         color: Colors.green,
//                         width: 2,
//                       ),
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null ||
//                         value.isEmpty) {
//                       return 'Please enter your password';
//                     }

//                     return null;
//                   },
//                 ),

//                 // =========================
//                 // FORGOT PASSWORD
//                 // =========================

//                 Align(
//                   alignment: Alignment.centerRight,
//                   child: TextButton(
//                     onPressed: () {
//                       // Forgot password logic later
//                     },
//                     child: const Text(
//                       'Forgot Password?',
//                       style: TextStyle(
//                         color: Colors.green,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 10),

//                 // =========================
//                 // LOGIN BUTTON
//                 // =========================

//                 SizedBox(
//                   width: double.infinity,
//                   height: 52,
//                   child: ElevatedButton(
//                     onPressed:
//                         _isLoading ? null : _login,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.green,
//                       foregroundColor: Colors.white,
//                       disabledBackgroundColor:
//                           Colors.green.shade300,
//                       shape: RoundedRectangleBorder(
//                         borderRadius:
//                             BorderRadius.circular(12),
//                       ),
//                     ),
//                     child: _isLoading
//                         ? const SizedBox(
//                             width: 24,
//                             height: 24,
//                             child:
//                                 CircularProgressIndicator(
//                               strokeWidth: 2.5,
//                               color: Colors.white,
//                             ),
//                           )
//                         : const Text(
//                             'Login',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),

//                 const SizedBox(height: 25),

//                 // =========================
//                 // REGISTER
//                 // =========================

//                 Row(
//                   mainAxisAlignment:
//                       MainAxisAlignment.center,
//                   children: [
//                     const Text(
//                       "Don't have an account?",
//                       style: TextStyle(
//                         color: Colors.grey,
//                       ),
//                     ),

//                     TextButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) =>
//                                 const RegisterPage(),
//                           ),
//                         );
//                       },
//                       child: const Text(
//                         'Register',
//                         style: TextStyle(
//                           color: Colors.green,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 20),

//                 // =========================
//                 // POWERED BY
//                 // =========================

//                 const Center(
//                   child: Text(
//                     'Powered by TARI',
//                     style: TextStyle(
//                       fontSize: 12,
//                       color: Colors.grey,
//                     ),
//                   ),
//                 ),

//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

import '../services/api_services/api_services.dart';
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
            result['message'] ?? 'Login successful',
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
                      ScrollViewKeyboardDismissBehavior.onDrag,

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

                        const Text(
                          'Cashew Production\nManagement System',

                          textAlign: TextAlign.center,

                          style: TextStyle(
                            fontSize: 20,
                            height: 1.05,
                            fontWeight: FontWeight.w800,
                            color: titleColor,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          'Sign in to continue',

                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),

                        const SizedBox(height: 34),

                        // ======================================
                        // USERNAME / EMAIL
                        // ======================================

                        TextFormField(
                          controller: _usernameController,

                          keyboardType:
                              TextInputType.text,

                          textInputAction:
                              TextInputAction.next,

                          style: const TextStyle(
                            fontSize: 12,
                            color: titleColor,
                          ),

                          decoration: _inputDecoration(
                            hintText: 'Username',
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'Please enter your username';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 14),

                        // ======================================
                        // PASSWORD
                        // ======================================

                        TextFormField(
                          controller: _passwordController,

                          obscureText: _obscurePassword,

                          textInputAction:
                              TextInputAction.done,

                          onFieldSubmitted: (_) {
                            if (!_isLoading) {
                              _login();
                            }
                          },

                          style: const TextStyle(
                            fontSize: 12,
                            color: titleColor,
                          ),

                          decoration: _inputDecoration(
                            hintText: 'Password',

                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword =
                                      !_obscurePassword;
                                });
                              },

                              icon: Icon(
                                _obscurePassword
                                    ? Icons
                                        .visibility_off_outlined
                                    : Icons
                                        .visibility_outlined,

                                size: 18,

                                color:
                                    Colors.grey.shade500,
                              ),
                            ),
                          ),

                          validator: (value) {
                            if (value == null ||
                                value.isEmpty) {
                              return 'Please enter your password';
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
                            onPressed:
                                _isLoading ? null : _login,

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
                                : const Text(
                                    'Login',

                                    style: TextStyle(
                                      fontSize: 12,
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
                            const Text(
                              "Don't have an account? ",

                              style: TextStyle(
                                color: primaryGreen,
                                fontSize: 10,
                                fontWeight:
                                    FontWeight.w500,
                              ),
                            ),

                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,

                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RegisterPage(),
                                  ),
                                );
                              },

                              child: const Text(
                                'Register',

                                style: TextStyle(
                                  color: primaryGreen,
                                  fontSize: 10,
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

            // Small green line at bottom, matching design
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
        fontSize: 11,
      ),

      filled: true,

      fillColor: fieldBackground,

      isDense: true,

      suffixIcon: suffixIcon,

      contentPadding: const EdgeInsets.symmetric(
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

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),

        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.3,
        ),
      ),
    );
  }
}