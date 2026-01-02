import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/models/jar_model.dart';
import '../../../../shared/widgets/glass_container.dart';

class JarSetupScreen extends ConsumerStatefulWidget {
  const JarSetupScreen({super.key});

  @override
  ConsumerState<JarSetupScreen> createState() => _JarSetupScreenState();
}

class _JarSetupScreenState extends ConsumerState<JarSetupScreen> {
  JarSetupMode _mode = JarSetupMode.select;
  JarType? _selectedJarType;
  final _jarNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _jarNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _createJar() async {
    if (_selectedJarType == null) return;
    if (_selectedJarType != JarType.personal && _jarNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a name for your jar'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.createJar(
        type: _selectedJarType!,
        name: _selectedJarType == JarType.personal
            ? 'My Memories'
            : _jarNameController.text.trim(),
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating jar: $e'),
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

  Future<void> _joinJar() async {
    if (_inviteCodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter an invite code'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      await authService.joinJar(_inviteCodeController.text.trim().toUpperCase());

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining jar: $e'),
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

  void _skipSetup() {
    // Create a default personal jar and go to home
    _selectedJarType = JarType.personal;
    _createJar();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                    _buildProgressDot(true, isDark),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      _getHeaderTitle(),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3),
                    const SizedBox(height: 8),
                    Text(
                      _getHeaderSubtitle(),
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _buildContent(isDark, theme),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: _isLoading ? null : _getMainAction(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  minimumSize: const Size(double.infinity, 52),
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
                    : Text(
                        _getMainButtonText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              if (_mode == JarSetupMode.select) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _skipSetup,
                  child: Text(
                    'Skip for now',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
              if (_mode != JarSetupMode.select) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _mode = JarSetupMode.select),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_back_rounded,
                        size: 18,
                        color: isDark ? Colors.white54 : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Back',
                        style: TextStyle(
                          color: isDark ? Colors.white54 : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getHeaderTitle() {
    switch (_mode) {
      case JarSetupMode.select:
        return 'Set Up Your Jar';
      case JarSetupMode.create:
        return 'Create a Jar';
      case JarSetupMode.join:
        return 'Join a Jar';
    }
  }

  String _getHeaderSubtitle() {
    switch (_mode) {
      case JarSetupMode.select:
        return 'Create a new memory jar or join an existing one';
      case JarSetupMode.create:
        return 'Choose a jar type and give it a name';
      case JarSetupMode.join:
        return 'Enter the invite code to join a shared jar';
    }
  }

  String _getMainButtonText() {
    switch (_mode) {
      case JarSetupMode.select:
        return 'Create New Jar';
      case JarSetupMode.create:
        return 'Create Jar';
      case JarSetupMode.join:
        return 'Join Jar';
    }
  }

  VoidCallback? _getMainAction() {
    switch (_mode) {
      case JarSetupMode.select:
        return () => setState(() => _mode = JarSetupMode.create);
      case JarSetupMode.create:
        return _selectedJarType != null ? _createJar : null;
      case JarSetupMode.join:
        return _joinJar;
    }
  }

  Widget _buildContent(bool isDark, ThemeData theme) {
    switch (_mode) {
      case JarSetupMode.select:
        return _buildSelectMode(isDark, theme);
      case JarSetupMode.create:
        return _buildCreateMode(isDark, theme);
      case JarSetupMode.join:
        return _buildJoinMode(isDark, theme);
    }
  }

  Widget _buildSelectMode(bool isDark, ThemeData theme) {
    return Column(
      children: [
        // Create New Jar Card
        GlassCard(
          onTap: () => setState(() => _mode = JarSetupMode.create),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create New Jar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start fresh with your own memory jar',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : AppColors.textTertiary,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

        const SizedBox(height: 16),

        // Join Existing Jar Card
        GlassCard(
          onTap: () => setState(() => _mode = JarSetupMode.join),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.secondaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.group_add_rounded,
                  size: 30,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join Existing Jar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enter an invite code to join a shared jar',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white60 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : AppColors.textTertiary,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),

        const SizedBox(height: 40),

        // Info Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.info.withOpacity(0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.info,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'You can create multiple jars for different groups - personal, family, friends, or work!',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms),
      ],
    );
  }

  Widget _buildCreateMode(bool isDark, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose Jar Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white70 : AppColors.textSecondary,
          ),
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 16),

        // Jar Type Grid
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: JarType.values.map((type) {
            final isSelected = _selectedJarType == type;
            return _JarTypeCard(
              type: type,
              isSelected: isSelected,
              isDark: isDark,
              onTap: () => setState(() => _selectedJarType = type),
            );
          }).toList(),
        ).animate().fadeIn(delay: 400.ms),

        const SizedBox(height: 24),

        // Jar Name Field (only for non-personal jars)
        if (_selectedJarType != null && _selectedJarType != JarType.personal) ...[
          Text(
            'Jar Name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
            ),
          ).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 12),

          GlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: TextField(
              controller: _jarNameController,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: _getJarNameHint(),
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : AppColors.textTertiary,
                ),
                border: InputBorder.none,
                prefixIcon: Text(
                  _selectedJarType!.defaultEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
        ],

        const SizedBox(height: 100),
      ],
    );
  }

  String _getJarNameHint() {
    switch (_selectedJarType) {
      case JarType.family:
        return 'e.g., The Smiths, Our Family';
      case JarType.friends:
        return 'e.g., Squad, College Friends';
      case JarType.work:
        return 'e.g., Team Wins, Project X';
      case JarType.custom:
        return 'Give your jar a name';
      default:
        return 'Jar name';
    }
  }

  Widget _buildJoinMode(bool isDark, ThemeData theme) {
    return Column(
      children: [
        // Invite Code Input
        GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: TextField(
            controller: _inviteCodeController,
            textCapitalization: TextCapitalization.characters,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
            textAlign: TextAlign.center,
            maxLength: 6,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
              UpperCaseTextFormatter(),
            ],
            decoration: InputDecoration(
              hintText: 'ABC123',
              hintStyle: TextStyle(
                color: isDark ? Colors.white.withOpacity(0.2) : AppColors.textTertiary,
                fontSize: 24,
                letterSpacing: 8,
              ),
              border: InputBorder.none,
              counterText: '',
            ),
          ),
        ).animate().fadeIn(delay: 400.ms).scale(delay: 400.ms),

        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.info.withOpacity(0.2),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.info,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                'Ask the jar owner for the 6-character invite code. Once you join, you\'ll be able to view and add memories to the shared jar.',
                style: TextStyle(
                  color: isDark ? Colors.white70 : AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 500.ms),

        const SizedBox(height: 100),
      ],
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

enum JarSetupMode { select, create, join }

class _JarTypeCard extends StatelessWidget {
  const _JarTypeCard({
    required this.type,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  final JarType type;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? type.defaultColor.withOpacity(0.15)
              : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? type.defaultColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: type.defaultColor.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    type.defaultColor.withOpacity(0.8),
                    type.defaultColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  type.defaultEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              type.displayName,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? type.defaultColor
                    : (isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              type == JarType.personal ? 'Just for you' : 'Shared',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white54 : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
