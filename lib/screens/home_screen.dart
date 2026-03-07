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

  String riskLevel = "Loading...";
  Color riskColor = Colors.grey;
  String riskMessage = "Fetching your latest prediction...";

  Map<String, dynamic> nutritionSummary = {};
  List<String> dayKeys = [];
  int currentDayIndex = 0;

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
        Uri.parse('http://10.192.170.66:3000/prediction/${widget.email}')
      );

      final data = json.decode(response.body);

      if (data['success'] == true) {

        String risk = data['predictedRisk'];

        setState(() {

          riskLevel = risk;

          if (risk == "LOW") {
            riskColor = Colors.green;
            riskMessage = "Excellent! Keep up the healthy habits.";
          }

          else if (risk == "MEDIUM") {
            riskColor = Colors.orange;
            riskMessage = "Be careful. Improve lifestyle habits.";
          }

          else if (risk == "HIGH") {
            riskColor = Colors.red;
            riskMessage = "High risk detected. Consult a doctor.";
          }

          else {
            riskColor = Colors.grey;
            riskMessage = "Unknown risk level";
          }

        });

      }

    } catch (e) {

      setState(() {
        riskLevel = "Error";
        riskMessage = "Server connection failed";
        riskColor = Colors.red;
      });

    }

  }

  // ---------------- Nutrition ----------------
  Future<void> fetchNutritionSummary() async {

    try {

      final response = await http.get(
        Uri.parse(
          'http://10.192.170.66:3000/nutrition_summary/${widget.email}'
        ),
      );

      final data = json.decode(response.body);

      if (data['success'] == true && data['summary'] != null) {

        setState(() {

          nutritionSummary = data['summary'];

          dayKeys = nutritionSummary.keys.toList()..sort();

          currentDayIndex = 0;

        });

      }

    } catch (e) {

      print("Nutrition error: $e");

    }

  }

  // ---------------- Legend ----------------
  Widget legendItem(String title, Color color) {

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [

        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),

        const SizedBox(width: 4),

        Text(title, style: const TextStyle(fontSize: 12)),

      ],
    );
  }

  // ---------------- Chart ----------------
  Widget buildNutritionPieChart() {

    if (nutritionSummary.isEmpty || dayKeys.isEmpty) {
      return const Center(child: Text("No nutrition summary yet"));
    }

    final dayKey = dayKeys[currentDayIndex];
    final dayData = nutritionSummary[dayKey];

    final protein = (dayData['protein'] ?? 0).toDouble();
    final carbs = (dayData['carbohydrates'] ?? 0).toDouble();
    final fat = (dayData['fat'] ?? 0).toDouble();
    final gi = (dayData['glycemicIndex'] ?? 0).toDouble();
    final calories = (dayData['calories'] ?? 0).toDouble();

    final total = protein + carbs + fat + gi;

    return Container(

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black.withOpacity(0.05),
          )
        ],
      ),

      child: Column(
        children: [

          Text(
            "Day ${currentDayIndex + 1} Nutrition",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 45,
                sectionsSpace: 3,
                startDegreeOffset: -90,
                sections: [

                  PieChartSectionData(
                    value: protein,
                    color: const Color(0xffFF9F43),
                    radius: 35,
                    title: "${((protein/total)*100).toStringAsFixed(0)}%",
                    titleStyle: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  PieChartSectionData(
                    value: carbs,
                    color: const Color(0xff54A0FF),
                    radius: 35,
                    title: "${((carbs/total)*100).toStringAsFixed(0)}%",
                    titleStyle: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  PieChartSectionData(
                    value: fat,
                    color: const Color(0xffFF6B6B),
                    radius: 35,
                    title: "${((fat/total)*100).toStringAsFixed(0)}%",
                    titleStyle: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                  PieChartSectionData(
                    value: gi,
                    color: const Color(0xff8E44AD),
                    radius: 35,
                    title: "${((gi/total)*100).toStringAsFixed(0)}%",
                    titleStyle: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),

                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: [

              legendItem("Protein", const Color(0xffFF9F43)),
              legendItem("Carbs", const Color(0xff54A0FF)),
              legendItem("Fat", const Color(0xffFF6B6B)),
              legendItem("GI", const Color(0xff8E44AD)),

            ],
          ),

          const SizedBox(height: 4),

          Text(
            "Calories: $calories kcal",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),

        ],
      ),
    );
  }

  // ---------------- Action Card ----------------
  Widget actionCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required Color color
  }) {

    return Expanded(
      child: GestureDetector(

        onTap: onTap,

        child: Container(

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.9),
                color.withOpacity(0.6),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
          ),

          child: Column(
            children: [

              Icon(icon, size: 30, color: Colors.white),

              const SizedBox(height: 8),

              Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xfff6f8fb),

      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "DiaPredict",
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold
          ),
        ),
      ),

      body: SafeArea(

        child: ListView(

          padding: const EdgeInsets.all(18),

          children: [

            Text(
              "Hello ${widget.userName}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 16),

            Container(

              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    riskColor.withOpacity(0.9),
                    riskColor.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(
                children: [

                  const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 30
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Diabetes Risk",
                          style: TextStyle(
                            color: Colors.white70
                          ),
                        ),

                        Text(
                          riskLevel,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),

                        Text(
                          riskMessage,
                          style: const TextStyle(
                            color: Colors.white70
                          ),
                        ),

                      ],
                    ),
                  ),

                ],
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [

                actionCard(
                  icon: Icons.restaurant_menu,
                  title: "Meal Plan",
                  color: Colors.green,
                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MealPlanScreen(
                          riskLevel: riskLevel,
                          email: widget.email,
                          userName: widget.userName,
                        ),
                      ),
                    );

                  },
                ),

                const SizedBox(width: 12),

                actionCard(
                  icon: Icons.analytics,
                  title: "Health Insights",
                  color: Colors.purple,
                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DashboardScreen(
                          email: widget.email,
                          riskLevel: riskLevel,
                        ),
                      ),
                    );

                  },
                ),

              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(

                onPressed: () {

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssessRiskScreen(
                        userName: widget.userName,
                        email: widget.email,
                      ),
                    ),
                  );

                },

                child: const Text(
                  "Assess Risk Now",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),

              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Daily Nutrition",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 260,
              child: PageView.builder(
                itemCount: dayKeys.length,
                onPageChanged: (index) {
                  setState(() {
                    currentDayIndex = index;
                  });
                },
                itemBuilder: (_, index) {
                  return buildNutritionPieChart();
                },
              ),
            ),

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
                builder: (_) => AssessRiskScreen(
                  userName: widget.userName,
                  email: widget.email,
                ),
              ),
            );

          }

          else if (index == 2) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MealPlanScreen(
                  riskLevel: riskLevel,
                  email: widget.email,
                  userName: widget.userName,
                ),
              ),
            );

          }

          else if (index == 3) {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DashboardScreen(
                  email: widget.email,
                  riskLevel: riskLevel,
                ),
              ),
            );

          }

        },

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.assessment),
            label: 'Assess'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: 'Meals'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Dashboard'
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile'
          ),

        ],
      ),
    );
  }
}