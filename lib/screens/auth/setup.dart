import 'dart:io';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetup> {
  final user = FirebaseAuth.instance.currentUser;
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  File? _profileImage;
  bool loading = false;

  Future<File> _compressImage(File file) async {
    final targetPath = '${file.path}_compressed.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality: 70,
    );
    return (result as File?) ?? file;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final compressed = await _compressImage(File(picked.path));
      setState(() {
        _profileImage = compressed;
      });
    }
  }

  Future<void> _submitProfile() async {
    if (_nameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      return;
    }
    if (loading) return;

    setState(() => loading = true);

    final currentUser = user;
    final uid = currentUser?.uid;
    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final goal = _goalController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();

    try {
      final userExists = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username)
          .get();

      if (userExists.docs.isNotEmpty) {
        if (mounted) {
          setState(() => loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username already taken.')),
          );
        }
        return;
      }

      String? photoURL;
      if (_profileImage != null) {
        final ref =
            FirebaseStorage.instance.ref().child('users/$uid/profile.jpg');
        await ref.putFile(_profileImage!);
        photoURL = await ref.getDownloadURL();
      }

      final userData = {
        'name': name,
        'username': username,
        'bio': bio,
        'goal': goal,
        'photoURL': photoURL,
        'uid': uid,
        'createdAt': Timestamp.now(),
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      debugPrint('Profile submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _buildNameAndImageStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: GestureDetector(
            onTap: _pickImage,
            child: CircleAvatar(
              radius: 50,
              backgroundImage:
                  _profileImage != null ? FileImage(_profileImage!) : null,
              child: _profileImage == null
                  ? const Icon(Icons.camera_alt, size: 40)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _nameController,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Full Name'),
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _usernameController,
          keyboardType: TextInputType.text,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
      ],
    );
  }

  Widget _buildBioStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        TextField(
          controller: _bioController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'Bio'),
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildGoalStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        TextField(
          controller: _goalController,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(labelText: 'What is your goal?'),
          maxLines: 3,
        ),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: _submitProfile,
          child: loading
              ? const CircularProgressIndicator()
              : const Text('Submit'),
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentPageIndex < 2) {
      setState(() => _currentPageIndex++);
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _bioController.dispose();
    _goalController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _currentPageIndex,
                children: [
                  _buildNameAndImageStep(theme),
                  _buildBioStep(),
                  _buildGoalStep(theme),
                ],
              ),
            ),
            if (_currentPageIndex < 2)
              ElevatedButton(
                onPressed: _nextStep,
                child: const Text('Next'),
              ),
          ],
        ),
      ),
    );
  }
}
