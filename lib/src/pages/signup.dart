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

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark blue background
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.white)), // White text
        backgroundColor: const Color(0xFF1A1A2E), // Match app bar with background
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
                  borderSide: BorderSide(color: Colors.white), // White underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // White underline on focus
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
                  borderSide: BorderSide(color: Colors.white), // White underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // White underline on focus
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
                  borderSide: BorderSide(color: Colors.white), // White underline
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white), // White underline on focus
                ),
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.white), // White text
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Handle sign up logic here
              },
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