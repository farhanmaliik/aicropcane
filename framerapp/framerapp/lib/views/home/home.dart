

import 'package:flutter/material.dart';
import 'package:framerapp/chatBot/chat_bot.dart';
import 'package:framerapp/views/Community/community_screen.dart';
import 'package:framerapp/views/homescreen/homescreen.dart';
import 'package:framerapp/views/profile/profilescreen.dart';
import 'package:framerapp/chatBot/chat_bot.dart';

import '../../utils/appcolors.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentIndex = 0;
  final screens = [
    const HomeScreen(),
    ChatBot(),
    CommunityScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.grass,
              color: currentIndex == 0 ? primaryColor : Colors.grey[600],
            ),
            label: "Your crops",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.smart_toy_outlined,
              color: currentIndex == 1 ? primaryColor : Colors.grey[600],
            ),
            label: "ChatBot",
          ),

          BottomNavigationBarItem(
            icon: Icon(
              Icons.chat_bubble_outline,
              color: currentIndex == 2 ? primaryColor : Colors.grey[600],
            ),
            label: "Community",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.person_outline,
              color: currentIndex == 3 ? primaryColor : Colors.grey[600],
            ),
            label: "You",
          ),
        ],
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 12,
          color: Colors.grey[600],
        ),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
      ),
    );
  }
}
