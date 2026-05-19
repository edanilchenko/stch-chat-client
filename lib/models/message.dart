import 'user.dart';

class Message {
  final int id;
  final int conversationId;
  final int userId;
  final String text;
  final DateTime createdAt;
  final User? sender;

  Message({
    required this.id,
    required this.conversationId,
    required this.userId,
    required this.text,
    required this.createdAt,
    this.sender,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as int,
      conversationId: json['conversation_id'] as int,
      userId: json['user_id'] as int,
      text: json['text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      sender: json['sender'] != null
          ? User.fromJson(json['sender'] as Map<String, dynamic>)
          : null,
    );
  }
}
