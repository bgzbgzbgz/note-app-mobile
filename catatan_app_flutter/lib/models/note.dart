class Note {
  final String id;
  final String title;
  final String content;
  final String createdAt;
  final String updatedAt;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor untuk membuat objek Note dari JSON Map
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'].toString(), // API kita mengirim ID sebagai String
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}