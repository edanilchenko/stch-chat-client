import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversation.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  static final _users = [
    User(id: 2, name: 'Test2 User', email: 'test2@ex.com'),
    User(id: 3, name: 'Test3 User', email: 'test3@ex.com'),
  ];

  bool _loading = false;

  Future<void> _start(User user) async {
    setState(() => _loading = true);
    try {
      final Conversation conv =
          await context.read<ApiService>().startConversation(user.id);
      if (mounted) Navigator.pop(context, conv);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Conversation')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _users.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final user = _users[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(user.name[0].toUpperCase()),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  onTap: () => _start(user),
                );
              },
            ),
    );
  }
}
