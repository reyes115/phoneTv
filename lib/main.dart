import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  runApp(const MediaApp());
}

class MediaApp extends StatelessWidget {
  const MediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: ShareMediaScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ShareMediaScreen extends StatefulWidget {
  const ShareMediaScreen({super.key});

  @override
  _ShareMediaScreenState createState() => _ShareMediaScreenState();
}

class _ShareMediaScreenState extends State<ShareMediaScreen> {
  final channel = IOWebSocketChannel.connect('ws://localhost:8080');
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickAndSendImage() async {
    final pickedFile =
        await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      String base64Image =
          base64Encode(File(pickedFile.path).readAsBytesSync());
      String fileName = pickedFile.path.split('/').last;
      _sendMessage({
        'type': 'image',
        'filename': fileName,
        'data': base64Image,
      });
    }
  }

  void _sendMessage(dynamic data) {
    String message = json.encode(data);
    channel.sink.add(message);
  }

  @override
  void dispose() {
    channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Sharing App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickAndSendImage,
              child: const Text('Pick and Send Image'),
            ),
          ],
        ),
      ),
    );
  }
}
