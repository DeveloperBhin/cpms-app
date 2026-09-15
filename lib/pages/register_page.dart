// import 'package:flutter/material.dart';
// import '../services/api_services/api_services.dart';

// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});

//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }

// class _RegisterPageState extends State<RegisterPage> {
//   final _formKey = GlobalKey<FormState>();

//   final TextEditingController _nameController =
//       TextEditingController();

//   final TextEditingController _emailController =
//       TextEditingController();

//   final TextEditingController _phoneController =
//       TextEditingController();

//   final TextEditingController _passwordController =
//       TextEditingController();

//   final TextEditingController _confirmPasswordController =
//       TextEditingController();

//   bool _obscurePassword = true;
//   bool _obscureConfirmPassword = true;

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   bool _isLoading = false;

// Future<void> _register() async {
//   if (!_formKey.currentState!.validate()) {
//     return;
//   }

//   setState(() {
//     _isLoading = true;
//   });

//   try {
//     final result = await ApiServices.register(
//       fullName: _nameController.text.trim(),
//       email: _emailController.text.trim(),
//       phone: _phoneController.text.trim(),
//       password: _passwordController.text,
//     );

//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           result['message'] ?? 'Registration successful',
//         ),
//         backgroundColor: Colors.green,
//       ),
//     );

//     // Go back to Login page
//     Navigator.pop(context);

//   } catch (e) {
//     if (!mounted) return;

//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           e.toString().replaceFirst('Exception: ', ''),
//         ),
//         backgroundColor: Colors.red,
//       ),
//     );
//   } finally {
//     if (mounted) {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }

//  @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     backgroundColor: Colors.white,

//     appBar: AppBar(
//       backgroundColor: Colors.white,
//       elevation: 0,
//       iconTheme: const IconThemeData(
//         color: Colors.black,
//       ),
//     ),

//     body: SafeArea(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.symmetric(
//           horizontal: 25,
//         ),

//         child: Form(
//           key: _formKey,

//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 10),

//               // =========================================================
//               // LOGO
//               // =========================================================
//               Center(
//                 child: Container(
//                   width: 90,
//                   height: 90,
//                   padding: const EdgeInsets.all(4),
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     border: Border.all(
//                       color: Colors.green,
//                       width: 3,
//                     ),
//                   ),
//                   child: ClipOval(
//                     child: Image.asset(
//                       'assets/images/app_icon.png',
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),

//               // =========================================================
//               // TITLE
//               // =========================================================
//               const Center(
//                 child: Text(
//                   'Create Account',
//                   style: TextStyle(
//                     fontSize: 26,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 5),

//               const Center(
//                 child: Text(
//                   'Join TARI Disease Detector',
//                   style: TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 30),

//               // =========================================================
//               // FULL NAME
//               // =========================================================
//               const Text(
//                 'Full Name',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               TextFormField(
//                 controller: _nameController,
//                 keyboardType: TextInputType.name,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your full name',
//                   prefixIcon: const Icon(
//                     Icons.person_outline,
//                     color: Colors.green,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                       color: Colors.green,
//                       width: 2,
//                     ),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your full name';
//                   }
//                   return null;
//                 },
//               ),

//               const SizedBox(height: 18),

//               // =========================================================
//               // EMAIL
//               // =========================================================
//               const Text(
//                 'Email',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               TextFormField(
//                 controller: _emailController,
//                 keyboardType: TextInputType.emailAddress,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your email',
//                   prefixIcon: const Icon(
//                     Icons.email_outlined,
//                     color: Colors.green,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                       color: Colors.green,
//                       width: 2,
//                     ),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your email';
//                   }

//                   if (!value.contains('@')) {
//                     return 'Please enter a valid email';
//                   }

//                   return null;
//                 },
//               ),

//               const SizedBox(height: 18),

//               // =========================================================
//               // PHONE
//               // =========================================================
//               const Text(
//                 'Phone Number',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               TextFormField(
//                 controller: _phoneController,
//                 keyboardType: TextInputType.phone,
//                 decoration: InputDecoration(
//                   hintText: 'Enter your phone number',
//                   prefixIcon: const Icon(
//                     Icons.phone_outlined,
//                     color: Colors.green,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                       color: Colors.green,
//                       width: 2,
//                     ),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.trim().isEmpty) {
//                     return 'Please enter your phone number';
//                   }

//                   return null;
//                 },
//               ),

//               const SizedBox(height: 18),

//               // =========================================================
//               // PASSWORD
//               // =========================================================
//               const Text(
//                 'Password',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               TextFormField(
//                 controller: _passwordController,
//                 obscureText: _obscurePassword,
//                 decoration: InputDecoration(
//                   hintText: 'Create a password',
//                   prefixIcon: const Icon(
//                     Icons.lock_outline,
//                     color: Colors.green,
//                   ),
//                   suffixIcon: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         _obscurePassword = !_obscurePassword;
//                       });
//                     },
//                     icon: Icon(
//                       _obscurePassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                       color: Colors.green,
//                       width: 2,
//                     ),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a password';
//                   }

//                   if (value.length < 6) {
//                     return 'Password must be at least 6 characters';
//                   }

//                   return null;
//                 },
//               ),

//               const SizedBox(height: 18),

