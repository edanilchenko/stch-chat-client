class Message {
  final int id;
  final String content;
  final int userId;
  final String createdAt;

  Message({
    required this.id,
    required this.content,
    required this.userId,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      content: json['text'] as String,
      userId: json['user_id'] as int,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }
}
