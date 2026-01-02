import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/glass_container.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  File? _profileImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  void _loadExistingData() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _displayNameController.text = user.displayName ?? '';
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.updateProfile(
        displayName: _displayNameController.text.trim(),
        photoFile: _profileImage,
      );

      if (mounted) {
        context.go('/onboarding/jar-setup');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving profile: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1a1a2e), const Color(0xFF16213e)]
                : [AppColors.background, AppColors.backgroundSecondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Progress Indicator
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    _buildProgressDot(true, isDark),
                    _buildProgressLine(true, isDark),
                    _buildProgressDot(false, isDark),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      'Create Your Profile',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                    const SizedBox(height: 8),
                    Text(
                      'Let\'s personalize your Memory Jar experience',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Photo
                        GestureDetector(
                          onTap: _pickImage,
                          child: Stack(
                            children: [
                              Container(
                                width: 140,
                                height: 140,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: _profileImage == null && user?.photoURL == null
                                      ? AppColors.primaryGradient
                                      : null,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                          width: 140,
                                          height: 140,
                                        )
                                      : user?.photoURL != null
                                          ? Image.network(
                                              user!.photoURL!,
                                              fit: BoxFit.cover,
                                              width: 140,
                                              height: 140,
                                            )
                                          : const Icon(
                                              Icons.person_rounded,
                                              size: 60,
                                              color: Colors.white,
                                            ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
                                      width: 3,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_rounded,
                                    size: 22,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms),

                        const SizedBox(height: 16),

                        Text(
                          'Tap to add a photo',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ).animate().fadeIn(delay: 500.ms),

                        const SizedBox(height: 40),

                        // Display Name Field
                        GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: TextFormField(
                            controller: _displayNameController,
                            style: TextStyle(
                              color: isDark ? Colors.white : AppColors.textPrimary,
                              fontSize: 16,
                            ),
                            decoration: InputDecoration(
                              labelText: 'Display Name',
                              labelStyle: TextStyle(
                                color: isDark ? Colors.white54 : AppColors.textSecondary,
                              ),
                              hintText: 'How should we call you?',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white30 : AppColors.textTertiary,
                              ),
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.person_outline_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                        ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

                        const SizedBox(height: 16),

                        // Email Display (read-only)
                        if (user?.email != null)
                          GlassCard(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.email_outlined,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Email',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        user!.email!,
                                        style: TextStyle(
                                          color: isDark ? Colors.white : AppColors.textPrimary,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.verified_rounded,
                                  color: AppColors.success,
                                  size: 20,
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),

                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressDot(bool isActive, bool isDark) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : (isDark ? Colors.white24 : Colors.grey.shade300),
      ),
    );
  }

  Widget _buildProgressLine(bool isActive, bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : (isDark ? Colors.white24 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
