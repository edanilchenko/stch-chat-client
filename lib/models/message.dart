class Message {
  final String text;
  final String sender;

  Message({required this.text, required this.sender});

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'],
      sender: json['sender'],
    );
  }
}