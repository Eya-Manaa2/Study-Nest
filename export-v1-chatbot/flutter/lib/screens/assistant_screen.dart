import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../app_provider.dart';
import '../config.dart';

/// Un message dans la conversation avec l'assistant.
class ChatMessage {
  final String role; // 'user' | 'assistant'
  final String text;
  const ChatMessage({required this.role, required this.text});
}

const _suggestions = [
  'Explique-moi les matrices simplement',
  'Crée un quiz de 5 questions sur Maxwell',
  'Résume le tri fusion en 3 points',
  'Fais-moi un planning de révision sur 1 semaine',
];

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  bool _busy = false;
  bool _error = false;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send(String raw) async {
    final text = raw.trim();
    if (text.isEmpty || _busy) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', text: text));
      _busy = true;
      _error = false;
      _controller.clear();
    });
    _scrollToEnd();

    try {
      final history = _messages
          .map((m) => {'role': m.role, 'content': m.text})
          .toList();

      final res = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/chat/plain'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': history}),
      );

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}');
      }

      final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      final reply = (data['text'] as String?)?.trim() ?? '';

      setState(() {
        _messages.add(ChatMessage(
          role: 'assistant',
          text: reply.isEmpty ? 'Je n\'ai pas de réponse pour le moment.' : reply,
        ));
        _busy = false;
      });
      _scrollToEnd();
    } catch (_) {
      setState(() {
        _busy = false;
        _error = true;
      });
      _scrollToEnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(appProvider).theme;

    return Scaffold(
      backgroundColor: t.bg,
      body: Column(
        children: [
          _AppBar(theme: t, busy: _busy),
          Expanded(
            child: _messages.isEmpty
                ? _EmptyState(theme: t, onPick: _send)
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    itemCount: _messages.length + (_busy ? 1 : 0) + (_error ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i < _messages.length) {
                        return _Bubble(theme: t, message: _messages[i]);
                      }
                      if (_busy && i == _messages.length) {
                        return _TypingBubble(theme: t);
                      }
                      return _ErrorBanner(theme: t, onRetry: () {
                        final lastUser = _messages.lastWhere(
                          (m) => m.role == 'user',
                          orElse: () => const ChatMessage(role: 'user', text: ''),
                        );
                        if (lastUser.text.isNotEmpty) {
                          _send(lastUser.text);
                        }
                      });
                    },
                  ),
          ),
          _Composer(
            theme: t,
            controller: _controller,
            busy: _busy,
            onSend: () => _send(_controller.text),
          ),
        ],
      ),
    );
  }
}

// ─── App bar ───────────────────────────────────────────────────────────────

class _AppBar extends StatelessWidget {
  final dynamic theme;
  final bool busy;
  const _AppBar({required this.theme, required this.busy});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.line, width: 1)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: t.accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.psychology_alt_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('NestIA',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: t.textColor,
                      )),
                  Text(busy ? 'écrit…' : 'Ton assistant d\'étude',
                      style: TextStyle(fontSize: 12, color: t.muted)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final dynamic theme;
  final void Function(String) onPick;
  const _EmptyState({required this.theme, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: t.surface2,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(Icons.psychology_alt_rounded, color: t.accent, size: 32),
            ),
            const SizedBox(height: 16),
            Text('Pose-moi une question',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: t.textColor,
                )),
            const SizedBox(height: 6),
            Text(
              'Je peux expliquer un cours, résumer un texte, créer un quiz ou t\'aider à planifier tes révisions.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: t.muted, height: 1.5),
            ),
            const SizedBox(height: 24),
            ..._suggestions.map((s) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Material(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => onPick(s),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: t.line),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                          child: Text(s,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: t.textColor,
                              )),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

// ─── Bubbles ─────────────────────────────────────────────────────────────────

class _Bubble extends StatelessWidget {
  final dynamic theme;
  final ChatMessage message;
  const _Bubble({required this.theme, required this.message});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final isUser = message.role == 'user';
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          color: isUser ? t.accent : t.surface,
          border: isUser ? null : Border.all(color: t.line),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isUser ? 18 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 18),
          ),
        ),
        child: Text(
          message.text,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isUser ? Colors.white : t.textColor,
          ),
        ),
      ),
    );
  }
}

class _TypingBubble extends StatelessWidget {
  final dynamic theme;
  const _TypingBubble({required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: SizedBox(
          width: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(
              3,
              (_) => Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: t.muted, shape: BoxShape.circle),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final dynamic theme;
  final VoidCallback onRetry;
  const _ErrorBanner({required this.theme, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      margin: const EdgeInsets.only(top: 4, bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text('Impossible de joindre l\'assistant',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: t.textColor,
              )),
          const SizedBox(height: 4),
          Text(
            'Vérifie ta connexion et la configuration du service IA, puis réessaie.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: t.muted, height: 1.4),
          ),
          const SizedBox(height: 10),
          Material(
            color: t.accent,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: onRetry,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                child: const Text('Réessayer',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Composer ────────────────────────────────────────────────────────────────

class _Composer extends StatelessWidget {
  final dynamic theme;
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;
  const _Composer({
    required this.theme,
    required this.controller,
    required this.busy,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.line, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  minLines: 1,
                  maxLines: 5,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  style: TextStyle(fontSize: 14, color: t.textColor),
                  decoration: InputDecoration(
                    hintText: 'Écris ton message…',
                    hintStyle: TextStyle(color: t.muted),
                    filled: true,
                    fillColor: t.bg,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: t.line),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: t.line),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide(color: t.accent, width: 1.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: t.accent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: busy ? null : onSend,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
