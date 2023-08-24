import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';


void main() {
  runApp(MyApp());
}

class ImageModel {
  final int id;
  final String base64Data;

  ImageModel({required this.id, required this.base64Data});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      base64Data: json['base64Data'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ImageUploadScreen(),
    );
  }
}

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File _image = File('');
  List<ImageModel> _images = [];
  

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
    final response = await http.post(
      Uri.parse('https://192.168.39.114:7080/swagger/index.html'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'base64Data': base64Image}),
    );

    if (response.statusCode == 201) {
      print('Image uploaded successfully');
    } else {
      print('Failed to upload image');
    }
  }

  Future<void> _fetchImages() async {
    final response = await http.get(Uri.parse('https://192.168.39.114:7080/swagger/index.html'));

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      setState(() {
        _images = responseData.map((json) => ImageModel.fromJson(json)).toList();
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Text('No image selected')
                : Image.file(_image, height: 200),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getImage,
              child: Text('Take Picture'),
            ),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text('Upload Image'),
            ),
            ElevatedButton(
              onPressed: _fetchImages,
              child: Text('Fetch Images'),
            ),
            Column(
              children: _images.map((image) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Image.memory(
                    base64Decode(image.base64Data),
                    height: 150,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
