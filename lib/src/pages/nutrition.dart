import 'package:flutter/material.dart';

class NutritionPage extends StatelessWidget {
  const NutritionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark theme background
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            const Text(
              'Weekly Nutrition Plan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildMealCard(context, 'Monday', 'High-Protein Meals'),
                  const SizedBox(height: 10),
                  _buildMealCard(context, 'Tuesday', 'Hydration & Recovery'),
                  const SizedBox(height: 10),
                  _buildMealCard(context, 'Wednesday', 'Pre-Workout Nutrition'),
                  const SizedBox(height: 10),
                  _buildMealCard(context, 'Thursday', 'Post-Workout Meals'),
                  const SizedBox(height: 10),
                  _buildMealCard(context, 'Friday', 'Balanced Diet Plan'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, String day, String mealType) {
    return GestureDetector(
      onTap: () {
        // Navigate to Meal Detail Page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailPage(day: day, mealType: mealType),
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
              day,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              mealType,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class MealDetailPage extends StatelessWidget {
  final String day;
  final String mealType;

  const MealDetailPage({super.key, required this.day, required this.mealType});

  @override
  Widget build(BuildContext context) {
    // Example meal plans
    final Map<String, String> mealPlans = {
      'Monday': 'Breakfast: Scrambled eggs with whole grain toast & avocado.\n'
          'Lunch: Grilled chicken salad with quinoa & veggies.\n'
          'Dinner: Baked salmon with roasted sweet potatoes & spinach.',
      'Tuesday': 'Breakfast: Oatmeal with chia seeds, berries, and almonds.\n'
          'Lunch: Lentil soup with whole grain bread.\n'
          'Dinner: Stir-fried tofu with brown rice and vegetables.',
      'Wednesday': 'Breakfast: Greek yogurt with honey, berries and granola.\n'
          'Lunch: Turkey and avocado wrap with a side of carrots.\n'
          'Dinner: Grilled fish with quinoa and steamed broccoli.',
      'Thursday': 'Breakfast: Smoothie with banana, protein powder, and almond milk.\n'
          'Lunch: Chicken breast with quinoa and roasted vegetables.\n'
          'Dinner: Beef stir-fry with whole grain noodles.',
      'Friday': 'Breakfast: Peanut butter toast with a banana.\n'
          'Lunch: Tuna salad with mixed greens and balsamic dressing.\n'
          'Dinner: Whole grain pasta with spinach and marinara sauce.'
    };

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$day - $mealType',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Meal Plan for the Day',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              mealPlans[day] ?? 'Meal plan not available.',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
