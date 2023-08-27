import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'image_item.dart' as custom;
import 'package:draggable_scrollbar/draggable_scrollbar.dart'; 
// Couldn't make it drop the image when drag somewhere in the list :/

void main() {
  HttpOverrides.global = MyHttpOverrides(); // Set custom HTTP overrides
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageUploadScreen(), // Set the home screen as ImageUploadScreen
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState(); // Create state for ImageUploadScreen
} // => Shorter way of writing a function that has only one expression in this instance.

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File _image = File(''); // Initialize an empty File for the selected image
  List<custom.ImageItem> _images = []; // Store uploaded images
  ScrollController _scrollController = ScrollController(); // Controller for scrolling
  int _draggedIndex = -1; // Index of currently dragged image

  Future<void> _getImage() async {
    final picker = ImagePicker(); // Create an instance of ImagePicker
    final pickedImage = await picker.pickImage(source: ImageSource.camera); // Pick an image from the camera
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path); // Set the selected image file
      });
    }
  }

 // Function to upload the selected image
  Future<void> _uploadImage() async {
    if (_image == null) return; // If no image is selected, return

    List<int> bytes = await _image.readAsBytes();
    String base64Image = base64Encode(bytes);

    try {
      final response = await http.post(
        Uri.parse('https://10.0.2.2:7080/api/images'), // API endpoint for image upload
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'base64Data': base64Image,
          'type': 'image/jpeg',
        }), // Send base64-encoded image data
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        print('Image uploaded successfully');
      } else {
        print('Failed to upload image');
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
  }

  // Function to fetch images from the API
  Future<void> _fetchImages() async {
    final response = await http.get(Uri.parse('https://10.0.2.2:7080/api/images'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        final fetchedImages = responseData.map((json) {
          final imageModel = custom.ImageDataModel.fromJson(json);
          final imageBytes = base64Decode(imageModel.base64Data);
          return custom.ImageItem(
            imageModel: imageModel,
            type: 'image/jpeg',
            size: imageBytes.length,
          );
        }).toList();

        _images.addAll(fetchedImages); // Add fetched images to the existing list
      });
    } else {
      print('Failed to fetch images');
    }
  }

 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Display selected image or a placeholder
            _image == null
                ? Text('No image selected')
                : Image.file(_image, height: 200),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _getImage, // Button to take a picture
                  child: Text('Take Picture'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _uploadImage, // Button to upload the selected image
                  child: Text('Upload Image'),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchImages, // Button to fetch and display images
              child: Text('Fetch Images'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final item = _images[index];

                  return LongPressDraggable<int>(
                    data: index,
                    onDragStarted: () {
                      setState(() {
                        _draggedIndex = index; // Mark the index of the dragged image
                      });
                    },
                    onDraggableCanceled: (Velocity velocity, Offset offset) {
                      setState(() {
                        _draggedIndex = -1; // Reset the dragged index
                      });
                    },
                    feedback: Opacity(
                      opacity: 0.6,
                      child: Image.memory(
                        base64Decode(item.imageModel.base64Data),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: DragTarget<int>(
                      builder: (BuildContext context, List<int?> candidateData, List<dynamic> rejectedData) {
                        return Dismissible(
                          key: Key('${item.imageModel.id}'), // Use image ID as the key
                          onDismissed: (direction) {
                            setState(() {
                              _images.removeAt(index); // Remove image when dismissed
                            });
                          },
                          child: ListTile(
                            leading: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) {
                                    return Scaffold(
                                      appBar: AppBar(
                                        title: Text('Full Size Image'),
                                      ),
                                      body: Center(
                                        child: Image.memory(
                                          base64Decode(item.imageModel.base64Data),
                                          height: 400,
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                              child: Image.memory(
                                base64Decode(item.imageModel.base64Data),
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text('${item.type} (${item.size} bytes)'),
                          ),
                        );
                      },
                      onWillAccept: (draggedIndex) =>
                          _draggedIndex != -1 && draggedIndex != index,
                      onAccept: (draggedIndex) {
                        setState(() {
                          final draggedItem = _images[_draggedIndex];
                          _images.removeAt(_draggedIndex);
                          _images.insert(draggedIndex, draggedItem);
                          _draggedIndex = -1;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}