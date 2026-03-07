import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;
import 'assess_risk_screen.dart';
import 'meal_plan_screen.dart';
import 'dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  final String email;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.email,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Prediction Data
  String riskLevel = "Loading...";
  Color riskColor = Colors.grey;
  String riskMessage = "Fetching your latest prediction...";

  // Nutrition Summary Data
  Map<String, dynamic> nutritionSummary =
      {}; // e.g., {day01: {...}, day02: {...}}
  List<String> dayKeys = [];
  int currentDayIndex = 0;

  // Temporary placeholders
  final double bmi = 22.5;
  final int dailyCalories = 1800;
  final int calorieGoal = 2200;

  @override
  void initState() {
    super.initState();
    fetchPrediction();
    fetchNutritionSummary();
  }

  // ---------------- Prediction ----------------
  Future<void> fetchPrediction() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.192.170.66:3000/prediction/${widget.email}'),
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {
        String risk = data['predictedRisk'];

        setState(() {
          riskLevel = risk;

          if (risk == "LOW") {
            riskColor = Colors.green;
            riskMessage = "Excellent! Keep up the healthy habits.";
          } else if (risk == "MEDIUM") {
            riskColor = Colors.orange;
            riskMessage = "Be careful. Improve lifestyle habits.";
          } else if (risk == "HIGH") {
            riskColor = Colors.red;
            riskMessage = "High risk detected. Consult a doctor.";
          } else {
            riskColor = Colors.grey;
            riskMessage = "Unknown risk level";
          }
        });
      } else {
        setState(() {
          riskLevel = "No Data";
          riskMessage = "No prediction available yet.";
          riskColor = Colors.grey;
        });
      }
    } catch (e) {
      print("Error fetching prediction: $e");
      setState(() {
        riskLevel = "Error";
        riskMessage = "Server connection failed";
        riskColor = Colors.red;
      });
    }
  }

  // ---------------- Nutrition Summary ----------------
  Future<void> fetchNutritionSummary() async {
    try {
      final response = await http.get(
        Uri.parse(
            'http://10.192.170.66:3000/nutrition_summary/${widget.email}'),
      );

      final data = json.decode(response.body);

      if (data['success'] == true && data['summary'] != null) {
        setState(() {
          nutritionSummary = data['summary'];
          dayKeys = nutritionSummary.keys.toList()
            ..sort(); // day01, day02, day03
          currentDayIndex = 0;
        });
      } else {
        print('No nutrition summary found');
      }
    } catch (e) {
      print("Error fetching nutrition summary: $e");
    }
  }

  // ---------------- Pie Chart Builder ----------------
  Widget buildNutritionPieChart() {
    if (nutritionSummary.isEmpty || dayKeys.isEmpty) {
      return const Center(child: Text("No nutrition summary yet"));
    }

    final dayKey = dayKeys[currentDayIndex];
    final dayData = nutritionSummary[dayKey];

    final calories = dayData['calories']?.toDouble() ?? 0;
    final protein = dayData['protein']?.toDouble() ?? 0;
    final carbs = dayData['carbohydrates']?.toDouble() ?? 0;
    final fat = dayData['fat']?.toDouble() ?? 0;
    final glycemicIndex = dayData['glycemicIndex']?.toDouble() ?? 0;

    return Column(
      children: [
        Text(
          "Day ${currentDayIndex + 1} Nutrition",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 195,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: [
                PieChartSectionData(
                    color: Colors.orange,
                    value: protein,
                    title: 'Protein',
                    radius: 50),
                PieChartSectionData(
                    color: Colors.blue,
                    value: carbs,
                    title: 'Carbs',
                    radius: 50),
                PieChartSectionData(
                    color: Colors.red, value: fat, title: 'Fat', radius: 50),
                // PieChartSectionData(color: Colors.green, value: calories, title: 'Calories', radius: 50),
                PieChartSectionData(
                    color: Colors.purple,
                    value: glycemicIndex,
                    title: 'GI',
                    radius: 50),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text("Calories: $calories kcal"),
        const SizedBox(height: 5),
      ],
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello ${widget.userName}!',
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),

            // Risk Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(Icons.trending_up, size: 40, color: riskColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Your Diabetes Risk',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            riskLevel,
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: riskColor),
                          ),
                          Text(riskMessage,
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BMI + Calories
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.scale, size: 40, color: Colors.blue),
                          const SizedBox(height: 10),
                          const Text('BMI', style: TextStyle(fontSize: 16)),
                          Text(bmi.toStringAsFixed(1),
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.local_fire_department,
                              size: 40, color: Colors.orange),
                          const SizedBox(height: 10),
                          const Text('Calorie Intake',
                              style: TextStyle(fontSize: 16)),
                          Text('$dailyCalories kcal',
                              style: const TextStyle(
                                  fontSize: 28, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Buttons
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AssessRiskScreen(
                            userName: widget.userName, email: widget.email)),
                  );
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16))),
                child: const Text('Assess Risk Now',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
            ),

            const SizedBox(height: 30),

            // Nutrition PieChart (swipeable)
            const Text('Daily Nutrition',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: dayKeys.length,
                onPageChanged: (index) {
                  setState(() {
                    currentDayIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return buildNutritionPieChart();
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AssessRiskScreen(
                      userName: widget.userName, email: widget.email)),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => MealPlanScreen(
                      riskLevel: riskLevel,
                      email: widget.email,
                      userName: widget.userName)),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DashboardScreen(
                  email: widget.email,
                  riskLevel: riskLevel,
                ),
              ),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.assessment), label: 'Assess'),
          BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu), label: 'Meals'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
