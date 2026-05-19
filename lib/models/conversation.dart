import 'message.dart';
import 'user.dart';

class Conversation {
  final int id;
  final User otherUser;
  final Message? lastMessage;
  final DateTime createdAt;

  Conversation({
    required this.id,
    required this.otherUser,
    this.lastMessage,
    required this.createdAt,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'] as int,
      otherUser: User.fromJson(json['other_user'] as Map<String, dynamic>),
      lastMessage: json['last_message'] != null
          ? Message.fromJson(json['last_message'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
