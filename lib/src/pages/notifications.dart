import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ), // Title style matches 'Weekly Workout Challenge'
        backgroundColor: const Color(0xFF1A1A2E), // Match AppBar color with HomePage
      ),
      backgroundColor: const Color(0xFF1A1A2E), // Set the background color to dark blue
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          Card(
            elevation: 4,
            child: ListTile(
              leading: Icon(Icons.check_circle, color: Colors.green),
              title: Text(
                "Congrats! You completed Workout One 🎉",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Log your details here"),
            ),
          ),
        ],
      ),
    );
  }
}