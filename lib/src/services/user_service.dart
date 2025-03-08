import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import '../models/user_model.dart'; // Import UserModel
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class UserService {
  static final UserService _instance = UserService._internal();
  UserModel? currentUser;

  factory UserService() {
    _instance._loadCurrentUser();
    return _instance;
  }

  UserService._internal();

  // Method to fetch user details from Firestore
  Future<void> _loadCurrentUser() async {
    try {
      // Assuming there's a way to get the current user's UID
      String uid = FirebaseAuth.instance.currentUser?.uid ??
          ''; // Use Firebase Auth to get the current user's UID
      if (uid.isEmpty) {
        throw Exception('No user logged in');
      }

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      // Create a UserModel instance and store it
      currentUser = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching user details: $e');
    }
  }
}
