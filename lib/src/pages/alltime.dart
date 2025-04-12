import 'package:flutter/material.dart';

class AllTimeActivityPage extends StatelessWidget {
  const AllTimeActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('All-Time Activity'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: Text(
          'All-time view of activity',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
