import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/color_schemes.dart';
import '../../../../shared/widgets/glass_container.dart';

class CreateMemoryScreen extends ConsumerStatefulWidget {
  const CreateMemoryScreen({super.key});

  @override
  ConsumerState<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends ConsumerState<CreateMemoryScreen> {
  final _contentController = TextEditingController();
  final List<XFile> _selectedImages = [];
  String _selectedMood = '😊';
  DateTime _memoryDate = DateTime.now();
  final Set<String> _selectedThemes = {};
  bool _isLoading = false;
  double _uploadProgress = 0;

  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '🥰', 'label': 'Loving'},
    {'emoji': '😎', 'label': 'Cool'},
    {'emoji': '🤗', 'label': 'Grateful'},
    {'emoji': '😇', 'label': 'Blessed'},
    {'emoji': '🤔', 'label': 'Thoughtful'},
    {'emoji': '😴', 'label': 'Tired'},
    {'emoji': '😢', 'label': 'Sad'},
    {'emoji': '😤', 'label': 'Frustrated'},
    {'emoji': '🤒', 'label': 'Sick'},
  ];

  final List<String> _themes = [
    'Family Time',
    'Adventure',
    'Milestone',
    'Celebration',
    'Daily Life',
    'Travel',
    'Food',
    'Nature',
    'Learning',
    'Achievement',
  ];

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 photos allowed'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final images = await picker.pickMultiImage(
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (images.isNotEmpty) {
      setState(() {
        final remaining = 5 - _selectedImages.length;
        _selectedImages.addAll(images.take(remaining));
      });
    }
  }

  Future<void> _takePhoto() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum 5 photos allowed'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedImages.add(image);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _memoryDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) {
      setState(() => _memoryDate = date);
    }
  }

  Future<void> _saveMemory() async {
    final content = _contentController.text.trim();
    if (content.isEmpty && _selectedImages.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add some text or photos'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    final userDoc = ref.read(userDocProvider).value;
    
    if (user == null || userDoc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to create memories'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (userDoc.familyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please join or create a family first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    try {
      // Create memory document first so uploads can use the memoryId path
      final memoryRef = FirebaseFirestore.instance
          .collection('families')
          .doc(userDoc.familyId!)
          .collection('memories')
          .doc();

      // Upload images
      final List<String> mediaUrls = [];
      
      for (int i = 0; i < _selectedImages.length; i++) {
        final image = _selectedImages[i];
        final imageId = const Uuid().v4();
        final ref = FirebaseStorage.instance
            .ref()
            .child('families')
            .child(userDoc.familyId!)
            .child('memories')
            .child(memoryRef.id)
            .child('$imageId.jpg');

        final uploadTask = ref.putFile(
          File(image.path),
          SettableMetadata(contentType: 'image/jpeg'),
        );

        uploadTask.snapshotEvents.listen((event) {
          setState(() {
            _uploadProgress = (i + event.bytesTransferred / event.totalBytes) / _selectedImages.length;
          });
        });

        await uploadTask;
        final url = await ref.getDownloadURL();
        mediaUrls.add(url);
      }

      await memoryRef.set({
        'authorId': user.uid,
        'authorName': userDoc.displayName,
        'authorAvatarEmoji': userDoc.avatarEmoji,
        'authorAvatarUrl': userDoc.avatarUrl,
        'familyId': userDoc.familyId,
        'content': content,
        'mediaUrls': mediaUrls,
        'thumbnailUrls': mediaUrls, // TODO: Generate thumbnails
        'mood': _selectedMood,
        'themes': _selectedThemes.toList(),
        'aiTags': [],
        'privacy': 'family',
        'allowedViewers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'memoryDate': Timestamp.fromDate(_memoryDate),
        'reactions': {},
        'commentCount': 0,
        'isHighlight': false,
        'yearTag': _memoryDate.year,
        'monthTag': _memoryDate.month,
        'weekTag': _getWeekOfYear(_memoryDate),
      });

      // Update user stats
      final statsUpdate = {
        'stats.totalMemories': FieldValue.increment(1),
        'stats.lastMemoryDate': FieldValue.serverTimestamp(),
      };
      
      if (content.isNotEmpty) {
        statsUpdate['stats.textCount'] = FieldValue.increment(1);
      }
      if (mediaUrls.isNotEmpty) {
        statsUpdate['stats.photosCount'] = FieldValue.increment(mediaUrls.length);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update(statsUpdate);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory saved! ✨'),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving memory: ${e.toString()}'),
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

  // Debug-only: create a tiny PNG and upload it to verify storage rules
  Future<void> _runDebugUploadTest() async {
    if (!kDebugMode) return;

    final user = ref.read(currentUserProvider);
    final userDoc = ref.read(userDocProvider).value;

    if (user == null || userDoc == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not signed in')),
      );
      return;
    }

    if (userDoc.familyId == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No family set')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _uploadProgress = 0;
    });

    try {
      final memoryRef = FirebaseFirestore.instance
          .collection('families')
          .doc(userDoc.familyId!)
          .collection('memories')
          .doc();

      final fileName = '${const Uuid().v4()}.png';
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$fileName');

      // 1x1 transparent PNG
      final pngBase64 = 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVQYV2NgYAAAAAMAAWgmWQ0AAAAASUVORK5CYII=';
      final bytes = base64Decode(pngBase64);
      await file.writeAsBytes(bytes, flush: true);

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('families')
          .child(userDoc.familyId!)
          .child('memories')
          .child(memoryRef.id)
          .child(fileName);

      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(contentType: 'image/png'),
      );

      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          if (event.totalBytes > 0)
            _uploadProgress = event.bytesTransferred / event.totalBytes;
        });
      });

      await uploadTask;
      final url = await storageRef.getDownloadURL();

      await memoryRef.set({
        'authorId': user.uid,
        'authorName': userDoc.displayName,
        'authorAvatarEmoji': userDoc.avatarEmoji,
        'authorAvatarUrl': userDoc.avatarUrl,
        'familyId': userDoc.familyId,
        'content': 'Debug upload',
        'mediaUrls': [url],
        'thumbnailUrls': [url],
        'mood': _selectedMood,
        'themes': [],
        'aiTags': [],
        'privacy': 'family',
        'allowedViewers': [],
        'createdAt': FieldValue.serverTimestamp(),
        'memoryDate': FieldValue.serverTimestamp(),
        'reactions': {},
        'commentCount': 0,
        'isHighlight': false,
        'yearTag': DateTime.now().year,
        'monthTag': DateTime.now().month,
        'weekTag': _getWeekOfYear(DateTime.now()),
      });

      // Update user stats
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'stats.totalMemories': FieldValue.increment(1),
        'stats.lastMemoryDate': FieldValue.serverTimestamp(),
        'stats.photosCount': FieldValue.increment(1),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debug upload successful ✅')),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Debug upload failed: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  int _getWeekOfYear(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysDiff = date.difference(firstDayOfYear).inDays;
    return ((daysDiff + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) return 'Today';
    if (dateOnly == yesterday) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
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
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.close),
                    ),
                    const Text(
                      'New Memory',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _saveMemory,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Save',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    // Debug upload button (visible only in debug builds)
                    if (kDebugMode)
                      IconButton(
                        tooltip: 'DEV: Upload test image',
                        onPressed: _isLoading ? null : _runDebugUploadTest,
                        icon: const Icon(Icons.bug_report, color: Colors.orange),
                      ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Upload Progress
              if (_isLoading && _uploadProgress > 0)
                LinearProgressIndicator(
                  value: _uploadProgress,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mood Selector
                      const Text(
                        'How are you feeling?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ).animate(delay: 100.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 72,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _moods.length,
                          itemBuilder: (context, index) {
                            final mood = _moods[index];
                            final isSelected = _selectedMood == mood['emoji'];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () => setState(() => _selectedMood = mood['emoji']!),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary.withOpacity(0.15)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : Colors.grey.shade200,
                                      width: isSelected ? 2 : 1,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        mood['emoji']!,
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        mood['label']!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.textSecondaryLight,
                                          fontWeight: isSelected
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ).animate(delay: (50 * index).ms).fadeIn(duration: 300.ms).slideX(begin: 0.1);
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Content Input
                      const Text(
                        'What happened?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ).animate(delay: 200.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: TextField(
                          controller: _contentController,
                          maxLines: 5,
                          maxLength: 500,
                          decoration: const InputDecoration(
                            hintText: 'Write about this memory...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ).animate(delay: 250.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Photos Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Photos',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            '${_selectedImages.length}/5',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            // Add Photo Buttons
                            GestureDetector(
                              onTap: _pickImages,
                              child: Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: AppColors.primary,
                                    width: 2,
                                    style: BorderStyle.solid,
                                  ),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library_outlined, color: AppColors.primary),
                                    SizedBox(height: 4),
                                    Text(
                                      'Gallery',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate(delay: 350.ms).fadeIn(duration: 300.ms),
                            GestureDetector(
                              onTap: _takePhoto,
                              child: Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt_outlined, color: Colors.grey.shade600),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Camera',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
                            // Selected Images
                            ..._selectedImages.asMap().entries.map((entry) {
                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    margin: const EdgeInsets.only(right: 12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      image: DecorationImage(
                                        image: FileImage(File(entry.value.path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 16,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(entry.key),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ).animate(delay: (450 + 50 * entry.key).ms).fadeIn(duration: 300.ms).scale(begin: const Offset(0.8, 0.8));
                            }),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Date Selector
                      const Text(
                        'When did this happen?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _selectDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today, color: AppColors.primary),
                              const SizedBox(width: 12),
                              Text(
                                _formatDate(_memoryDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              Icon(Icons.chevron_right, color: Colors.grey.shade400),
                            ],
                          ),
                        ),
                      ).animate(delay: 550.ms).fadeIn(duration: 400.ms),

                      const SizedBox(height: 24),

                      // Theme Tags
                      const Text(
                        'Add tags (optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimaryLight,
                        ),
                      ).animate(delay: 600.ms).fadeIn(duration: 400.ms),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _themes.asMap().entries.map((entry) {
                          final theme = entry.value;
                          final isSelected = _selectedThemes.contains(theme);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  _selectedThemes.remove(theme);
                                } else if (_selectedThemes.length < 3) {
                                  _selectedThemes.add(theme);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Maximum 3 tags allowed'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                theme,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimaryLight,
                                  fontWeight: isSelected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ).animate(delay: (650 + 30 * entry.key).ms).fadeIn(duration: 300.ms);
                        }).toList(),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
