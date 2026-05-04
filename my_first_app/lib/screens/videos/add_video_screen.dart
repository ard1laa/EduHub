import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../models/video_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';

class AddVideoScreen extends StatefulWidget {
  const AddVideoScreen({super.key});

  @override
  State<AddVideoScreen> createState() => _AddVideoScreenState();
}

class _AddVideoScreenState extends State<AddVideoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  VideoCategory _selectedCategory = VideoCategory.other;
  bool _isPublic = false;
  bool _isLoading = false;
  String _previewId = '';

  @override
  void dispose() {
    _urlCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  void _onUrlChanged(String url) {
    final id = VideoModel.extractYoutubeId(url.trim());
    setState(() => _previewId = id);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final id = VideoModel.extractYoutubeId(_urlCtrl.text.trim());
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube URL. Please try again.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final prov = context.read<AppProvider>();
    final tags = _tagsCtrl.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final video = VideoModel(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      youtubeUrl: _urlCtrl.text.trim(),
      youtubeId: id,
      category: _selectedCategory,
      ownerId: prov.currentUser?.id ?? '',
      ownerName: prov.currentUser?.fullName ?? '',
      tags: tags,
      isPublic: _isPublic,   // provider will intercept this for students
      savedAt: DateTime.now(),
    );

    prov.addVideo(video);

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPublic
              ? 'Video saved! Share request submitted for admin review.'
              : 'Video saved to your private library.',
        ),
        backgroundColor: AppColors.accentGreen,
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Learning Video'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingMD),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // URL input
              Text('YouTube URL',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              CustomTextField(
                controller: _urlCtrl,
                label: 'YouTube Link',
                hint: 'https://www.youtube.com/watch?v=...',
                prefixIcon: Icons.link_rounded,
                keyboardType: TextInputType.url,
                onChanged: _onUrlChanged,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'URL is required';
                  final id = VideoModel.extractYoutubeId(v.trim());
                  if (id.isEmpty) return 'Enter a valid YouTube URL';
                  return null;
                },
              ),

              // Preview
              if (_previewId.isNotEmpty) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLG),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl:
                            'https://img.youtube.com/vi/$_previewId/maxresdefault.jpg',
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(
                          height: 200,
                          color: AppColors.surfaceVariant,
                          child: const Center(
                              child: CircularProgressIndicator()),
                        ),
                        errorWidget: (ctx, url, err) => Container(
                          height: 200,
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.play_circle_outline,
                              size: 60, color: AppColors.primary),
                        ),
                      ),
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          child: const Icon(Icons.play_circle_filled,
                              size: 60, color: Colors.white),
                        ),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Preview',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 11)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Text('Video Details',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),

              CustomTextField(
                controller: _titleCtrl,
                label: 'Title',
                hint: 'Give this video a descriptive title',
                prefixIcon: Icons.title_rounded,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Title is required';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _descCtrl,
                label: 'Description',
                hint: 'What is this video about?',
                prefixIcon: Icons.description_outlined,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: 14),

              // Category
              DropdownButtonFormField<VideoCategory>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  prefixIcon: const Icon(Icons.category_outlined),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMD),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                ),
                items: VideoCategory.values
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat.displayName),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _selectedCategory = v);
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _tagsCtrl,
                label: 'Tags (comma separated)',
                hint: 'e.g., flutter, dart, mobile',
                prefixIcon: Icons.tag_rounded,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Sharing toggle
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: _isPublic
                      ? AppColors.primary.withOpacity(0.07)
                      : AppColors.surfaceVariant,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: _isPublic
                        ? AppColors.primary.withOpacity(0.4)
                        : AppColors.border,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isPublic
                              ? Icons.public_rounded
                              : Icons.lock_rounded,
                          color: _isPublic
                              ? AppColors.primary
                              : AppColors.textSecondary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _isPublic
                                    ? 'Request Community Sharing'
                                    : 'Keep Private',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _isPublic
                                        ? AppColors.primary
                                        : AppColors.textPrimary),
                              ),
                              Text(
                                _isPublic
                                    ? 'Admin approval required before it goes public'
                                    : 'Only you can see this video',
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isPublic,
                          onChanged: (v) => setState(() => _isPublic = v),
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    if (_isPublic) ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.08),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSM),
                          border: Border.all(
                              color:
                                  AppColors.accentOrange.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.shield_rounded,
                                size: 14, color: AppColors.accentOrange),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'A share request will be automatically submitted. '  
                                'You will be notified once an admin reviews it.',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.accentOrange,
                                    height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 28),
              GradientButton(
                label: 'Save Video',
                onPressed: _isLoading ? null : _save,
                isLoading: _isLoading,
                icon: const Icon(Icons.save_rounded, color: Colors.white),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
