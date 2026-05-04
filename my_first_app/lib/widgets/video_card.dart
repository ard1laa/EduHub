import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/video_model.dart';
import '../utils/app_constants.dart';
import 'common_widgets.dart';
import 'package:timeago/timeago.dart' as timeago;

class VideoCard extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool showAlbumBadge;

  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.onMoreTap,
    this.showAlbumBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
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
                    height: 180,
                    fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(
                      height: 180,
                      color: AppColors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (ctx, url, err) => Container(
                      height: 180,
                      color: AppColors.surfaceVariant,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.play_circle_outline,
                              size: 48, color: AppColors.primary),
                          const SizedBox(height: 8),
                          Text(video.title,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ),
                  // Duration badge
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSM),
                      ),
                      child: Text(
                        video.durationLabel,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  // Download badge
                  if (video.isDownloaded)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.9),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSM),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.download_done,
                                color: Colors.white, size: 12),
                            SizedBox(width: 3),
                            Text('Saved',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                )),
                          ],
                        ),
                      ),
                    ),
                  // Shared badge
                  if (video.isShared)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: StatusBadge(
                        label: video.shareApproved ? 'Shared' : 'Pending',
                        color: video.shareApproved
                            ? AppColors.accentGreen
                            : AppColors.accentOrange,
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (onMoreTap != null)
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onMoreTap,
                            borderRadius: BorderRadius.circular(20),
                            child: const Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(Icons.more_vert,
                                  size: 18, color: AppColors.textSecondary),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusRound),
                        ),
                        child: Text(
                          video.category.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.remove_red_eye_outlined,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 3),
                      Text(
                        '${video.viewCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        video.lastViewedAt != null
                            ? timeago.format(video.lastViewedAt!)
                            : timeago.format(video.savedAt),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  if (video.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: video.tags
                          .take(3)
                          .map(
                            (tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusRound),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoListTile extends StatelessWidget {
  final VideoModel video;
  final VoidCallback? onTap;
  final Widget? trailing;

  const VideoListTile({
    super.key,
    required this.video,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingSM),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.paddingSM),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(AppDimensions.radiusSM),
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  width: 80,
                  height: 55,
                  fit: BoxFit.cover,
                  placeholder: (ctx, url) => Container(
                    width: 80,
                    height: 55,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.play_circle_outline,
                        color: AppColors.primary),
                  ),
                  errorWidget: (ctx, url, err) => Container(
                    width: 80,
                    height: 55,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.play_circle_outline,
                        color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.paddingSM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: Theme.of(context).textTheme.labelLarge,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          video.category.displayName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          video.durationLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
        ),
      ),
    );
  }
}
