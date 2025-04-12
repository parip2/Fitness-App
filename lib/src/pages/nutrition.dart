import 'package:flutter/material.dart';

class FoodItem {
  final String name;
  final String servingSize;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;

  FoodItem({
    required this.name,
    required this.servingSize,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });
}

class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  final List<FoodItem> _foodItems = [];
  int _dailyCalorieGoal = 2200;
  Map<String, double> _macroGoals = {
    'protein': 150,
    'carbs': 250,
    'fats': 70,
  };

  void _addFoodItem(FoodItem item) {
    setState(() {
      _foodItems.add(item);
    });
  }

  void _updateGoals(int calories, Map<String, double> macros) {
    setState(() {
      _dailyCalorieGoal = calories;
      _macroGoals = macros;
    });
  }

  int _calculateTotalCalories() {
    return _foodItems.fold(0, (sum, item) => sum + item.calories);
  }

  Map<String, double> _calculateTotalMacros() {
    return {
      'protein': _foodItems.fold(0, (sum, item) => sum + item.protein),
      'carbs': _foodItems.fold(0, (sum, item) => sum + item.carbs),
      'fats': _foodItems.fold(0, (sum, item) => sum + item.fats),
    };
  }

  @override
  Widget build(BuildContext context) {
    final totalCalories = _calculateTotalCalories();
    final totalMacros = _calculateTotalMacros();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Nutrition Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.settings, color: Color(0xFF4ECDC4)),
                  onPressed: () async {
                    final result = await Navigator.push<Map<String, dynamic>>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NutritionGoalsPage(
                          currentCalories: _dailyCalorieGoal,
                          currentMacros: _macroGoals,
                        ),
                      ),
                    );
                    if (result != null) {
                      _updateGoals(
                        result['calories'] as int,
                        result['macros'] as Map<String, double>,
                      );
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildCalorieSummary(totalCalories),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Food Items',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push<FoodItem>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddFoodItemPage(),
                      ),
                    );
                    if (result != null) {
                      _addFoodItem(result);
                    }
                  },
                  icon: const Icon(Icons.add, color: Color(0xFF4ECDC4)),
                  label: const Text(
                    'Add Food',
                    style: TextStyle(color: Color(0xFF4ECDC4)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  final item = _foodItems[index];
                  return _buildFoodItemCard(item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalorieSummary(int totalCalories) {
    final totalMacros = _calculateTotalMacros();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4ECDC4),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCalorieItem(
                  'Daily Goal', _dailyCalorieGoal.toString(), 'kcal'),
              _buildCalorieItem('Consumed', totalCalories.toString(), 'kcal'),
              _buildCalorieItem('Remaining',
                  (_dailyCalorieGoal - totalCalories).toString(), 'kcal'),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Colors.white30),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroSummaryItem('Protein', totalMacros['protein'] ?? 0,
                  _macroGoals['protein'] ?? 0),
              _buildMacroSummaryItem('Carbs', totalMacros['carbs'] ?? 0,
                  _macroGoals['carbs'] ?? 0),
              _buildMacroSummaryItem(
                  'Fats', totalMacros['fats'] ?? 0, _macroGoals['fats'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          unit,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildMacroSummaryItem(String label, double value, double goal) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 5),
        Text(
          '${value.toStringAsFixed(1)}/${goal.toStringAsFixed(1)}g',
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFoodItemCard(FoodItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFd8aa74),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              Text(
                '${item.calories} kcal',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            'Serving: ${item.servingSize}',
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroItem('Protein', '${item.protein}g'),
              _buildMacroItem('Carbs', '${item.carbs}g'),
              _buildMacroItem('Fats', '${item.fats}g'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class AddFoodItemPage extends StatefulWidget {
  const AddFoodItemPage({super.key});

  @override
  State<AddFoodItemPage> createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatsController = TextEditingController();
  final _servingSizeController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  int _calculateCalories() {
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fats = double.tryParse(_fatsController.text) ?? 0;

    // 4 calories per gram of protein and carbs, 9 calories per gram of fat
    return (protein * 4 + carbs * 4 + fats * 9).round();
  }

  void _updateCalories() {
    if (_proteinController.text.isNotEmpty &&
        _carbsController.text.isNotEmpty &&
        _fatsController.text.isNotEmpty) {
      final calculatedCalories = _calculateCalories();
      _caloriesController.text = calculatedCalories.toString();
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final calculatedCalories = _calculateCalories();
      final enteredCalories = int.tryParse(_caloriesController.text) ?? 0;

      if (calculatedCalories != enteredCalories) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Calories do not match the macronutrient values!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final foodItem = FoodItem(
        name: _nameController.text,
        servingSize: _servingSizeController.text,
        calories: calculatedCalories,
        protein: double.parse(_proteinController.text),
        carbs: double.parse(_carbsController.text),
        fats: double.parse(_fatsController.text),
      );

      Navigator.pop(context, foodItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Food Item',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Food Name',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a food name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _servingSizeController,
                label: 'Serving Size (e.g., 100g, 1 cup)',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a serving size';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _proteinController,
                      label: 'Protein (g)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      onChanged: (_) => _updateCalories(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _carbsController,
                      label: 'Carbs (g)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      onChanged: (_) => _updateCalories(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      controller: _fatsController,
                      label: 'Fats (g)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                      onChanged: (_) => _updateCalories(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _caloriesController,
                label: 'Calories (auto-calculated)',
                keyboardType: TextInputType.number,
                enabled: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4ECDC4),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Add Food Item',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool enabled = true,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      onChanged: onChanged,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white70),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4ECDC4)),
        ),
      ),
    );
  }
}

class NutritionGoalsPage extends StatefulWidget {
  final int currentCalories;
  final Map<String, double> currentMacros;

  const NutritionGoalsPage({
    super.key,
    required this.currentCalories,
    required this.currentMacros,
  });

  @override
  State<NutritionGoalsPage> createState() => _NutritionGoalsPageState();
}

class _NutritionGoalsPageState extends State<NutritionGoalsPage> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;

  @override
  void initState() {
    super.initState();
    _caloriesController =
        TextEditingController(text: widget.currentCalories.toString());
    _proteinController = TextEditingController(
        text: widget.currentMacros['protein']?.toString());
    _carbsController =
        TextEditingController(text: widget.currentMacros['carbs']?.toString());
    _fatsController =
        TextEditingController(text: widget.currentMacros['fats']?.toString());
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    final calories = int.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final carbs = double.tryParse(_carbsController.text);
    final fats = double.tryParse(_fatsController.text);

    if (calories == null || protein == null || carbs == null || fats == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid numbers for all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.pop(context, {
      'calories': calories,
      'macros': {
        'protein': protein,
        'carbs': carbs,
        'fats': fats,
      },
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nutrition Goals',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Calorie Goal',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Calories',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4ECDC4)),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Macronutrient Goals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _proteinController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Protein (g)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4ECDC4)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _carbsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Carbs (g)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4ECDC4)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _fatsController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Fats (g)',
                labelStyle: TextStyle(color: Colors.white70),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4ECDC4)),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoals,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4ECDC4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Save Goals',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
