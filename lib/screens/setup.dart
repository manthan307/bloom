import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> requestStoragePermission() async {
  final deviceInfo = DeviceInfoPlugin();
  final androidInfo = await deviceInfo.androidInfo;

  if (Platform.isAndroid && androidInfo.version.sdkInt >= 33) {
    await Permission.photos.request();
  } else {
    await Permission.storage.request();
  }
}

class ProfileSetup extends StatefulWidget {
  const ProfileSetup({super.key});

  @override
  State<ProfileSetup> createState() => _ProfileSetupState();
}

class _ProfileSetupState extends State<ProfileSetup> {
  final User user = FirebaseAuth.instance.currentUser!;

  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final List<String> goalsList = [
    "Become more productive",
    "Increase focus",
    "Build a consistent routine",
    "Learn time management",
    "Improve mental health",
    "Boost physical fitness",
    "Learn a new skill",
    "Other",
  ];

  String? selectedGoal;
  final TextEditingController _customGoalController = TextEditingController();

  File? _profileImage;
  int _currentPageIndex = 0;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    requestStoragePermission();

    _nameController.text = user.displayName ?? '';

    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPageIndex) {
        setState(() {
          _currentPageIndex = newPage;
        });
      }
    });
  }

  Future<void> _pickImage() async {
    PermissionStatus status = await Permission.photos.request();

    if (status.isGranted) {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        setState(() {
          _profileImage = File(picked.path);
        });
      }
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Permission denied to access photos")),
        );
      }
    }
  }

  void _nextPage() {
    if (_currentPageIndex == 0 && _nameController.text.trim().isEmpty) return;
    if (_currentPageIndex == 1 && _bioController.text.trim().isEmpty) return;

    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitProfile() async {
    setState(() {
      loading = true;
    });

    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();
    final goal = selectedGoal == "Other"
        ? _customGoalController.text.trim()
        : selectedGoal ?? "";

    try {
      final user = FirebaseAuth.instance.currentUser;

      // Update Firebase Auth profile
      await user!.updateDisplayName(name);

      // Save bio and goal to Firestore
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.set({
        'name': name,
        'bio': bio,
        'goal': goal,
        'photoURL': user.photoURL,
        'email': user.email,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return; // Ensure the widget is still mounted
      context.go('/');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save profile: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: LinearProgressIndicator(
          value: (_currentPageIndex + 1) / 3, // 3 steps now
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            theme.colorScheme.primary,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Expanded(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            // Step 1: Name & Image
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          theme.colorScheme.primary.withOpacity(0.2),
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? Icon(Icons.add_a_photo,
                              size: 40,
                              color:
                                  theme.colorScheme.onSurface.withOpacity(0.6))
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: "Your Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),

            // Step 2: Bio
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _bioController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: "Tell us about yourself",
                      hintText: "E.g. I love coding & coffee ☕",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _nextPage,
                    child: const Text("Next"),
                  ),
                ],
              ),
            ),

            // Step 3: Goal
            // In your build method inside Step 3 widget
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What is your main goal?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: goalsList.map((goal) {
                        final isSelected = selectedGoal == goal;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedGoal = goal;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withOpacity(0.15)
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              goal,
                              style: TextStyle(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : Colors.black87,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (selectedGoal == "Other") ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _customGoalController,
                        decoration: const InputDecoration(
                          labelText: "Enter your custom goal",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: loading ? null : _submitProfile,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text("Finish"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
