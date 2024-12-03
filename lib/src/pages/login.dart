import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'signup.dart'; // Import the signup page
import 'home.dart'; // Import the home page
import '../models/user_model.dart'; // Import the UserModel

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark blue background
      appBar: AppBar(
        title: const Text('Login', style: TextStyle(color: Colors.white)), // White text
        backgroundColor: const Color(0xFF1A1A2E), // Match app bar with background
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
                // Handle login logic here
                try {
                  UserCredential userCredential =
                      await FirebaseAuth.instance.signInWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );

                  // Fetch user data from Firestore
                  DocumentSnapshot userDoc = await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userCredential.user?.uid)
                      .get();

                  // Create a UserModel instance
                  UserModel user =
                      UserModel.fromMap(userDoc.data() as Map<String, dynamic>);

                  // Navigate to the home page after successful login
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()), // Navigate to home page
                  );

                  // Store user data in a global state or pass it to the next screen
                  print('User Info: ${user.username}, ${user.email}, ${user.bio}');
                } catch (e) {
                  // Handle login error
                  print(e);
                }
              },
              child: const Text('Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4ECDC4), // Button color
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupPage()),
                );
              },
              child: const Text('Don\'t have an account? Sign Up', style: TextStyle(color: Colors.white)), // White text
            ),
          ],
        ),
      ),
    );
  }
}