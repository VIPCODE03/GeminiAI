import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zent_gemini/gemini_config.dart';
import 'package:zent_gemini/gemini_exception.dart';
import 'gemini_models.dart';

class GeminiAI {
  /// Cấu hình
  final GeminiConfig _config;

  /// Constructor.
  GeminiAI(this._config);

  /// Lịch sử trò chuyện
  List<Content> _chatHistory = [];
  set setHistory(List<Content> history) => _chatHistory = history;
  List<Content> get chatHistory => _chatHistory;

  /// Hướng dẫn hệ thống
  String? _systemInstruction;
  set setSystemInstruction(String instruction) => _systemInstruction = instruction;

  /// Chế độ search
  bool _googleSearch = false;
  set setGoogleSearch(bool enable) => _googleSearch = enable;
  bool get googleSearch => _googleSearch;

  /// Chế độ tư duy
  bool _thinking = false;
  set setThinking(bool enable) => _thinking = enable;
  bool get thinking => _thinking;

  //- Tạo nội dung request  -----------------------------------------------------------------
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'x-goog-api-key': _config.apiKey,
    };
  }

  Future<String> _buildBody(Content content) async {
    final payload = <String, dynamic>{};

    if (_systemInstruction != null) {
      payload['system_instruction'] = {'parts': [{'text': _systemInstruction}]};
    }
    if(_googleSearch) {
      payload['tools'] = [{'google_search': {}}, {'url_context': {}}];
    }
    payload['generationConfig'] = {
      'thinkingConfig': {'thinkingBudget': _thinking ? -1 : 0}
    };
    final contents = <Map<String, dynamic>>[];

    if (_chatHistory.isNotEmpty) {
      contents.addAll(_chatHistory.map((c) => c.toJson()));
    }
    contents.add(content.toJson());
    payload['contents'] = contents;
    
    return jsonEncode(payload);
  }

  //- ĐẦU RA VĂN BẢN  ----------------------------------------------------------------------
  ///--------------------------------------------------------------------------------------
  //- Tạo văn bản --------------------------------------------------------------
  Future<Content?> generateContent(Content content) async {
    final url = Uri.parse('${_config.baseUrl}:generateContent');
    final headers = _buildHeaders();
    final body = await _buildBody(content);

    //- Kết quả -
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return _extractContentFromResponse(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      _handleException(response.statusCode);
      return null;
    }
  }

  //- Trò chuyện  ---------------------------------------------------------------
  Future<Content?> sendMessage(Content content) async {
    final url = Uri.parse('${_config.baseUrl}:generateContent');
    final headers = _buildHeaders();
    final body = await _buildBody(content);

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final content = _extractContentFromResponse(jsonDecode(response.body) as Map<String, dynamic>);
      if (content != null) {
        _chatHistory.add(content);
        return content;
      }
      return null;
    } else {
      _handleException(response.statusCode);
      return null;
    }
  }

  Stream<Content?> streamGenerateContent(Content content) async* {
    final url = Uri.parse('${_config.baseUrl.replaceFirst(_config.model, 'gemini-2.0-flash')}:streamGenerateContent?alt=sse');
    final headers = _buildHeaders();
    final body =  await _buildBody(content);

    try {
      final request = http.Request('POST', url);
      request.headers.addAll(headers);
      request.body = body;

      final streamedResponse = await request.send();

      if (streamedResponse.statusCode == 200) {
        Content? lastContent;
        await for (final chunk in streamedResponse.stream) {
          final responseData = utf8.decode(chunk);
          final events = responseData.split('\n\n');
          for (final event in events) {
            if (event.startsWith('data: ')) {
              final jsonData = event.substring(6).trim();
              if (jsonData.isNotEmpty) {
                try {
                  lastContent = _extractContentFromResponse(jsonDecode(jsonData) as Map<String, dynamic>);
                  yield lastContent;
                } catch (e) {
                  throw Exception('Error parse JSON in stream: $e');
                }
              }
            } else if (event.startsWith('error: ')) {
              final errorData = event.substring(7).trim();
              throw Exception('Error stream: $errorData');
            }
            else if (event.startsWith(':')) {}
          }
        }
      } else {
        _handleException(streamedResponse.statusCode);
        yield null;
      }
    } catch (e) {
      throw Exception('Failed to stream content: $e');
    }
  }

  //- Raw-----------------------------------------------------------------------
  /// Hàm để gọi API tạo nội dung (generateContent) sử dụng model được cấu hình.
  /// [prompt] là prompt bạn muốn gửi đến Gemini API.
  Future<Map<String, dynamic>?> generateContentRaw(Content content) async {
    //- Cấu hình nội dun  -
    final payload = <String, dynamic>{
      'contents': [content.toJson()],
    };
    if (_systemInstruction != null) {
      payload['system_instruction'] = {'parts': [{'text': _systemInstruction}]};
    }
    final body = jsonEncode(payload);

    //- Cấu hình request  -
    final url = Uri.parse('${_config.baseUrl}:generateContent');
    final headers = {
      'Content-Type': 'application/json',
      'x-goog-api-key': _config.apiKey,
    };
    final response = await http.post(url, headers: headers, body: body);

    //- Kết quả -
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      _handleException(response.statusCode);
      return null;
    }
  }

  //- Tạo cache ----------------------------------------------------------------
  /// Creates cached content in the Gemini API.
  /// Returns the name of the created cache, or null if an error occurs.
  Future<String?> createCachedContent({
    required Content content,
    String? systemInstruction,
    Duration? ttl = const Duration(seconds: 3153600000),
  }) async {
    final url = Uri.parse('${_config.baseUrl.replaceFirst(_config.model, '')}v1beta/cachedContents?key=${_config.apiKey}');
    final headers = {
      'Content-Type': 'application/json',
    };
    final payload = <String, dynamic>{
      'contents': [content.toJson()],
    };
    if (systemInstruction != null) {
      payload['systemInstruction'] = {'parts': [{'text': systemInstruction}]};
    }
    if (ttl != null) {
      payload['ttl'] = '${ttl.inSeconds}s';
    }

    final body = jsonEncode(payload);

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseJson = jsonDecode(response.body) as Map<String, dynamic>;
        return responseJson['name'] as String?;
      } else {
        _handleException(response.statusCode);
        return null;
      }
    } catch (e) {
      throw Exception('Error creating cached content: $e');
    }
  }

  //- Xử lý content-------------------------------------------------------------------
  Content? _extractContentFromResponse(Map<String, dynamic> responseJson) {
    try {
      final content = Content.fromJson(responseJson['candidates'][0]['content'] as Map<String, dynamic>);
      return content;
    }
    catch (e) {
      throw Exception('Error extracting content from response: $e');
    }
  }

  //- Các tiện ích  ------------------------------------------------------------
  void clearChatHistory() {
    _chatHistory.clear();
  }

  //---------------------- Xử lý lỗi  ------------------------------------------
  void _handleException(int statusCode) {
    switch (statusCode) {
      case 400:
        throw BadRequestException();
      case 401:
        throw UnauthorizedException();
      case 403:
        throw ForbiddenException();
      case 404:
        throw NotFoundException();
      case 406:
        throw NotAcceptableException();
      case 429:
        throw TooManyRequestsException();
      case 500:
        throw InternalServerErrorException();
      case 502:
        throw BadGatewayException();
      case 503:
        throw ServiceUnavailableException();
      default:
        throw GemException('An unexpected API error occurred with status code: $statusCode');
    }
  }
}