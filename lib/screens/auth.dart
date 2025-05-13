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
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
            child: Column(
          children: [
            Expanded(
                child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Welcome to Bloom!!',
                  style: const TextStyle().copyWith(
                    fontSize: 60,
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.onSurface,
                  )),
            )),
            Container(
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 30),
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.inverseSurface,
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40))),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: () async {
                        setState(() {
                          isLoading = true; // Start loading
                        });

                        try {
                          final user =
                              await signInWithGoogle(); // Sign in with Google

                          if (!context.mounted) return;

                          if (user.user != null) {
                            // If user is signed in, navigate to home page
                            try {
                              final doc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.user?.uid)
                                  .get();

                              if (doc.exists) {
                                if (!context.mounted) return;
                                context.go('/');
                              } else {
                                if (!context.mounted) return;
                                context.go('/setup');
                              }
                            } catch (e) {
                              context.go('/auth');
                            }
                          } else {
                            // If user is not signed in, show a dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Login Failed'),
                                content:
                                    const Text('Please login to continue!'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          // Handle any errors during the sign-in process
                          setState(() {
                            isLoading = false; // Stop loading if error occurs
                          });

                          if (!context.mounted) return;
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Error'),
                              content: Text('An error occurred: $e'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        } finally {
                          setState(() {
                            isLoading =
                                false; // Stop loading once the process completes
                          });
                        }
                      },
                      icon: const Icon(Icons.g_mobiledata),
                      label: const Text('Get started with Google'),
                    ),
            )
          ],
        )));
  }
}

class AuthNotifier extends ChangeNotifier {
  late final Stream<User?> _authStream;

  AuthNotifier() {
    _authStream = FirebaseAuth.instance.authStateChanges();
    _authStream.listen((_) => notifyListeners());
  }
}

Future<UserCredential> signInWithGoogle() async {
  try {
    final scopes = ['email', 'https://www.googleapis.com/auth/drive.file'];

    final GoogleSignIn googleSignIn = GoogleSignIn(scopes: scopes);
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'SIGN_IN_ABORTED',
        message: 'Google sign-in was aborted by the user.',
      );
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    return await FirebaseAuth.instance.signInWithCredential(
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ),
    );
  } catch (e) {
    if (e is FirebaseAuthException) {
      // Firebase-specific errors
      throw FirebaseAuthException(
        code: e.code,
        message:
            e.message ?? 'An unknown error occurred during Google sign-in.',
      );
    } else if (e is Exception) {
      // General errors
      throw Exception(
          'An error occurred during Google sign-in. Please try again later.');
    }
  }
  // Ensure a throw statement for any unexpected cases
  throw Exception('An unknown error occurred during Google sign-in.');
}
