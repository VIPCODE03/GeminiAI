import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:zent_gemini/gemini_config.dart';
import 'gemini_models.dart';

/// Class chịu trách nhiệm thực hiện các cuộc gọi API đến Gemini.
class GeminiAI {
  /// Config AI
  final GeminiConfig _config;
  /// Quản lý nhiều lượt trò chuyện.
  List<Content> _chatHistory = [];
  /// Hướng dẫn hệ thống
  String? _systemInstruction;

  /// Hàm khởi tạo cho class GeminiService.
  /// Nhận một instance của [GeminiConfig].
  GeminiAI(this._config);

  //------------------------------Raw-------------------------------------------
  /// Hàm để gọi API tạo nội dung (generateContent) sử dụng model được cấu hình.
  /// [prompt] là prompt bạn muốn gửi đến Gemini API.
  Future<Map<String, dynamic>> generateContentRaw(Content content) async {
    final url = Uri.parse('${_config.baseUrl}:generateContent');
    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': _config.apiKey,
    };
    final payload = <String, dynamic>{
      'contents': [content.toJson()],
    };
    if (_systemInstruction != null) {
      payload['system_instruction'] = {'parts': [{'text': _systemInstruction}]};
    }
    final body = jsonEncode(payload);

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      throw Exception('Failed to generate content: ${response.statusCode}');
    }
  }

  //------------------------------Đầu vào văn bản--------------------------------------
  /// Hàm để gọi API tạo nội dung và trả về trực tiếp phần text được tạo.
  /// [prompt] là prompt bạn muốn gửi đến Gemini API.
  Future<String?> generateContent(String prompt) async {
    final content = Content(role: 'user', parts: [
      {'text': prompt}
    ]);
    final url = Uri.parse('${_config.baseUrl}:generateContent');
    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': _config.apiKey,
    };
    final payload = <String, dynamic>{
      'contents': [content.toJson()],
    };
    if (_systemInstruction != null) {
      payload['system_instruction'] = {'parts': [{'text': _systemInstruction}]};
    }
    final body = jsonEncode(payload);
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return _getContent(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to generate content: ${response.statusCode}');
    }
  }

  //----------------------------------Đầu vào hình ảnh + văn bản----------------------------
  /// Hàm để gọi API tạo nội dung với văn bản và hình ảnh.
  /// [textPrompt] là đoạn văn bản prompt.
  /// [imagePath] là đường dẫn đến file hình ảnh.
  Future<String?> generateContentWithImage(String textPrompt, String imagePath) async {
    try {
      final bytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(bytes);

      final content = Content(role: 'user', parts: [
        {'text': textPrompt},
        {
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Image,
          },
        }
      ]);
      final url = Uri.parse('${_config.baseUrl}:generateContent');
      final headers = {
        'Content-Type': 'application/json',
        'x-goog-api-key': _config.apiKey,
      };
      final payload = <String, dynamic>{
        'contents': [content.toJson()],
      };
      if (_systemInstruction != null) {
        payload['system_instruction'] = {'parts': [{'text': _systemInstruction}]};
      }
      final body = jsonEncode(payload);
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        return _getContent(jsonDecode(response.body) as Map<String, dynamic>);
      } else {
        throw Exception('Failed to generate content with image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  //-----------------------------------Stream content-----------------------------------
  /// Hàm để gọi API tạo nội dung (streamGenerateContent) sử dụng model được cấu hình và trả về một Stream của các phần văn bản được tạo.
  /// [prompt] là prompt bạn muốn gửi đến Gemini API.
  Stream<String> streamGenerateContent(String prompt) async* {
    final url = Uri.parse('${_config.baseUrl.replaceFirst(_config.model, 'gemini-2.0-flash')}:streamGenerateContent?alt=sse');
    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': _config.apiKey,
    };
    final payload = <String, dynamic>{
      'contents': [
        {
          'parts': [
            {'text': prompt}
          ]
        }
      ],
    };
    if (_systemInstruction != null) {
      payload['system_instruction'] = {'parts': [{'text': _systemInstruction}]};
    }
    final body = jsonEncode(payload);

    try {
      final request = http.Request('POST', url);
      request.headers.addAll(headers);
      request.body = body;

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        await for (final chunk in streamedResponse.stream) {
          final responseData = utf8.decode(chunk);
          // Các event SSE được phân tách bằng '\n\n'
          final events = responseData.split('\n\n');
          for (final event in events) {
            if (event.startsWith('data: ')) {
              final jsonData = event.substring(6).trim();
              if (jsonData.isNotEmpty) {
                try {
                  final responseJson = jsonDecode(jsonData) as Map<String, dynamic>;
                  final content = _getContent(responseJson);
                  if (content != null) {
                    yield content;
                  }
                } catch (e) {
                  print('Lỗi khi parse JSON trong stream: $e');
                  // Có thể quyết định ném lỗi hoặc bỏ qua tùy thuộc vào yêu cầu
                }
              }
            } else if (event.startsWith('error: ')) {
              final errorData = event.substring(7).trim();
              print('Lỗi từ stream: $errorData');
              // Có thể ném lỗi tùy thuộc vào yêu cầu
            } else if (event.startsWith(':')) {
              // Đây là dòng comment trong SSE, bỏ qua
            }
          }
        }
      } else {
        throw Exception('Failed to stream content: ${streamedResponse.statusCode}');
      }
    } catch (e) {
      print('Lỗi khi gọi API stream: $e');
      throw e;
    }
  }

  //-------------------------------------Trò chuyện----------------------------------
  /// Hàm để bắt đầu hoặc tiếp tục một cuộc trò chuyện với Gemini API.
  /// [userMessage] là tin nhắn của người dùng.
  Future<String?> sendMessage(String userMessage) async {
    // Thêm tin nhắn của người dùng vào lịch sử trò chuyện
    final userContent = Content(role: 'user', parts: [
      {'text': userMessage}
    ]);
    _chatHistory.add(userContent);

    final url = Uri.parse('${_config.baseUrl}:generateContent');
    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': _config.apiKey,
    };
    final payload = <String, dynamic>{
      'contents': _chatHistory.map((content) => content.toJson()).toList(),
    };
    if (_systemInstruction != null) {
      payload['system_instruction'] = {'parts': [{'text': _systemInstruction}]};
    }
    final body = jsonEncode(payload);

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
      final modelResponseContent = _extractContentFromResponse(responseJson);
      if (modelResponseContent != null) {
        _chatHistory.add(modelResponseContent);
        return _getTextFromContent(modelResponseContent);
      }
      return null;
    } else {
      throw Exception('Failed to send message: ${response.statusCode}');
    }
  }
  /// Set lịch sử
  set setHistory(List<Content> history) => _chatHistory = history; // Chỉnh sửa kiểu dữ liệu

  /// Lấy lịch sử trò chuyện hiện tại.
  List<Content> getChatHistory() {
    return _chatHistory; // Không cần kiểm tra null nữa
  }

  /// Xóa lịch sử trò chuyện.
  void clearChatHistory() {
    _chatHistory.clear(); // Không cần kiểm tra null nữa
  }

  //------------------------------------Hướng dẫn hệ thống--------------------------
  set setSystemInstruction(String instruction) => _systemInstruction = instruction;

  //----------------------------------Xử lý content-------------------------------------
  /// Hàm xử lý lấy content
  /// [responseJson] là kết quả trả về
  String? _getContent(Map<String, dynamic> responseJson) {
    if (responseJson.containsKey('candidates') &&
        responseJson['candidates'] is List &&
        responseJson['candidates'].isNotEmpty &&
        responseJson['candidates'][0].containsKey('content') &&
        responseJson['candidates'][0]['content'] is Map &&
        responseJson['candidates'][0]['content'].containsKey('parts') &&
        responseJson['candidates'][0]['content']['parts'] is List &&
        responseJson['candidates'][0]['content']['parts'].isNotEmpty &&
        responseJson['candidates'][0]['content']['parts'][0].containsKey('text')) {
      return responseJson['candidates'][0]['content']['parts'][0]['text'] as String?; // Thêm ? để phù hợp với kiểu trả về
    } else {
      // Xử lý trường hợp không tìm thấy text trong response
      return null; // Trả về null thay vì throw Exception
    }
  }

  /// Hàm trích xuất đối tượng Content từ response JSON.
  Content? _extractContentFromResponse(Map<String, dynamic> responseJson) {
    if (responseJson.containsKey('candidates') &&
        responseJson['candidates'] is List &&
        responseJson['candidates'].isNotEmpty &&
        responseJson['candidates'][0].containsKey('content') &&
        responseJson['candidates'][0]['content'] is Map) {
      return Content.fromJson(responseJson['candidates'][0]['content'] as Map<String, dynamic>);
    }
    return null;
  }

  /// Hàm lấy text từ đối tượng Content.
  String? _getTextFromContent(Content? content) {
    if (content != null && content.parts.isNotEmpty && content.parts[0].containsKey('text')) {
      return content.parts[0]['text'] as String?;
    }
    return null;
  }
}