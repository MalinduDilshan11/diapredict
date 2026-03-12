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
        Uri.parse("http://10.63.63.66:3000/mealplan/${widget.email}")
      );

      final data = jsonDecode(response.body);

      if (data["success"] == true && data["plan"] != null) {

        setState(() {
          mealPlan = Map<String, dynamic>.from(data["plan"]);
          loading = false;
        });

      } else {
        loading = false;
      }

    } catch (e) {

      loading = false;

    }

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

  Widget foodRow(String food) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(

        children: [

          const Icon(
            Icons.circle,
            size: 8,
            color: Colors.blue,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              food,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          )

        ],
      ),
    );

  }

  Widget mealCard(String title, IconData icon, dynamic meal) {

    final foods = extractFoods(meal);

    if (foods.isEmpty) return const SizedBox();

    return Container(

      margin: const EdgeInsets.only(bottom: 18),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
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

              const SizedBox(width: 10),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )

            ],
          ),

          const SizedBox(height: 15),

          ...foods.map((f) => foodRow(f)).toList()

        ],

      ),

    );

  }

  Widget buildMeals() {

    final key = "day0$selectedDay";

    if (!mealPlan.containsKey(key)) {

      return const Center(
        child: Text("No meal plan found."),
      );

    }

    final day = mealPlan[key];

    return Column(

      children: [

        mealCard(
          "Breakfast",
          Icons.free_breakfast,
          day["breakfast"],
        ),

        mealCard(
          "Lunch",
          Icons.lunch_dining,
          day["lunch"],
        ),

        mealCard(
          "Dinner",
          Icons.dinner_dining,
          day["dinner"],
        ),

      ],

    );

  }

  Widget daySelector(int day) {

    bool selected = selectedDay == day;

    return GestureDetector(

      onTap: () {

        setState(() {
          selectedDay = day;
        });

      },

      child: Container(

        padding: const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 10,
        ),

        decoration: BoxDecoration(

          color: selected
              ? Colors.blue
              : Colors.grey.shade200,

          borderRadius: BorderRadius.circular(20),

        ),

        child: Text(

          "Day $day",

          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.black,
            fontWeight: FontWeight.bold,
          ),

        ),

      ),

    );

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: const Color(0xfff5f7fb),

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

            /// USER HEADER

            Row(

              children: [

                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(
                    "https://api.dicebear.com/7.x/personas/png?seed=${widget.userName}",
                  ),
                ),

                const SizedBox(width: 12),

                Column(

                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [

                    Text(
                      widget.userName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      widget.riskLevel,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    )

                  ],
                )

              ],

            ),

            const SizedBox(height: 25),

            const Text(
              "Your 3 Day Meal Plan",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            /// DAY SELECTOR

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                daySelector(1),
                daySelector(2),
                daySelector(3),

              ],

            ),

            const SizedBox(height: 25),

            buildMeals(),

          ],

        ),

      ),

    );

  }
}