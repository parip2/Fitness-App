import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController usernameController =
        TextEditingController(); // Add username controller

    Future<void> signUp() async {
      try {
        // Create user with email and password
        final UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        // Get the user
        final User? user = userCredential.user;

        if (user != null) {
          // Store additional user data in Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
            'username': usernameController.text.trim(),
            'email': emailController.text.trim(),
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Show success message
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Account created successfully!')),
            );
            // Navigate to home page or login page
            Navigator.pop(context);
          }
        }
      } on FirebaseAuthException catch (e) {
        String message = 'An error occurred';
        if (e.code == 'weak-password') {
          message = 'The password provided is too weak.';
        } else if (e.code == 'email-already-in-use') {
          message = 'An account already exists for that email.';
        } else if (e.code == 'invalid-email') {
          message = 'The email address is invalid.';
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark blue background
      appBar: AppBar(
        title: const Text('Sign Up',
            style: TextStyle(color: Colors.white)), // White text
        backgroundColor:
            const Color(0xFF1A1A2E), // Match app bar with background
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              controller: usernameController, // Capture username input
              decoration: const InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white), // White label text
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white), // White underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // White underline on focus
                ),
              ),
              style: const TextStyle(color: Colors.white), // White text
            ),
            TextField(
              controller: emailController, // Capture email input
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white), // White label text
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white), // White underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // White underline on focus
                ),
              ),
              style: const TextStyle(color: Colors.white), // White text
            ),
            TextField(
              controller: passwordController, // Capture password input
              decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white), // White label text
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: Colors.white), // White underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.white), // White underline on focus
                ),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white), // White text
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: const Text('Sign Up'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4), // Button color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
