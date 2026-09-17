import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../theme/app_text_styles.dart';
import '../l10n/app_localizations.dart';
import '../providers/language_provider.dart';
import '../services/api_services/api_services.dart';

import 'login_page.dart';

class MePage extends StatefulWidget {
  final VoidCallback onBack;

  const MePage({
    super.key,
    required this.onBack,
  });

  @override
  State<MePage> createState() => _MePageState();
}

class _MePageState extends State<MePage> {
  Map<String, dynamic>? user;

  bool isLoading = true;

  String? errorMessage;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // ============================================================
  // LOAD CURRENT USER
  // ============================================================

  Future<void> _loadUser() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final data = await ApiServices.getCurrentUser();

      if (!mounted) return;

      setState(() {
        user = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = e
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );

        isLoading = false;
      });
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    try {
      await ApiServices.logout();
    } catch (_) {
      // Continue to home even if logout fails.
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const LoginPage(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // CHANGE LANGUAGE
  // ============================================================

  Future<void> _showLanguageDialog() async {
    final l10n =
        AppLocalizations.of(context)!;

    final languageProvider =
        context.read<LanguageProvider>();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding:
              const EdgeInsets.fromLTRB(
            18,
            12,
            18,
            25,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top: Radius.circular(22),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFE8ECE9,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 18,
                ),

                Text(
                  l10n.changeLanguage,
                  style:
                      const TextStyle(
  fontSize: AppTextStyles.subtitle,
                    fontWeight:
                        FontWeight.w700,
                    color:
                        Colors.black87,
                  ),
                ),

                const SizedBox(
                  height: 14,
                ),

                _languageOption(
                  title:
                      l10n.swahili,
                  code: 'sw',
                  currentCode:
                      languageProvider
                          .languageCode,
                  onTap: () async {
                    await languageProvider
                        .setLanguage(
                      'sw',
                    );

                    if (sheetContext
                        .mounted) {
                      Navigator.pop(
                        sheetContext,
                      );
                    }
                  },
                ),

                const SizedBox(
                  height: 8,
                ),

                _languageOption(
                  title:
                      l10n.english,
                  code: 'en',
                  currentCode:
                      languageProvider
                          .languageCode,
                  onTap: () async {
                    await languageProvider
                        .setLanguage(
                      'en',
                    );

                    if (sheetContext
                        .mounted) {
                      Navigator.pop(
                        sheetContext,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // LANGUAGE OPTION
  // ============================================================

  Widget _languageOption({
    required String title,
    required String code,
    required String currentCode,
    required VoidCallback onTap,
  }) {
    final selected =
        code == currentCode;

    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(
        10,
      ),
      child: Container(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        decoration:
            BoxDecoration(
          color: selected
              ? const Color(
                  0xFFEAFBF0,
                )
              : Colors.white,
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          border: Border.all(
            color: selected
                ? Colors.green
                : const Color(
                    0xFFE8ECE9,
                  ),
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.translate,
              color: Colors.green,
              size: 18,
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(
                  fontSize: AppTextStyles.body,
                  fontWeight:
                      FontWeight.w600,
                  color:
                      Colors.black87,
                ),
              ),
            ),

            if (selected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 18,
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // UPLOAD FILES
  // ============================================================

  Future<void> _uploadFiles() async {
    final l10n =
        AppLocalizations.of(context)!;

    try {
      final result =
          await FilePicker.platform
              .pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: [
          'jpg',
          'jpeg',
          'png',
          'gif',
          'webp',
          'zip',
        ],
      );

      if (result == null ||
          result.files.isEmpty) {
        return;
      }

      await ApiServices.uploadFiles(
        result.files,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            l10n
                .filesUploadedSuccessfully,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.uploadFailed}: $e',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final l10n =
        AppLocalizations.of(context)!;

    final languageProvider =
        context.watch<
            LanguageProvider>();

    final fullName =
        user?['fullName']
                ?.toString() ??
            l10n.user;

    final username =
        user?['username']
                ?.toString() ??
            '';

    // IMPORTANT:
    // Backend uses phoneNumber.
    final phoneNumber =
        user?['phoneNumber']
                ?.toString() ??
            '';

    final status =
        user?['status']
                ?.toString() ??
            '';

    final role =
        _getRoleLabel(
      user?['roles'],
    );

    final currentLanguage =
        languageProvider.isSwahili
            ? l10n.swahili
            : l10n.english;

    return Scaffold(
      backgroundColor:
          const Color(
        0xFFF8FAF9,
      ),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            Colors.white,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          onPressed:
              widget.onBack,
          icon:
              const Icon(
            Icons
                .arrow_back_ios_new,
            color: Colors.black,
            size: 18,
          ),
        ),

        title: Text(
          l10n.profile,
          style:
              const TextStyle(
            color: Colors.black,
            fontSize: AppTextStyles.title,
            fontWeight:
                FontWeight.w700,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: RefreshIndicator(
        onRefresh: _loadUser,

        child:
            SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),

          child: Column(
            children: [
              // =================================================
              // PROFILE HEADER
              // =================================================

              Container(
                width:
                    double.infinity,

                padding:
                    const EdgeInsets
                        .fromLTRB(
                  20,
                  18,
                  20,
                  22,
                ),

                decoration:
                    const BoxDecoration(
                  color:
                      Color(
                    0xFFF0FFF5,
                  ),

                  borderRadius:
                      BorderRadius.only(
                    bottomLeft:
                        Radius.circular(
                      22,
                    ),
                    bottomRight:
                        Radius.circular(
                      22,
                    ),
                  ),
                ),

                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 78,
                          height: 78,

                          padding:
                              const EdgeInsets
                                  .all(
                            3,
                          ),

                          decoration:
                              BoxDecoration(
                            shape:
                                BoxShape
                                    .circle,
                            color:
                                Colors
                                    .white,
                            border:
                                Border.all(
                              color:
                                  Colors
                                      .white,
                              width: 2,
                            ),
                          ),

                          child:
                              ClipOval(
                            child:
                                Image.asset(
                              'assets/images/app_icon.png',
                              fit:
                                  BoxFit
                                      .cover,
                            ),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 2,

                          child:
                              Container(
                            width: 24,
                            height: 24,

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors
                                      .green,
                              shape:
                                  BoxShape
                                      .circle,
                              border:
                                  Border.all(
                                color:
                                    Colors
                                        .white,
                                width: 2,
                              ),
                            ),

                            child:
                                const Icon(
                              Icons
                                  .camera_alt,
                              color:
                                  Colors
                                      .white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 9,
                    ),

                    if (isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,

                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                        ),
                      )
                    else if (errorMessage !=
                        null)
                      Column(
                        children: [
                          Text(
                            l10n
                                .unableToLoadProfile,
                            style:
                                const TextStyle(
                              color:
                                  Colors
                                      .red,
                              fontWeight:
                                  FontWeight
                                      .w600,
                            ),
                          ),

                          const SizedBox(
                            height: 4,
                          ),

                          TextButton(
                            onPressed:
                                _loadUser,
                            child: Text(
                              l10n.retry,
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Text(
                            fullName,
                            textAlign:
                                TextAlign
                                    .center,
                            style:
                                const TextStyle(
                              fontSize:
                                  AppTextStyles.title,
                              fontWeight:
                                  FontWeight
                                      .w700,
                              color:
                                  Colors
                                      .black,
                            ),
                          ),

                          if (username
                              .isNotEmpty) ...[
                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              '@$username',
                              textAlign:
                                  TextAlign
                                      .center,
                              style:
                                  const TextStyle(
                                fontSize:
                                    AppTextStyles.body,
                                color:
                                    Colors
                                        .grey,
                              ),
                            ),
                          ],

                          if (phoneNumber
                              .isNotEmpty) ...[
                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              phoneNumber,
                              style:
                                  const TextStyle(
                                fontSize:
                                    AppTextStyles.body,
                                color:
                                    Colors
                                        .grey,
                              ),
                            ),
                          ],

                          const SizedBox(
                            height: 8,
                          ),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              if (status
                                      .toUpperCase() ==
                                  'ACTIVE')
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        9,
                                    vertical:
                                        4,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        const Color(
                                      0xFFD9FBE5,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      20,
                                    ),
                                  ),
                                  child: Text(
                                    l10n
                                        .active,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors
                                              .green,
                                      fontSize:
                                          AppTextStyles.bodySmall,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                ),

                              if (status
                                      .toUpperCase() ==
                                      'ACTIVE' &&
                                  role
                                      .isNotEmpty)
                                const SizedBox(
                                  width: 6,
                                ),

                              if (role
                                  .isNotEmpty)
                                Container(
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal:
                                        8,
                                    vertical:
                                        4,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color:
                                        Colors
                                            .white,
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      20,
                                    ),
                                  ),
                                  child: Text(
                                    role,
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors
                                              .grey,
                                      fontSize:
                                          AppTextStyles.bodySmall,
                                      fontWeight:
                                          FontWeight
                                              .w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // =================================================
              // CONTENT
              // =================================================

              Padding(
                padding:
                    const EdgeInsets
                        .fromLTRB(
                  14,
                  14,
                  14,
                  25,
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [
                    // ===========================================
                    // PERSONAL INFORMATION
                    // ===========================================

                    _sectionTitle(
                      l10n
                          .personalInformation,
                    ),

                    _settingsCard(
                      children: [
                        _settingsItem(
                          icon:
                              Icons
                                  .person_outline,
                          title:
                              l10n
                                  .editProfile,
                          subtitle:
                              l10n
                                  .updateYourDetails,
                          trailingText:
                              l10n
                                  .updateYourDetails,
                          onTap: () {},
                        ),

                        _divider(),

                        _settingsItem(
                          icon:
                              Icons
                                  .notifications_none,
                          title:
                              l10n
                                  .notifications,
                          subtitle:
                              l10n.enabled,
                          trailingText:
                              l10n.enabled,
                          onTap: () {},
                        ),

                        _divider(),

                        _settingsItem(
                          icon:
                              Icons
                                  .translate,
                          title:
                              l10n
                                  .language,
                          subtitle:
                              currentLanguage,
                          trailingText:
                              currentLanguage,
                          onTap:
                              _showLanguageDialog,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ===========================================
                    // SYSTEM & SECURITY
                    // ===========================================

                    _sectionTitle(
                      l10n
                          .systemSecurity,
                    ),

                    _settingsCard(
                      children: [
                        _settingsItem(
                          icon:
                              Icons
                                  .settings_brightness_outlined,
                          title:
                              l10n
                                  .lightDarkMode,
                          subtitle: '',
                          onTap: () {},
                        ),

                        _divider(),

                        _settingsItem(
                          icon:
                              Icons
                                  .verified_user_outlined,
                          title:
                              l10n
                                  .privacySecurity,
                          subtitle: '',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ===========================================
                    // SUPPORT
                    // ===========================================

                    _sectionTitle(
                      l10n.support,
                    ),

                    _settingsCard(
                      children: [
                        _settingsItem(
                          icon:
                              Icons
                                  .help_outline,
                          title:
                              l10n
                                  .helpCenter,
                          subtitle: '',
                          onTap: () {},
                        ),

                        _divider(),

                        _settingsItem(
                          icon:
                              Icons
                                  .description_outlined,
                          title:
                              l10n
                                  .termsOfService,
                          subtitle: '',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 14,
                    ),

                    // ===========================================
                    // UPLOADS
                    // ===========================================

                    _uploads(
                      l10n.uploads,
                    ),

                    _settingsCard(
                      children: [
                        _settingsItem(
                          icon:
                              Icons
                                  .cloud_upload_outlined,
                          title:
                              l10n
                                  .uploadFiles,
                          subtitle:
                              l10n
                                  .uploadFilesDescription,
                          onTap:
                              _uploadFiles,
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    // ===========================================
                    // LOGOUT
                    // ===========================================

                    SizedBox(
                      width:
                          double.infinity,
                      height: 52,

                      child:
                          OutlinedButton
                              .icon(
                        onPressed:
                            _logout,

                        icon:
                            const Icon(
                          Icons.logout,
                          color:
                              Colors.red,
                          size: 18,
                        ),

                        label: Text(
                          l10n.logout,
                          style:
                              const TextStyle(
                            color:
                                Colors.red,
                            fontSize:
                                AppTextStyles.bodyLarge,
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),

                        style:
                            OutlinedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFFFFF5F5,
                          ),

                          side:
                              const BorderSide(
                            color:
                                Color(
                              0xFFFFDADA,
                            ),
                          ),

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              10,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    Center(
                      child: Text(
                        l10n
                            .poweredByTari,
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                          fontSize: AppTextStyles.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ROLE
  // ============================================================

  String _getRoleLabel(
    dynamic roles,
  ) {
    if (roles is! List ||
        roles.isEmpty) {
      return '';
    }

    final raw =
        roles.first
            .toString()
            .replaceFirst(
              'ROLE_',
              '',
            )
            .replaceAll(
              '_',
              ' ',
            )
            .toLowerCase();

    if (raw.isEmpty) {
      return '';
    }

    return raw
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : '${word[0].toUpperCase()}'
                  '${word.substring(1)}',
        )
        .join(' ');
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: 4,
        bottom: 7,
      ),

      child: Text(
        title,

        style:
            const TextStyle(
          fontSize: AppTextStyles.bodySmall,
          fontWeight:
              FontWeight.w700,
          color: Colors.grey,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  // ============================================================
  // UPLOAD TITLE
  // ============================================================

  Widget _uploads(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        left: 4,
        bottom: 7,
      ),

      child: Row(
        children: [
          const Icon(
            Icons.folder_outlined,
            size: 14,
            color: Colors.grey,
          ),

          const SizedBox(
            width: 5,
          ),

          Text(
            title,

            style:
                const TextStyle(
              fontSize: AppTextStyles.bodySmall,
              fontWeight:
                  FontWeight.w700,
              color:
                  Colors.grey,
              letterSpacing:
                  0.4,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SETTINGS CARD
  // ============================================================

  Widget _settingsCard({
    required List<Widget>
        children,
  }) {
    return Container(
      width: double.infinity,

      decoration:
          BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          11,
        ),

        border: Border.all(
          color:
              const Color(
            0xFFE8ECE9,
          ),
        ),
      ),

      child: Column(
        children: children,
      ),
    );
  }

  // ============================================================
  // SETTINGS ITEM
  // ============================================================

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius:
          BorderRadius.circular(
        11,
      ),

      child: Padding(
        padding:
            const EdgeInsets
                .symmetric(
          horizontal: 10,
          vertical: 9,
        ),

        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFEAFBF0,
                ),

                borderRadius:
                    BorderRadius
                        .circular(
                  9,
                ),
              ),

              child: Icon(
                icon,
                color:
                    Colors.green,
                size: 17,
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Text(
                    title,

                    style:
                        const TextStyle(
                      fontSize:
                          AppTextStyles.body,
                      fontWeight:
                          FontWeight
                              .w600,
                      color:
                          Colors
                              .black87,
                    ),
                  ),

                  if (subtitle
                      .isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        top: 2,
                      ),

                      child: Text(
                        subtitle,

                        style:
                            const TextStyle(
                          fontSize:
                              AppTextStyles.bodySmall,
                          color:
                              Colors
                                  .grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (trailingText !=
                    null &&
                trailingText
                    .isNotEmpty)
              Text(
                trailingText,

                style:
                    const TextStyle(
                  fontSize: AppTextStyles.bodySmall,
                  color:
                      Colors.grey,
                ),
              ),

            const SizedBox(
              width: 5,
            ),

            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 17,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 54,
      endIndent: 10,
    );
  }
}