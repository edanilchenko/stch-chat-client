import 'package:flutter/material.dart';
import './screens/chat_page.dart'; // <-- your ChatPage file

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat',
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    );
  }
}