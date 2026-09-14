import 'package:flutter/material.dart';
import '../services/api_services/api_services.dart';
import 'home_page.dart';
import 'package:file_picker/file_picker.dart';


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

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

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
        errorMessage = e.toString().replaceFirst(
              'Exception: ',
              '',
            );
        isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    try {
      await ApiServices.logout();
    } catch (_) {
      // Continue to home even if the API logout request fails.
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fullName = user?['fullName']?.toString() ?? 'User';
    final email = user?['email']?.toString() ?? '';
    final phone = user?['phone']?.toString() ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,

        leading: IconButton(
          onPressed: widget.onBack,
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 18,
          ),
        ),

        title: const Text(
          'Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _loadUser,

        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),

          child: Column(
            children: [
              // --------------------------------------------------
              // PROFILE HEADER
              // --------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(
                  20,
                  18,
                  20,
                  22,
                ),

                decoration: const BoxDecoration(
                  color: Color(0xFFF0FFF5),

                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                ),

                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          width: 78,
                          height: 78,

                          padding: const EdgeInsets.all(3),

                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),

                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app_icon.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        Positioned(
                          right: 0,
                          bottom: 2,

                          child: Container(
                            width: 24,
                            height: 24,

                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),

                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 9),

                    if (isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    else if (errorMessage != null)
                      Column(
                        children: [
                          const Text(
                            'Unable to load profile',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 4),

                          TextButton(
                            onPressed: _loadUser,
                            child: const Text('Retry'),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          Text(
                            fullName,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            email,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),

                          if (phone.isNotEmpty) ...[
                            const SizedBox(height: 3),

                            Text(
                              phone,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                          ],

                          const SizedBox(height: 8),

                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,

                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color:
                                      const Color(0xFFD9FBE5),
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),

                              
                              ),

                              const SizedBox(width: 6),

                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),

                          
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // --------------------------------------------------
              // CONTENT
              // --------------------------------------------------
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  14,
                  14,
                  14,
                  25,
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionTitle('PERSONAL INFORMATION'),

                    _settingsCard(
                      children: [
                        _settingsItem(
                          icon: Icons.person_outline,
                          title: 'Edit Profile',
                          subtitle: 'Update your details',
                          trailingText: 'Update your details',
                          onTap: () {},
                        ),

                        _divider(),

                        _settingsItem(
                          icon: Icons.notifications_none,
                          title: 'Notifications',
                          subtitle: 'Enabled',
                          trailingText: 'Enabled',
                          onTap: () {},
                        ),

                        _divider(),

                        _settingsItem(
                          icon: Icons.translate,
                          title: 'Language',
                          subtitle: 'English',
                          trailingText: 'English',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _sectionTitle('SYSTEM & SECURITY'),

                    _settingsCard(
                      children: [
                        _settingsItem(
                          icon: Icons.settings_brightness_outlined,
                          title: 'Light/Dark Mode',
                          subtitle: '',
                          onTap: () {},
                        ),

                        _divider(),

                        _settingsItem(
                          icon: Icons.verified_user_outlined,
                          title: 'Privacy & Security',
                          subtitle: '',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    _sectionTitle('SUPPORT'),

                    _settingsCard(
                      children: [
                        _settingsItem(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          subtitle: '',
                          onTap: () {},
                        ),

                        _divider(),

                        _settingsItem(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          subtitle: '',
                          onTap: () {},
                        ),
                      ],
                    ),
                                        const SizedBox(height: 14),

                    _uploads('UPLOADS'),

_settingsCard(
  children: [
    _settingsItem(
      icon: Icons.cloud_upload_outlined,
      title: 'Upload Files',
      subtitle: 'Upload documents, images or PDFs',
      onTap: () async {
  try {
    final result = await FilePicker.platform.pickFiles(
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Files uploaded successfully',
        ),
      ),
    );

  } catch (e) {

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Upload failed: $e',
        ),
      ),
    );
  }
},
    ),
  ],
),

const SizedBox(height: 16),

                    // --------------------------------------------------
                    // LOGOUT
                    // --------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      height: 52,

                      child: OutlinedButton.icon(
                        onPressed: _logout,

                        icon: const Icon(
                          Icons.logout,
                          color: Colors.red,
                          size: 18,
                        ),

                        label: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        style: OutlinedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFFFFF5F5),

                          side: const BorderSide(
                            color: Color(0xFFFFDADA),
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Center(
                      child: Text(
                        'Powered by TARI',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 10,
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 4,
        bottom: 7,
      ),

      child: Text(
        title,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: Colors.grey,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

Widget _uploads(String title) {
  return Padding(
    padding: const EdgeInsets.only(
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
        const SizedBox(width: 5),
        Text(
          title,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: Colors.grey,
            letterSpacing: 0.4,
          ),
        ),
      ],
    ),
  );
}
  Widget _settingsCard({
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(11),

        border: Border.all(
          color: const Color(0xFFE8ECE9),
        ),
      ),

      child: Column(
        children: children,
      ),
    );
  }

  Widget _settingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,

      borderRadius: BorderRadius.circular(11),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 9,
        ),

        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,

              decoration: BoxDecoration(
                color: const Color(0xFFEAFBF0),
                borderRadius:
                    BorderRadius.circular(9),
              ),

              child: Icon(
                icon,
                color: Colors.green,
                size: 17,
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),

                  if (subtitle.isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 2),

                      child: Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            if (trailingText != null &&
                trailingText.isNotEmpty)
              Text(
                trailingText,
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                ),
              ),

            const SizedBox(width: 5),

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

  Widget _divider() {
    return const Divider(
      height: 1,
      thickness: 0.5,
      indent: 54,
      endIndent: 10,
    );
  }
}