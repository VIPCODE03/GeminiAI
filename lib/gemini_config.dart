
class GeminiConfig {
  /// API key để xác thực với Gemini API.
  final String apiKey;

  /// Tên model Gemini bạn muốn sử dụng.
  /// Ví dụ: 'gemini-pro'
  final String model;

  /// Base URL của Gemini API.
  /// Ví dụ sau khi khởi tạo: 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro'
  final String baseUrl;

  /// Hàm khởi tạo cho class GeminiConfig.
  /// [apiKey] là API key của bạn.
  /// [model] là tên model Gemini bạn muốn sử dụng.
  GeminiConfig({required this.apiKey, required this.model})
      : baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/$model';
}