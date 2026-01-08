import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'assess_risk_screen.dart';  // ← Import the new assessment screen

class HomeScreen extends StatelessWidget {
  final String userName;

  const HomeScreen({super.key, required this.userName});

  // Temporary placeholder data (replace with real data from backend later)
  final String riskLevel = "Low Risk";
  final Color riskColor = Colors.green;
  final String riskMessage = "Excellent! Keep up the healthy habits.";
  final double bmi = 22.5;
  final int dailyCalories = 1800;
  final int calorieGoal = 2200;

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
            // Personalized greeting with real name
            Text(
              'Hello $userName!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
            const SizedBox(height: 20),

            // Diabetes Risk Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Icon(Icons.trending_down, size: 40, color: Colors.green),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Diabetes Risk',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            riskLevel,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: riskColor,
                            ),
                          ),
                          Text(riskMessage, style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // BMI & Calorie Intake Row
            Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.scale, size: 40, color: Colors.blue),
                          const SizedBox(height: 10),
                          const Text('BMI', style: TextStyle(fontSize: 16)),
                          Text(
                            bmi.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          const Icon(Icons.local_fire_department, size: 40, color: Colors.orange),
                          const SizedBox(height: 10),
                          const Text('Calorie Intake', style: TextStyle(fontSize: 16)),
                          Text(
                            '$dailyCalories kcal',
                            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Action Buttons
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to Assess Risk Screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AssessRiskScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Assess Risk Now',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to Meal Planner (later)
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  "Plan Today's Meals",
                  style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: OutlinedButton(
                onPressed: () {
                  // Navigate to Progress (later)
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue, width: 2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'View Progress',
                  style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Daily Calorie Intake Ring Chart
            const Text(
              'Daily Calorie Intake',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text("Today's Progress: $dailyCalories kcal"),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 40,
                  sections: [
                    PieChartSectionData(
                      color: Colors.orange,
                      value: dailyCalories.toDouble(),
                      title: '',
                      radius: 50,
                    ),
                    PieChartSectionData(
                      color: Colors.grey[300],
                      value: (calorieGoal - dailyCalories).toDouble(),
                      title: '',
                      radius: 50,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        currentIndex: 0, // Home is selected
        onTap: (index) {
          if (index == 1) {
            // Assess tab tapped
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AssessRiskScreen()),
            );
          }
          // Add other tabs later
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: 'Assess'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Meals'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}