import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../providers/app_provider.dart';
import '../../models/album_model.dart';
import '../../utils/app_constants.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/album_card.dart';
import 'album_detail_screen.dart';

class AlbumsScreen extends StatelessWidget {
  const AlbumsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final albums = prov.albums;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Albums'),
      ),
      body: albums.isEmpty
          ? EmptyState(
              icon: Icons.folder_outlined,
              title: 'No Albums Yet',
              subtitle:
                  'Create albums to organize your learning videos into playlists.',
              actionLabel: 'Create Album',
              onAction: () => _showCreateAlbumSheet(context, prov),
            )
          : Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${albums.length} Album${albums.length != 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.88,
                      ),
                      itemCount: albums.length,
                      itemBuilder: (ctx, i) {
                        final album = albums[i];
                        return AlbumCard(
                          album: album,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    AlbumDetailScreen(album: album)),
                          ),
                          onMoreTap: () =>
                              _showAlbumOptions(context, prov, album),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateAlbumSheet(context, prov),
        backgroundColor: AppColors.secondary,
        icon: const Icon(Icons.create_new_folder_rounded, color: Colors.white),
        label: const Text('New Album',
            style:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  void _showCreateAlbumSheet(BuildContext context, AppProvider prov) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXXL)),
      ),
      builder: (ctx) => _CreateAlbumSheet(prov: prov),
    );
  }

  void _showAlbumOptions(
      BuildContext context, AppProvider prov, AlbumModel album) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.radiusXXL)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 16),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.edit_rounded, color: AppColors.primary),
              title: const Text('Rename Album'),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, prov, album);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: AppColors.accentRed),
              title: const Text('Delete Album',
                  style: TextStyle(color: AppColors.accentRed)),
              onTap: () {
                prov.deleteAlbum(album.id);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Album deleted')),
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(
      BuildContext context, AppProvider prov, AlbumModel album) {
    final ctrl = TextEditingController(text: album.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename Album'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Album Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                prov.updateAlbum(album.copyWith(title: ctrl.text.trim()));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }
}

class _CreateAlbumSheet extends StatefulWidget {
  final AppProvider prov;
  const _CreateAlbumSheet({required this.prov});

  @override
  State<_CreateAlbumSheet> createState() => _CreateAlbumSheetState();
}

class _CreateAlbumSheetState extends State<_CreateAlbumSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedColor = '#4361EE';
  bool _isPublic = false;

  final List<String> _colors = [
    '#4361EE', '#7209B7', '#F77F00', '#06D6A0',
    '#EF233C', '#4CC9F0', '#1A237E', '#B5179E',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _create() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final album = AlbumModel(
      id: const Uuid().v4(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      ownerId: widget.prov.currentUser?.id ?? '',
      ownerName: widget.prov.currentUser?.fullName ?? '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      colorHex: _selectedColor,
      isPublic: _isPublic,
    );
    widget.prov.addAlbum(album);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Album created successfully!')),
    );
  }

  Color _hexColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      builder: (ctx, ctrl) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Create New Album',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),

            TextField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Album Name',
                prefixIcon: Icon(Icons.folder_rounded),
              ),
            ),
            const SizedBox(height: 14),

            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
                prefixIcon: Icon(Icons.description_outlined),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            Text('Album Color',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 10),
            Row(
              children: _colors
                  .map(
                    (hex) => GestureDetector(
                      onTap: () => setState(() => _selectedColor = hex),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: _hexColor(hex),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColor == hex
                                ? AppColors.textPrimary
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: _selectedColor == hex
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : null,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                const Text('Make Public',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                const Spacer(),
                Switch(
                  value: _isPublic,
                  onChanged: (v) => setState(() => _isPublic = v),
                  activeColor: AppColors.primary,
                ),
              ],
            ),

            const Spacer(),
            GradientButton(
              label: 'Create Album',
              onPressed: _create,
              gradient: const LinearGradient(
                colors: [Color(0xFF7209B7), Color(0xFFB5179E)],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
