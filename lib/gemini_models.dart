import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';

class Content {
  final String role;
  final List<Map<String, dynamic>> parts;

  Content._private({required this.role, required this.parts});

  static Future<Content> build({required String textPrompt, Uint8List? image, Uint8List? pdf}) async {
    if (image != null) {
      final imageCompressed = await _compressImage(image);
      return Content._userImage(textPrompt, imageCompressed);
    } else if (pdf != null) {
      return Content._userPdf(textPrompt, pdf);
    } else {
      return Content._userText(textPrompt);
    }
  }

  String? get text {
    for(final part in parts) {
      if(part['text'] != null) {
        return part['text'] as String?;
      }
    }
    return null;
  }

  Uint8List? get image {
    for(final part in parts) {
      if(part['inline_data'] != null && part['inline_data']['mime_type'] == 'image/jpeg') {
        return base64Decode(part['inline_data']['data'] as String);
      }
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'parts': parts,
    };
  }

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content._private(
      role: json['role'] as String,
      parts: (json['parts'] as List).cast<Map<String, dynamic>>(),
    );
  }

  factory Content._userText(String textPrompt) => Content._private(role: 'user', parts: [{'text': textPrompt}]);

  factory Content._userImage(String? textPrompt, Uint8List image) {
    final Uint8List bytes = image;
    final base64Image = base64Encode(bytes);
    return Content._private(role: 'user', parts: [
      {
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Image,
        }
      },
      {'text': textPrompt},
    ]);
  }

  factory Content._userPdf(String? textPrompt, Uint8List pdf) {
    final Uint8List bytes = pdf;
    final base64Pdf = base64Encode(bytes);
    return Content._private(role: 'user', parts: [
      {
        'inline_data': {
          'mime_type': 'application/pdf',
          'data': base64Pdf,
        }
      },
      {'text': textPrompt},
    ]);
  }
}

Future<Uint8List> _compressImage(Uint8List inputBytes) async {
  final result = await FlutterImageCompress.compressWithList(
    inputBytes,
    minWidth: 1000,
    minHeight: 800,
    quality: 50,
    format: CompressFormat.webp,
  );
  return Uint8List.fromList(result);
}