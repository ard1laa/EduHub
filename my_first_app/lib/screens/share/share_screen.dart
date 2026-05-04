import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_provider.dart';
import '../../models/video_model.dart';
import '../../models/share_download_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../videos/video_detail_screen.dart';

class ShareScreen extends StatelessWidget {
  const ShareScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final pendingCount =
        prov.myShareRequests.where((r) => r.isPending).length;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Community'),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            tabs: [
              const Tab(
                icon: Icon(Icons.public_rounded, size: 18),
                text: 'Shared Videos',
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('My Requests'),
                    if (pendingCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$pendingCount',
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _CommunityFeed(videos: prov.publicVideos),
            _MyRequestsList(requests: prov.myShareRequests),
          ],
        ),
      ),
    );
  }
}

// ── Community Feed – admin-approved public videos ─────────────────────────────
class _CommunityFeed extends StatelessWidget {
  final List<VideoModel> videos;
  const _CommunityFeed({required this.videos});

  @override
  Widget build(BuildContext context) {
    if (videos.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline_rounded,
        title: 'Nothing Shared Yet',
        subtitle:
            'Videos approved by admins will appear here for everyone to watch.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: videos.length,
      itemBuilder: (ctx, i) => _CommunityVideoCard(video: videos[i]),
    );
  }
}

class _CommunityVideoCard extends StatelessWidget {
  final VideoModel video;
  const _CommunityVideoCard({required this.video});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => VideoDetailScreen(video: video)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail with overlays
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusLG),
                topRight: Radius.circular(AppDimensions.radiusLG),
              ),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: video.thumbnailUrl,
                    width: double.infinity,
                    height: 170,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 170,
                      color: AppColors.surfaceVariant,
                      child: const Center(
                          child: CircularProgressIndicator(
                              color: AppColors.primary)),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 170,
                      color: AppColors.surfaceVariant,
                      child: const Icon(Icons.play_circle_outline,
                          size: 48, color: AppColors.primary),
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.15),
                      child: const Center(
                        child: Icon(Icons.play_circle_filled_rounded,
                            size: 52, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 12, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Approved',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(video.category.displayName,
                          style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),

            // Info section
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(video.title,
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 6),
                  if (video.description.isNotEmpty) ...[
                    Text(video.description,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: AppColors.primary.withOpacity(0.15),
                        child: Text(
                          video.ownerName.isNotEmpty
                              ? video.ownerName[0].toUpperCase()
                              : 'S',
                          style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Shared by ${video.ownerName}',
                          style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary),
                        ),
                      ),
                      if (video.tags.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Text(
                            '#${video.tags.first}',
                            style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── My Requests ──────────────────────────────────────────────────────────────
class _MyRequestsList extends StatelessWidget {
  final List<ShareRequestModel> requests;
  const _MyRequestsList({required this.requests});

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return const EmptyState(
        icon: Icons.share_outlined,
        title: 'No Share Requests Yet',
        subtitle:
            'Add a video and enable "Request Community Sharing" to submit it for admin approval.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: requests.length,
      itemBuilder: (ctx, i) => _RequestCard(request: requests[i]),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ShareRequestModel request;
  const _RequestCard({required this.request});

  Color get _c {
    switch (request.status) {
      case ShareStatus.pending:  return AppColors.accentOrange;
      case ShareStatus.approved: return AppColors.accentGreen;
      case ShareStatus.rejected: return AppColors.accentRed;
    }
  }

  String get _label {
    switch (request.status) {
      case ShareStatus.pending:  return 'Pending Review';
      case ShareStatus.approved: return 'Approved & Live';
      case ShareStatus.rejected: return 'Not Approved';
    }
  }

  IconData get _icon {
    switch (request.status) {
      case ShareStatus.pending:  return Icons.pending_rounded;
      case ShareStatus.approved: return Icons.verified_rounded;
      case ShareStatus.rejected: return Icons.cancel_rounded;
    }
  }

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: request.isPending ? c.withOpacity(0.45) : AppColors.border,
          width: request.isPending ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSM),
                  child: CachedNetworkImage(
                    imageUrl: request.videoThumbnail,
                    width: 80,
                    height: 55,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        width: 80,
                        height: 55,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.play_circle_outline,
                            color: AppColors.primary)),
                    errorWidget: (_, __, ___) => Container(
                        width: 80,
                        height: 55,
                        color: AppColors.surfaceVariant,
                        child: const Icon(Icons.play_circle_outline,
                            color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.videoTitle,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(color: AppColors.textPrimary),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(_icon, size: 14, color: c),
                          const SizedBox(width: 4),
                          StatusBadge(label: _label, color: c),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Admin note
            if (request.reviewerNote != null &&
                request.reviewerNote!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: c.withOpacity(0.08),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusSM),
                  border: Border.all(color: c.withOpacity(0.25)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined, size: 14, color: c),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Admin note',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: c,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(request.reviewerNote!,
                              style:
                                  TextStyle(fontSize: 12, color: c)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Timestamps
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_rounded,
                    size: 12, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(_ago(request.requestedAt),
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textHint)),
                if (request.reviewedAt != null) ...[
                  const Text(' · ',
                      style: TextStyle(color: AppColors.textHint)),
                  Icon(
                    request.isApproved
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    size: 12,
                    color: c,
                  ),
                  const SizedBox(width: 4),
                  Text(_ago(request.reviewedAt!),
                      style: TextStyle(fontSize: 11, color: c)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

