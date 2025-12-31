import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../shared/widgets/glass_container.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDoc = ref.watch(userDocProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.backgroundLight,
              Color(0xFFFFF5EB),
            ],
          ),
        ),
        child: SafeArea(
          child: userDoc.when(
            data: (userData) => CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.primaryLight,
                                AppColors.primary,
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              userData?.avatarEmoji ?? '😊',
                              style: const TextStyle(fontSize: 48),
                            ),
                          ),
                        ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          userData?.displayName ?? 'Memory Keeper',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                        
                        if (userData?.email != null && userData!.email.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            userData.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
                        ],
                        
                        const SizedBox(height: 8),
                        
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Joined ${DateFormat('MMM yyyy').format(userData?.createdAt ?? DateTime.now())}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                      ],
                    ),
                  ),
                ),

                // Stats Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GlassContainer(
                      borderRadius: 20,
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: _StatColumn(
                              value: '${userData?.stats.totalMemories ?? 0}',
                              label: 'Memories',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _StatColumn(
                              value: '${userData?.stats.currentStreak ?? 0}',
                              label: 'Day Streak',
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 50,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: _StatColumn(
                              value: '${userData?.achievements.length ?? 0}',
                              label: 'Badges',
                            ),
                          ),
                        ],
                      ),
                    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Settings Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ).animate(delay: 400.ms).fadeIn(duration: 400.ms),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                // Settings Items
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _SettingsItem(
                            icon: Icons.person_outline,
                            title: 'Edit Profile',
                            onTap: () {},
                          ),
                          _SettingsDivider(),
                          _SettingsItem(
                            icon: Icons.notifications_outlined,
                            title: 'Notifications',
                            trailing: Switch(
                              value: userData?.settings.notificationsEnabled ?? true,
                              onChanged: (value) {},
                              activeColor: AppColors.primary,
                            ),
                          ),
                          _SettingsDivider(),
                          _SettingsItem(
                            icon: Icons.palette_outlined,
                            title: 'Appearance',
                            subtitle: 'System default',
                            onTap: () {},
                          ),
                          _SettingsDivider(),
                          _SettingsItem(
                            icon: Icons.language_outlined,
                            title: 'Language',
                            subtitle: 'English',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ).animate(delay: 500.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Support Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Text(
                      'Support',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _SettingsItem(
                            icon: Icons.help_outline,
                            title: 'Help & FAQ',
                            onTap: () {},
                          ),
                          _SettingsDivider(),
                          _SettingsItem(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: () {},
                          ),
                          _SettingsDivider(),
                          _SettingsItem(
                            icon: Icons.description_outlined,
                            title: 'Terms of Service',
                            onTap: () {},
                          ),
                          _SettingsDivider(),
                          _SettingsItem(
                            icon: Icons.info_outline,
                            title: 'About',
                            subtitle: 'Version 1.0.0',
                            onTap: () {},
                          ),
                        ],
                      ),
                    ).animate(delay: 700.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Sign Out Button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: OutlinedButton(
                      onPressed: () => _showSignOutDialog(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, size: 20),
                          SizedBox(width: 8),
                          Text('Sign Out'),
                        ],
                      ),
                    ).animate(delay: 800.ms).fadeIn(duration: 400.ms),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(child: Text('Error loading profile')),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;

  const _StatColumn({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondaryLight,
              ),
            )
          : null,
      trailing: trailing ?? (onTap != null ? Icon(Icons.chevron_right, color: Colors.grey.shade400) : null),
      onTap: onTap,
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 72,
      color: Colors.grey.shade200,
    );
  }
}
