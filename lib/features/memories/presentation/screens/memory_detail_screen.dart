import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/glass_container.dart';
import '../../../../shared/models/memory_model.dart';

class MemoryDetailScreen extends ConsumerStatefulWidget {
  final String memoryId;
  
  const MemoryDetailScreen({super.key, required this.memoryId});

  @override
  ConsumerState<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends ConsumerState<MemoryDetailScreen> {
  MemoryModel? _memory;
  bool _isLoading = true;
  String? _error;
  int _currentImageIndex = 0;
  final PageController _pageController = PageController();
  
  // Reaction emojis
  final List<String> _reactionEmojis = ['❤️', '😊', '🥺', '😂', '🎉', '💪'];
  
  @override
  void initState() {
    super.initState();
    _loadMemory();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
  
  Future<void> _loadMemory() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      
      // Get user's family ID
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final familyId = userDoc.data()?['familyId'] as String?;
      if (familyId == null) {
        setState(() {
          _error = 'No family found';
          _isLoading = false;
        });
        return;
      }
      
      // Get memory
      final memoryDoc = await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('memories')
          .doc(widget.memoryId)
          .get();
      
      if (!memoryDoc.exists) {
        setState(() {
          _error = 'Memory not found';
          _isLoading = false;
        });
        return;
      }
      
      setState(() {
        _memory = MemoryModel.fromFirestore(memoryDoc);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load memory: $e';
        _isLoading = false;
      });
    }
  }
  
  Future<void> _addReaction(String emoji) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || _memory == null) return;
    
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final familyId = userDoc.data()?['familyId'] as String?;
      if (familyId == null) return;
      
      // Simple toggle - one reaction per user
      final reactions = Map<String, String>.from(_memory!.reactions);
      
      // Check if user already reacted with this emoji
      if (reactions[user.uid] == emoji) {
        reactions.remove(user.uid);
      } else {
        reactions[user.uid] = emoji;
      }
      
      await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('memories')
          .doc(widget.memoryId)
          .update({'reactions': reactions});
      
      setState(() {
        _memory = _memory!.copyWith(reactions: reactions);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add reaction: $e')),
      );
    }
  }
  
  Future<void> _deleteMemory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Memory'),
        content: const Text('Are you sure you want to delete this memory? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || _memory == null) return;
      
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      final familyId = userDoc.data()?['familyId'] as String?;
      if (familyId == null) return;
      
      await FirebaseFirestore.instance
          .collection('families')
          .doc(familyId)
          .collection('memories')
          .doc(widget.memoryId)
          .delete();
      
      // Update user stats
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_memory!.authorId)
          .update({
        'totalMemories': FieldValue.increment(-1),
        if (_memory!.mediaUrls.isNotEmpty)
          'photosCount': FieldValue.increment(-_memory!.mediaUrls.length),
        if (_memory!.content.isNotEmpty)
          'textCount': FieldValue.increment(-1),
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory deleted'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.05),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildErrorState()
                  : _buildContent(),
        ),
      ),
    );
  }
  
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContent() {
    final memory = _memory!;
    final colorScheme = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;
    final isAuthor = user?.uid == memory.authorId;
    
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: memory.mediaUrls.isNotEmpty ? 400 : 0,
          pinned: true,
          leading: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            onPressed: () => context.pop(),
          ),
          actions: [
            if (isAuthor)
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onPressed: _deleteMemory,
              ),
          ],
          flexibleSpace: memory.mediaUrls.isNotEmpty
              ? FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      // Image carousel
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        itemCount: memory.mediaUrls.length,
                        itemBuilder: (context, index) {
                          return CachedNetworkImage(
                            imageUrl: memory.mediaUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[300],
                              child: const Center(child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          );
                        },
                      ),
                      // Page indicator
                      if (memory.mediaUrls.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              memory.mediaUrls.length,
                              (index) => Container(
                                width: index == _currentImageIndex ? 24 : 8,
                                height: 8,
                                margin: const EdgeInsets.symmetric(horizontal: 4),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: index == _currentImageIndex
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : null,
          backgroundColor: colorScheme.surface,
        ),
        
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with mood and date
                Row(
                  children: [
                    // Mood emoji
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        memory.mood,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ).animate().scale(delay: 100.ms),
                    const SizedBox(width: 16),
                    // Author and date
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                memory.authorAvatarEmoji ?? '👤',
                                style: const TextStyle(fontSize: 20),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                memory.authorName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE, MMMM d, yyyy').format(memory.memoryDate),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          Text(
                            'Added ${_formatRelativeTime(memory.createdAt)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.4),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.2),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Content
                if (memory.content.isNotEmpty)
                  GlassContainer(
                    padding: const EdgeInsets.all(20),
                    borderRadius: 20,
                    child: Text(
                      memory.content,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        height: 1.6,
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 20),
                
                // Tags (themes)
                if (memory.themes.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: memory.themes.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 24),
                ],
                
                // Reactions section
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  borderRadius: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reactions',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Reaction buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _reactionEmojis.map((emoji) {
                          // Count reactions for this emoji
                          final count = memory.reactions.values.where((r) => r == emoji).length;
                          final hasReacted = memory.reactions[user?.uid] == emoji;
                          
                          return GestureDetector(
                            onTap: () => _addReaction(emoji),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: hasReacted
                                    ? colorScheme.primaryContainer
                                    : colorScheme.surface,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: hasReacted
                                      ? colorScheme.primary
                                      : colorScheme.outline.withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 20)),
                                  if (count > 0) ...[
                                    const SizedBox(width: 4),
                                    Text(
                                      count.toString(),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: hasReacted
                                            ? colorScheme.primary
                                            : colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                
                const SizedBox(height: 100), // Bottom padding
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} minutes ago';
      }
      return '${difference.inHours} hours ago';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d').format(dateTime);
    }
  }
}
