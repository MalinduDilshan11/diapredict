import 'package:flutter/services.dart';
import '../models/meal_model.dart';

class MealService {
  static Future<List<MealModel>> loadMeals() async {
    final rawData = await rootBundle.loadString('assets/balanced_meal2.csv');
    final lines = rawData.split('\n');

    List<MealModel> meals = [];

    for (int i = 1; i < lines.length; i++) {
      final row = lines[i].trim().split(',');

      if (row.length >= 4) {
        meals.add(MealModel.fromCsv(row));
      }
    }

    return meals;
  }
}