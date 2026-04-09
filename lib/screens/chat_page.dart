import 'package:flutter/material.dart';
import '../services/chat_service.dart';
import '../models/message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatService service = ChatService();
  final TextEditingController controller = TextEditingController();

  List<Message> messages = [];

  @override
  void initState() {
    super.initState();
    loadMessages();

    // polling every 2 seconds
    Future.doWhile(() async {
      await Future.delayed(Duration(seconds: 2));
      await loadMessages();
      return true;
    });
  }

  Future<void> loadMessages() async {
    final data = await service.fetchMessages();
    setState(() => messages = data);
  }

  void send() async {
    if (controller.text.isEmpty) return;

    await service.sendMessage(controller.text);
    controller.clear();
    loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: messages.map((m) {
                return Align(
                  alignment: m.sender == 'client'
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(5),
                    color: m.sender == 'client'
                        ? Colors.blue
                        : Colors.grey,
                    child: Text(m.text),
                  ),
                );
              }).toList(),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(controller: controller),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: send,
              )
            ],
          )
        ],
      ),
    );
  }
}