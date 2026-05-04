import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/session_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class SessionsScreen extends StatefulWidget {
  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _elapsed(DateTime startTime) {
    final d = DateTime.now().difference(startTime);
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final sessions = prov.sessions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Sessions'),
        actions: [
          if (prov.hasActiveSession)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: () => _showEndSessionDialog(context, prov),
                icon: const Icon(Icons.stop_circle_outlined,
                    color: AppColors.accentRed, size: 18),
                label: const Text('End Session',
                    style: TextStyle(color: AppColors.accentRed)),
              ),
            )
          else
            TextButton.icon(
              onPressed: () {
                prov.startSession();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Study session started!')),
                );
              },
              icon: const Icon(Icons.play_circle_outline, size: 18),
              label: const Text('Start'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Active session banner
          if (prov.hasActiveSession)
            Container(
              margin: const EdgeInsets.all(AppDimensions.paddingMD),
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Session in Progress',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Live HH:MM:SS counter
                        Text(
                          _elapsed(prov.activeSession!.startTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 26,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Started at ${_formatTime(prov.activeSession!.startTime)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showEndSessionDialog(context, prov),
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('End'),
                  ),
                ],
              ),
            ),

          // Stats header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Total Sessions',
                  value: '${sessions.length}',
                  icon: Icons.timer_rounded,
                  color: AppColors.primary,
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                _StatItem(
                  label: 'Total Hours',
                  value: prov.totalStudyHours.toStringAsFixed(1),
                  icon: Icons.access_time_rounded,
                  color: AppColors.secondary,
                ),
                Container(width: 1, height: 40, color: AppColors.border),
                _StatItem(
                  label: 'This Week',
                  value: _weekSessions(sessions),
                  icon: Icons.calendar_today_rounded,
                  color: AppColors.accentGreen,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('All Sessions',
                    style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: sessions.isEmpty
                ? const EmptyState(
                    icon: Icons.timer_outlined,
                    title: 'No Sessions Yet',
                    subtitle:
                        'Start a study session to track your learning time.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sessions.length,
                    itemBuilder: (ctx, i) =>
                        _SessionCard(session: sessions[i]),
                  ),
          ),
        ],
      ),
    );
  }

  String _weekSessions(List<SessionModel> sessions) {
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    return sessions.where((s) => s.startTime.isAfter(cutoff)).length.toString();
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  void _showEndSessionDialog(BuildContext context, AppProvider prov) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Study Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Add session notes (optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                hintText: 'What did you learn today?',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              prov.endSession(notes: notesCtrl.text.trim());
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session saved!')),
              );
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            )),
        Text(label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            )),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionModel session;
  const _SessionCard({required this.session});

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left accent
            Container(
              width: 4,
              height: 70,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(session.startTime),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusRound),
                        ),
                        child: Text(
                          session.durationLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatTime(session.startTime)} – ${session.endTime != null ? _formatTime(session.endTime!) : "ongoing"}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.video_library_outlined,
                          size: 13, color: AppColors.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${session.videoIdsWatched.length} video${session.videoIdsWatched.length != 1 ? 's' : ''} watched',
                        style: Theme.of(context).textTheme.labelSmall,
                      ),
                    ],
                  ),
                  if (session.notes != null && session.notes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Notes: ${session.notes}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
