import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/album_model.dart';
import '../utils/app_constants.dart';

Color _hexToColor(String hex) {
  try {
    return Color(int.parse(hex.replaceFirst('#', '0xFF')));
  } catch (_) {
    return AppColors.primary;
  }
}

class AlbumCard extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;

  const AlbumCard({
    super.key,
    required this.album,
    this.onTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _hexToColor(album.colorHex);
    return Container(
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
            // Cover image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusLG),
                topRight: Radius.circular(AppDimensions.radiusLG),
              ),
              child: Stack(
                children: [
                  if (album.coverThumbnail.isNotEmpty)
                    CachedNetworkImage(
                      imageUrl: album.coverThumbnail,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (ctx, url) => _buildColorCover(color),
                      errorWidget: (ctx, url, err) => _buildColorCover(color),
                    )
                  else
                    _buildColorCover(color),
                  // Gradient overlay
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Video count
                  Positioned(
                    bottom: 8,
                    left: 10,
                    child: Row(
                      children: [
                        const Icon(Icons.play_circle_outline,
                            color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${album.videoCount} videos',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // More button
                  if (onMoreTap != null)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Material(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          onTap: onMoreTap,
                          borderRadius: BorderRadius.circular(20),
                          child: const Padding(
                            padding: EdgeInsets.all(4),
                            child: Icon(Icons.more_vert,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Info
            Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingSM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    album.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    album.description,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCover(Color color) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Icon(Icons.folder_open, size: 40, color: Colors.white),
    );
  }
}
