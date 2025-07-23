// import 'dart:typed_data';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter/material.dart'; // để gọi WidgetsFlutterBinding
//
// import 'package:zent_gemini/gemini_config.dart';
// import 'package:zent_gemini/gemini_service.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized(); // 🔥 Thêm dòng này để kích hoạt rootBundle
//
//   final config = GeminiConfig(
//     apiKey: 'AIzaSyDuc_13fXJlfwVMc41N31ovULEmUeW1vgE',
//     model: 'gemini-2.0-flash',
//   );
//
//   final geminiAI = GeminiAI(config);
//   geminiAI.setSystemInstruction = 'Bạn tên là Triệu';
//
//   try {
//     final image = await loadImageFromAssets('assets/img.png');
//     String? response1 = await geminiAI.generateContent(Input(textPrompt: 'Đây là nhân vật nào', image: image));
//     print('Model: $response1');
//
//     final his = geminiAI.chatHistory;
//     his.forEach((e) => print(e.toJson()));
//   } catch (e) {
//     print('Lỗi: $e');
//   }
// }
// Future<Uint8List> loadImageFromAssets(String assetPath) async {
//   final byteData = await rootBundle.load(assetPath);
//   return byteData.buffer.asUint8List();
// }