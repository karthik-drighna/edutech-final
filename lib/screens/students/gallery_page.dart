import 'dart:io';
import 'package:drighna_ed_tech/widgets/gallery_Image_view.dart';
import 'package:drighna_ed_tech/widgets/gallery_video_player.dart';
import 'package:flutter/material.dart';

class Gallery extends StatefulWidget {
  final List<Map<String, String>> mediaUrls;

  const Gallery({super.key, required this.mediaUrls});

  @override
  State<Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.mediaUrls.isEmpty
        ? const Center(
            child: Text('No media available'),
          )
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4.0,
              mainAxisSpacing: 4.0,
            ),
            itemCount: widget.mediaUrls.length,
            itemBuilder: (context, index) {
              String type = widget.mediaUrls[index]['type']!;
              String url = widget.mediaUrls[index]['url']!;
              String thumbUrl = widget.mediaUrls[index]['thumbUrl']!;

              return GestureDetector(
                onTap: () {
                  if (type == 'image') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GalleryImageViewerPage(imageUrl: url),
                      ),
                    );
                  } else if (type == 'video') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GalleryVideoPlayerPage(videoUrl: url),
                      ),
                    );
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    thumbUrl == "assets/play_icon.png"
                        ? const Icon(
                            Icons.play_circle_outline,
                            color: Colors.black,
                            size: 41,
                          )
                        : Image.network(
                            thumbUrl,
                            fit: BoxFit.cover,
                          ),
                    if (type == 'video')
                      const Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 36,
                      ),
                  ],
                ),
              );
            },
          );
  }
}
