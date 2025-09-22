import 'package:flutter/material.dart';
import 'package:ai_chat_app/simple_gemini_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Chat App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  SimpleGeminiClient? _client;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    // ย้ายการเริ่มต้น client ไปที่ didChangeDependencies
    _initializeGemini();
  }

  // ย้ายโค้ดที่แสดง SnackBar ไปที่ didChangeDependencies
  void _initializeGemini() {
    const apiKey = 'AIzaSyCiaITOkFUPm5-oJxkGpmKFec-9hVOLFDc'; // ใส่ API Key ของคุณที่นี่

    if (apiKey.isEmpty) {
      return;
    }
    
    _client = SimpleGeminiClient(
      apiKey: apiKey,
      model: 'gemini-2.5-flash',
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // ตรวจสอบและแสดงข้อความแจ้งเตือนหลังจาก initState ทำงานเสร็จแล้ว
    if (_client == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showError('Please set a valid Gemini API key');
        }
      });
    }
  }

  void _showError(String message) {
    // ตรวจสอบว่า mounted หรือไม่ก่อนแสดง SnackBar
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty) return;
    
    _textController.clear();
    
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
      ));
      _isTyping = true;
    });
    
    if (_client == null) {
      _showError('Gemini client not initialized');
      setState(() {
        _isTyping = false;
      });
      return;
    }
    
    try {
      final response = await _client!.chat(
        text,
        systemPrompt: 'You are a helpful assistant. Be concise and friendly.',
      );
      
      // ตรวจสอบว่า widget ยังคงอยู่ใน tree หรือไม่
      if (!mounted) return;
      
      setState(() {
        _messages.add(ChatMessage(
          text: response,
          isUser: false,
        ));
        _isTyping = false;
      });
    } catch (e) {
      // ตรวจสอบว่า widget ยังคงอยู่ใน tree หรือไม่
      if (!mounted) return;
      
      _showError('Error getting AI response: $e');
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Chat App'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (_, index) => _messages[_messages.length - 1 - index],
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 8),
                  Text('AI is typing...'),
                ],
              ),
            ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
            ),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.primary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUser;

  const ChatMessage({
    super.key,
    required this.text,
    required this.isUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: isUser 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.secondary,
              child: Text(isUser ? 'You' : 'AI'),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUser ? 'You' : 'AI Assistant',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}