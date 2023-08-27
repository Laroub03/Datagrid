import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'image_item.dart' as custom;

void main() {
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageUploadScreen(),
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
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File _image = File('');
  List<custom.ImageItem> _images = [];

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.camera);
    if (pickedImage != null) {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    List<int> bytes = await _image.readAsBytes();
    String base64Image = base64Encode(bytes);

    try {
      final response = await http.post(
        Uri.parse('https://10.0.2.2:7080/api/images'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'base64Data': base64Image,
          'type': 'image/jpeg',
        }),
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
            _image == null
                ? Text('No image selected')
                : Image.file(_image, height: 200),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _getImage,
                  child: Text('Take Picture'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _uploadImage,
                  child: Text('Upload Image'),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _fetchImages,
              child: Text('Fetch Images'),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _images.length,
                itemBuilder: (context, index) {
                  final item = _images[index];

                  return Dismissible(
                    key: UniqueKey(), // Unique key for state preservation
                    onDismissed: (direction) {
                      setState(() {
                        _images.remove(item);
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
