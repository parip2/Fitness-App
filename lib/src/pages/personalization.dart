import 'package:flutter/material.dart';

class PersonalizationPage extends StatelessWidget {
  const PersonalizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personalize Your Experience')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Personalize question 1?'),
            // Add options here
            // Example options
            RadioListTile(
              title: const Text('Option 1'),
              value: 'option1',
              groupValue: 'selectedOption1', // Replace with state management
              onChanged: (value) {},
            ),
            RadioListTile(
              title: const Text('Option 2'),
              value: 'option2',
              groupValue: 'selectedOption1', // Replace with state management
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            const Text('Personalize question 2?'),
            // Add options here
            ElevatedButton(onPressed: () {}, child: const Text('Next')),
          ],
        ),
      ),
    );
  }
} 