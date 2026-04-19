import 'dart:async';

import 'package:flutter/material.dart';
import 'package:realtime_client/realtime_client.dart';

import '../../core/supabase_client.dart';
import '../../core/theme.dart';
import '../../models/message.dart';
import '../../services/messages_service.dart';
import '../../widgets/nuvelo_screen.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.threadId});

  final String threadId;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _msgs = MessagesService();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  List<Message> _items = [];
  RealtimeChannel? _channel;
  @override
  void initState() {
    super.initState();
    _load();
    _channel = _msgs.subscribeToMessages(widget.threadId, (m) {
      setState(() => _items.add(m));
      _scrollBottom();
    });
  }

  Future<void> _load() async {
    final rows = await _msgs.getMessages(widget.threadId);
    setState(() => _items = rows);
    _scrollBottom();
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  @override
  void dispose() {
    final ch = _channel;
    if (ch != null) {
      unawaited(ch.unsubscribe());
    }
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await _msgs.sendMessage(widget.threadId, text);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final uid = supabase.auth.currentUser?.id;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return NuveloScreen(
      safeTop: false,
      safeBottom: false,
      appBar: AppBar(title: const Text('Chat')),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _items.length,
              itemBuilder: (context, i) {
                final m = _items[i];
                final mine = m.senderId == uid;
                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.sizeOf(context).width * 0.82),
                    decoration: BoxDecoration(
                      color: mine
                          ? NuveloColors.primaryOrange
                          : NuveloColors.deepCard,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      m.body,
                      style: TextStyle(
                        color:
                            mine ? Colors.white : NuveloColors.textPrimary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 8, 12, 8 + bottom),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _input,
                    decoration: const InputDecoration(
                      hintText: 'Message…',
                    ),
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: NuveloColors.primaryOrange,
                  onPressed: _send,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
