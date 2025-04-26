import 'package:flutter/material.dart';
import '../services/user_service.dart'; // Import UserService
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'dart:math' as math;
import 'week.dart';
import 'activity.dart';
import 'alltime.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isEditing = false;
  late TextEditingController nameController;
  final user = UserService().currentUser;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: user?.username ?? 'Your Name');
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  Future<void> _updateUsername() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Update Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'username': nameController.text,
        });
        
        // Get the updated document
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        
        // Update the UserService singleton
        final userService = UserService();
        userService.currentUser = UserModel.fromMap(
            userDoc.data() as Map<String, dynamic>);
        
        // Update local state
        setState(() {
          isEditing = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update username'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            // Profile Header with gradient background
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.deepPurple.shade900,
                    const Color(0xFF1A1A2E),
                  ],
                ),
              ),
              child: Column(
                children: [
                  // Profile Image and Name
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white24,
                    child: Text(
                      user?.username?.substring(0, 1).toUpperCase() ?? 'U',
                      style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isEditing) ...[
                        Expanded(
                          child: TextField(
                            controller: nameController,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: _updateUsername,
                        ),
                      ] else ...[
                        Text(
                          user?.username ?? 'Your Name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () => setState(() => isEditing = true),
                        ),
                      ],
                    ],
                  ),
                  // Stats Row
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStat('165.0', 'Height', 'cm'),
                      _buildStat('73.0', 'Weight', 'kg'),
                      _buildStat('27.5', 'Age', 'year'),
                    ],
                  ),
                ],
              ),
            ),
            // Activity Graph
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Activity',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Activity Period Selector
                    Row(
                      children: [
                        _buildPeriodButton('WEEK', const WeekActivityPage()),
                        const SizedBox(width: 10),
                        _buildPeriodButton('MONTH', const MonthActivityPage()),
                        const SizedBox(width: 10),
                        _buildPeriodButton('ALL TIME', const AllTimeActivityPage()),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Activity Graph
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildBar('Sun', 0.3, false),
                                  _buildBar('Mon', 0.5, false),
                                  _buildBar('Tue', 0.4, false),
                                  _buildBar('Wed', 0.6, false),
                                  _buildBar('Thu', 0.3, false),
                                  _buildBar('Fri', 0.8, true),
                                  _buildBar('Sat', 0.2, false),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Days row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildDayLabel('Sun'),
                                _buildDayLabel('Mon'),
                                _buildDayLabel('Tue'),
                                _buildDayLabel('Wed'),
                                _buildDayLabel('Thu'),
                                _buildDayLabel('Fri'),
                                _buildDayLabel('Sat'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '$label ($unit)',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  /*Widget _buildPeriodButton(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? Colors.pink : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );

    
  }*/
  Widget _buildPeriodButton(String text, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.pink,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildBar(String day, double height, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: 150 * height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.blue.withOpacity(0.2),
                isActive ? Colors.pink : Colors.blue.withOpacity(0.5),
              ],
            ),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ],
    );
  }

  Widget _buildDayLabel(String day) {
    return Text(
      day,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
      ),
    );
  }
}