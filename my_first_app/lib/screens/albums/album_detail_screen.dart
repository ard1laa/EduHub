import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';
import '../../models/album_model.dart';
import '../../widgets/video_card.dart';
import '../videos/video_detail_screen.dart';

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;
  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AppProvider>();
    final videos = prov.getAlbumVideos(album);

    return Scaffold(
      appBar: AppBar(
        title: Text(album.title),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: videos.isEmpty
          ? const Center(
              child: Text('No videos in this album yet.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: videos.length,
              itemBuilder: (context, i) {
                return VideoCard(
                  video: videos[i],
                  onTap: () {
                    prov.markVideoViewed(videos[i].id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoDetailScreen(video: videos[i]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
