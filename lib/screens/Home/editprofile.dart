import 'dart:io';

import 'package:bloom/modals/user_modal.dart';
import 'package:bloom/provider/user_provider.dart';
import 'package:bloom/repo/user_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

final userProfileRepositoryProvider =
    Provider((ref) => UserProfileRepository());

final userProfileProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserModel?>>(
        (ref) => UserProfileNotifier(ref.watch(userProfileRepositoryProvider)));

class EditProfile extends ConsumerStatefulWidget {
  const EditProfile({super.key});

  @override
  ConsumerState<EditProfile> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfile> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();

  File? _imageFile;
  bool _loading = false;
  String? _error;
  bool _initialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<bool> _isUsernameTaken(String username, String currentUid) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return false;
    return query.docs.first.id != currentUid;
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
    final name = _nameController.text.trim();
    final userAsync = ref.read(userProfileProvider);
    final user = userAsync.asData?.value;

    if (user == null) {
      setState(() {
        _error = "User data not loaded yet.";
        _loading = false;
      });
      return;
    }

    final currentUserUid = FirebaseAuth.instance.currentUser!.uid;

    try {
      if (username != user.username &&
          await _isUsernameTaken(username, currentUserUid)) {
        setState(() {
          _error = "Username already taken.";
          _loading = false;
        });
        return;
      }

      final photoURL = await _uploadProfilePic(currentUserUid);

      final updatedUser = user.copyWith(
        name: name,
        username: username,
        bio: bio,
        photoURL: photoURL ?? user.photoURL,
      );

      await ref.read(userProfileProvider.notifier).updateUser(updatedUser);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully")),
      );
      context.pop();
    } catch (e) {
      setState(() {
        _error = "Failed to update profile. Please try again.";
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text("Error loading profile: $error")),
        data: (user) {
          if (!_initialized && user != null) {
            _nameController.text = user.name;
            _usernameController.text = user.username ?? '';
            _bioController.text = user.bio ?? '';
            _initialized = true;
          }

          return _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (_error != null)
                          Text(_error!,
                              style: const TextStyle(color: Colors.red)),
                        const SizedBox(height: 10),
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (user?.photoURL != null
                                      ? NetworkImage(user!.photoURL!)
                                      : null) as ImageProvider<Object>?,
                              child:
                                  _imageFile == null && user?.photoURL == null
                                      ? const Icon(Icons.person, size: 50)
                                      : null,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loading ? null : _pickImage,
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                            contentPadding: EdgeInsets.all(20),
                          ),
                          validator: (val) => val == null || val.trim().isEmpty
                              ? "Name is required"
                              : null,
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: "Username",
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
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
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25)),
                            ),
                            contentPadding: EdgeInsets.all(20),
                          ),
                          maxLines: 3,
                          maxLength: 150,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton.icon(
                          onPressed: _loading ? null : _saveProfile,
                          icon: const Icon(Icons.save),
                          label: const Text("Save"),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
