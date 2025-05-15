import 'package:bloom/func/username.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Auth extends StatefulWidget {
  const Auth({super.key});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Welcome to Bloom!!',
                  style: const TextStyle().copyWith(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: theme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              decoration: BoxDecoration(
                color: theme.inverseSurface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _startSignIn(context),
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Get started with Google'),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startSignIn(BuildContext context) async {
    if (!mounted || isLoading) return;

    setState(() => isLoading = true);

    try {
      await _handleSignIn(context);
    } catch (e) {
      if (mounted) _showErrorDialog(this.context, e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

Future<void> _handleSignIn(BuildContext context) async {
  final user = await signInWithGoogle();

  if (!context.mounted) return;

  final currentUser = user.user;
  if (currentUser == null) {
    throw Exception('Login failed. Please try again.');
  }

  final docRef =
      FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
  final doc = await docRef.get();

  if (doc.exists) {
    if (context.mounted) context.go('/');
  } else {
    final username = await getUniqueUsername();

    await docRef.set({
      'name': currentUser.displayName,
      'bio': null,
      'goal': null,
      'photoURL': currentUser.photoURL,
      'email': currentUser.email,
      'uid': currentUser.uid,
      'username': username,
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (context.mounted) context.go('/setup');
  }
}

Future<UserCredential> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'SIGN_IN_ABORTED',
        message: 'Sign-in was cancelled.',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    if (e is FirebaseAuthException) {
      throw FirebaseAuthException(
        code: e.code,
        message: e.message ?? 'Unknown Firebase error occurred.',
      );
    } else {
      throw Exception('Google sign-in failed. Please try again later.');
    }
  }
}
