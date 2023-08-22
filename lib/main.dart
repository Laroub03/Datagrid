import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/datagrid/lib/image_data.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Gallery',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ImageGallery(),
    );
  }
}

class ImageGallery extends StatefulWidget {
  @override
  _ImageGalleryState createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  List<ImageData> _imageDataList = [];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _showImageDialog(File(pickedImage.path));
      });
    }
  }

  Future<void> _showImageDialog(File image) async {
    TextEditingController nameController = TextEditingController();
    String selectedType = '.jpg';
    TextEditingController sizeController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Image Information'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.file(image, height: 100),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Image Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    onChanged: (newValue) {
                      setState(() {
                        selectedType = newValue!;
                      });
                    },
                    items: <String>['.jpg', '.png', '.gif']
                        .map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                    decoration: InputDecoration(labelText: 'Image Type'),
                  ),
                  TextField(
                    controller: sizeController,
                    decoration: InputDecoration(labelText: 'Image Size'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    ImageData imageData = ImageData(
                      image: image,
                      name: nameController.text,
                      type: selectedType,
                      size: sizeController.text,
                    );

                    setState(() {
                      _imageDataList.add(imageData);
                    });

                    Navigator.of(context).pop();
                  },
                  child: Text('Save Image Information'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showImageDataDialog(ImageData imageData) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _showOriginalImageDialog(imageData.image);
                },
                child: Image.file(imageData.image, height: 100),
              ),
              Text('Name: ${imageData.name}'),
              Text('Type: ${imageData.type}'),
              Text('Size: ${imageData.size}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showOriginalImageDialog(File image) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Image.file(image),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageDataGrid() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemCount: _imageDataList.length,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () {
            _showImageDataDialog(_imageDataList[index]);
          },
          child: Image.file(_imageDataList[index].image),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Gallery'),
      ),
      body: _buildImageDataGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.add),
      ),
    );
  }
}
