import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/models/memory_model.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userDoc = ref.watch(userDocProvider);
    final user = ref.watch(currentUserProvider);

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
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(userDocProvider);
            },
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: userDoc.when(
                      data: (userData) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: AppColors.textSecondaryLight,
                                    ),
                                  ).animate().fadeIn(duration: 400.ms),
                                  const SizedBox(height: 4),
                                  Text(
                                    userData?.displayName ?? 'Memory Keeper',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryLight,
                                    ),
                                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                                ],
                              ),
                              Container(
                                width: 50,
                                height: 50,
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
                                ),
                                child: Center(
                                  child: Text(
                                    userData?.avatarEmoji ?? '😊',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ).animate(delay: 200.ms).fadeIn(duration: 400.ms).scale(begin: const Offset(0.8, 0.8)),
                            ],
                          ),
                        ],
                      ),
                      loading: () => const SizedBox(height: 60),
                      error: (_, __) => const Text('Error loading profile'),
                    ),
                  ),
                ),

                // Jar Stats Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: userDoc.when(
                      data: (userData) => _JarStatsCard(
                        totalMemories: userData?.stats.totalMemories ?? 0,
                        streak: userData?.stats.currentStreak ?? 0,
                        photos: userData?.stats.photosCount ?? 0,
                        text: userData?.stats.textCount ?? 0,
                      ),
                      loading: () => _JarStatsCard(
                        totalMemories: 0,
                        streak: 0,
                        photos: 0,
                        text: 0,
                      ),
                      error: (_, __) => const SizedBox(),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.shuffle,
                            label: 'Random',
                            color: AppColors.accentPurple,
                            onTap: () => _showRandomMemory(context, ref),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.today,
                            label: 'This Day',
                            color: AppColors.accentBlue,
                            onTap: () => _showThisDayMemories(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.auto_awesome,
                            label: 'Reflect',
                            color: AppColors.accentGreen,
                            onTap: () => context.go('/reflections'),
                          ),
                        ),
                      ],
                    ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Recent Memories Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Memories',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('See all'),
                        ),
                      ],
                    ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                  ),
                ),

                // Memories List
                userDoc.when(
                  data: (userData) {
                    if (userData?.familyId == null) {
                      return SliverToBoxAdapter(
                        child: _EmptyState(
                          onCreateFirst: () => context.push('/create-memory'),
                          message: 'Join a family to start adding memories!',
                        ),
                      );
                    }
                    return _MemoriesList(familyId: userData!.familyId!);
                  },
                  loading: () => const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (_, __) => const SliverToBoxAdapter(
                    child: Center(child: Text('Error loading memories')),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showRandomMemory(BuildContext context, WidgetRef ref) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎲 Shaking the jar...'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showThisDayMemories(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📅 Looking at this day in history...'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}

class _JarStatsCard extends StatelessWidget {
  final int totalMemories;
  final int streak;
  final int photos;
  final int text;

  const _JarStatsCard({
    required this.totalMemories,
    required this.streak,
    required this.photos,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryLight,
                      AppColors.primary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text('🫙', style: TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$totalMemories',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      'memories in your jar',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '$streak',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.accentOrange,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.photo_outlined,
                  value: '$photos',
                  label: 'Photos',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.text_snippet_outlined,
                  value: '$text',
                  label: 'Text',
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.shade300,
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.mic_outlined,
                  value: '0',
                  label: 'Voice',
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondaryLight, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
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
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoriesList extends StatelessWidget {
  final String familyId;

  const _MemoriesList({required this.familyId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('memories')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return SliverToBoxAdapter(
            child: _EmptyState(
              onCreateFirst: () => context.push('/create-memory'),
            ),
          );
        }

        final memories = snapshot.data!.docs
            .map((doc) => MemoryModel.fromFirestore(doc))
            .toList();

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final memory = memories[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _MemoryCard(memory: memory),
                ).animate(delay: (100 * index).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05);
              },
              childCount: memories.length,
            ),
          ),
        );
      },
    );
  }
}

class _MemoryCard extends StatelessWidget {
  final MemoryModel memory;

  const _MemoryCard({required this.memory});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/memory/${memory.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      memory.authorAvatarEmoji ?? '😊',
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memory.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _formatDate(memory.memoryDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(memory.mood, style: const TextStyle(fontSize: 24)),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Content
            Text(
              memory.content,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: AppColors.textPrimaryLight,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            
            // Photos
            if (memory.hasMedia) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: memory.mediaUrls.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: memory.mediaUrls[index],
                          width: 120,
                          height: 120,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            
            // Themes/Tags
            if (memory.themes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: memory.themes.map((theme) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      theme,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    
    return DateFormat('MMM d, y').format(date);
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateFirst;
  final String? message;

  const _EmptyState({required this.onCreateFirst, this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🫙', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message ?? 'Your jar is empty',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding memories to fill it up!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onCreateFirst,
            icon: const Icon(Icons.add),
            label: const Text('Add First Memory'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.95, 0.95));
  }
}
