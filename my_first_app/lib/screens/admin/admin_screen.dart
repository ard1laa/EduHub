import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/app_provider.dart';
import '../../models/news_model.dart';
import '../../models/user_model.dart';
import '../../models/share_download_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() => _tabIndex = _tabController.index);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppProvider>().loadAllUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final pendingCount = prov.pendingRequests.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            tabs: [
              const Tab(icon: Icon(Icons.newspaper_rounded, size: 18), text: 'News'),
              const Tab(icon: Icon(Icons.people_rounded, size: 18), text: 'Users'),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pending'),
                    if (pendingCount > 0) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('$pendingCount',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ],
                ),
              ),
              const Tab(icon: Icon(Icons.list_alt_rounded, size: 18), text: 'Requests'),
            ],
          ),
        ),
      ),
      floatingActionButton: _tabIndex == 0
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Post', style: TextStyle(fontWeight: FontWeight.w600)),
              onPressed: () => _showNewsDialog(context, prov, null),
            )
          : null,
      body: TabBarView(
        controller: _tabController,
        children: [
          _NewsTab(prov: prov, onEdit: (n) => _showNewsDialog(context, prov, n)),
          _UsersTab(prov: prov),
          _PendingList(prov: prov),
          _AllRequestsList(prov: prov),
        ],
      ),
    );
  }

  void _showNewsDialog(BuildContext context, AppProvider prov, NewsModel? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final contentCtrl = TextEditingController(text: existing?.content ?? '');
    NewsCategory category = existing?.category ?? NewsCategory.announcement;
    bool isPublished = existing?.isPublished ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            existing == null ? 'Create News Post' : 'Edit News Post',
            style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700),
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<NewsCategory>(
                    value: category,
                    dropdownColor: AppColors.cardBg,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    items: NewsCategory.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.displayName)))
                        .toList(),
                    onChanged: (v) => setDialogState(() => category = v ?? category),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Title *',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: contentCtrl,
                    style: const TextStyle(color: AppColors.textPrimary),
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Content *',
                      alignLabelWithHint: true,
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.primary,
                    title: const Text('Publish immediately',
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                    subtitle: Text(
                      isPublished ? 'Visible to all users' : 'Saved as draft',
                      style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                    value: isPublished,
                    onChanged: (v) => setDialogState(() => isPublished = v),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textHint)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleCtrl.text.trim();
                final content = contentCtrl.text.trim();
                if (title.isEmpty || content.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Title and content are required.')));
                  return;
                }
                final admin = prov.currentUser!;
                if (existing == null) {
                  prov.adminAddNews(NewsModel(
                    id: 'news_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    content: content,
                    authorId: admin.id,
                    authorName: admin.fullName,
                    category: category,
                    createdAt: DateTime.now(),
                    isPublished: isPublished,
                  ));
                } else {
                  prov.adminUpdateNews(existing.copyWith(
                    title: title,
                    content: content,
                    category: category,
                    isPublished: isPublished,
                    updatedAt: DateTime.now(),
                  ));
                }
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(existing == null ? 'News post created!' : 'News post updated!'),
                  backgroundColor: AppColors.accentGreen,
                ));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, foregroundColor: Colors.black),
              child: Text(existing == null ? 'Publish' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

// ══ Tab 1 – News Management ══════════════════════════════════════════════════
class _NewsTab extends StatelessWidget {
  final AppProvider prov;
  final void Function(NewsModel?) onEdit;
  const _NewsTab({required this.prov, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final items = prov.adminNewsFeed;
    if (items.isEmpty) {
      return const EmptyState(
        icon: Icons.newspaper_rounded,
        title: 'No News Posts Yet',
        subtitle: 'Tap the button below to create your first announcement.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _NewsCard(news: items[i], prov: prov, onEdit: onEdit),
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsModel news;
  final AppProvider prov;
  final void Function(NewsModel?) onEdit;
  const _NewsCard({required this.news, required this.prov, required this.onEdit});

  Color _catColor(NewsCategory c) {
    switch (c) {
      case NewsCategory.announcement: return AppColors.primary;
      case NewsCategory.update: return AppColors.accentBlue;
      case NewsCategory.event: return AppColors.accentGreen;
      case NewsCategory.maintenance: return AppColors.accentOrange;
    }
  }

  String _timeAgo(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 60) return '${d.inMinutes}m ago';
    if (d.inHours < 24) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _catColor(news.category);
    final isPublished = news.isPublished;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: isPublished
              ? AppColors.border
              : AppColors.accentOrange.withOpacity(0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: catColor.withOpacity(0.4)),
                  ),
                  child: Text(news.category.displayName,
                      style: TextStyle(color: catColor, fontSize: 11, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                if (!isPublished)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.accentOrange.withOpacity(0.4)),
                    ),
                    child: const Text('Draft',
                        style: TextStyle(
                            color: AppColors.accentOrange, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  color: AppColors.cardBg,
                  icon: const Icon(Icons.more_vert_rounded, size: 20, color: AppColors.textHint),
                  onSelected: (v) {
                    if (v == 'edit') onEdit(news);
                    if (v == 'toggle') prov.adminTogglePublish(news.id);
                    if (v == 'delete') _confirmDelete(context);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(
                        value: 'edit',
                        child: Row(children: [
                          Icon(Icons.edit_rounded, size: 16, color: AppColors.primary),
                          SizedBox(width: 8), Text('Edit')
                        ])),
                    PopupMenuItem(
                        value: 'toggle',
                        child: Row(children: [
                          Icon(
                              isPublished ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                              size: 16,
                              color: isPublished ? AppColors.textHint : AppColors.accentGreen),
                          const SizedBox(width: 8),
                          Text(isPublished ? 'Unpublish' : 'Publish')
                        ])),
                    const PopupMenuItem(
                        value: 'delete',
                        child: Row(children: [
                          Icon(Icons.delete_rounded, size: 16, color: AppColors.accentRed),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: AppColors.accentRed))
                        ])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(news.title,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 6),
            Text(news.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(news.authorName,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
                const Spacer(),
                const Icon(Icons.access_time_rounded, size: 13, color: AppColors.textHint),
                const SizedBox(width: 4),
                Text(_timeAgo(news.updatedAt ?? news.createdAt),
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete News', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('Delete "${news.title}"? This cannot be undone.',
            style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { prov.adminDeleteNews(news.id); Navigator.pop(ctx); },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentRed, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ══ Tab 2 – User Monitor ═════════════════════════════════════════════════════
class _UsersTab extends StatelessWidget {
  final AppProvider prov;
  const _UsersTab({required this.prov});

  @override
  Widget build(BuildContext context) {
    final users = prov.allUsers;
    if (users.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    final adminCount = users.where((u) => u.isAdmin).length;
    final studentCount = users.where((u) => !u.isAdmin).length;
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(AppDimensions.paddingMD),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatChip(label: 'Total', value: '${users.length}',
                  color: AppColors.primary, icon: Icons.people_rounded),
              _StatChip(label: 'Admins', value: '$adminCount',
                  color: AppColors.accentOrange, icon: Icons.shield_rounded),
              _StatChip(label: 'Students', value: '$studentCount',
                  color: AppColors.accentGreen, icon: Icons.school_rounded),
            ],
          ),
        ),
        // ── Broadcast button ──────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.campaign_rounded, size: 18),
              label: const Text('Broadcast Notification to All Students'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
              ),
              onPressed: () => _showBroadcastDialog(context, prov),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingMD),
            itemCount: users.length,
            itemBuilder: (ctx, i) => _UserTile(user: users[i], prov: prov),
          ),
        ),
      ],
    );
  }

  void _showBroadcastDialog(BuildContext context, AppProvider prov) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.campaign_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text('Broadcast to All Students',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Notification Title *',
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message *',
                alignLabelWithHint: true,
                labelStyle: const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Broadcast'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final title = titleCtrl.text.trim();
              final body = bodyCtrl.text.trim();
              if (title.isEmpty || body.isEmpty) return;
              prov.adminBroadcastNotification(title, body);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notification broadcast to all students!'),
                  backgroundColor: AppColors.accentGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label, value;
  final Color color;
  final IconData icon;
  const _StatChip({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20)),
        Text(label, style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
      ],
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel user;
  final AppProvider prov;
  const _UserTile({required this.user, required this.prov});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user.isAdmin;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
            color: isAdmin ? AppColors.primary.withOpacity(0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isAdmin
                ? AppColors.primary.withOpacity(0.2)
                : AppColors.accentBlue.withOpacity(0.2),
            child: Text(user.initials,
                style: TextStyle(
                    color: isAdmin ? AppColors.primary : AppColors.accentBlue,
                    fontWeight: FontWeight.w800, fontSize: 14)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(user.fullName,
                          style: const TextStyle(
                              color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 14),
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAdmin
                            ? AppColors.primary.withOpacity(0.15)
                            : AppColors.accentGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(isAdmin ? 'Admin' : 'Student',
                          style: TextStyle(
                              color: isAdmin ? AppColors.primary : AppColors.accentGreen,
                              fontSize: 10, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(user.email,
                    style: const TextStyle(color: AppColors.textHint, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _MiniStat(icon: Icons.video_library_outlined,
                        value: '${user.videosCount}', label: 'videos'),
                    const SizedBox(width: 12),
                    _MiniStat(icon: Icons.timer_outlined,
                        value: '${(user.totalSessionMinutes / 60).toStringAsFixed(1)}h', label: 'study'),
                    const SizedBox(width: 12),
                    _MiniStat(icon: Icons.download_outlined,
                        value: '${user.downloadCount}', label: 'dl'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Joined', style: TextStyle(color: AppColors.textHint, fontSize: 10)),
              Text(
                '${user.joinedAt.day}/${user.joinedAt.month}/${user.joinedAt.year}',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (!isAdmin)
                GestureDetector(
                  onTap: () => _showSendNotifDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notifications_active_rounded,
                            size: 12, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text('Notify',
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showSendNotifDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.notifications_active_rounded,
                color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'Notify ${user.fullName}',
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Notification Title *',
                labelStyle:
                    const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bodyCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Message *',
                alignLabelWithHint: true,
                labelStyle:
                    const TextStyle(color: AppColors.textSecondary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textHint)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.send_rounded, size: 16),
            label: const Text('Send'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              final title = titleCtrl.text.trim();
              final body = bodyCtrl.text.trim();
              if (title.isEmpty || body.isEmpty) return;
              prov.adminSendNotificationToUser(user.fullName, title, body);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Notification sent to ${user.fullName}!'),
                  backgroundColor: AppColors.accentGreen,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value, label;
  const _MiniStat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 12, color: AppColors.textHint),
      const SizedBox(width: 3),
      Text('$value $label', style: const TextStyle(color: AppColors.textHint, fontSize: 11)),
    ],
  );
}

// ══ Tab 3 – Pending Requests ═════════════════════════════════════════════════
class _PendingList extends StatelessWidget {
  final AppProvider prov;
  const _PendingList({required this.prov});

  @override
  Widget build(BuildContext context) {
    final pending = prov.pendingRequests;
    if (pending.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline_rounded,
        title: 'No Pending Requests',
        subtitle: 'All share requests have been reviewed.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: pending.length,
      itemBuilder: (ctx, i) => _AdminRequestCard(request: pending[i], prov: prov),
    );
  }
}

// ══ Tab 4 – All Requests ═════════════════════════════════════════════════════
class _AllRequestsList extends StatelessWidget {
  final AppProvider prov;
  const _AllRequestsList({required this.prov});

  @override
  Widget build(BuildContext context) {
    final all = prov.allShareRequests;
    if (all.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        title: 'No Requests Yet',
        subtitle: 'Share requests from students will appear here.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: all.length,
      itemBuilder: (ctx, i) =>
          _AdminRequestCard(request: all[i], prov: prov, showActions: false),
    );
  }
}

// ══ Share Request Card (shared by Pending + All Requests tabs) ═══════════════
class _AdminRequestCard extends StatelessWidget {
  final ShareRequestModel request;
  final AppProvider prov;
  final bool showActions;
  const _AdminRequestCard({required this.request, required this.prov, this.showActions = true});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;
    switch (request.status) {
      case ShareStatus.pending:
        statusColor = AppColors.accentOrange;
        statusLabel = 'Pending';
        statusIcon = Icons.pending_rounded;
        break;
      case ShareStatus.approved:
        statusColor = AppColors.accentGreen;
        statusLabel = 'Approved';
        statusIcon = Icons.check_circle_rounded;
        break;
      case ShareStatus.rejected:
        statusColor = AppColors.accentRed;
        statusLabel = 'Rejected';
        statusIcon = Icons.cancel_rounded;
        break;
    }
    final isPending = request.status == ShareStatus.pending;

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(
          color: isPending && showActions
              ? AppColors.accentOrange.withOpacity(0.3)
              : AppColors.border,
          width: isPending && showActions ? 1.5 : 1,
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
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                  child: CachedNetworkImage(
                    imageUrl: request.videoThumbnail,
                    width: 80, height: 55, fit: BoxFit.cover,
                    placeholder: (ctx, url) => Container(
                        width: 80, height: 55, color: AppColors.surfaceVariant,
                        child: const Icon(Icons.play_circle_outline, color: AppColors.primary)),
                    errorWidget: (ctx, url, err) => Container(
                        width: 80, height: 55, color: AppColors.surfaceVariant,
                        child: const Icon(Icons.play_circle_outline, color: AppColors.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.videoTitle,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.textPrimary),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.primary.withOpacity(0.15),
                          child: Text(
                            request.requesterName.isNotEmpty
                                ? request.requesterName[0].toUpperCase() : 'S',
                            style: const TextStyle(
                                fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(request.requesterName, style: Theme.of(context).textTheme.bodySmall),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(children: [
                  Icon(statusIcon, size: 13, color: statusColor),
                  const SizedBox(width: 4),
                  StatusBadge(label: statusLabel, color: statusColor),
                ]),
              ],
            ),
            if (request.message.isNotEmpty) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSM)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.format_quote_rounded, size: 16, color: AppColors.textHint),
                    const SizedBox(width: 6),
                    Expanded(child: Text(request.message, style: Theme.of(context).textTheme.bodySmall)),
                  ],
                ),
              ),
            ],
            if (request.reviewerNote != null && request.reviewerNote!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.shield_outlined, size: 14, color: AppColors.textHint),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('Admin note: ${request.reviewerNote}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: statusColor, fontStyle: FontStyle.italic)),
                ),
              ]),
            ],
            if (showActions && isPending) ...[
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.cancel_outlined, color: AppColors.accentRed, size: 16),
                    label: const Text('Reject', style: TextStyle(color: AppColors.accentRed)),
                    style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.accentRed),
                        padding: const EdgeInsets.symmetric(vertical: 10)),
                    onPressed: () => _showReviewDialog(context, false),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10)),
                    onPressed: () => _showReviewDialog(context, true),
                  ),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  void _showReviewDialog(BuildContext context, bool isApproval) {
    final noteCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(isApproval ? 'Approve Request' : 'Reject Request',
            style: const TextStyle(color: AppColors.textPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isApproval
                  ? 'Add an optional note for the student:'
                  : 'Please provide a reason for rejection:',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: isApproval ? 'Great resource!' : 'Reason...'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (isApproval) {
                prov.approveShareRequest(request.id, noteCtrl.text.trim());
              } else {
                prov.rejectShareRequest(request.id, noteCtrl.text.trim());
              }
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(isApproval
                    ? 'Request approved and shared to community!'
                    : 'Request rejected.'),
                backgroundColor: isApproval ? AppColors.accentGreen : AppColors.accentRed,
              ));
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: isApproval ? AppColors.accentGreen : AppColors.accentRed,
                foregroundColor: Colors.white),
            child: Text(isApproval ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}
