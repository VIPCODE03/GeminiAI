import 'package:zent_gemini/gemini_config.dart';
import 'package:zent_gemini/gemini_service.dart';

void main() async {
  final config = GeminiConfig(
      apiKey: 'AIzaSyDuc_13fXJlfwVMc41N31ovULEmUeW1vgE',
      model: 'gemini-2.0-flash'
  ); // Hoặc model khác
  final geminiAI = GeminiAI(config);

  geminiAI.setSystemInstruction = 'Bạn tên là Triệu';

  try {
    String? response1 = await geminiAI.sendMessage('Bạn tên là gì, Tôi tên là Just');
    print('Model: $response1');

    String? response2 = await geminiAI.sendMessage('Tên của tôi có mấy chữ cái');
    print('Model: $response2');

  } catch (e) {
    print('Lỗi: $e');
  }
}