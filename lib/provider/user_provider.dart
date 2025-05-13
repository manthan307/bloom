// lib/providers/user_provider.dart
import 'package:bloom/modals/user_modal.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider with ChangeNotifier {
  UserModel? _user;

  UserModel? get user => _user;

  UserProvider() {
    // Listen to auth state changes
    FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        clearUser(); // User logged out
      } else {
        fetchUserData(); // User logged in
      }
    });
  }

  /// Called on login/auth change
  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (doc.exists) {
      _user = UserModel.fromMap(doc.data()!);
      notifyListeners();
    }
  }

  /// Called manually from pull-to-refresh or settings
  Future<void> refreshUser() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .get();

    if (doc.exists) {
      _user = UserModel.fromMap(doc.data()!);
      notifyListeners();
    }
  }

  void clearUser() {
    _user = null;
    notifyListeners();
  }
}
