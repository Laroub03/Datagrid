class ImageDataModel {
  final int id;
  final String base64Data;

  ImageDataModel({required this.id, required this.base64Data});

  factory ImageDataModel.fromJson(Map<String, dynamic> json) {
    return ImageDataModel(
      id: json['id'],
      base64Data: json['base64Data'],
    );
  }
}

class ImageItem {
  final ImageDataModel imageModel;
  final String type;
  final int size;

  ImageItem({
    required this.imageModel,
    required this.type,
    required this.size,
  });
}
