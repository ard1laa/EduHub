import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import 'notification_detail_screen.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final all = prov.notifications;

    final now = DateTime.now();
    final today = all.where((n) {
      final diff = now.difference(n.time);
      return diff.inHours < 24 && now.day == n.time.day;
    }).toList();
    final yesterday = all.where((n) {
      final diff = now.difference(n.time);
      return diff.inDays == 1;
    }).toList();
    final older = all.where((n) {
      final diff = now.difference(n.time);
      return diff.inDays > 1;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (prov.unreadCount > 0)
            TextButton(
              onPressed: prov.markAllNotificationsRead,
              child: const Text(
                'Mark all read',
                style: TextStyle(color: AppColors.primary, fontSize: 13),
              ),
            ),
        ],
      ),
      body: all.isEmpty
          ? const EmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No Notifications',
              subtitle: 'You\'re all caught up!',
            )
          : ListView(
              padding: const EdgeInsets.symmetric(
                  vertical: AppDimensions.paddingSM),
              children: [
                if (today.isNotEmpty) ...[
                  _GroupHeader(label: 'Today'),
                  ...today.map((n) => _NotifTile(notif: n)),
                ],
                if (yesterday.isNotEmpty) ...[
                  _GroupHeader(label: 'Yesterday'),
                  ...yesterday.map((n) => _NotifTile(notif: n)),
                ],
                if (older.isNotEmpty) ...[
                  _GroupHeader(label: 'Older'),
                  ...older.map((n) => _NotifTile(notif: n)),
                ],
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

// ─── Group Header ──────────────────────────────────────────────────────────
class _GroupHeader extends StatelessWidget {
  final String label;
  const _GroupHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.textHint,
              letterSpacing: 0.8,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ─── Notification Tile ─────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final AppNotification notif;
  const _NotifTile({required this.notif});

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
    if (diff.inDays == 1) return 'Yesterday';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => NotificationDetailScreen(notif: notif),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        color: notif.isRead
            ? Colors.transparent
            : AppColors.primary.withOpacity(0.04),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon bubble
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon(), color: color, size: 20),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: Theme.of(context)
                              .textTheme
                              .titleSmall
                              ?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: notif.isRead
                                    ? FontWeight.w500
                                    : FontWeight.w700,
                              ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _timeLabel(),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notif.body,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: notif.isRead
                              ? AppColors.textHint
                              : AppColors.textSecondary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!notif.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 5),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
