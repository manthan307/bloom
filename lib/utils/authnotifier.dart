import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'; // For ChangeNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthNotifier extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  AuthNotifier() {
    // Listen to Firebase Auth state changes
    _user = _auth.currentUser;
    _auth.authStateChanges().listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  User? get user => _user;

  bool get isLoggedIn => _user != null;
}

// Riverpod provider
final authNotifierProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});