//               // =========================================================
//               // CONFIRM PASSWORD
//               // =========================================================
//               const Text(
//                 'Confirm Password',
//                 style: TextStyle(
//                   fontSize: 14,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const SizedBox(height: 8),

//               TextFormField(
//                 controller: _confirmPasswordController,
//                 obscureText: _obscureConfirmPassword,
//                 decoration: InputDecoration(
//                   hintText: 'Confirm your password',
//                   prefixIcon: const Icon(
//                     Icons.lock_outline,
//                     color: Colors.green,
//                   ),
//                   suffixIcon: IconButton(
//                     onPressed: () {
//                       setState(() {
//                         _obscureConfirmPassword =
//                             !_obscureConfirmPassword;
//                       });
//                     },
//                     icon: Icon(
//                       _obscureConfirmPassword
//                           ? Icons.visibility_off
//                           : Icons.visibility,
//                     ),
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12),
//                     borderSide: const BorderSide(
//                       color: Colors.green,
//                       width: 2,
//                     ),
//                   ),
//                 ),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please confirm your password';
//                   }

//                   if (value != _passwordController.text) {
//                     return 'Passwords do not match';
//                   }

//                   return null;
//                 },
//               ),

//               const SizedBox(height: 28),

//               // =========================================================
//               // REGISTER BUTTON
//               // =========================================================
//               SizedBox(
//                 width: double.infinity,
//                 height: 52,
//                 child: ElevatedButton(
//                   onPressed: _isLoading ? null : _register,

//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     disabledBackgroundColor: Colors.green.shade300,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),

//                   child: _isLoading
//                       ? const SizedBox(
//                           width: 24,
//                           height: 24,
//                           child: CircularProgressIndicator(
//                             strokeWidth: 2.5,
//                             color: Colors.white,
//                           ),
//                         )
//                       : const Text(
//                           'Create Account',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                 ),
//               ),

//               const SizedBox(height: 18),

//               // =========================================================
//               // LOGIN
//               // =========================================================
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Text(
//                     'Already have an account?',
//                     style: TextStyle(
//                       color: Colors.grey,
//                     ),
//                   ),

//                   TextButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     child: const Text(
//                       'Login',
//                       style: TextStyle(
//                         color: Colors.green,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               const SizedBox(height: 15),

//               // =========================================================
//               // POWERED BY
//               // =========================================================
//               const Center(
//                 child: Text(
//                   'Powered by TARI',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
// }


import 'package:flutter/material.dart';

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
            result['message'] ?? 'Registration successful',
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
        child: Container(
          width: double.infinity,
          height: double.infinity,

          decoration: const BoxDecoration(
            color: Colors.white,

            // Screenshot has rounded bottom corners
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

                  // Rounded right side like screenshot
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(35),
                  ),
                ),

                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),

                child: Row(
                  children: [
                    // BACK BUTTON
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

                    // TITLE
                    const Expanded(
                      child: Column(
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,

                        children: [
                          Text(
                            'Create Account',

                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),

                          SizedBox(height: 2),

                          Text(
                            'Register farmer or staff',

                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // CLOSE
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
                      ScrollViewKeyboardDismissBehavior.onDrag,

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
                        // FULL NAME
// FULL NAME
_buildField(
  controller: _nameController,
  hint: 'Full Name',
  keyboardType: TextInputType.name,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  },
),

_gap(),

// USERNAME
_buildField(
  controller: _usernameController,
  hint: 'Username',
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    return null;
  },
),

_gap(),

// REGION
_buildField(
  controller: _regionController,
  hint: 'Region',
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Region is required';
    }
    return null;
  },
),

_gap(),

// DISTRICT
_buildField(
  controller: _districtController,
  hint: 'District',
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'District is required';
    }
    return null;
  },
),

_gap(),

// WARD
_buildField(
  controller: _wardController,
  hint: 'Ward',
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ward is required';
    }
    return null;
  },
),

_gap(),

// VILLAGE
_buildField(
  controller: _villageController,
  hint: 'Village',
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Village is required';
    }
    return null;
  },
),

_gap(),

// PHONE NUMBER
_buildField(
  controller: _phoneController,
  hint: 'Phone Number',
  keyboardType: TextInputType.phone,
  validator: (value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    return null;
  },
),

_gap(),

// PASSWORD
_buildField(
  controller: _passwordController,
  hint: 'Password',
  obscureText: true,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Minimum 6 characters';
    }

    return null;
  },
),

_gap(),

// CONFIRM PASSWORD
_buildField(
  controller: _confirmPasswordController,
  hint: 'Confirm Password',
  obscureText: true,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Confirm password is required';
    }

    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  },
),

                        const SizedBox(height: 42),

                        // =======================================
                        // REGISTER BUTTON
                        // =======================================

                        SizedBox(
                          width: double.infinity,
                          height: 46,

                          child: ElevatedButton(
                            onPressed:
                                _isLoading ? null : _register,

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
                                : const Text(
                                    'Register',

                                    style: TextStyle(
                                      fontSize: 11,
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

        contentPadding: const EdgeInsets.symmetric(
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

      validator: validator,
    );
  }

  Widget _gap() {
    return const SizedBox(height: 12);
  }
}