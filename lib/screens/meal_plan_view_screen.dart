import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MealPlanViewScreen extends StatefulWidget {
  final String email;
  final String userName;
  final String riskLevel;

  const MealPlanViewScreen({
    super.key,
    required this.email,
    required this.userName,
    required this.riskLevel,
  });

  @override
  State<MealPlanViewScreen> createState() => _MealPlanViewScreenState();
}

class _MealPlanViewScreenState extends State<MealPlanViewScreen> {
  Map<String, dynamic> mealPlan = {};
  bool loading = true;
  int selectedDay = 1;

  @override
  void initState() {
    super.initState();
    fetchMealPlan();
  }

  Future<void> fetchMealPlan() async {
    try {
      final response = await http.get(
        Uri.parse("http://10.192.170.66:3000/mealplan/${widget.email}"),
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true && data["plan"] != null) {
        setState(() {
          mealPlan = Map<String, dynamic>.from(data["plan"]);
          loading = false;
        });
      } else {
        setState(() {
          mealPlan = {};
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        mealPlan = {};
        loading = false;
      });
    }
  }

  Color riskColor() {
    if (widget.riskLevel == "LOW") return Colors.green;
    if (widget.riskLevel == "MEDIUM") return Colors.orange;
    return Colors.red;
  }

  List<String> extractFoods(dynamic meal) {
    List<String> foods = [];

    if (meal is Map) {
      meal.forEach((key, value) {
        if (value is List) {
          foods.addAll(value.cast<String>());
        }
      });
    }

    return foods;
  }

  Widget foodChip(String food) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(food),
    );
  }

  Widget mealSection(String title, IconData icon, dynamic meal) {
    final foods = extractFoods(meal);

    if (foods.isEmpty) return const SizedBox();

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: foods.map((f) => foodChip(f)).toList(),
          ),
        ],
      ),
    );
  }

  Widget buildDayMeals() {
    final key = "day0$selectedDay";

    if (!mealPlan.containsKey(key)) {
      return const Text("No meal plan available.");
    }

    final day = mealPlan[key];

    return Column(
      children: [
        mealSection("Breakfast", Icons.free_breakfast, day["breakfast"]),
        mealSection("Lunch", Icons.lunch_dining, day["lunch"]),
        mealSection("Dinner", Icons.dinner_dining, day["dinner"]),
      ],
    );
  }

  Widget dayTab(int day) {
    bool selected = selectedDay == day;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDay = day;
        });
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          "Day $day",
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff4f7fb),
      appBar: AppBar(
        title: const Text("Meal Plan"),
        centerTitle: true,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xff4facfe),
                          Color(0xff00f2fe),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          backgroundImage: NetworkImage(
                            "https://api.dicebear.com/7.x/personas/png?seed=${widget.userName}",
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: riskColor(),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.riskLevel,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Text(
                    "Your 3-Day Meal Plan",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  /// DAY TABS
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      dayTab(1),
                      dayTab(2),
                      dayTab(3),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// MEALS
                  buildDayMeals(),
                ],
              ),
            ),
    );
  }
}