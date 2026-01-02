import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/glass_container.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';
  bool _notificationsEnabled = true;
  bool _dailyReminderEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _loadSettings();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
      });
    }
  }

  void _loadSettings() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      // Load settings from user doc when available
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final themeMode = ref.watch(themeModeProvider);

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
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Settings Content
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Appearance Section
                    _buildSectionHeader('Appearance', Icons.palette_outlined, isDark)
                        .animate().fadeIn(delay: 100.ms).slideX(begin: -0.1),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildSettingTile(
                            title: 'Theme',
                            subtitle: _getThemeModeName(themeMode),
                            icon: Icons.brightness_6_rounded,
                            trailing: PopupMenuButton<ThemeMode>(
                              icon: Icon(
                                Icons.chevron_right_rounded,
                                color: isDark ? Colors.white54 : AppColors.textSecondary,
                              ),
                              onSelected: (mode) {
                                ref.read(themeModeProvider.notifier).setThemeMode(mode);
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: ThemeMode.light,
                                  child: Row(
                                    children: [
                                      Icon(Icons.light_mode_rounded, size: 20),
                                      SizedBox(width: 12),
                                      Text('Light'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: ThemeMode.dark,
                                  child: Row(
                                    children: [
                                      Icon(Icons.dark_mode_rounded, size: 20),
                                      SizedBox(width: 12),
                                      Text('Dark'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: ThemeMode.system,
                                  child: Row(
                                    children: [
                                      Icon(Icons.settings_suggest_rounded, size: 20),
                                      SizedBox(width: 12),
                                      Text('System'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),

                    const SizedBox(height: 24),

                    // Notifications Section
                    _buildSectionHeader('Notifications', Icons.notifications_outlined, isDark)
                        .animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildSwitchTile(
                            title: 'Push Notifications',
                            subtitle: 'Receive notifications about new memories',
                            icon: Icons.notifications_active_outlined,
                            value: _notificationsEnabled,
                            onChanged: (v) => setState(() => _notificationsEnabled = v),
                            isDark: isDark,
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                          _buildSwitchTile(
                            title: 'Daily Reminder',
                            subtitle: 'Get reminded to add memories',
                            icon: Icons.schedule_outlined,
                            value: _dailyReminderEnabled,
                            onChanged: (v) => setState(() => _dailyReminderEnabled = v),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),

                    const SizedBox(height: 24),

                    // Privacy & Security Section
                    _buildSectionHeader('Privacy & Security', Icons.security_outlined, isDark)
                        .animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildSettingTile(
                            title: 'Export My Data',
                            subtitle: 'Download a copy of your data (GDPR)',
                            icon: Icons.download_outlined,
                            onTap: () => _showExportDataDialog(context),
                            isDark: isDark,
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                          _buildSettingTile(
                            title: 'Delete Account',
                            subtitle: 'Permanently delete your account and data',
                            icon: Icons.delete_forever_outlined,
                            iconColor: Colors.red,
                            onTap: () => _showDeleteAccountDialog(context),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1),

                    const SizedBox(height: 24),

                    // Support Section
                    _buildSectionHeader('Support', Icons.help_outline_rounded, isDark)
                        .animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildSettingTile(
                            title: 'Help & FAQ',
                            subtitle: 'Frequently asked questions',
                            icon: Icons.quiz_outlined,
                            onTap: () => _showFAQSheet(context),
                            isDark: isDark,
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                          _buildSettingTile(
                            title: 'Contact Support',
                            subtitle: 'Get help from our team',
                            icon: Icons.mail_outlined,
                            onTap: () => _launchEmail('support@memoryjar.app'),
                            isDark: isDark,
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                          _buildSettingTile(
                            title: 'Report a Bug',
                            subtitle: 'Help us improve Memory Jar',
                            icon: Icons.bug_report_outlined,
                            onTap: () => _launchEmail('bugs@memoryjar.app'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 450.ms).slideX(begin: -0.1),

                    const SizedBox(height: 24),

                    // Legal Section
                    _buildSectionHeader('Legal', Icons.gavel_outlined, isDark)
                        .animate().fadeIn(delay: 500.ms).slideX(begin: -0.1),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildSettingTile(
                            title: 'Terms of Service',
                            subtitle: 'Read our terms and conditions',
                            icon: Icons.description_outlined,
                            onTap: () => _showLegalSheet(context, 'Terms of Service', _termsOfService),
                            isDark: isDark,
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                          _buildSettingTile(
                            title: 'Privacy Policy',
                            subtitle: 'UK GDPR compliant privacy policy',
                            icon: Icons.privacy_tip_outlined,
                            onTap: () => _showLegalSheet(context, 'Privacy Policy', _privacyPolicy),
                            isDark: isDark,
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                          _buildSettingTile(
                            title: 'Cookie Policy',
                            subtitle: 'Essential cookies only',
                            icon: Icons.cookie_outlined,
                            onTap: () => _showLegalSheet(context, 'Cookie Policy', _cookiePolicy),
                            isDark: isDark,
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                          _buildSettingTile(
                            title: 'Open Source Licenses',
                            subtitle: 'Third-party software licenses',
                            icon: Icons.code_outlined,
                            onTap: () => showLicensePage(
                              context: context,
                              applicationName: 'Memory Jar',
                              applicationVersion: _appVersion,
                              applicationIcon: Container(
                                width: 64,
                                height: 64,
                                margin: const EdgeInsets.only(bottom: 16),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text('🫙', style: TextStyle(fontSize: 32)),
                                ),
                              ),
                            ),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 550.ms).slideX(begin: -0.1),

                    const SizedBox(height: 24),

                    // About Section
                    _buildSectionHeader('About', Icons.info_outline_rounded, isDark)
                        .animate().fadeIn(delay: 600.ms).slideX(begin: -0.1),
                    GlassCard(
                      child: Column(
                        children: [
                          _buildSettingTile(
                            title: 'Version',
                            subtitle: _appVersion.isNotEmpty ? _appVersion : 'Loading...',
                            icon: Icons.info_outlined,
                            isDark: isDark,
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                          _buildSettingTile(
                            title: 'Rate Memory Jar',
                            subtitle: 'Share your feedback on the App Store',
                            icon: Icons.star_outline_rounded,
                            onTap: () {
                              // TODO: Open app store rating
                            },
                            isDark: isDark,
                          ),
                          Divider(color: isDark ? Colors.white12 : Colors.grey.shade200),
                          _buildSettingTile(
                            title: 'Share Memory Jar',
                            subtitle: 'Invite friends and family',
                            icon: Icons.share_outlined,
                            onTap: () {
                              // TODO: Open share sheet
                            },
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 650.ms).slideX(begin: -0.1),

                    const SizedBox(height: 32),

                    // Sign Out Button
                    GlassButton(
                      onPressed: () => _showSignOutDialog(context),
                      color: Colors.red.shade400,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Sign Out',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 700.ms).scale(delay: 700.ms),

                    const SizedBox(height: 32),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '© 2025 Memory Jar Ltd',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Made with ❤️ in the United Kingdom',
                            style: TextStyle(
                              color: isDark ? Colors.white38 : AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Compliant with UK GDPR & Data Protection Act 2018',
                            style: TextStyle(
                              color: isDark ? Colors.white30 : AppColors.textTertiary.withOpacity(0.7),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 750.ms),

                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required String subtitle,
    required IconData icon,
    Color? iconColor,
    Widget? trailing,
    VoidCallback? onTap,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.primary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: iconColor ?? AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : AppColors.textSecondary,
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? Colors.white38 : AppColors.textTertiary,
                )
              : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.primary,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? Colors.white54 : AppColors.textSecondary,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  void _showFAQSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      'Help & FAQ',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _faqItems.length,
                  itemBuilder: (context, index) {
                    final faq = _faqItems[index];
                    return _FAQItem(
                      question: faq['question']!,
                      answer: faq['answer']!,
                      isDark: isDark,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLegalSheet(BuildContext context, String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1a1a2e) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark ? Colors.white70 : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    content,
                    style: TextStyle(
                      color: isDark ? Colors.white70 : AppColors.textSecondary,
                      height: 1.6,
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

  void _showExportDataDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1a1a2e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Export Your Data',
          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
        ),
        content: Text(
          'We will prepare a copy of all your data including memories, photos, and account information. You\'ll receive an email with a download link within 24 hours.\n\nThis is your right under UK GDPR (Data Portability).',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Export request submitted. Check your email within 24 hours.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Request Export', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1a1a2e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.red.shade400),
            const SizedBox(width: 12),
            Text(
              'Delete Account',
              style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
            ),
          ],
        ),
        content: Text(
          'This action is permanent and cannot be undone.\n\n'
          '• All your memories will be deleted\n'
          '• All your photos and voice recordings will be removed\n'
          '• You will be removed from all shared jars\n'
          '• Your account will be permanently deleted within 30 days\n\n'
          'As per UK GDPR, you can request this at any time (Right to Erasure).',
          style: TextStyle(
            color: isDark ? Colors.white70 : AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement account deletion
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete Account', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1a1a2e) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out',
          style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: isDark ? Colors.white70 : AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: isDark ? Colors.white54 : AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go('/welcome');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  static const List<Map<String, String>> _faqItems = [
    {
      'question': 'How do I create a new memory?',
      'answer': 'Tap the + button on the home screen to create a new memory. You can add text, photos, or voice recordings. Choose which jar to save it to and add any tags to help organise your memories.',
    },
    {
      'question': 'Can I share memories with family members?',
      'answer': 'Yes! Create a Family jar and invite your family members using the invite code. All members can view and add memories to shared jars. You can also create jars for friends or work colleagues.',
    },
    {
      'question': 'How do AI reflections work?',
      'answer': 'Our AI analyses your memories over time to generate meaningful reflections. You can choose weekly, monthly, or yearly reflections in your jar settings. The AI never shares your data and runs with your explicit consent.',
    },
    {
      'question': 'Is my data secure?',
      'answer': 'Absolutely. We use AES-256 encryption at rest and TLS 1.3 in transit. Your data is stored in UK/EU data centres and we comply with UK GDPR and the Data Protection Act 2018.',
    },
    {
      'question': 'How do I delete a memory?',
      'answer': 'Open the memory you want to delete, tap the three dots menu in the top right, and select "Delete". Deleted memories are permanently removed within 30 days.',
    },
    {
      'question': 'Can I export my data?',
      'answer': 'Yes, go to Settings > Privacy & Security > Export My Data. Under UK GDPR, you have the right to data portability. We\'ll send you a download link within 24 hours.',
    },
    {
      'question': 'What happens if I delete my account?',
      'answer': 'All your data including memories, photos, and account information will be permanently deleted within 30 days. You will be removed from all shared jars. This action cannot be undone.',
    },
    {
      'question': 'How do I change my profile picture?',
      'answer': 'Go to the Profile tab, tap on your current profile picture, and choose a new image from your photo library or take a new photo.',
    },
  ];

  static const String _termsOfService = '''
MEMORY JAR - TERMS OF SERVICE
Last Updated: December 2025

1. ACCEPTANCE OF TERMS
By accessing or using the Memory Jar application, you agree to these Terms.

2. SERVICE DESCRIPTION
Memory Jar is a digital platform for capturing and sharing personal memories.

3. USER ACCOUNTS
• You must provide accurate information
• You are responsible for account security
• Minimum age: 13 years (parental consent required under 18)

4. USER CONTENT
• You retain ownership of your content
• You grant us a limited license to store and display your content
• You are responsible for your content

5. ACCEPTABLE USE
Do NOT:
• Upload illegal or harmful content
• Impersonate others
• Attempt unauthorised access
• Use for commercial purposes without permission

6. INTELLECTUAL PROPERTY
The Service and its features are owned by Memory Jar Ltd.

7. LIMITATION OF LIABILITY
We are not liable for indirect, incidental, or consequential damages.

8. GOVERNING LAW
These Terms are governed by the laws of England and Wales.

9. CONTACT
legal@memoryjar.app
''';

  static const String _privacyPolicy = '''
MEMORY JAR - PRIVACY POLICY
Last Updated: December 2025

Compliant with UK GDPR and Data Protection Act 2018

1. DATA CONTROLLER
Memory Jar Ltd
Contact: privacy@memoryjar.app

2. DATA WE COLLECT
• Account information (name, email, photo)
• Memories (text, photos, voice)
• Device and usage data

3. LEGAL BASIS (UK GDPR Article 6)
• Contract: To provide the Service
• Legitimate Interest: To improve the Service
• Consent: For optional features

4. YOUR RIGHTS
• Access your data
• Correct inaccurate data
• Delete your data
• Export your data
• Object to processing
• Withdraw consent

5. DATA SECURITY
• AES-256 encryption at rest
• TLS 1.3 in transit
• UK/EU data centres

6. DATA RETENTION
• Active accounts: While active
• Deleted data: Removed within 30 days
• Backups purged within 90 days

7. CHILDREN'S PRIVACY
We comply with the Age Appropriate Design Code.

8. CONTACT
privacy@memoryjar.app
ICO: ico.org.uk
''';

  static const String _cookiePolicy = '''
MEMORY JAR - COOKIE POLICY
Last Updated: December 2025

Compliant with UK PECR

WHAT COOKIES WE USE

Memory Jar uses only strictly necessary cookies required for the app to function. These include:

• Authentication cookies: To keep you logged in
• Security cookies: To protect against fraud
• Preference cookies: To remember your settings

We do NOT use:
• Advertising cookies
• Analytics cookies
• Third-party tracking cookies

CONSENT

Under UK PECR (Privacy and Electronic Communications Regulations), strictly necessary cookies do not require consent as they are essential for the service to function.

YOUR CHOICES

You can clear cookies through your device settings, but this may affect the app's functionality.

CONTACT

For questions: privacy@memoryjar.app
''';
}

class _FAQItem extends StatefulWidget {
  const _FAQItem({
    required this.question,
    required this.answer,
    required this.isDark,
  });

  final String question;
  final String answer;
  final bool isDark;

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: widget.isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: widget.isDark ? Colors.white : AppColors.textPrimary,
              fontSize: 15,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.remove_rounded : Icons.add_rounded,
            color: AppColors.primary,
          ),
          onExpansionChanged: (expanded) {
            setState(() => _isExpanded = expanded);
          },
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.answer,
                style: TextStyle(
                  color: widget.isDark ? Colors.white60 : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
