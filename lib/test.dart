// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:file_picker/file_picker.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:zent_gemini/gemini_config.dart';
// import 'package:zent_gemini/gemini_service.dart';
//
// final config = GeminiConfig(
//   apiKey: 'AIzaSyDuc_13fXJlfwVMc41N31ovULEmUeW1vgE',
//   model: 'gemini-2.0-flash',
// );
//
// final geminiAI = GeminiAI(config);
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Gemini PDF Demo',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(useMaterial3: true),
//       home: const PdfUploadScreen(),
//     );
//   }
// }
//
// class PdfUploadScreen extends StatefulWidget {
//   const PdfUploadScreen({super.key});
//
//   @override
//   State<PdfUploadScreen> createState() => _PdfUploadScreenState();
// }
//
// class _PdfUploadScreenState extends State<PdfUploadScreen> {
//   final _controller = TextEditingController();
//   Uint8List? _selectedBytes;
//   String? _selectedFileName;
//   String _result = '';
//   bool _loading = false;
//
//   Future<void> _pickFile() async {
//     final result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//       withData: true, // Quan trọng để có dữ liệu trên Web
//     );
//
//     if (result != null && result.files.single.bytes != null) {
//       setState(() {
//         _selectedBytes = result.files.single.bytes!;
//         _selectedFileName = result.files.single.name;
//       });
//     }
//   }
//
//   Future<void> _sendToGemini() async {
//     if (_selectedBytes == null || _controller.text.isEmpty) return;
//
//     setState(() {
//       _loading = true;
//       _result = '';
//     });
//
//     try {
//       final result = await geminiAI.generateContent(Input.pdf(_controller.text, _selectedBytes!));
//       setState(() {
//         _result = result ?? 'Không có kết quả';
//         _loading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _result = 'Lỗi: $e';
//       });
//     } finally {
//       setState(() {
//         _loading = false;
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Gemini PDF Demo')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 labelText: 'Nhập prompt',
//                 border: OutlineInputBorder(),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: _pickFile,
//                   child: const Text('Chọn file PDF'),
//                 ),
//                 const SizedBox(width: 8),
//                 Expanded(
//                   child: Text(
//                     _selectedFileName ?? 'Chưa chọn file',
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton.icon(
//               onPressed: _loading ? null : _sendToGemini,
//               icon: const Icon(Icons.send),
//               label: const Text('Gửi'),
//             ),
//             const SizedBox(height: 16),
//             Expanded(
//               child: _loading
//                   ? const Center(child: CircularProgressIndicator())
//                   : SingleChildScrollView(
//                 child: Text(
//                   _result,
//                   style: const TextStyle(fontSize: 16),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
