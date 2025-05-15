import 'dart:io';
import 'package:bloom/provider/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class Editprofile extends StatefulWidget {
  const Editprofile({super.key});

  @override
  State<Editprofile> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<Editprofile> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _nameController;
  File? _imageFile;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _usernameController = TextEditingController(text: user?.username ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    super.initState();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<bool> _isUsernameTaken(String username) async {
    final user = FirebaseAuth.instance.currentUser!;
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return false;
    return query.docs.first.id != user.uid; // allow own username
  }

  Future<String?> _uploadProfilePic(String uid) async {
    if (_imageFile == null) return null;
    final ref = FirebaseStorage.instance.ref().child('profile_pics/$uid.jpg');
    await ref.putFile(_imageFile!);
    return await ref.getDownloadURL();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    final username = _usernameController.text.trim();
    final bio = _bioController.text.trim();
    final currentUser = FirebaseAuth.instance.currentUser!;
    final user = Provider.of<UserProvider>(context, listen: false).user;

    try {
      // Only check for username taken if the username was changed
      if (username != user?.username && await _isUsernameTaken(username)) {
        setState(() {
          _error = "Username already taken.";
        });
        return;
      }

      final photoUrl = await _uploadProfilePic(currentUser.uid);

      final updates = {
        'username': username,
        'bio': bio,
        if (photoUrl != null) 'photoUrl': photoUrl,
      };

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update(updates);

      if (!mounted) return;
      // Refresh provider
      await Provider.of<UserProvider>(context, listen: false).fetchUserData();
      if (!mounted) return;
      context.pop();
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_error != null)
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        CircleAvatar(
                          radius: 25,
                          backgroundImage: _imageFile != null
                              ? FileImage(_imageFile!)
                              : (user?.photoURL != null
                                  ? NetworkImage(user!.photoURL!)
                                  : null) as ImageProvider?,
                          child: _imageFile == null && user?.photoURL == null
                              ? const Icon(Icons.person, size: 25)
                              : null,
                        ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: const Text('Change profile photo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: "Name",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        contentPadding: EdgeInsets.all(20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Name is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _usernameController,
                      decoration: const InputDecoration(
                        labelText: "Username",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        contentPadding: EdgeInsets.all(20),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return "Username required";
                        }
                        if (val.length < 3) return "Username too short";
                        if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(val)) {
                          return "Only letters, numbers, dot or underscore";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _bioController,
                      decoration: const InputDecoration(
                        labelText: "Bio",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                        ),
                        contentPadding: EdgeInsets.all(20),
                      ),
                      maxLines: 3,
                      maxLength: 150,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save),
                      label: const Text("Save"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
