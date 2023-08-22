import 'dart:io';

class ImageData {
  final File image;
  final String name;
  final String type;
  final String size;

  ImageData({
    required this.image,
    required this.name,
    required this.type,
    required this.size,
  });
}
