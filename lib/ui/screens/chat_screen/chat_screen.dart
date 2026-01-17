import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_operations/ui/screens/chat_screen/common_message_bubble.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String receiverId;
  final String receiverName;
  const ChatScreen({
    super.key,
    required this.chatId,
    required this.receiverId,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final _textFormField = TextEditingController();

  String? inputError;

  String formatTime(Timestamp timestamp) {
    DateTime date = timestamp.toDate();
    return DateFormat('hh:mm a').format(date);
  }

  void sendMessage() async {
    if (_textFormField.text.trim().isEmpty) return;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    await FirebaseFirestore.instance
        .collection("chats")
        .doc(widget.chatId)
        .collection("messages")
        .add({
          'text': _textFormField.text,
          'senderId': uid,
          'receiverId': widget.receiverId,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
          'type': 'text',
        });
    
    // Update lastMessage
    await FirebaseFirestore.instance.collection("chats").doc(widget.chatId).set(
      {
        'participants': [uid, widget.receiverId],
        'lastMessage': _textFormField.text,
        'lastTimestamp': FieldValue.serverTimestamp(),
      },
    );
    _textFormField.clear();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text(
                  widget.receiverName.trim()[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text(widget.receiverName),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _store
                    .collection('chats')
                    .doc(widget.chatId)
                    .collection('messages')
                    .orderBy('timestamp')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var message = snapshot.data!.docs;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      var msg = message[index];
                      bool isMe =
                          msg['senderId'] ==
                          FirebaseAuth.instance.currentUser!.uid;
                      return CommonMessageBubble(
                        isMe: isMe,
                        message: msg['text'],
                        time: msg['timestamp'] != null
                            ? formatTime(msg['timestamp'])
                            : '',
                      );
                    },
                    itemCount: message.length,
                    reverse: false,
                  );
                },
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textFormField,
                    decoration: InputDecoration(
                      hintText: 'chat.....',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      errorText: inputError,
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(width: 1, color: Colors.red),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    sendMessage();
                  },
                  icon: Icon(Icons.send_rounded),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
