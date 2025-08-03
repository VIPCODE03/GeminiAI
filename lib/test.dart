import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<Uint8List> compressImageWebP(Uint8List inputBytes) async {
  final result = await FlutterImageCompress.compressWithList(
    inputBytes,
    minWidth: 1000,
    minHeight: 800,
    quality: 70,
    format: CompressFormat.webp,
  );
  return Uint8List.fromList(result);
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Web Image Compress Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImageCompressWebDemo(),
    );
  }
}


class ImageCompressWebDemo extends StatefulWidget {
  const ImageCompressWebDemo({super.key});

  @override
  State createState() => _ImageCompressWebDemoState();
}

class _ImageCompressWebDemoState extends State<ImageCompressWebDemo> {
  Uint8List? _original;
  Uint8List? _compressed;

  Future<void> _pickAndCompress() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    final bytes = file.bytes!;
    final compressed = await compressImageWebP(
      bytes,
    );

    setState(() {
      _original = bytes;
      _compressed = compressed;
    });
  }

  String _fmt(int bytes) => '${(bytes / 1024).toStringAsFixed(1)} KB';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Web Image Compress Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.photo),
              label: Text('Chọn ảnh & nén'),
              onPressed: _pickAndCompress,
            ),
            const SizedBox(height: 20),
            if (_original != null && _compressed != null) ...[
              Text(
                'Original: ${_fmt(_original!.length)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Image.memory(_original!),
              const SizedBox(height: 16),
              Text(
                'Compressed: ${_fmt(_compressed!.length)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Image.memory(_compressed!),
            ] else
              Expanded(
                child: Center(
                  child: Text(
                    'Chưa có ảnh nào',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
