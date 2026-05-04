import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final items = prov.historyItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning History'),
      ),
      body: items.isEmpty
          ? const EmptyState(
              icon: Icons.history,
              title: 'No History Yet',
              subtitle:
                  'Your learning activities will appear here after you watch videos or start study sessions.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              itemCount: items.length,
              separatorBuilder: (ctx, i) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final item = items[i];
                return _HistoryTile(item: item);
              },
            ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final Map<String, dynamic> item;
  const _HistoryTile({required this.item});

  IconData get _icon {
    switch (item['icon']) {
      case 'play': return Icons.play_circle_rounded;
      case 'download': return Icons.download_done_rounded;
      case 'session': return Icons.timer_rounded;
      default: return Icons.history;
    }
  }

  Color get _color {
    switch (item['icon']) {
      case 'play': return AppColors.primary;
      case 'download': return AppColors.accentGreen;
      case 'session': return AppColors.accentOrange;
      default: return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _color;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] as String,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item['subtitle'] as String,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(item['time'] as DateTime),
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}
