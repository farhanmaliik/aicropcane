
// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:framerapp/provider/community_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:framerapp/utils/appcolors.dart';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionCtrl = TextEditingController();
  File? _image;
  String _selectedCategory = 'Wheat';
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
    });
  }

  Future<void> _takePhoto() async {
    final XFile? picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1200, imageQuality: 80);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
    });
  }

  Future<void> _submit() async {
    if (_captionCtrl.text.trim().isEmpty && _image == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Add an image or caption')));
      return;
    }

    setState(() => _isPosting = true);

    
    final newPost = Post(
      id: const Uuid().v4(),
      username: 'You', 
      avatarUrl: '',
      caption: _captionCtrl.text.trim(),
      category: _selectedCategory,
      createdAt: DateTime.now(),
      imageFile: _image,
      likes: 0,
      comments: 0,
    );

    await Future.delayed(const Duration(milliseconds: 300)); 

    Provider.of<CommunityProvider>(context, listen: false).addPost(newPost);

    setState(() => _isPosting = false);

    
    Navigator.of(context).pop(_image);
  }

  @override
  Widget build(BuildContext context) {
    final filters = Provider.of<CommunityProvider>(context, listen: false).filters;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _submit,
            child: _isPosting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Post', style: TextStyle(fontWeight: FontWeight.w700)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _image == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add_a_photo_outlined, size: 36),
                            SizedBox(height: 8),
                            Text('Add photo')
                          ],
                        ),
                      )
                    : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_image!, fit: BoxFit.cover)),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                TextButton.icon(onPressed: _takePhoto, icon: const Icon(Icons.camera_alt), label: const Text('Camera')),
                const SizedBox(width: 8),
                TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo_library), label: const Text('Gallery')),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _captionCtrl,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Write a caption...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Select category', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: filters.map((f) {
                final active = _selectedCategory == f;
                return ChoiceChip(
                  label: Text(f),
                  selected: active,
                  onSelected: (_) => setState(() => _selectedCategory = f),
                  selectedColor: primaryColor.withOpacity(0.12),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isPosting ? null : _submit,
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _isPosting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Post', style: TextStyle(fontWeight: FontWeight.w800,color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
