import 'package:flutter/material.dart';

class MonthActivityPage extends StatelessWidget {
  const MonthActivityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Month Activity'),
        backgroundColor: Colors.pink,
      ),
      body: const Center(
        child: Text(
          'Month view of activity',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
