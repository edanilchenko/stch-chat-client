import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/user.dart';
import '../services/api_service.dart';

class NewConversationScreen extends StatefulWidget {
  const NewConversationScreen({super.key});

  @override
  State<NewConversationScreen> createState() => _NewConversationScreenState();
}

class _NewConversationScreenState extends State<NewConversationScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;

  List<User> _results = [];
  bool _isSearching = false;
  bool _isStarting = false;
  String? _error;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _error = null;
        _isSearching = false;
      });
      return;
    }
    _debounce = Timer(
      const Duration(milliseconds: 300),
      () => _search(query.trim()),
    );
  }

  Future<void> _search(String query) async {
    setState(() {
      _isSearching = true;
      _error = null;
    });
    try {
      final results = await context.read<ApiService>().searchUsers(query);
      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isSearching = false;
          _hasSearched = true;
        });
      }
    }
  }

  Future<void> _startConversation(User user) async {
    setState(() => _isStarting = true);
    try {
      final conv = await context.read<ApiService>().startConversation(user.id);
      if (mounted) Navigator.pop(context, conv);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _isStarting = false);
      }
    }
  }

  Widget _buildBody() {
    if (_isStarting || _isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Text(_error!, style: const TextStyle(color: Colors.red)),
      );
    }
    if (!_hasSearched) {
      return const Center(child: Text('Search for people to message'));
    }
    if (_results.isEmpty) {
      return const Center(child: Text('No users found'));
    }
    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final user = _results[i];
        return ListTile(
          leading: CircleAvatar(
            child: Text(user.name[0].toUpperCase()),
          ),
          title: Text(user.name),
          subtitle: Text(user.email),
          onTap: () => _startConversation(user),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Conversation')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _onQueryChanged,
            ),
          ),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }
}
