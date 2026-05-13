
import 'dart:io';
import 'package:flutter/material.dart';

class Post {
  final String id;
  final String username;
  final String avatarUrl; 
  final String caption;
  final String category;
  final DateTime createdAt;
  final File? imageFile;
  int likes;
  int comments;
  bool liked;

  Post({
    required this.id,
    required this.username,
    required this.avatarUrl,
    required this.caption,
    required this.category,
    required this.createdAt,
    this.imageFile,
    this.likes = 0,
    this.comments = 0,
    this.liked = false,
  });
}

class CommunityProvider extends ChangeNotifier {
  final List<Post> _posts = [
    Post(
      id: 'p1',
      username: 'Ali Khan',
      avatarUrl: '', 
      caption: 'Leaves showing yellow spots — any idea?',
      category: 'Wheat',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      likes: 12,
      comments: 4,
    ),
    Post(
      id: 'p2',
      username: 'Sara Ahmed',
      avatarUrl: '',
      caption: 'Early morning irrigation schedule — what works for you?',
      category: 'Rice',
      createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      likes: 21,
      comments: 6,
    ),
  ];

  String _searchQuery = '';
  String _activeFilter = 'All'; 

  List<String> get filters => ['All', 'Wheat', 'Rice', 'Tomato', 'Maize'];

  List<Post> get posts {
    var list = _posts.toList();
    if (_activeFilter != 'All') {
      list = list.where((p) => p.category == _activeFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.caption.toLowerCase().contains(q) || p.username.toLowerCase().contains(q)).toList();
    }
    
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  String get activeFilter => _activeFilter;

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void setSearch(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void addPost(Post post) {
    _posts.add(post);
    notifyListeners();
  }

  void toggleLike(String postId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    final p = _posts[idx];
    p.liked = !p.liked;
    p.likes += p.liked ? 1 : -1;
    notifyListeners();
  }

  void addComment(String postId) {
    final idx = _posts.indexWhere((p) => p.id == postId);
    if (idx == -1) return;
    _posts[idx].comments++;
    notifyListeners();
  }
}
