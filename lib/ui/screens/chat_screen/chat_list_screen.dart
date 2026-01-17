import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_operations/ui/screens/chat_screen/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final currentUid = FirebaseAuth.instance.currentUser!.uid;
  Stream<QuerySnapshot> chatListStream() {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUid)
        .orderBy('lastTimestamp', descending: true)
        .snapshots();
  }

  String getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chats')),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatListStream(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var currentList = snapshot.data!.docs;
          var currentUid = FirebaseAuth.instance.currentUser!.uid;
          return ListView.builder(
            itemCount: currentList.length,
            itemBuilder: (context, index) {
              var chat = currentList[index];
              List listUser = chat['participants'];
              String otherUid = listUser.firstWhere((uid) => uid != currentUid);
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(otherUid)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return SizedBox();
                  var user = userSnapshot.data!;
                  final avatarLetter = user['fullName'].isNotEmpty
                      ? user['fullName'].trim()[0].toUpperCase()
                      : 'U';
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 30,
                      child: Text(
                        avatarLetter,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(user['fullName'] ?? 'Unknown'),
                    subtitle: Text(chat['lastMessage'] ?? ''),
                    trailing: Text(
                      chat['lastTimestamp'] != null
                          ? TimeOfDay.fromDateTime(
                              (chat['lastTimestamp'] as Timestamp).toDate(),
                            ).format(context)
                          : '',
                      style: TextStyle(fontSize: 12),
                    ),
                    onTap: () {
                      final chatId = getChatId(
                        FirebaseAuth.instance.currentUser!.uid,
                        user.id,
                      );
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            chatId: chatId,
                            receiverId: user.id,
                            receiverName: user['fullName'],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
