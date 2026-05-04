import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/app_provider.dart';
import '../../models/video_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/video_card.dart';
import '../videos/video_detail_screen.dart';
import '../videos/add_video_screen.dart';
import '../history/history_screen.dart';
import '../sessions/sessions_screen.dart';
import '../share/share_screen.dart';
import '../admin/admin_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  VideoCategory? _selectedCategory;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<VideoModel> _filteredVideos(List<VideoModel> videos) {
    return videos.where((v) {
      final matchesSearch = _searchQuery.isEmpty ||
          v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      final matchesCategory =
          _selectedCategory == null || v.category == _selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final user = prov.currentUser;
    final weeklyData = prov.weeklyMinutes;
    final maxVal =
        weeklyData.isEmpty ? 60.0 : (weeklyData.reduce((a, b) => a > b ? a : b) + 20);

    final bool isFiltering = _searchQuery.isNotEmpty || _selectedCategory != null;
    final filteredVideos = _filteredVideos(prov.videos);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSM),
                  ),
                  child: const Icon(Icons.school_rounded,
                      size: 20, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Text(AppStrings.appName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        )),
              ],
            ),
            actions: [
              // Session indicator
              if (prov.hasActiveSession)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.1),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusRound),
                    border: Border.all(
                        color: AppColors.accentGreen.withOpacity(0.4)),
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
                      const SizedBox(width: 5),
                      const Text('Live',
                          style: TextStyle(
                              fontSize: 12,
                              color: AppColors.accentGreen,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              const SizedBox(width: 4),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(108),
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Search bar
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                        border: Border.all(
                          color: _searchQuery.isNotEmpty
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
                              controller: _searchCtrl,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.textPrimary,
                              ),
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
                          if (_searchQuery.isNotEmpty)
                            GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _searchQuery = '');
                              },
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
                    // Category filter chips
                    SizedBox(
                      height: 34,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _CategoryChip(
                            label: 'All',
                            isSelected: _selectedCategory == null,
                            onTap: () =>
                                setState(() => _selectedCategory = null),
                          ),
                          ...VideoCategory.values.map((cat) => _CategoryChip(
                                label: cat.displayName,
                                isSelected: _selectedCategory == cat,
                                onTap: () => setState(() =>
                                    _selectedCategory =
                                        _selectedCategory == cat ? null : cat),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppDimensions.paddingLG),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusXL),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Welcome back,',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  Text(
                                    user?.fullName.split(' ').first ?? 'Student',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (user?.isAdmin ?? false)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusRound),
                                      ),
                                      child: const Text('Admin',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 32,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              child: Text(
                                user?.initials ?? 'U',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMD),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.timer_outlined,
                                  color: Colors.white, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Total study: ${prov.totalStudyHours.toStringAsFixed(1)}h',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingLG),

                  // Stat cards
                  SectionHeader(
                    title: 'Overview',
                    actionLabel: 'History',
                    onAction: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen())),
                  ),
                  const SizedBox(height: AppDimensions.paddingSM),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.55,
                    children: [
                      StatCard(
                        title: 'Videos Saved',
                        value: '${prov.totalVideos}',
                        icon: Icons.video_library_rounded,
                        gradient: AppColors.primaryGradient,
                        subtitle: 'In your library',
                      ),
                      StatCard(
                        title: 'Albums Created',
                        value: '${prov.totalAlbums}',
                        icon: Icons.folder_rounded,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7209B7), Color(0xFFB5179E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        subtitle: 'Organized playlists',
                      ),
                      StatCard(
                        title: 'Downloads',
                        value: '${prov.totalDownloads}',
                        icon: Icons.download_done_rounded,
                        gradient: AppColors.greenGradient,
                        subtitle: 'Resources saved',
                      ),
                      StatCard(
                        title: 'Study Sessions',
                        value: '${prov.sessions.length}',
                        icon: Icons.timer_rounded,
                        gradient: AppColors.orangeGradient,
                        subtitle: '${prov.totalStudyHours.toStringAsFixed(1)}h total',
                      ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingLG),

                  // Weekly activity chart
                  SectionHeader(title: 'Weekly Activity'),
                  const SizedBox(height: AppDimensions.paddingSM),

                  Container(
                    padding: const EdgeInsets.all(AppDimensions.paddingMD),
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusLG),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: BarChart(
                      BarChartData(
                        maxY: maxVal,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (v) => FlLine(
                            color: AppColors.border,
                            strokeWidth: 1,
                            dashArray: [4, 4],
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                const days = [
                                  'M', 'T', 'W', 'T', 'F', 'S', 'S'
                                ];
                                return Text(
                                  days[val.toInt()],
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textHint,
                                    fontWeight: FontWeight.w500,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        barGroups: List.generate(
                          7,
                          (i) => BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: weeklyData[i],
                                gradient: AppColors.primaryGradient,
                                width: 20,
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6),
                                  topRight: Radius.circular(6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.paddingLG),

                  // Quick actions
                  SectionHeader(title: 'Quick Actions'),
                  const SizedBox(height: AppDimensions.paddingSM),

                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.1,
                    children: [
                      _QuickAction(
                        icon: Icons.add_circle_rounded,
                        label: 'Add Video',
                        color: AppColors.primary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const AddVideoScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.timer_rounded,
                        label: prov.hasActiveSession
                            ? 'End Session'
                            : 'Start Session',
                        color: prov.hasActiveSession
                            ? AppColors.accentRed
                            : AppColors.accentGreen,
                        onTap: () {
                          if (prov.hasActiveSession) {
                            _showEndSessionDialog(context, prov);
                          } else {
                            prov.startSession();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Study session started!')),
                            );
                          }
                        },
                      ),
                      _QuickAction(
                        icon: Icons.share_rounded,
                        label: 'Community',
                        color: AppColors.secondary,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ShareScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.history_rounded,
                        label: 'History',
                        color: AppColors.accentOrange,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HistoryScreen()),
                        ),
                      ),
                      _QuickAction(
                        icon: Icons.timeline_rounded,
                        label: 'Sessions',
                        color: AppColors.info,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SessionsScreen()),
                        ),
                      ),
                      if (prov.isAdmin)
                        _QuickAction(
                          icon: Icons.admin_panel_settings_rounded,
                          label: 'Admin',
                          color: AppColors.accentRed,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AdminScreen()),
                          ),
                        )
                      else
                        _QuickAction(
                          icon: Icons.pending_actions_rounded,
                          label: 'Pending',
                          color: AppColors.warning,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ShareScreen()),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: AppDimensions.paddingLG),

                  // Recent / filtered videos
                  if (isFiltering) ...[
                    SectionHeader(
                      title: filteredVideos.isEmpty
                          ? 'No Results'
                          : '${filteredVideos.length} Result${filteredVideos.length == 1 ? '' : 's'}',
                    ),
                    const SizedBox(height: AppDimensions.paddingSM),
                    if (filteredVideos.isEmpty)
                      const EmptyState(
                        icon: Icons.search_off_rounded,
                        title: 'No videos found',
                        subtitle: 'Try a different search term or category.',
                      )
                    else
                      ...filteredVideos.map(
                        (v) => VideoCard(
                          video: v,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => VideoDetailScreen(video: v)),
                          ),
                        ),
                      ),
                  ] else if (prov.recentVideos.isNotEmpty) ...[
                    SectionHeader(
                      title: 'Recently Saved',
                      actionLabel: 'See All',
                      onAction: () {},
                    ),
                    const SizedBox(height: AppDimensions.paddingSM),
                    ...prov.recentVideos.take(3).map(
                          (v) => VideoCard(
                            video: v,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => VideoDetailScreen(video: v)),
                            ),
                          ),
                        ),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context, AppProvider prov) {
    final notesCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('End Session'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Add notes for this session (optional):'),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                hintText: 'e.g., Focused on Flutter basics...',
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
                const SnackBar(content: Text('Session ended and saved!')),
              );
            },
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
}


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
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? AppColors.textOnPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
