import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../styles/colors.dart';
import 'chat_ia_style.dart';

class ChatIaScreen extends StatefulWidget {
  const ChatIaScreen({super.key});

  @override
  State<ChatIaScreen> createState() => _ChatIaScreenState();
}

class _ChatIaScreenState extends State<ChatIaScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {
      'role': 'assistant',
      'text':
          '¡Hola! Soy tu asistente de Reciclin-Point. Pregúntame lo que quieras sobre reciclaje y cuidado ambiental. 🌍♻️',
    },
  ];
  bool _isLoading = false;

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });

    _controller.clear();

    try {
      final url = Uri.parse('http://192.168.100.8:3333/api/chat');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'mensaje': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messages.add({
            'role': 'assistant',
            'text': data['respuesta'] ?? 'Sin respuesta.',
          });
        });
      } else {
        setState(() {
          _messages.add({
            'role': 'assistant',
            'text': 'Upps, no pude procesar eso. Revisa el backend.',
          });
        });
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Error de conexión con el servidor.',
        });
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistente Ambiental IA'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: ChatStyles.screenPadding,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: ChatStyles.bubbleMargin,
                    padding: ChatStyles.bubblePadding,
                    decoration: BoxDecoration(
                      color: isUser ? ChatStyles.userBubble : ChatStyles.assistantBubble,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(ChatStyles.bubbleRadius),
                        topRight: const Radius.circular(ChatStyles.bubbleRadius),
                        bottomLeft: isUser
                            ? const Radius.circular(ChatStyles.bubbleRadius)
                            : const Radius.circular(0),
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(ChatStyles.bubbleRadius),
                      ),
                    ),
                    child: Text(
                      msg['text'] ?? '',
                      style: const TextStyle(
                        fontSize: ChatStyles.messageFontSize,
                        color: ChatStyles.messageText,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: ChatStyles.loadingPadding,
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          Padding(
            padding: ChatStyles.inputPadding,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Pregúntame sobre materiales...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(ChatStyles.inputRadius),
                      ),
                      contentPadding: ChatStyles.inputContentPadding,
                    ),
                  ),
                ),
                const SizedBox(width: ChatStyles.inputGap),
                IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: () => _sendMessage(_controller.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
