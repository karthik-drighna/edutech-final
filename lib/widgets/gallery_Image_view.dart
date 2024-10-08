
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class GalleryImageViewerPage extends StatelessWidget {
  final String imageUrl;

  const GalleryImageViewerPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Viewer'),
      ),
      body: PhotoView(
        imageProvider: NetworkImage(imageUrl),
      ),
    );
  }
}
