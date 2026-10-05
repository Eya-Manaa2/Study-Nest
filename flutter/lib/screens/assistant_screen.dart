import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
import '../config.dart';
import '../app_provider.dart';
import '../models.dart';

class ChatMessage {
  final String role; // 'user' or 'assistant'
  final String content;

  ChatMessage({required this.role, required this.content});
}

class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  final SpeechToText _speechToText = SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  final List<String> _suggestions = [
    'Explique-moi le concept de...',
    'Résume ce document',
    'Crée un quiz sur...',
    'Aide-moi à planifier mes révisions',
  ];

  List<String> _buildSuggestions(AppState state) {
    final subjectNames = state.subjects.map((s) => s.name).take(3).toList();
    if (subjectNames.isEmpty) {
      return _suggestions;
    }

    final contextual = [
      'Crée un quiz sur ${subjectNames.first}',
      'Résume ma matière ${subjectNames.first}',
      'Planifie mes révisions pour ${subjectNames.first}',
      'Explique-moi les points clés de ${subjectNames.first}',
    ];

    return contextual;
  }

  Future<void> _generateQuiz(String topic) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/chat?action=quiz&_topic=${Uri.encodeComponent(topic)}&count=5'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final quizTitle = data['title'] ?? 'Quiz';
        final questions = data['questions'] as List;
        
        String quizText = '# $quizTitle\n\n';
        for (var i = 0; i < questions.length; i++) {
          final q = questions[i];
          quizText += '**${i + 1}. ${q['question']}**\n\n';
          final options = q['options'] as List;
          for (var j = 0; j < options.length; j++) {
            quizText += '- ${options[j]}\n';
          }
          if (q['explanation'] != null && q['explanation'].isNotEmpty) {
            quizText += '\n*Explication: ${q['explanation']}*\n\n';
          } else {
            quizText += '\n';
          }
        }

        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(role: 'assistant', content: quizText));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Erreur serveur: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur de connexion: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _summarizeText(String text) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/chat?action=summarize&_topic=${Uri.encodeComponent(text)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['title'] ?? 'Résumé';
        final mainPoints = data['mainPoints'] as List;
        final keyConcepts = data['keyConcepts'] as List;
        final summary = data['summary'] ?? '';
        
        String summaryText = '# $title\n\n';
        summaryText += '**Résumé:**\n$summary\n\n';
        
        summaryText += '**Points clés:**\n';
        for (var point in mainPoints) {
          summaryText += '- $point\n';
        }
        
        if (keyConcepts.isNotEmpty) {
          summaryText += '\n**Concepts clés:**\n\n';
          for (var concept in keyConcepts) {
            summaryText += '**${concept['concept']}**\n';
            summaryText += '*Définition:* ${concept['definition']}\n';
            if (concept['example'] != null) {
              summaryText += '*Exemple:* ${concept['example']}\n';
            }
            summaryText += '\n';
          }
        }

        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(role: 'assistant', content: summaryText));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Erreur serveur: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur de connexion: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createRevisionPlan(String subject) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.apiBaseUrl}/api/chat?action=plan&_topic=${Uri.encodeComponent(subject)}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final title = data['title'] ?? 'Plan de révision';
        final totalWeeks = data['totalWeeks'] ?? 4;
        final milestones = data['milestones'] as List;
        final dailySchedule = data['dailySchedule'] as Map;
        final tips = data['tips'] as List;
        
        String planText = '# $title\n\n';
        planText += '**Durée totale:** $totalWeeks semaines\n\n';
        
        planText += '## 📅 Planning hebdomadaire\n\n';
        for (var milestone in milestones) {
          planText += '**Semaine ${milestone['week']}: ${milestone['title']}**\n';
          planText += '- Sujets: ${(milestone['topics'] as List).join(', ')}\n';
          planText += '- Tâches: ${(milestone['tasks'] as List).join(', ')}\n';
          planText += '- Temps estimé: ${milestone['estimatedHours']}h\n\n';
        }
        
        planText += '## ⏰ Planning quotidien\n\n';
        final days = {
          'monday': 'Lundi',
          'tuesday': 'Mardi',
          'wednesday': 'Mercredi',
          'thursday': 'Jeudi',
          'friday': 'Vendredi',
          'saturday': 'Samedi',
          'sunday': 'Dimanche'
        };
        for (var entry in dailySchedule.entries) {
          planText += '**${days[entry.key] ?? entry.key}:** ${entry.value}\n';
        }
        
        if (tips.isNotEmpty) {
          planText += '\n## 💡 Conseils\n\n';
          for (var tip in tips) {
            planText += '- $tip\n';
          }
        }

        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(role: 'assistant', content: planText));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Erreur serveur: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur de connexion: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) setState(() {});
  }

  void _startListening() async {
    final status = await Permission.microphone.request();
    if (status.isGranted) {
      await _speechToText.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _controller.text = result.recognizedWords;
          });
        },
        listenOptions: SpeechListenOptions(
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: 'fr_FR',
        ),
      );
      if (mounted) {
        setState(() => _isListening = true);
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Permission microphone requise')),
      );
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(role: 'user', content: text));
      _isLoading = true;
      _error = null;
    });

    _controller.clear();

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.apiBaseUrl}/api/chat/plain'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'messages': [
          {'role': 'user', 'content': text}
        ]}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _messages.add(ChatMessage(role: 'assistant', content: data['text'] ?? 'Réponse non disponible'));
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Erreur serveur: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Erreur de connexion: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final t = appState.theme;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        title: const Text('NestIA'),
        backgroundColor: t.bg,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _messages.isEmpty ? null : () => setState(() => _messages.clear()),
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Nouvelle conversation',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState(t)
                : _buildChatList(t),
          ),
          if (_error != null) _buildErrorBanner(),
          _buildInputArea(t),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppThemeDef t) {
    final suggestions = _buildSuggestions(ref.watch(appProvider));

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.psychology,
            size: 80,
            color: t.accent.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'NestIA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: t.textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Votre assistant d\'étude IA',
            style: TextStyle(
              fontSize: 14,
              color: t.muted,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: t.line),
            ),
            child: Row(
              children: [
                Icon(Icons.support_agent_rounded, size: 18, color: t.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Support : eyamanaa3@gmail.com',
                    style: TextStyle(fontSize: 12.5, color: t.textColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...suggestions.map((suggestion) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: InkWell(
                  onTap: () => _sendMessage(suggestion),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: t.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 20, color: t.accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            suggestion,
                            style: TextStyle(color: t.textColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildChatList(AppThemeDef t) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isLoading) {
          return _buildTypingIndicator(t);
        }

        final message = _messages[index];
        final isUser = message.role == 'user';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment:
                isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isUser) ...[
                CircleAvatar(
                  backgroundColor: t.accent,
                  child: const Icon(Icons.psychology, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isUser ? t.accent : t.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: isUser
                      ? Text(
                          message.content,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        )
                      : MarkdownBody(
                          data: message.content,
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(color: t.textColor, fontSize: 14),
                            h1: TextStyle(color: t.textColor, fontSize: 20, fontWeight: FontWeight.bold),
                            h2: TextStyle(color: t.textColor, fontSize: 18, fontWeight: FontWeight.bold),
                            h3: TextStyle(color: t.textColor, fontSize: 16, fontWeight: FontWeight.bold),
                            listBullet: TextStyle(color: t.accent),
                            code: TextStyle(
                              backgroundColor: t.surface2,
                              color: t.textColor,
                              fontFamily: 'monospace',
                            ),
                            codeblockDecoration: BoxDecoration(
                              color: t.surface2,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tableHead: TextStyle(color: t.textColor, fontWeight: FontWeight.bold),
                            tableBody: TextStyle(color: t.textColor),
                            tableBorder: TableBorder.all(
                              color: t.line,
                              width: 1,
                            ),
                            tableCellsPadding: const EdgeInsets.all(8),
                            tableColumnWidth: const FlexColumnWidth(),
                          ),
                        ),
                ),
              ),
              if (isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: t.accent.withValues(alpha: 0.3),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator(AppThemeDef t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: t.accent,
            child: const Icon(Icons.psychology, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildDot(t),
                const SizedBox(width: 4),
                _buildDot(t),
                const SizedBox(width: 4),
                _buildDot(t),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(AppThemeDef t) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: t.muted,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.red.shade50,
      child: Row(
        children: [
          Icon(Icons.error, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Erreur: $_error',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
          TextButton(
            onPressed: () {
              setState(() => _error = null);
            },
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(AppThemeDef t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              if (_speechEnabled)
                IconButton(
                  onPressed: _isListening ? _stopListening : _startListening,
                  icon: Icon(
                    _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                    color: _isListening ? t.accent : t.muted,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: _isListening 
                        ? t.accent.withValues(alpha: 0.2)
                        : t.surface,
                    padding: const EdgeInsets.all(8),
                  ),
                  constraints: const BoxConstraints(),
                ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Posez votre question...',
                    filled: true,
                    fillColor: t.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: _sendMessage,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _isLoading
                    ? null
                    : () => _sendMessage(_controller.text),
                icon: Icon(
                  Icons.send,
                  color: t.accent,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: t.accent.withValues(alpha: 0.1),
                  padding: const EdgeInsets.all(8),
                ),
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Quick action buttons
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                TextButton.icon(
                  onPressed: _isLoading ? null : () {
                    final topic = _controller.text.trim();
                    if (topic.isNotEmpty) {
                      _generateQuiz(topic);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entrez un sujet pour générer un quiz')),
                      );
                    }
                  },
                  icon: Icon(Icons.quiz_rounded, size: 18, color: t.accent),
                  label: Text('Générer un quiz', style: TextStyle(color: t.accent, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _isLoading ? null : () {
                    final text = _controller.text.trim();
                    if (text.isNotEmpty) {
                      _summarizeText(text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entrez un texte à résumer')),
                      );
                    }
                  },
                  icon: Icon(Icons.summarize_rounded, size: 18, color: t.accent),
                  label: Text('Résumer', style: TextStyle(color: t.accent, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: _isLoading ? null : () {
                    final subject = _controller.text.trim();
                    if (subject.isNotEmpty) {
                      _createRevisionPlan(subject);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Entrez un sujet pour créer un plan')),
                      );
                    }
                  },
                  icon: Icon(Icons.event_note_rounded, size: 18, color: t.accent),
                  label: Text('Plan de révision', style: TextStyle(color: t.accent, fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
