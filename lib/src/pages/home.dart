import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'login.dart'; // Import the login page
import 'profile.dart'; // Import the profile page

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
    Center(child: Text('Search Page (Dummy Content)')), // Search content
    Center(child: Text('Notifications Page (Dummy Content)')), // Notifications content
    ProfilePage(), // Profile page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Update the selected index
    });
  }

  Future<void> _logout() async {
    //await FirebaseAuth.instance.signOut(); // Sign out the user
    Navigator.pushReplacement(
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
            icon: Icon(Icons.search),
            label: 'Search',
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
                  _buildWorkoutCard(context, 'Workout Name 1', 'Monday'),
                  const SizedBox(height: 10),
                  _buildWorkoutCard(context, 'Workout Name 2', 'Tuesday'),
                  const SizedBox(height: 10),
                  _buildWorkoutCard(context, 'Workout Name 3', 'Wednesday'),
                  const SizedBox(height: 10),
                  _buildWorkoutCard(context, 'Workout Name 4', 'Thursday'),
                  const SizedBox(height: 10),
                  _buildWorkoutCard(context, 'Workout Name 5', 'Friday'),
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          workoutName,
          style: const TextStyle(
          color: Colors.white,
          fontSize: 26,
          fontWeight: FontWeight.bold,
        ),
      ),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white), // Set back arrow color to white
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
        ),
      ),

      backgroundColor: const Color (0xFF1A1A2E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Workout Details',
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Day: $day',
              style: const TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              'This workout includes exercises designed to help you build strength and endurance.',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}