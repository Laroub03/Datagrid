import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'api_service.dart';

class ImagePickerWidget extends StatefulWidget {
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  List<File> selectedImages = [];

  Future<void> pickAndUploadImages() async {
    List<XFile> pickedImages = await ImagePicker().pickMultiImage();

    if (pickedImages != null && pickedImages.isNotEmpty) {
      selectedImages = pickedImages.map((xFile) => File(xFile.path)).toList();
      await ApiService.uploadImages(selectedImages);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: pickAndUploadImages,
          child: Text('Pick and Upload Images'),
        ),
      ],
    );
  }
}
