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
      debugShowCheckedModeBanner: false, // Elimina el banner de depuración
    );
  }
}

class ShareMediaScreen extends StatefulWidget {
  const ShareMediaScreen({Key? key}) : super(key: key);

  @override
  _ShareMediaScreenState createState() => _ShareMediaScreenState();
}

class _ShareMediaScreenState extends State<ShareMediaScreen> {
  final channel = IOWebSocketChannel.connect('ws://192.168.100.7:8080');
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> _pickImage() async {
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

  Future<void> _pickVideo() async {
    final pickedFile =
        await _imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      String base64Video =
          base64Encode(File(pickedFile.path).readAsBytesSync());
      String fileName = pickedFile.path.split('/').last;
      _sendMessage({
        'type': 'video',
        'filename': fileName,
        'data': base64Video,
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
        backgroundColor: Colors.blue,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 8),
            Text('Compartir '),
          ],
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 250, 250, 250),
              Color.fromARGB(255, 6, 49, 189)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(
                  height: 30,
                ),
                ElevatedButton(
                  onPressed: _pickImage,
                  child: const Text('Seleccionar Imagen'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
