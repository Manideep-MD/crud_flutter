import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_operations/source/local/hive_helper.dart';
import 'package:crud_operations/source/local/shared_pref_helper.dart';
import 'package:crud_operations/ui/screens/animation_screen.dart';
import 'package:crud_operations/ui/screens/chat_screen/chat_screen.dart';
import 'package:crud_operations/ui/screens/create_user_screen.dart';
import 'package:crud_operations/ui/utils/transition.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with Transitions {
  final _searchController = TextEditingController();
  final FirebaseFirestore _store = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var Version = '0.0.0';
  String searchText = '';

  handleDeleteUser(String userId) async {
    await _store.collection('users').doc(userId).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User deleted successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  getDeviceInfo() async {
    final info = await PackageInfo.fromPlatform();
    Version = info.version;
    setState(() {});
  }

  String getChatId(String uid1, String uid2) {
    return uid1.compareTo(uid2) < 0 ? '$uid1\_$uid2' : '$uid2\_$uid1';
  }

  Widget _buildUserCard(QueryDocumentSnapshot userDoc) {
    final data = userDoc.data() as Map<String, dynamic>;
    final fullName = (data['fullName'] ?? '').toString();
    final email = (data['email'] ?? '').toString();
    final avatarLetter = fullName.isNotEmpty
        ? fullName.trim()[0].toUpperCase()
        : 'U';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 30,
              child: Text(
                avatarLetter,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name & email
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Actions
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Edit (navigates to create/edit user screen)
                // IconButton(
                //   tooltip: 'Edit user',
                //   onPressed: () {
                //     Navigator.push(
                //       context,
                //       MaterialPageRoute(
                //         builder: (context) => CreateUserScreen(
                //           isEdit: true,
                //           name: data['fullName'] ?? '',
                //           email: data['email'] ?? '',
                //           mobile: data['mobile'] ?? '',
                //           id: userDoc.id,
                //         ),
                //       ),
                //     );
                //   },
                //   icon: const Icon(Icons.edit_outlined),
                // ),
                GestureDetector(
                  onTap: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => CreateUserScreen(
                    //       isEdit: true,
                    //       name: data['fullName'] ?? '',
                    //       email: data['email'] ?? '',
                    //       mobile: data['mobile'] ?? '',
                    //       id: userDoc.id,
                    //     ),
                    //   ),
                    // );
                    Navigator.push(
                      context,
                      slideUpAnimRoute(
                        CreateUserScreen(
                          isEdit: true,
                          name: data['fullName'] ?? '',
                          email: data['email'] ?? '',
                          mobile: data['mobile'] ?? '',
                          id: userDoc.id,
                        ),
                      ),
                    );
                  },
                  child: Hero(
                    tag: 'hero-box',
                    child: const Icon(Icons.edit_outlined),
                  ),
                ),

                // Chat
                IconButton(
                  tooltip: 'Chat',
                  onPressed: () {
                    final chatId = getChatId(
                      _auth.currentUser!.uid,
                      userDoc.id,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                          receiverId: userDoc.id,
                          receiverName: fullName,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline),
                  color: Colors.blue[700],
                ),

                // Delete
                IconButton(
                  tooltip: 'Delete user',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AnimationScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red[600],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getDeviceInfo();
    super.initState();
    print('SharedPrefHelper.userId');
    print(SharedPrefHelper.userId);
    print(',"hiveData---------->"');
    // print(HiveHelper.getData('id'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        elevation: 1,
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => searchText = val.trim()),
            ),
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(12),
        child: StreamBuilder<QuerySnapshot>(
          stream: searchText.isEmpty
              ? _store.collection('users').orderBy('fullName').snapshots()
              : _store
                    .collection('users')
                    .where(
                      'fullName',
                      isGreaterThanOrEqualTo: searchText,
                      isLessThan: searchText + '\uf8ff',
                    )
                    .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No users found.'));
            }

            final currentUserId = FirebaseAuth.instance.currentUser!.uid;
            final userList = snapshot.data!.docs
                .where((doc) => doc['id'] != currentUserId)
                .toList();

            return ListView.separated(
              itemCount: userList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final userDoc = userList[index];
                return _buildUserCard(userDoc);
              },
            );
          },
        ),
      ),
    );
  }
}
