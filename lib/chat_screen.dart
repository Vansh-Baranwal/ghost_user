import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// UI Constants
const Color kSamsungGreen = Color(0xFFDCF8C6);
const Color kOutgoingChatBubble = Color(0xFFDCF8C6);
const Color kIncomingChatBubble = Colors.white;

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final String _chatId = 'demo_chat'; // Fixed for prototype

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;

    final text = _controller.text.trim();
    _controller.clear();

    // In a real app, ensure Firebase is initialized.
    // Here we just try to write to Firestore if available.
    try {
      await FirebaseFirestore.instance
          .collection('messages')
          .doc(_chatId)
          .collection('chats')
          .add({
        'text': text,
        'sender': 'user',
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Also update the 'typing' status trigger for the bot if needed handled by function
    } catch (e) {
      debugPrint("Error sending message: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 70,
        leading: InkWell(
          onTap: () {},
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
               Icon(Icons.arrow_back),
               CircleAvatar(
                 radius: 20,
                 backgroundColor: Colors.grey,
                 child: Icon(Icons.person, color: Colors.white),
               ),
            ],
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Rohan", style: TextStyle(fontSize: 18.5, fontWeight: FontWeight.bold)),
            // Status Header simulates the "Rohan" -> "Online" -> "Typing..." state
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('status').doc(_chatId).snapshots(),
              builder: (context, snapshot) {
                String status = "Online";
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null && data['status'] == 'typing') {
                    status = "Typing...";
                  } else {
                    status = "Online";
                  }
                }
                return Text(
                  status,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Colors.white70),
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                 image: DecorationImage(
                   image: NetworkImage("https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png"),
                   fit: BoxFit.cover,
                 ),
                 color: Color(0xFFECE5DD), // Fallback
              ),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(_chatId)
                    .collection('chats')
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data!.docs;
                  return ListView.builder(
                    reverse: true,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final isMe = data['sender'] == 'user';
                      return MessageBubble(
                        text: data['text'] ?? '',
                        isMe: isMe,
                        timestamp: data['timestamp'] as Timestamp?,
                      );
                    },
                  );
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      color: Colors.transparent,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 1)
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
                    onPressed: () {},
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Message",
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.openSans(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.attach_file, color: Colors.grey),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFF128C7E),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final Timestamp? timestamp;

  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // Format timestamp
    final timeStr = timestamp != null
        ? DateFormat('h:mm a').format(timestamp!.toDate())
        : DateFormat('h:mm a').format(DateTime.now());

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          decoration: BoxDecoration(
            color: isMe ? kOutgoingChatBubble : kIncomingChatBubble,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
               BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 1),
                  blurRadius: 1,
               )
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20, right: 10), // Space for time
                child: Text(
                  text,
                  style: GoogleFonts.openSans(
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  children: [
                    Text(
                      timeStr.toLowerCase(),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 3),
                      const Icon(Icons.done_all, size: 14, color: Colors.blue), // Blue ticks for read
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
