import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(OCIQApp());

class OCIQApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OC IQ Bot',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [
    {"role": "bot", "text": "Hi! I'm OC IQ Bot 🤖✨ Upgraded with real AI! Ask me anything!"}
  ];
  bool _isLoading = false;

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": text});
      _isLoading = true;
    });
    _controller.clear();

    try {
      // Using free Pollinations AI - no key needed!
      final response = await http.post(
        Uri.parse('https://text.pollinations.ai/openai'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "model": "openai",
          "messages": [
            {"role": "system", "content": "You are OC IQ Bot, a helpful, smart, friendly AI assistant created by OC. Answer concisely and helpfully."},
           ..._messages.where((m) => m['role']!= 'bot').map((m) => {"role": m['role'] == 'user'? 'user' : 'assistant', "content": m['text']}),
            {"role": "user", "content": text}
          ],
          "max_tokens": 500
        }),
      );

      String botReply;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        botReply = data['choices'][0]['message']['content'];
      } else {
        // Fallback simple API
        final fallback = await http.get(Uri.parse('https://text.pollinations.ai/${Uri.encodeComponent(text)}'));
        botReply = fallback.body;
      }

      setState(() {
        _messages.add({"role": "bot", "text": botReply});
      });
    } catch (e) {
      setState(() {
        _messages.add({"role": "bot", "text": "Error: $e\n\nTip: Check internet. I'm trying to connect to AI brain!"});
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OC IQ Bot - AI', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, i) {
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 6),
                    padding: EdgeInsets.all(14),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser? Colors.deepPurple.shade100 : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(msg['text']!, style: TextStyle(fontSize: 15)),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Padding(
              padding: EdgeInsets.all(8),
              child: Row(children: [CircularProgressIndicator(), SizedBox(width: 10), Text("OC IQ Bot is thinking...")]),
            ),
          Container(
            padding: EdgeInsets.all(8),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Ask OC IQ Bot anything...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(icon: Icon(Icons.send, color: Colors.white), onPressed: _sendMessage),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
