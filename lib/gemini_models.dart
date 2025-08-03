import 'dart:convert';
import 'dart:typed_data';

class Content {
  final String role;
  final List<Map<String, dynamic>> parts;

  Content({required this.role, required this.parts});

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
    return Content(
      role: json['role'] as String,
      parts: (json['parts'] as List).cast<Map<String, dynamic>>(),
    );
  }

  factory Content.modelText(String textPrompt) => Content(role: 'model', parts: [{'text': textPrompt}]);

  factory Content.userText(String textPrompt) => Content(role: 'user', parts: [{'text': textPrompt}]);

  factory Content.userImage(String? textPrompt, Uint8List image) {
    final Uint8List bytes = image;
    final base64Image = base64Encode(bytes);

    final int byteSize = image.lengthInBytes;
    print('📦 Kích thước Uint8List: $byteSize bytes (${(byteSize / 1024).toStringAsFixed(2)} KB)');
    final int base64Size = base64Image.length;
    print('📄 Kích thước chuỗi base64: $base64Size ký tự (${(base64Size / 1024).toStringAsFixed(2)} KB)');

    return Content(role: 'user', parts: [
      {
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Image,
        }
      },
      {'text': textPrompt},
    ]);
  }

  factory Content.userPdf(String? textPrompt, Uint8List pdf) {
    final Uint8List bytes = pdf;
    final base64Pdf = base64Encode(bytes);
    return Content(role: 'user', parts: [
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