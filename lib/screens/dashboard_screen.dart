import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  final String email;
  final String riskLevel;

  const DashboardScreen({
    super.key,
    required this.email,
    required this.riskLevel,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  Map<String, dynamic> nutritionSummary = {};

  double totalCalories = 0;
  double protein = 0;
  double carbs = 0;
  double fat = 0;
  double gi = 0;

  double averageCalories = 0;

  final double calorieGoal = 2200;

  @override
  void initState() {
    super.initState();
    fetchNutrition();
  }

  /// Fetch nutrition summary from backend
  Future<void> fetchNutrition() async {

    try {

      final response = await http.get(
        Uri.parse("http://10.63.63.66:3000/nutrition_summary/${widget.email}")
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true && data["summary"] != null) {

        nutritionSummary = data["summary"];

        double cal = 0;
        double p = 0;
        double c = 0;
        double f = 0;
        double g = 0;

        int days = 0;

        nutritionSummary.forEach((day, dayData) {

          cal += double.tryParse(dayData["calories"].toString()) ?? 0;
          p += double.tryParse(dayData["protein"].toString()) ?? 0;
          c += double.tryParse(dayData["carbohydrates"].toString()) ?? 0;
          f += double.tryParse(dayData["fat"].toString()) ?? 0;
          g += double.tryParse(dayData["glycemicIndex"].toString()) ?? 0;

          days++;

        });

        setState(() {

          totalCalories = cal;
          protein = p;
          carbs = c;
          fat = f;
          gi = g;

          if (days > 0) {
            averageCalories = cal / days;
          }

        });

      }

    } catch (e) {
      print("Dashboard error: $e");
    }

  }

  /// Risk color
  Color getRiskColor() {

    if (widget.riskLevel == "LOW") return Colors.green;
    if (widget.riskLevel == "MEDIUM") return Colors.orange;
    if (widget.riskLevel == "HIGH") return Colors.red;

    return Colors.grey;

  }

  /// Risk based tips
  List<String> getRiskTips() {

    if (widget.riskLevel == "LOW") {
      return [
        "Maintain balanced meals and healthy eating habits.",
        "Continue regular physical activity.",
        "Stay hydrated and sleep well."
      ];
    }

    if (widget.riskLevel == "MEDIUM") {
      return [
        "Reduce sugar and refined carbohydrates.",
        "Increase daily physical activity.",
        "Maintain a healthy body weight."
      ];
    }

    if (widget.riskLevel == "HIGH") {
      return [
        "Consult a healthcare professional.",
        "Monitor blood glucose regularly.",
        "Follow a doctor-recommended diet plan."
      ];
    }

    return [];

  }

  /// Legend builder
  Widget buildLegend(Color color, String name, double value) {

    return Row(
      children: [

        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        const SizedBox(width: 8),

        Text(name),

        const Spacer(),

        Text(value.toStringAsFixed(1)),

      ],
    );

  }

  /// Pie chart
  Widget buildPieChart() {

    double total = protein + carbs + fat + gi;

    if (total == 0) {
      return const Center(child: Text("No nutrition data"));
    }

    return PieChart(

      PieChartData(

        sectionsSpace: 3,
        centerSpaceRadius: 50,

        sections: [

          PieChartSectionData(
            value: protein,
            color: Colors.orange,
            radius: 60,
            title: "${((protein / total) * 100).toStringAsFixed(0)}%",
          ),

          PieChartSectionData(
            value: carbs,
            color: Colors.blue,
            radius: 60,
            title: "${((carbs / total) * 100).toStringAsFixed(0)}%",
          ),

          PieChartSectionData(
            value: fat,
            color: Colors.red,
            radius: 60,
            title: "${((fat / total) * 100).toStringAsFixed(0)}%",
          ),

          PieChartSectionData(
            value: gi,
            color: Colors.purple,
            radius: 60,
            title: "${((gi / total) * 100).toStringAsFixed(0)}%",
          ),

        ],

      ),

      swapAnimationDuration: const Duration(milliseconds: 700),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xfff6f8fb),

      appBar: AppBar(
        title: const Text(
          "Health Dashboard",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            /// Risk Card
            Container(

              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: getRiskColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Row(

                children: [

                  Icon(Icons.favorite,
                      color: getRiskColor(),
                      size: 30),

                  const SizedBox(width: 15),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      const Text("Diabetes Risk"),

                      Text(
                        widget.riskLevel,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: getRiskColor(),
                        ),
                      ),

                    ],
                  )

                ],
              ),
            ),

            const SizedBox(height: 25),

            /// Average Calories
            const Text(
              "Average Daily Calories",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              "${averageCalories.toStringAsFixed(0)} kcal/day",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text("Total for 3 Days: ${totalCalories.toStringAsFixed(0)} kcal"),

            const SizedBox(height: 30),

            /// Nutrition Chart
            Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black.withOpacity(0.05),
                  )
                ],
              ),

              child: Column(

                children: [

                  const Text(
                    "3-Day Nutrition Distribution",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    height: 220,
                    child: buildPieChart(),
                  ),

                  const SizedBox(height: 20),

                  buildLegend(Colors.orange, "Protein", protein),
                  const SizedBox(height: 8),

                  buildLegend(Colors.blue, "Carbohydrates", carbs),
                  const SizedBox(height: 8),

                  buildLegend(Colors.red, "Fat", fat),
                  const SizedBox(height: 8),

                  buildLegend(Colors.purple, "Glycemic Index", gi),

                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Health Tips
            Container(

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  const Row(
                    children: [

                      Icon(Icons.lightbulb, color: Colors.blue),

                      SizedBox(width: 8),

                      Text(
                        "Health Tips",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(height: 12),

                  ...getRiskTips().map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(

                        children: [

                          const Icon(Icons.check_circle,
                              color: Colors.green,
                              size: 18),

                          const SizedBox(width: 8),

                          Expanded(child: Text(tip)),

                        ],
                      ),
                    ),
                  ),

                ],
              ),
            )

          ],
        ),
      ),
    );
  }
}