class Content {
  final String role;
  final List<Map<String, dynamic>> parts;

  Content({required this.role, required this.parts});

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
}