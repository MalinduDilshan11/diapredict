import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/meal_model.dart';
import '../services/meal_service.dart';
import 'home_screen.dart';


class MealPlanScreen extends StatefulWidget {
  final String riskLevel;
  final String email;
  final String userName;
   

  const MealPlanScreen({
    super.key,
    required this.riskLevel,
    required this.email,
    required this.userName, 

  });

  @override
  State<MealPlanScreen> createState() => _MealPlanScreenState();
}

class _MealPlanScreenState extends State<MealPlanScreen> {
  List<MealModel> filteredMeals = [];
  bool loading = false;

  int currentDay = 1;

  final Map<String, Set<String>> selectedFoods = {};

  final Map<String, Map<String, int>> userLimits = {
    "Breakfast": {"Protein": 2, "Staple": 1, "Vegetable": 1, "Fruit": 1},
    "Lunch": {"Protein": 2, "Staple": 1, "Vegetable": 2, "Fruit": 1},
    "Dinner": {"Protein": 2, "Staple": 1, "Vegetable": 2, "Fruit": 2},
  };

  final Map<String, Map<String, int>> maxItems = {
    "Breakfast": {"Protein": 3, "Staple": 3, "Vegetable": 3, "Fruit": 3},
    "Lunch": {"Protein": 5, "Staple": 3, "Vegetable": 4, "Fruit": 3},
    "Dinner": {"Protein": 5, "Staple": 3, "Vegetable": 4, "Fruit": 3},
  };

  Map<String, List<MealModel>> randomMeals = {};

  @override
  void initState() {
    super.initState();
    loadMeals();
  }

  Future<void> loadMeals() async {
    setState(() => loading = true);
    final meals = await MealService.loadMeals();

    filteredMeals = meals.where((m) {
      return m.risk.toLowerCase() == widget.riskLevel.toLowerCase();
    }).toList();

    generateRandomMeals();

    setState(() => loading = false);
  }

  void generateRandomMeals() {
    randomMeals.clear();
    final mealTypes = ["Breakfast", "Lunch", "Dinner"];
    final categories = ["Protein", "Staple", "Vegetable", "Fruit"];
    final random = Random();

    for (var meal in mealTypes) {
      randomMeals[meal] = [];
      for (var cat in categories) {
        if (meal == "Breakfast" && cat.toLowerCase() == "vegetable") continue;

        final items = filteredMeals
            .where((m) =>
                (m.mealType.toLowerCase() == meal.toLowerCase() ||
                    (cat.toLowerCase() == "fruit" &&
                        m.mealType.toLowerCase() == "snack")) &&
                m.foodType.toLowerCase() == cat.toLowerCase())
            .toList();

        items.shuffle(random);
        final count = maxItems[meal]![cat] ?? 0;
        randomMeals[meal]!.addAll(items.take(count));
      }
    }
  }

  void toggleFood(String key, String food, String meal, String category) {
    selectedFoods.putIfAbsent(key, () => {});

    final selectedCount =
        selectedFoods[key]!.where((f) => f.startsWith("$category|")).length;

    if (selectedFoods[key]!.contains("$category|$food")) {
      selectedFoods[key]!.remove("$category|$food");
    } else if (selectedCount < userLimits[meal]![category]!) {
      selectedFoods[key]!.add("$category|$food");
    }

    setState(() {});
  }

  bool isDayCompleted(int day) {
    final mealTypes = ["Breakfast", "Lunch", "Dinner"];

    for (var meal in mealTypes) {
      for (var category in userLimits[meal]!.keys) {
        if (meal == "Breakfast" &&
            category.toLowerCase() == "vegetable") continue;

        final key = "Day $day-$meal";
        final count = selectedFoods[key]
                ?.where((f) => f.startsWith("$category|"))
                .length ??
            0;

        if (count < userLimits[meal]![category]!) return false;
      }
    }
    return true;
  }

  // ----------------------------------------------------
  
 Future<void> saveMealPlan() async {

  final url = Uri.parse("http://10.192.170.66:3000/mealplan");

  final Map<String, dynamic> formatted = {};

  selectedFoods.forEach((key, values) {
    // key = "Day 1-Breakfast"

    final parts = key.split('-');
    final day = parts[0].trim();      // Day 1
    final meal = parts[1].trim();     // Breakfast

    final dayKey =
        "day${day.replaceAll('Day', '').trim().padLeft(2, '0')}";

    formatted.putIfAbsent(dayKey, () => {});
    formatted[dayKey].putIfAbsent(meal.toLowerCase(), () => {});

    for (final item in values) {
      // item = Protein|Egg
      final split = item.split('|');

      final category = split[0].toLowerCase(); // protein
      final food = split[1];

      formatted[dayKey][meal.toLowerCase()]
          .putIfAbsent(category, () => []);

      formatted[dayKey][meal.toLowerCase()][category].add(food);
    }
  });

  final body = {
    "email": widget.email,
    "riskLevel": widget.riskLevel,
    "plan": formatted,
  };

  final response = await http.post(
    url,
    headers: {"Content-Type": "application/json"},
    body: jsonEncode(body),
  );

  final data = jsonDecode(response.body);

  if (data["success"] != true) {
    throw Exception("Save failed");
  }
}

  Widget buildMealCard(String meal) {
    final key = "Day $currentDay-$meal";
    final categories = ["Protein", "Staple", "Vegetable", "Fruit"];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Day $currentDay • $meal",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            for (var category in categories) ...[
              if (!(meal == "Breakfast" &&
                  category.toLowerCase() == "vegetable")) ...[
                Text(
                  "$category (select ${userLimits[meal]![category]})",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 5),
                ...randomMeals[meal]!
                    .where((m) =>
                        m.foodType.toLowerCase() ==
                        category.toLowerCase())
                    .map((mealItem) {
                  final selected = selectedFoods[key]
                          ?.contains(
                              "$category|${mealItem.foodName}") ??
                      false;

                  return CheckboxListTile(
                    title: Text(mealItem.foodName),
                    value: selected,
                    onChanged: (_) => toggleFood(
                        key, mealItem.foodName, meal, category),
                  );
                }).toList(),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'DiaPredict',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              "Risk Level: ${widget.riskLevel}",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Current Day: $currentDay",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  buildMealCard("Breakfast"),
                  buildMealCard("Lunch"),
                  buildMealCard("Dinner"),
                ],
              ),
            ),
            if (isDayCompleted(currentDay) && currentDay < 3)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentDay++;
                    });
                  },
                  child: const Text("Next Day"),
                ),
              ),
            if (currentDay == 3 && isDayCompleted(currentDay))
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                 onPressed: () async {
                      try {
                        await saveMealPlan();

                        if (!mounted) return;

                        // ✅ show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Meal plan saved successfully!"),
                          ),
                        );

                        // ✅ wait a short moment so user can see the message
                        await Future.delayed(const Duration(milliseconds: 800));

                        // ✅ go to home screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => HomeScreen(
                               userName: widget.userName,
                                email: widget.email,
                            ),
                          ),
                        );

                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Failed to save meal plan"),
                          ),
                        );
                      }
                    },
                  child: const Text("Finish"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}