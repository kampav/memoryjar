import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../shared/widgets/glass_container.dart';

class FamilySetupScreen extends ConsumerStatefulWidget {
  const FamilySetupScreen({super.key});

  @override
  ConsumerState<FamilySetupScreen> createState() => _FamilySetupScreenState();
}

class _FamilySetupScreenState extends ConsumerState<FamilySetupScreen> {
  final _familyNameController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  bool _isLoading = false;
  String _selectedMode = 'create'; // 'create', 'join', or 'skip'

  @override
  void dispose() {
    _familyNameController.dispose();
    _inviteCodeController.dispose();
    super.dispose();
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(8, (_) => chars[random.nextInt(chars.length)]).join();
  }

  Future<void> _createFamily() async {
    final name = _familyNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a family name'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        context.go('/welcome');
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? {};
      final displayName = userData['displayName'] ?? 'User';
      final avatarEmoji = userData['avatarEmoji'] ?? '😊';

      final inviteCode = _generateInviteCode();
      final familyRef = FirebaseFirestore.instance.collection('families').doc();

      await familyRef.set({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': user.uid,
        'inviteCode': inviteCode,
        'members': {
          user.uid: {
            'role': 'admin',
            'joinedAt': FieldValue.serverTimestamp(),
            'displayName': displayName,
            'avatarEmoji': avatarEmoji,
          },
        },
        'memberCount': 1,
        'settings': {
          'allowChildAccounts': true,
          'requireApproval': false,
        },
      });

      await ref.read(authServiceProvider).updateUserProfile(
        uid: user.uid,
        familyId: familyRef.id,
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating family: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _joinFamily() async {
    final code = _inviteCodeController.text.trim().toUpperCase();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an invite code'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = ref.read(currentUserProvider);
      if (user == null) {
        context.go('/welcome');
        return;
      }

      final familyQuery = await FirebaseFirestore.instance
          .collection('families')
          .where('inviteCode', isEqualTo: code)
          .limit(1)
          .get();

      if (familyQuery.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid invite code. Please check and try again.'),
              backgroundColor: AppColors.error,
            ),
          );
        }
        return;
      }

      final familyDoc = familyQuery.docs.first;
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data() ?? {};
      final displayName = userData['displayName'] ?? 'User';
      final avatarEmoji = userData['avatarEmoji'] ?? '😊';

      await familyDoc.reference.update({
        'members.${user.uid}': {
          'role': 'member',
          'joinedAt': FieldValue.serverTimestamp(),
          'displayName': displayName,
          'avatarEmoji': avatarEmoji,
        },
        'memberCount': FieldValue.increment(1),
      });

      await ref.read(authServiceProvider).updateUserProfile(
        uid: user.uid,
        familyId: familyDoc.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Joined ${familyDoc.data()['name']}!'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error joining family: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _skipForNow() async {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                
                // Progress indicator
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 300.ms),
                
                const SizedBox(height: 32),
                
                // Header
                const Text(
                  'Set up your\nFamily Jar',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                    height: 1.2,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                
                const SizedBox(height: 8),
                
                Text(
                  'Create a new jar or join your family\'s existing one',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textSecondaryLight,
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                
                const SizedBox(height: 32),
                
                // Mode Selector
                Row(
                  children: [
                    Expanded(
                      child: _ModeCard(
                        icon: Icons.add_circle_outline,
                        title: 'Create New',
                        isSelected: _selectedMode == 'create',
                        onTap: () => setState(() => _selectedMode = 'create'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ModeCard(
                        icon: Icons.group_add_outlined,
                        title: 'Join Family',
                        isSelected: _selectedMode == 'join',
                        onTap: () => setState(() => _selectedMode = 'join'),
                      ),
                    ),
                  ],
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 24),
                
                // Content based on mode
                Expanded(
                  child: _selectedMode == 'create'
                      ? _buildCreateContent()
                      : _buildJoinContent(),
                ),
                
                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading 
                        ? null 
                        : (_selectedMode == 'create' ? _createFamily : _joinFamily),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
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
                            _selectedMode == 'create' ? 'Create Family Jar' : 'Join Family',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 12),
                
                // Skip for now
                Center(
                  child: TextButton(
                    onPressed: _isLoading ? null : _skipForNow,
                    child: const Text(
                      'Skip for now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateContent() {
    return Column(
      children: [
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🫙', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Text(
                    'New Family Jar',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _familyNameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: 'Family name',
                  hintText: 'e.g., The Smiths',
                  prefixIcon: const Icon(Icons.family_restroom),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '💡 After creating, you can invite family members with a unique code.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
      ],
    );
  }

  Widget _buildJoinContent() {
    return Column(
      children: [
        GlassContainer(
          borderRadius: 20,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🔗', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Text(
                    'Join with Code',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _inviteCodeController,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(8),
                ],
                decoration: InputDecoration(
                  labelText: 'Invite code',
                  hintText: 'Enter 8-character code',
                  prefixIcon: const Icon(Icons.vpn_key_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '💡 Ask a family member for the invite code from their app.',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
