import 'package:flutter/material.dart';
import 'api_service.dart';

class ImageViewerWidget extends StatefulWidget {
  @override
  _ImageViewerWidgetState createState() => _ImageViewerWidgetState();
}

class _ImageViewerWidgetState extends State<ImageViewerWidget> {
  List<Image> uploadedImages = [];

  @override
  void initState() {
    super.initState();
    fetchImages();
  }

  Future<void> fetchImages() async {
    uploadedImages = await ApiService.fetchImages();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: uploadedImages.map((image) => Container(child: image)).toList(),
    );
  }
}
