import 'package:crud_operations/ui/screens/chat_screen/chat_list_screen.dart';
import 'package:crud_operations/ui/screens/home_screen/home_screen.dart';
import 'package:crud_operations/ui/screens/profile_screen/profile_screen.dart';
import 'package:crud_operations/ui/utils/transition.dart';
import 'package:flutter/material.dart';

import '../../utils/notifications_handler.dart';

class BottomScreen extends StatefulWidget {
  const BottomScreen({super.key});
  @override
  State<BottomScreen> createState() => _BottomScreenState();
}

class _BottomScreenState extends State<BottomScreen> with Transitions {
  int selectedIndex = 0;
  NotificationsHandler obj = NotificationsHandler();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    obj.setupFCM();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: [HomeScreen(), ChatListScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.white,
          primaryColor: Colors.white,
          textTheme: Theme.of(
            context,
          ).textTheme.copyWith(bodySmall: const TextStyle(color: Colors.white)),
        ),
        child: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_rounded),
              label: "Users",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: "Profile",
            ),
          ],
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          elevation: 3,
          backgroundColor: Colors.white,
          onTap: (int val) {
            selectedIndex = val;
            setState(() {});
          },
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
        ),
      ),
      drawer: Container(width: 200, color: Colors.blue),
    );
  }
}
