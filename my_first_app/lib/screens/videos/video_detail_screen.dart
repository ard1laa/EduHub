import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/app_provider.dart';
import '../../models/video_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class VideoDetailScreen extends StatefulWidget {
  final VideoModel video;
  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late VideoModel _video;

  @override
  void initState() {
    super.initState();
    _video = widget.video;
  }

  Future<void> _openVideo() async {
    final uri = Uri.parse(_video.watchUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open YouTube')),
        );
      }
    }
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _video.watchUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Link copied to clipboard!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    // Get fresh video from provider
    final fresh = prov.videos.firstWhere(
      (v) => v.id == _video.id,
      orElse: () => _video,
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Collapsible header with thumbnail
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.primary,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: fresh.thumbnailUrl,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(
                      color: AppColors.primaryDark,
                      child: const Icon(Icons.play_circle_outline,
                          size: 60, color: Colors.white),
                    ),
                    errorWidget: (ctx, url, err) => Container(
                      color: AppColors.primaryDark,
                      child: const Icon(Icons.play_circle_outline,
                          size: 60, color: Colors.white),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Play button
                  Center(
                    child: GestureDetector(
                      onTap: _openVideo,
                      child: Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.play_arrow_rounded,
                            size: 36, color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  fresh.isDownloaded
                      ? Icons.download_done
                      : Icons.download_outlined,
                  color: Colors.white,
                ),
                onPressed: () {
                  prov.toggleDownload(fresh.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(fresh.isDownloaded
                          ? 'Removed from offline saves'
                          : 'Video saved offline!'),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: Colors.white),
                onPressed: _copyLink,
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category & status row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusRound),
                        ),
                        child: Text(
                          fresh.category.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (fresh.isDownloaded)
                        StatusBadge(
                            label: 'Offline',
                            color: AppColors.accentGreen),
                      if (fresh.isShared) ...[
                        const SizedBox(width: 8),
                        StatusBadge(
                          label: fresh.shareApproved ? 'Shared' : 'Pending',
                          color: fresh.shareApproved
                              ? AppColors.accentGreen
                              : AppColors.accentOrange,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(fresh.title,
                      style: Theme.of(context).textTheme.headlineMedium),

                  const SizedBox(height: 10),

                  // Meta row
                  Row(
                    children: [
                      const Icon(Icons.remove_red_eye_outlined,
                          size: 15, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text('${fresh.viewCount} views',
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 16),
                      const Icon(Icons.timer_outlined,
                          size: 15, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(fresh.durationLabel,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 16),
                      const Icon(Icons.person_outline,
                          size: 15, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(fresh.ownerName,
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),

                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Description
                  Text('Description',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    fresh.description.isNotEmpty
                        ? fresh.description
                        : 'No description provided.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),

                  if (fresh.tags.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text('Tags',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: fresh.tags
                          .map((tag) => AppChip(label: '#$tag'))
                          .toList(),
                    ),
                  ],

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Action buttons
                  Text('Actions',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.open_in_new_rounded,
                          label: 'Watch on\nYouTube',
                          color: AppColors.accentRed,
                          onTap: _openVideo,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.copy_rounded,
                          label: 'Copy\nLink',
                          color: AppColors.primary,
                          onTap: _copyLink,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: fresh.isDownloaded
                              ? Icons.download_done_rounded
                              : Icons.download_rounded,
                          label: fresh.isDownloaded ? 'Saved\nOffline' : 'Save\nOffline',
                          color: AppColors.accentGreen,
                          onTap: () {
                            prov.toggleDownload(fresh.id);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ActionButton(
                          icon: Icons.folder_open_rounded,
                          label: 'Add to\nAlbum',
                          color: AppColors.secondary,
                          onTap: () => _showAlbumPicker(context, prov, fresh),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Open in YouTube
                  GradientButton(
                    label: 'Open in YouTube',
                    onPressed: _openVideo,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF0000), Color(0xFFCC0000)],
                    ),
                    icon: const Icon(Icons.play_circle_filled,
                        color: Colors.white, size: 20),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAlbumPicker(
      BuildContext context, AppProvider prov, VideoModel video) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXXL)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Add to Album',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
            const Divider(height: 1),
            if (prov.albums.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text('No albums found. Create an album first.'),
              )
            else
              ...prov.albums.map(
                (album) => ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.folder_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  title: Text(album.title),
                  subtitle: Text('${album.videoCount} videos'),
                  trailing: album.videoIds.contains(video.id)
                      ? const Icon(Icons.check_circle,
                          color: AppColors.accentGreen)
                      : null,
                  onTap: () {
                    if (album.videoIds.contains(video.id)) {
                      prov.removeVideoFromAlbum(album.id, video.id);
                    } else {
                      prov.addVideoToAlbum(album.id, video.id);
                    }
                    Navigator.pop(ctx);
                  },
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
