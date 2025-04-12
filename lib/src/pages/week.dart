import 'package:flutter/material.dart';

class WeekActivityPage extends StatelessWidget {
  const WeekActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Week Activity'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: Text(
          'Week view of activity',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}