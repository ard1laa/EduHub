import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../models/video_model.dart';
import '../utils/app_constants.dart';
import '../screens/notifications/notifications_page.dart';

// ─── App Bar Sliver ──────────────────────────────────────────────────────────
// The full top bar: EduHub logo, live session pill, notification bell,
// search field and category chips. Drop this into a CustomScrollView's slivers.

class AppNavBarSliver extends StatelessWidget {
  final bool hasActiveSession;
  final String sessionElapsed;

  // Search & filter
  final String searchQuery;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final VideoCategory? selectedCategory;
  final ValueChanged<VideoCategory?> onCategoryChanged;

  const AppNavBarSliver({
    super.key,
    required this.hasActiveSession,
    required this.sessionElapsed,
    required this.searchQuery,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      backgroundColor: AppColors.surface,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          // ── EduHub logo ──────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
            ),
            child: const Icon(Icons.school_rounded, size: 20, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Text(
            AppStrings.appName,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
      actions: [
        // ── Live session pill ────────────────────────────────────────────
        if (hasActiveSession)
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              border: Border.all(color: AppColors.accentGreen.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.accentGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  sessionElapsed,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(108),
        child: Container(
          color: AppColors.surface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Search bar ─────────────────────────────────────────────
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                    color: searchQuery.isNotEmpty
                        ? AppColors.primary
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(Icons.search_rounded,
                          color: AppColors.textHint, size: 20),
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        onChanged: onSearchChanged,
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          hintText: 'Search videos, tags…',
                          hintStyle: TextStyle(
                              color: AppColors.textHint, fontSize: 14),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: onClearSearch,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Icon(Icons.close_rounded,
                              color: AppColors.textHint, size: 18),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // ── Category chips ──────────────────────────────────────────
              SizedBox(
                height: 34,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _CategoryChip(
                      label: 'All',
                      isSelected: selectedCategory == null,
                      onTap: () => onCategoryChanged(null),
                    ),
                    ...VideoCategory.values.map(
                      (cat) => _CategoryChip(
                        label: cat.displayName,
                        isSelected: selectedCategory == cat,
                        onTap: () => onCategoryChanged(
                            selectedCategory == cat ? null : cat),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Notification Dropdown Overlay ───────────────────────────────────────────
// Place this inside a Stack. It renders the transparent barrier (tap-to-close)
// and the dropdown panel positioned below the app bar.

class NotificationDropdownOverlay extends StatelessWidget {
  final double topOffset;
  final List<AppNotification> notifications;
  final int unreadCount;
  final VoidCallback onMarkAllRead;
  final ValueChanged<String> onMarkRead;
  final VoidCallback onClose;

  const NotificationDropdownOverlay({
    super.key,
    required this.topOffset,
    required this.notifications,
    required this.unreadCount,
    required this.onMarkAllRead,
    required this.onMarkRead,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Stack(
        children: [
          // Barrier — tap outside to close
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onClose,
              child: const ColoredBox(color: Colors.transparent),
            ),
          ),
          // Panel
          Positioned(
            top: topOffset,
            right: 12,
            left: 12,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              child: Material(
                color: Colors.transparent,
                child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLG),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLG),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        color: AppColors.surfaceVariant,
                        child: Row(
                          children: [
                            const Icon(Icons.notifications_rounded,
                                size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Notifications',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            if (unreadCount > 0)
                              GestureDetector(
                                onTap: onMarkAllRead,
                                child: const Text(
                                  'Mark all read',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      // Rows
                      if (notifications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('No notifications yet.',
                              style:
                                  TextStyle(color: AppColors.textHint)),
                        )
                      else
                        ConstrainedBox(
                          constraints:
                              const BoxConstraints(maxHeight: 280),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: notifications
                                  .take(5)
                                  .map((n) => NavbarNotifRow(
                                        notif: n,
                                        onTap: () => onMarkRead(n.id),
                                      ))
                                  .toList(),
                            ),
                          ),
                        ),
                      const Divider(height: 1, color: AppColors.border),
                      // See All
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          onClose();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    const NotificationsPage()),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              'See All Notifications',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),        // Positioned (panel)
        ],
      ),
    );
  }
}

// ─── Notification Row ─────────────────────────────────────────────────────────
// A single row inside the dropdown panel.

class NavbarNotifRow extends StatelessWidget {
  final AppNotification notif;
  final VoidCallback onTap;

  const NavbarNotifRow({
    super.key,
    required this.notif,
    required this.onTap,
  });

  IconData _icon() {
    switch (notif.type) {
      case NotificationType.session:
        return Icons.timer_rounded;
      case NotificationType.video:
        return Icons.video_library_rounded;
      case NotificationType.share:
        return Icons.share_rounded;
      case NotificationType.download:
        return Icons.download_done_rounded;
      case NotificationType.system:
        return Icons.info_outline_rounded;
      case NotificationType.announcement:
        return Icons.campaign_rounded;
    }
  }

  Color _color() {
    switch (notif.type) {
      case NotificationType.session:
        return AppColors.accentGreen;
      case NotificationType.video:
        return AppColors.primary;
      case NotificationType.share:
        return AppColors.secondary;
      case NotificationType.download:
        return AppColors.info;
      case NotificationType.system:
        return AppColors.accentOrange;
      case NotificationType.announcement:
        return AppColors.accentBlue;
    }
  }

  String _timeLabel() {
    final diff = DateTime.now().difference(notif.time);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        color: notif.isRead
            ? Colors.transparent
            : AppColors.primary.withOpacity(0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12), shape: BoxShape.circle),
              child: Icon(_icon(), color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: notif.isRead
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _timeLabel(),
                        style: const TextStyle(
                            fontSize: 10, color: AppColors.textHint),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    notif.body,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notif.isRead)
              Container(
                width: 7,
                height: 7,
                margin: const EdgeInsets.only(top: 4, left: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight:
                isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
