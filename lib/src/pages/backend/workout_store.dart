import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new workout to Firestore
  Future<void> addWorkout(String userId, Map<String, dynamic> workoutData) async {
    try {
      await _firestore.collection('workouts').add({
        'userId': userId, // Associate workout with a user
        'date': workoutData['date'], // Date of the workout
        'workoutType': workoutData['workoutType'], // Type of workout
        'exercises': workoutData['exercises'], // List of exercises
      });
      print("Workout stored successfully!");
    } catch (e) {
      print("Error adding workout: $e");
    }
  }

  // Retrieve workouts for a specific user
  Future<List<Map<String, dynamic>>> getUserWorkouts(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('workouts')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      print("Error retrieving workouts: $e");
      return [];
    }
  }
}
