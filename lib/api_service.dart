import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService {
  static Future<void> uploadImages(List<File> images) async {
    final url = Uri.parse('https://localhost:7080/api/images/upload');
    var request = http.MultipartRequest('POST', url);

    for (var image in images) {
      var stream = http.ByteStream(image.openRead());
      var length = await image.length();

      var multipartFile = http.MultipartFile('images', stream, length,
          filename: image.path.split('/').last);
      request.files.add(multipartFile);
    }

    var response = await request.send();

    if (response.statusCode == 200) {
      print('Images uploaded successfully');
    } else {
      print('Failed to upload images');
    }
  }

  static Future<List<Image>> fetchImages() async {
    final response = await http.get(Uri.parse('https://localhost:7080/api/images/upload'));
    if (response.statusCode == 200) {
      List<dynamic> base64Images = jsonDecode(response.body);
      List<Image> images = [];

      for (var base64Image in base64Images) {
        final decodedBytes = base64.decode(base64Image);
        final image = Image.memory(decodedBytes);
        images.add(image);
      }

      return images;
    } else {
      throw Exception('Failed to load images');
    }
  }
}
