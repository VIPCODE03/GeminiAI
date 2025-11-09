
class GeminiConfig {
  /// API key để xác thực với Gemini API.
  final String apiKey;

  /// Nhiều API key để xác thực với Gemini API.
  final List<String> apiKeys;

  /// Tên model Gemini bạn muốn sử dụng.
  /// Ví dụ: 'gemini-pro'
  final String model;

  /// Base URL của Gemini API.
  /// Ví dụ sau khi khởi tạo: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro'
  final String baseUrl;

  /// Hàm khởi tạo cho class GeminiConfig.
  /// [apiKey] là API key của bạn.
  /// [apiKeys] là danh sách các API key của bạn.
  /// [model] là tên model Gemini bạn muốn sử dụng.
  const GeminiConfig({
    required this.apiKey,
    this.apiKeys = const [],
    required this.model
  })
      : baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$model';
}