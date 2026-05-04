import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/share_download_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final items = prov.downloadItems;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Downloads'),
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            tabs: [
              Tab(text: 'All Resources'),
              Tab(text: 'Downloaded'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ResourceList(
                items: items,
                prov: prov,
                emptyMsg: 'No resources available.'),
            _ResourceList(
                items: prov.downloadedItems,
                prov: prov,
                emptyMsg: 'No downloaded resources yet.'),
          ],
        ),
      ),
    );
  }
}

class _ResourceList extends StatelessWidget {
  final List<DownloadItem> items;
  final AppProvider prov;
  final String emptyMsg;

  const _ResourceList({
    required this.items,
    required this.prov,
    required this.emptyMsg,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return EmptyState(
        icon: Icons.download_outlined,
        title: 'No Resources',
        subtitle: emptyMsg,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppDimensions.paddingMD),
      itemCount: items.length,
      itemBuilder: (ctx, i) => _DownloadCard(item: items[i], prov: prov),
    );
  }
}

class _DownloadCard extends StatefulWidget {
  final DownloadItem item;
  final AppProvider prov;

  const _DownloadCard({required this.item, required this.prov});

  @override
  State<_DownloadCard> createState() => _DownloadCardState();
}

class _DownloadCardState extends State<_DownloadCard> {
  bool _downloading = false;

  Color _fileColor(String type) {
    switch (type.toUpperCase()) {
      case 'PDF': return AppColors.accentRed;
      case 'DOCX': return AppColors.primary;
      case 'XLSX': return AppColors.accentGreen;
      case 'PPTX': return AppColors.accentOrange;
      default: return AppColors.textSecondary;
    }
  }

  Future<void> _toggleDownload() async {
    if (!widget.item.isDownloaded) {
      setState(() => _downloading = true);
      // Simulate download
      await Future.delayed(const Duration(milliseconds: 1500));
      setState(() => _downloading = false);
    }
    widget.prov.toggleDownloadItem(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final color = _fileColor(item.fileType);

    return Container(
      margin: const EdgeInsets.only(bottom: AppDimensions.paddingMD),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingMD),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // File icon
            Container(
              width: 48,
              height: 56,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.description_rounded, color: color, size: 22),
                  const SizedBox(height: 2),
                  Text(
                    item.fileType,
                    style: TextStyle(
                      fontSize: 9,
                      color: color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          )),
                  const SizedBox(height: 4),
                  Text(item.description,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(
                              AppDimensions.radiusRound),
                        ),
                        child: Text(
                          item.category,
                          style: const TextStyle(
                              fontSize: 10, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.storage_rounded,
                          size: 12, color: AppColors.textHint),
                      const SizedBox(width: 3),
                      Text(item.sizeLabel,
                          style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                  if (item.isDownloaded && item.downloadedAt != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            size: 12, color: AppColors.accentGreen),
                        const SizedBox(width: 4),
                        Text(
                          'Downloaded ${_formatDate(item.downloadedAt!)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.accentGreen,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Download button
            Column(
              children: [
                if (_downloading)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primary,
                    ),
                  )
                else
                  GestureDetector(
                    onTap: _toggleDownload,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: item.isDownloaded
                            ? AppColors.accentGreen.withOpacity(0.1)
                            : AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isDownloaded
                            ? Icons.download_done_rounded
                            : Icons.download_rounded,
                        size: 20,
                        color: item.isDownloaded
                            ? AppColors.accentGreen
                            : AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final diff = DateTime.now().difference(dt).inDays;
    if (diff == 0) return 'today';
    if (diff == 1) return 'yesterday';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
