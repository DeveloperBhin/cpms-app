/// SplashPage - Initial loading screen for
/// Cashew Production Management System (CPMS)
///
/// This page is shown when the application starts.
///
/// It:
/// - Loads the AI disease detection model
/// - Loads disease information
/// - Initializes application services
/// - Checks and validates the saved login session
///
/// Navigation:
/// - Valid saved session -> MainPage
/// - Missing/invalid session -> LoginPage

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/disease_info_loader.dart';
import '../providers/app_provider.dart';
import '../providers/auth_provider.dart';
import '../services/model_service.dart';
import '../theme/app_text_styles.dart';

import 'login_page.dart';
import 'main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({
    super.key,
  });

  @override
  State<SplashPage> createState() =>
      _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryGreen =
      Color(0xFF087A2F);

  static const Color darkGreen =
      Color(0xFF075C26);

  static const Color backgroundColor =
      Color(0xFFF8FAF8);

  // ============================================================
  // ANIMATION
  // ============================================================

  late AnimationController _animationController;

  late Animation<double> _scaleAnimation;

  // ============================================================
  // LOADING STATE
  // ============================================================

  String _loadingMessage = 'Initializing...';

  // ============================================================
  // INITIALIZE
  // ============================================================

  @override
  void initState() {
    super.initState();

    _setupAnimation();

    _initializeApp();
  }

  // ============================================================
  // SETUP LOGO ANIMATION
  // ============================================================

  void _setupAnimation() {
    _animationController =
        AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1500,
      ),
    )..repeat(
        reverse: true,
      );

    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  // ============================================================
  // UPDATE LOADING MESSAGE
  // ============================================================

  void _updateLoadingMessage(
    String message,
  ) {
    if (!mounted) {
      return;
    }

    setState(() {
      _loadingMessage = message;
    });
  }

  // ============================================================
  // INITIALIZE APPLICATION
  // ============================================================

  Future<void> _initializeApp() async {
    try {
      final modelService = ModelService();

      final diseaseInfoLoader =
          DiseaseInfoLoader();

      // --------------------------------------------------------
      // LOAD AI MODEL
      // --------------------------------------------------------

      _updateLoadingMessage(
        'Loading AI model...',
      );

      try {
        await modelService.loadModel();
      } catch (e) {
        // CPMS can continue working even when the
        // disease-detection model fails to load.

        debugPrint(
          'Warning: AI model loading failed: $e',
        );
      }

      // --------------------------------------------------------
      // LOAD DISEASE INFORMATION
      // --------------------------------------------------------

      _updateLoadingMessage(
        'Loading disease information...',
      );

      try {
        await diseaseInfoLoader
            .loadDiseaseInfo();
      } catch (e) {
        debugPrint(
          'Warning: Disease information loading failed: $e',
        );
      }

      // --------------------------------------------------------
      // UPDATE APPLICATION PROVIDER
      // --------------------------------------------------------

      if (!mounted) {
        return;
      }

      context
          .read<AppProvider>()
          .setModelLoaded(
            modelService.isModelLoaded,
          );

      // --------------------------------------------------------
      // CHECK AND VALIDATE LOGIN SESSION
      // --------------------------------------------------------

      _updateLoadingMessage(
        'Checking session...',
      );

      final authProvider =
          context.read<AuthProvider>();

      await authProvider.checkSession();

      if (!mounted) {
        return;
      }

      debugPrint(
        '================================',
      );

      debugPrint(
        'CPMS SESSION CHECK',
      );

      debugPrint(
        'AUTHENTICATED: '
        '${authProvider.isAuthenticated}',
      );

      if (authProvider.currentUser != null) {
        debugPrint(
          'CURRENT USER: '
          '${authProvider.currentUser}',
        );
      }

      debugPrint(
        '================================',
      );

      // --------------------------------------------------------
      // READY
      // --------------------------------------------------------

      _updateLoadingMessage(
        'Ready!',
      );

      await Future.delayed(
        const Duration(
          milliseconds: 500,
        ),
      );

      if (!mounted) {
        return;
      }

      // --------------------------------------------------------
      // NAVIGATE
      // --------------------------------------------------------

      if (authProvider.isAuthenticated) {
        _navigateToMain();
      } else {
        _navigateToLogin();
      }
    } catch (e, stackTrace) {
      debugPrint(
        'CPMS INITIALIZATION ERROR: $e',
      );

      debugPrint(
        'CPMS INITIALIZATION STACK: '
        '$stackTrace',
      );

      if (!mounted) {
        return;
      }

      context
          .read<AppProvider>()
          .setError(
            'Failed to initialize application: $e',
          );

      _updateLoadingMessage(
        'Unable to initialize application',
      );

      await Future.delayed(
        const Duration(
          seconds: 2,
        ),
      );

      if (!mounted) {
        return;
      }

      _navigateToLogin();
    }
  }

  // ============================================================
  // NAVIGATE TO LOGIN
  // ============================================================

  void _navigateToLogin() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // NAVIGATE TO MAIN
  // ============================================================

  void _navigateToMain() {
    if (!mounted) {
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const MainPage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE5F4E9),
              Color(0xFFF8FAF8),
              Colors.white,
            ],
            stops: [
              0.0,
              0.55,
              1.0,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 30,
              ),
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  // ============================================
                  // LOGO
                  // ============================================

                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 145,
                      height: 145,
                      padding:
                          const EdgeInsets.all(
                        8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryGreen
                              .withValues(
                            alpha: 0.18,
                          ),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: primaryGreen
                                .withValues(
                              alpha: 0.18,
                            ),
                            blurRadius: 28,
                            spreadRadius: 5,
                            offset:
                                const Offset(
                              0,
                              8,
                            ),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          fit: BoxFit.cover,
                          errorBuilder: (
                            context,
                            error,
                            stackTrace,
                          ) {
                            return Container(
                              color:
                                  const Color(
                                0xFFE7F3EB,
                              ),
                              alignment:
                                  Alignment
                                      .center,
                              child:
                                  const Icon(
                                Icons
                                    .agriculture_outlined,
                                size: 65,
                                color:
                                    primaryGreen,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 38,
                  ),

                  // ============================================
                  // TARI
                  // ============================================

                  const Text(
                    'TARI',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: primaryGreen,
                      fontSize:
                          AppTextStyles
                              .subtitle,
                      fontWeight:
                          FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  // ============================================
                  // SYSTEM NAME
                  // ============================================

                  const Text(
                    'CASHEW PRODUCTION',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: darkGreen,
                      fontSize:
                          AppTextStyles
                              .largeHeading,
                      fontWeight:
                          FontWeight.w800,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(
                    'MANAGEMENT SYSTEM',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: darkGreen,
                      fontSize:
                          AppTextStyles
                              .heading,
                      fontWeight:
                          FontWeight.w700,
                      height: 1.15,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // ============================================
                  // INSTITUTE
                  // ============================================

                  const Text(
                    'Tanzania Agricultural Research Institute',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Color(
                        0xFF66746A,
                      ),
                      fontSize:
                          AppTextStyles.body,
                      fontWeight:
                          FontWeight.w500,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  // ============================================
                  // DESCRIPTION
                  // ============================================

                  const Text(
                    'Smart cashew production, farm management '
                    'and disease monitoring.',
                    textAlign:
                        TextAlign.center,
                    style: TextStyle(
                      color: Color(
                        0xFF89948C,
                      ),
                      fontSize:
                          AppTextStyles.body,
                      fontWeight:
                          FontWeight.w400,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 52,
                  ),

                  // ============================================
                  // LOADING INDICATOR
                  // ============================================

                  const SizedBox(
                    width: 34,
                    height: 34,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 3,
                      color: primaryGreen,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // ============================================
                  // LOADING MESSAGE
                  // ============================================

                  AnimatedSwitcher(
                    duration:
                        const Duration(
                      milliseconds: 250,
                    ),
                    child: Text(
                      _loadingMessage,
                      key: ValueKey<String>(
                        _loadingMessage,
                      ),
                      textAlign:
                          TextAlign.center,
                      style:
                          const TextStyle(
                        color: Color(
                          0xFF637168,
                        ),
                        fontSize:
                            AppTextStyles
                                .body,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 42,
                  ),

                  // ============================================
                  // CPMS LABEL
                  // ============================================

                  Container(
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFE7F3EB,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        30,
                      ),
                    ),
                    child:
                        const Text(
                      'CPMS',
                      style:
                          TextStyle(
                        color:
                            primaryGreen,
                        fontSize:
                            AppTextStyles
                                .bodySmall,
                        fontWeight:
                            FontWeight
                                .w800,
                        letterSpacing:
                            1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}