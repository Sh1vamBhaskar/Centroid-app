import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;

  String? _error;

  Map<String, dynamic>? _profile;

  late final TextEditingController _displayNameController;
  late final TextEditingController _profilePictureController;
  late final TextEditingController _socialLinkController;
  late final TextEditingController _bioController;

  @override
  void initState() {
    super.initState();

    _displayNameController = TextEditingController();
    _profilePictureController = TextEditingController();
    _socialLinkController = TextEditingController();
    _bioController = TextEditingController();

    _loadProfile();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _profilePictureController.dispose();
    _socialLinkController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await ApiService.getMyProfile();

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _isLoading = false;
      });

      _setControllers(profile);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e
            .toString()
            .replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _setControllers(Map<String, dynamic> profile) {
    _displayNameController.text =
        profile['displayName']?.toString() ?? '';

    _profilePictureController.text =
        profile['profilePicture']?.toString() ?? '';

    _socialLinkController.text =
        profile['socialLink']?.toString() ?? '';

    _bioController.text =
        profile['bio']?.toString() ?? '';
  }

  void _startEditing() {
    if (_profile != null) {
      _setControllers(_profile!);
    }

    setState(() {
      _isEditing = true;
    });
  }

  void _cancelEditing() {
    if (_profile != null) {
      _setControllers(_profile!);
    }

    setState(() {
      _isEditing = false;
    });
  }

  Future<void> _saveProfile() async {
    final displayName =
    _displayNameController.text.trim();

    if (displayName.isEmpty) {
      _showMessage('Display name cannot be empty');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedProfile =
      await ApiService.updateProfile(
        displayName: displayName,
        profilePicture:
        _profilePictureController.text.trim().isEmpty
            ? null
            : _profilePictureController.text.trim(),
        socialLink:
        _socialLinkController.text.trim().isEmpty
            ? null
            : _socialLinkController.text.trim(),
        bio: _bioController.text.trim().isEmpty
            ? null
            : _bioController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _profile = updatedProfile;
        _isEditing = false;
        _isSaving = false;
      });

      _setControllers(updatedProfile);

      _showMessage('Profile updated');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log out?'),
          content: const Text(
            'You will need to log in again to use Centroid.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await ApiService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
        isError ? AppColors.danger : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(message),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final picture =
        _profile?['profilePicture']?.toString() ?? '';

    return Container(
      width: 104,
      height: 104,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(
          color: AppColors.primarySoft,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipOval(
        child: picture.isNotEmpty
            ? Image.network(
          picture,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return _defaultAvatar();
          },
        )
            : _defaultAvatar(),
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: AppColors.primarySoft,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 46,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    if (value.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMode() {
    final displayName =
        _profile?['displayName']?.toString() ?? '';

    final socialLink =
        _profile?['socialLink']?.toString() ?? '';

    final bio =
        _profile?['bio']?.toString() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: _buildProfileAvatar(),
        ),

        const SizedBox(height: 18),

        Center(
          child: Text(
            displayName.isEmpty
                ? 'Centroid User'
                : displayName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 26),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'About',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              if (bio.isNotEmpty)
                Padding(
                  padding:
                  const EdgeInsets.only(bottom: 18),
                  child: Text(
                    bio,
                    style: AppTextStyles.bodySecondary,
                  ),
                ),

              _buildInfoRow(
                icon: Icons.link_rounded,
                label: 'Social link',
                value: socialLink,
              ),

              if (bio.isEmpty && socialLink.isEmpty)
                const Text(
                  'Add a bio or social link to tell people a little about yourself.',
                  style: AppTextStyles.bodySecondary,
                ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _startEditing,
            icon: const Icon(
              Icons.edit_outlined,
              size: 19,
            ),
            label: const Text('Edit profile'),
          ),
        ),


      ],
    );
  }

  Widget _buildEditMode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Edit profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Update the information shown on your profile.',
          style: AppTextStyles.bodySecondary,
        ),

        const SizedBox(height: 24),

        _buildTextField(
          controller: _displayNameController,
          label: 'Display name',
          hint: 'Your name',
        ),

        const SizedBox(height: 16),

        _buildTextField(
          controller: _profilePictureController,
          label: 'Profile picture URL',
          hint: 'https://...',
          keyboardType: TextInputType.url,
        ),

        const SizedBox(height: 16),

        _buildTextField(
          controller: _socialLinkController,
          label: 'Social link',
          hint: 'https://...',
          keyboardType: TextInputType.url,
        ),

        const SizedBox(height: 16),

        _buildTextField(
          controller: _bioController,
          label: 'Bio',
          hint: 'Tell people a little about yourself',
          maxLines: 4,
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isSaving
                ? null
                : _saveProfile,
            child: _isSaving
                ? const SizedBox(
              width: 21,
              height: 21,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Colors.white,
              ),
            )
                : const Text('Save changes'),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed:
            _isSaving ? null : _cancelEditing,
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: false,
        actions: [
          if (!_isEditing && !_isLoading)
            IconButton(
              onPressed: _startEditing,
              icon: const Icon(
                Icons.edit_outlined,
              ),
              tooltip: 'Edit profile',
            ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_off_outlined,
                  size: 28,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Couldn’t load your profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySecondary,
              ),

              const SizedBox(height: 18),

              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });

                  _loadProfile();
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _isEditing
              ? _buildEditMode()
              : _buildViewMode(),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(
                Icons.logout_rounded,
                size: 19,
              ),
              label: const Text('Log out'),
            ),
          ),
        ],
      ),
    );
  }
}