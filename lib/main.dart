import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'image_data.dart'; // Importing the ImageData class from a separate file

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
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<ImageData> _imageDataList = [];

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage != null) {
      setState(() {
        _showImageDialog(File(pickedImage.path));
      });
    }
  }

  // Function to show the dialog for adding image information
  Future<void> _showImageDialog(File image) async {
    // Controllers for capturing user input
    TextEditingController nameController = TextEditingController();
    String selectedType = '.jpg';
    TextEditingController sizeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Image Information'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Display the selected image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.file(image, height: 100),
                    ],
                  ),
                  // Text field for capturing image name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Image Name'),
                  ),
                  // Dropdown for selecting image type
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
                  // Text field for capturing image size
                  TextField(
                    controller: sizeController,
                    decoration: InputDecoration(labelText: 'Image Size'),
                  ),
                ],
              ),
              actions: [
                // Save image information and update the list
                TextButton(
                  onPressed: () async {
                    ImageData imageData = ImageData(
                      image: image,
                      name: nameController.text,
                      type: selectedType,
                      size: sizeController.text,
                    );

                    // Close the dialog
                    Navigator.of(context).pop();

                    // Update the image list
                    setState(() {
                      _imageDataList.insert(0, imageData);
                    });

                    // Insert the item at the beginning of the animated list
                    _listKey.currentState?.insertItem(0);
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

  // Function to show the dialog with detailed image information
  Future<void> _showImageDataDialog(ImageData imageData) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Image Information'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Display the image with an option to view full-size
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                  _showOriginalImageDialog(imageData.image);
                },
                child: Image.file(imageData.image, height: 100),
              ),
              // Display image name, type, and size
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

  // Function to show the dialog with the original image
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

  // Function to build the animated list of images
  Widget _buildImageList() {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _imageDataList.length,
      itemBuilder: (BuildContext context, int index, Animation<double> animation) {
        return _buildImageListItem(_imageDataList[index], animation, index);
      },
    );
  }

  // Function to build an individual item in the animated list
  Widget _buildImageListItem(ImageData imageData, Animation<double> animation, int index) {
    return SizeTransition(
      sizeFactor: animation,
      child: GestureDetector(
        onTap: () {
          _showImageDataDialog(imageData);
        },
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Display image information
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Name: ${imageData.name}'),
                        Text('Type: ${imageData.type}'),
                        Text('Size: ${imageData.size}'),
                      ],
                    ),
                  ),
                  // Display thumbnail of the image
                  Expanded(
                    flex: 1,
                    child: Image.file(imageData.image, height: 50),
                  ),
                ],
              ),
            ),
            Divider(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Gallery'),
      ),
      body: _buildImageList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: Icon(Icons.add),
      ),
    );
  }
}
