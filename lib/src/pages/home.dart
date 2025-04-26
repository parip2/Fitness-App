import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'login.dart'; // Import the login page
import 'profile.dart'; // Import the profile page
import 'dart:math';
import 'notifications.dart';
import 'nutrition.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Track the selected index

  // List of widgets for each tab
  final List<Widget> _pages = const [
    WeeklyWorkoutChallenge(), // New workout challenge page
    NutritionPage(),
    NotificationsPage(),
    ProfilePage(), // Profile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  Future<void> _logout() async {
    //await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()), // Navigate to login page
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PowerUP', style: TextStyle(color: Colors.white)), // Generic title for other pages
        backgroundColor: const Color(0xFF1A1A2E), // Match app bar with background
        leading: IconButton(
          icon: const Icon(Icons.logout, color: Colors.white), // Logout icon
          onPressed: _logout, // Call logout function
        ),
      ),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color(0xFF1A1A2E),
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.deepPurple,
        selectedItemColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu), 
            label: 'Nutrition',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class WeeklyWorkoutChallenge extends StatelessWidget {
  const WeeklyWorkoutChallenge({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark blue background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              'Weekly Workout Challenge',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Workout Options
            Expanded(
              child: ListView(
                children: [
                  _buildWorkoutCard(context, 'Workout 1', 'Monday'),
                  const SizedBox(height: 10),
                  _buildWorkoutCard(context, 'Workout 2', 'Tuesday'),
                  const SizedBox(height: 10),
                  _buildWorkoutCard(context, 'Workout 3', 'Wednesday'),
                  const SizedBox(height: 10),
                  _buildWorkoutCard(context, 'Workout 4', 'Thursday'),
                  const SizedBox(height: 10),
                  _buildWorkoutCard(context, 'Workout 5', 'Friday'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, String workoutName, String day) {
    return GestureDetector(
      onTap: () {
        // Navigate to Workout Detail Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WorkoutDetailPage(workoutName: workoutName, day: day),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFd8aa74),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              workoutName,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              day,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}


class WorkoutDetailPage extends StatelessWidget {
  final String workoutName;
  final String day;

  const WorkoutDetailPage({super.key, required this.workoutName, required this.day});

  @override
  Widget build(BuildContext context) {
    // List of possible workout descriptions
    final List<String> workoutDescriptions = [
      'This workout is designed to build upper body strength.\nBarbell Bench Press. 3 sets of 8-10 repititions.\nLat Pulldown. 3 sets of 8-10 repititions.\nChest Press. 3 sets of 8-10 repititions. \nLat Row. 3 sets of 8-10 repititions. \nPec Flys. 3 sets of 8-10 repititions.\nFace Pulls. 3 sets of 8-10 repititions.\nEnd the workout with light stretching and core exercises. \n',
      'Focus on endurance and stamina with this workout.\n For a total 5 rounds: \n 3 minutes of slow jogging. 1 minute walking. \n 2 minutes of faster jogging. 1 minute walking.\n 1 minute high speed jogging/ sprinting. 1 minute off. \n Repeat. \n End the workout with light stretching and core exercises. \n',
      'This workout is designed to build upper body strength. \nBarbell Back Squat. 3 sets of 10-12 repititions. \nSmith Machine Hip Thrust. 3 sets of 10-12 repititions. \nLeg Extensions. 3 sets of 10-12 repititions. \nRDLs. 3 sets of 10-12 repititions. \nCalf Raises. 3 sets of 10-12 repititions. \nEnd the workout with light stretching and core exercises. \n',
      'Boost agility and speed with this dynamic session. \nFor a total of 4 rounds: \n2 minutes of slow jogging. 1 minute of high speed sprinting. 1 minute of walking.\nEnd the workout with light stretching and core exercises. \n',
      'This workout is designed to build arm strength. \nDumbbell Bicep Curls. 3 sets of 8-10 repititions. \nHammer Curls. 3 sets of 8-10 repititions. \nTricep Rope Pushdown. 3 sets of 8-10 repitions. \nOverhead Tricep Extension. 3 sets of 8-10 repitions.\nEnd the workout with light stretching and core exercises. \n',
      'A high-intensity session to push your limits. Total of 40 minutes: \nStairmaster. Do 10 minutes at a high speed and every 10 minutes decrease the speed by one.\n'
    ];

    // Randomly select a workout description
    final String selectedDescription = (workoutDescriptions..shuffle()).first;

    return Scaffold(
      appBar: AppBar(
        title: Text(workoutName,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Section header
          Text(
            'Workout Details',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Day + Description card
          Card(
            color: const Color(0xFF2E2E3A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Day: $day',
                        style: const TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedDescription,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.5, // loosen line-spacing for readability
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          // Start button
          ElevatedButton.icon(
            onPressed: () {
              // TODO: wire up start logic
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Workout',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFd8aa74),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}