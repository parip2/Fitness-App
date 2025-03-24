import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'src/pages/login.dart'; // Import the login page
import 'src/pages/signup.dart'; // Import the signup page
import 'src/pages/home.dart'; // Import the home page
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

// Import firebase_options correctly
import 'firebase_options.dart'
    if (dart.library.html) 'firebase_options.dart'
    if (dart.library.io) 'firebase_options_stub.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized

  // Initialize Firebase with platform-specific handling
  try {
    if (kIsWeb) {
      // Web-specific initialization
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized for web');
    } else if (Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print('Firebase initialized for ${Platform.operatingSystem}');
    } else {
      // Skip Firebase on unsupported platforms
      print('Skipping Firebase on unsupported platform');
    }
  } catch (e) {
    print('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: _buildAuthenticatedFlow(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignupPage(),
      },
    );
  }

  Widget _buildAuthenticatedFlow() {
    // Temporary development bypass - comment this out before production!
    return const HomePage(); // This will directly show the HomePage without authentication

    // Original authentication code - uncomment this before production
    /*
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          final User? user = snapshot.data;
          if (user != null) {
            return const HomePage();
          }
        }
        return const LoginPage();
      },
    );
    */
  }
}
