
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class ChatProvider extends ChangeNotifier{

  List<String> _recentChat = [];

  List<String> get recentChat => _recentChat;

  void addChat(String chat){
    _recentChat.insert(0, chat);
    notifyListeners();
  }
}