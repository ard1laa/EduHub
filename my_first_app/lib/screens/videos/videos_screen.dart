import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/video_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/video_card.dart';
import 'add_video_screen.dart';
import 'video_detail_screen.dart';

class VideosScreen extends StatelessWidget {
  const VideosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final videos = prov.filteredVideos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Videos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter
          Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            color: AppColors.surface,
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: prov.setVideoSearch,
                  decoration: InputDecoration(
                    hintText: 'Search videos, tags...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: prov.videoSearchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => prov.setVideoSearch(''),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 10),
                // Category filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      AppChip(
                        label: 'All',
                        selected: prov.selectedCategory == null,
                        onTap: () => prov.setSelectedCategory(null),
                      ),
                      const SizedBox(width: 8),
                      ...VideoCategory.values.map(
                        (cat) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: AppChip(
                            label: cat.displayName,
                            selected: prov.selectedCategory == cat,
                            onTap: () => prov.setSelectedCategory(cat),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Video count
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Text(
                  '${videos.length} video${videos.length != 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(),
                if (prov.selectedCategory != null || prov.videoSearchQuery.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      prov.setSelectedCategory(null);
                      prov.setVideoSearch('');
                    },
                    icon: const Icon(Icons.filter_alt_off, size: 16),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                    ),
                  ),
              ],
            ),
          ),

          // Video list
          Expanded(
            child: videos.isEmpty
                ? EmptyState(
                    icon: Icons.video_library_outlined,
                    title: 'No Videos Yet',
                    subtitle:
                        'Start by adding your first YouTube learning video.',
                    actionLabel: 'Add Video',
                    onAction: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddVideoScreen()),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: videos.length,
                    itemBuilder: (ctx, i) {
                      final video = videos[i];
                      return VideoCard(
                        video: video,
                        onTap: () {
                          prov.markVideoViewed(video.id);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    VideoDetailScreen(video: video)),
                          );
                        },
                        onMoreTap: () =>
                            _showVideoOptions(context, prov, video),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddVideoScreen()),
        ),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Video',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showVideoOptions(
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
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(
                video.isDownloaded
                    ? Icons.download_done_rounded
                    : Icons.download_rounded,
                color: video.isDownloaded
                    ? AppColors.accentGreen
                    : AppColors.primary,
              ),
              title: Text(video.isDownloaded ? 'Remove Download' : 'Save Offline'),
              onTap: () {
                prov.toggleDownload(video.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(video.isDownloaded
                          ? 'Removed from downloads'
                          : 'Video saved offline')),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.share_rounded,
                color: video.isShared ? AppColors.accentOrange : AppColors.secondary,
              ),
              title: Text(video.isShared ? 'Share Status' : 'Share with Community'),
              onTap: () {
                Navigator.pop(ctx);
                if (!video.isShared) {
                  _showShareDialog(context, prov, video);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.folder_open_rounded,
                  color: AppColors.info),
              title: const Text('Add to Album'),
              onTap: () {
                Navigator.pop(ctx);
                _showAddToAlbumDialog(context, prov, video);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.accentRed),
              title: const Text('Delete Video',
                  style: TextStyle(color: AppColors.accentRed)),
              onTap: () {
                prov.deleteVideo(video.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video deleted')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showShareDialog(
      BuildContext context, AppProvider prov, VideoModel video) {
    final msgCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Share with Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
                'Share this video with other students. An admin will review before it goes live.'),
            const SizedBox(height: 12),
            TextField(
              controller: msgCtrl,
              decoration: const InputDecoration(
                labelText: 'Message to admin',
                hintText: 'Why is this useful for students?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              prov.submitShareRequest(video, msgCtrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share request submitted for review!')),
              );
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }

  void _showAddToAlbumDialog(
      BuildContext context, AppProvider prov, VideoModel video) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add to Album'),
        content: prov.albums.isEmpty
            ? const Text('No albums yet. Create an album first.')
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: prov.albums
                    .map(
                      (album) => CheckboxListTile(
                        title: Text(album.title),
                        subtitle: Text('${album.videoCount} videos'),
                        value: album.videoIds.contains(video.id),
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          if (val == true) {
                            prov.addVideoToAlbum(album.id, video.id);
                          } else {
                            prov.removeVideoFromAlbum(album.id, video.id);
                          }
                          Navigator.pop(ctx);
                        },
                      ),
                    )
                    .toList(),
              ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }
}
