import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> _signUpWithGoogle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      print('Google sign-out...');
      await _googleSignIn.signOut();
      print('Google sign-in...');
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      print('Google user: ' + (googleUser?.email ?? 'null'));
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
          _error = 'Google sign-in cancelled';
        });
        print('User cancelled Google sign-in');
        return;
      }
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('Got Google auth');
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      print('Signing in to Firebase with Google credential...');
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      print(
        'AFTER signInWithCredential, currentUser: [32m[1m${FirebaseAuth.instance.currentUser}[0m',
      );
      final user = userCredential.user;
      print('Firebase user: ' + (user?.uid ?? 'null'));
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        final data = doc.data();
        print('Firestore user doc: ' + (data?.toString() ?? 'null'));
        bool _ =
            data != null &&
            data['name'] != null &&
            data['phone'] != null &&
            data['name'].toString().trim().isNotEmpty &&
            data['phone'].toString().trim().isNotEmpty;

        // Navigation is now handled by StreamBuilder in main.dart
        // Optionally, you can show a message or update UI state here
        // Do NOT manually navigate
        return;
      }
      if (!mounted) return;
      print('User is null after Firebase sign-in!');
      setState(() {
        _error = 'Google sign-in failed: User is null.';
        _isLoading = false;
      });
    } catch (e, stack) {
      print('Google sign-in error: ' + e.toString());
      print(stack.toString());
      setState(() {
        _error = 'Google sign-in failed: ${e.toString()}';
        _isLoading = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signup() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
        setState(() {
          _error = 'Please enter email and password';
          _isLoading = false;
        });
        return;
      }
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );
      final user = userCredential.user;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'createdAt': FieldValue.serverTimestamp(),
          'email': _emailController.text,
        }, SetOptions(merge: true));
        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/complete-profile');
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'The account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'An error occurred: ${e.message}';
      }
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'An unexpected error occurred.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        automaticallyImplyLeading: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFe0e7ff), Color(0xFFf0f4ff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 10,
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Create your account',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2563eb),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563eb),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _isLoading ? null : _signup,
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Sign Up',
                              style: TextStyle(fontSize: 18),
                            ),
                    ),
                    const SizedBox(height: 18),
                    IconButton(
                      icon: Image.asset(
                        'assets/google_icon.png',
                        width: 32,
                        height: 32,
                      ),
                      tooltip: 'Sign up with Google',
                      onPressed: _isLoading ? null : _signUpWithGoogle,
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/login'),
                      child: const Text(
                        "Already have an account? Login",
                        style: TextStyle(
                          color: Color(0xFF2563eb),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
