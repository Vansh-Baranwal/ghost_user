import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:intl/intl.dart';
import 'firebase_options.dart'; 

// ---------------------------------------------------------
// 🔑 TODO: PASTE YOUR API KEY BELOW (Don't keep the quotes if you don't need them, but usually String needs "")
// Get it from: https://aistudio.google.com/app/apikey
const String GEMINI_API_KEY = "AIzaSyAVYMFiCtLQrk4cjOq30JkOUI1TqV6O4jg"; 
// ---------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const GhostUserApp());
}

class GhostUserApp extends StatelessWidget {
  const GhostUserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rohan (Intern)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF075E54),
        scaffoldBackgroundColor: const Color(0xFFECE5DD), 
        useMaterial3: true,
      ),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  bool _isTyping = false;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // THE PERSONA: We make him strict here to ensure he acts right
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: GEMINI_API_KEY,
      systemInstruction: Content.system("""
        You are Rohan, a lazy Gen Z intern.
        1. Reply in 1 short sentence.
        2. Use lowercase and slang (lol, fr, idk).
        3. If asked for help, say 'google it' or 'busy rn'.
        4. Never admit you are an AI.
      """),
    );
    _chat = _model.startChat();
  }

  // 🗑️ FUNCTION TO CLEAR CHAT
  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  void _sendMessage() async {
    if (_controller.text.isEmpty) return;
    
    final userText = _controller.text;
    setState(() {
      _messages.add({"text": userText, "isUser": true, "time": DateTime.now()});
      _isTyping = true;
      _controller.clear();
    });
    
    // Auto-scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });

    try {
      // Fake human delay
      await Future.delayed(const Duration(seconds: 2));

      // AI Response
      final response = await _chat.sendMessage(Content.text(userText));
      final botText = response.text ?? "huh?";

      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({"text": botText, "isUser": false, "time": DateTime.now()});
        });
        
        // Scroll to bottom
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    } catch (e) {
      // 🚨 ERROR HANDLING: This tells us WHY he didn't reply
      setState(() => _isTyping = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF075E54),
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey, 
            child: Icon(Icons.person, color: Colors.white)
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Rohan (Intern)", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              _isTyping ? "typing..." : "Online", 
              style: const TextStyle(color: Colors.white70, fontSize: 12)
            ),
          ],
        ),
        actions: [
          // 🗑️ THE DELETE BUTTON
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: _clearChat,
            tooltip: "Clear Chat",
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              padding: const EdgeInsets.all(10),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment: msg['isUser'] ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: msg['isUser'] ? const Color(0xFFDCF8C6) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))]
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['text'],
                          style: GoogleFonts.openSans(fontSize: 15, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('hh:mm a').format(msg['time']),
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: "Message",
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF075E54),
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white, size: 20),
              onPressed: _sendMessage,
            ),
          )
        ],
      ),
    );
  }
}