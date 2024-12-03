import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout), // Logout icon
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Sign out the user
            },
          ),
        ],
      ),
      body: Center(
        child: const Text('Welcome to the Home Page!'),
      ),
    );
  }
}
