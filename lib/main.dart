import 'package:flutter/material.dart';

void main() => runApp(OCIQBot());

class OCIQBot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OC IQ Bot',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final List<Map<String,String>> _messages = [
    {"role":"bot","text":"Hi! I'm OC IQ Bot 🤖 How can I help you today?"}
  ];

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"role":"user","text":_controller.text});
      _messages.add({"role":"bot","text":"You said: ${_controller.text}. (OC IQ Bot is working!)"});
    });
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("OC IQ Bot")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (c,i){
                final m = _messages[i];
                final isUser = m["role"]=="user";
                return Align(
                  alignment: isUser?Alignment.centerRight:Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.all(8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser?Colors.deepPurple[100]:Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(m["text"]!),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: InputDecoration(hintText: "Type a message...", border: OutlineInputBorder()))),
                SizedBox(width:8),
                IconButton(icon: Icon(Icons.send), onPressed: _send)
              ],
            ),
          )
        ],
      ),
    );
  }
}
