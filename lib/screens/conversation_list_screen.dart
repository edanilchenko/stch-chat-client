import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/conversation.dart';
import '../providers/auth_provider.dart';
import '../providers/conversation_provider.dart';
import 'chat_screen.dart';
import 'new_conversation_screen.dart';

class ConversationListScreen extends StatefulWidget {
  const ConversationListScreen({super.key});

  @override
  State<ConversationListScreen> createState() => _ConversationListScreenState();
}

class _ConversationListScreenState extends State<ConversationListScreen> {
  late final ConversationProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = context.read<ConversationProvider>();
    _provider.addListener(_onProviderError);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadConversations();
    });
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderError);
    super.dispose();
  }

  String? _lastShownError;

  void _onProviderError() {
    final error = _provider.error;
    if (error != null && error != _lastShownError && mounted) {
      _lastShownError = error;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(error)));
    }
  }

  String _relativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  void _openChat(Conversation conversation) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(conversation: conversation)),
    ).then((_) {
      if (mounted) _provider.loadConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ConversationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _provider.loadConversations(),
        child: provider.isLoading && provider.conversations.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : provider.conversations.isEmpty
                ? const Center(child: Text('No conversations yet'))
                : ListView.separated(
                    itemCount: provider.conversations.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, i) => _ConversationTile(
                      conversation: provider.conversations[i],
                      relativeTime: _relativeTime,
                      onTap: () => _openChat(provider.conversations[i]),
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final conv = await Navigator.push<Conversation>(
            context,
            MaterialPageRoute(builder: (_) => const NewConversationScreen()),
          );
          if (conv != null && mounted) _openChat(conv);
        },
        child: const Icon(Icons.edit),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final String Function(DateTime) relativeTime;
  final VoidCallback onTap;

  const _ConversationTile({
    required this.conversation,
    required this.relativeTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lastMsg = conversation.lastMessage;
    return ListTile(
      leading: CircleAvatar(
        child: Text(conversation.otherUser.name[0].toUpperCase()),
      ),
      title: Text(conversation.otherUser.name),
      subtitle: Text(
        lastMsg?.text ?? 'No messages yet',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: lastMsg != null
          ? Text(
              relativeTime(lastMsg.createdAt),
              style: Theme.of(context).textTheme.bodySmall,
            )
          : null,
      onTap: onTap,
    );
  }
}
