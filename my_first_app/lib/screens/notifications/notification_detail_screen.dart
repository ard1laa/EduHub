import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notification_model.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_constants.dart';

class NotificationDetailScreen extends StatefulWidget {
  final AppNotification notif;
  const NotificationDetailScreen({super.key, required this.notif});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final _replyCtrl = TextEditingController();
  bool _replySent = false;

  @override
  void dispose() {
    _replyCtrl.dispose();
    super.dispose();
  }

  IconData _icon() {
    switch (widget.notif.type) {
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
    switch (widget.notif.type) {
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

  String _typeLabel() {
    switch (widget.notif.type) {
      case NotificationType.session:
        return 'Session';
      case NotificationType.video:
        return 'Video';
      case NotificationType.share:
        return 'Share';
      case NotificationType.download:
        return 'Download';
      case NotificationType.system:
        return 'System';
      case NotificationType.announcement:
        return 'Announcement';
    }
  }

  String _fullTimeLabel() {
    final t = widget.notif.time;
    final now = DateTime.now();
    final diff = now.difference(t);
    final timeStr =
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago · $timeStr';
    if (diff.inHours < 24) return '${diff.inHours} hours ago · $timeStr';
    if (diff.inDays == 1)
      return 'Yesterday · $timeStr';
    return '${t.day}/${t.month}/${t.year} · $timeStr';
  }

  void _showReplySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.reply_rounded,
                      color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Reply to Notification',
                    style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _replyCtrl,
                autofocus: true,
                maxLines: 4,
                minLines: 2,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Write your reply…',
                  hintStyle: const TextStyle(color: AppColors.textHint),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_replyCtrl.text.trim().isEmpty) return;
                    Navigator.pop(ctx);
                    setState(() => _replySent = true);
                  },
                  icon: const Icon(Icons.send_rounded, size: 18),
                  label: const Text('Send Reply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMD),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _color();
    final notif = widget.notif;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notification Detail',
          style: TextStyle(
              color: AppColors.textPrimary, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon + type chip ─────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_icon(), color: color, size: 28),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _typeLabel(),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _fullTimeLabel(),
                      style: const TextStyle(
                          color: AppColors.textHint, fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                if (!notif.isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            // ── Title ────────────────────────────────────────────────────
            Text(
              notif.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
            ),
            const SizedBox(height: 16),
            // ── Divider ──────────────────────────────────────────────────
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),
            // ── Body ─────────────────────────────────────────────────────
            Text(
              notif.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontSize: 15,
                  ),
            ),
            const SizedBox(height: 32),
            // ── Reply sent confirmation ──────────────────────────────────
            if (_replySent)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen.withOpacity(0.1),
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(
                      color: AppColors.accentGreen.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.accentGreen, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Reply sent successfully!',
                      style: TextStyle(
                        color: AppColors.accentGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            // ── Action buttons ───────────────────────────────────────────
            Row(
              children: [
                // Reply button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showReplySheet(context),
                    icon: const Icon(Icons.reply_rounded, size: 18),
                    label: const Text('Reply'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMD),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Mark as read button
                Expanded(
                  child: Consumer<AppProvider>(
                    builder: (ctx, prov, _) {
                      final isRead = prov.notifications
                          .firstWhere((n) => n.id == notif.id,
                              orElse: () => notif)
                          .isRead;
                      return ElevatedButton.icon(
                        onPressed: isRead
                            ? null
                            : () => prov.markNotificationRead(notif.id),
                        icon: Icon(
                          isRead
                              ? Icons.check_circle_rounded
                              : Icons.mark_email_read_rounded,
                          size: 18,
                        ),
                        label: Text(isRead ? 'Read' : 'Mark as Read'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.textOnPrimary,
                          disabledBackgroundColor:
                              AppColors.primary.withOpacity(0.3),
                          disabledForegroundColor:
                              AppColors.textOnPrimary.withOpacity(0.6),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusMD),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
