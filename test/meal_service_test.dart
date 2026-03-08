import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:diapredict/services/meal_service.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadMeals parses CSV correctly', () async {

    final meals = await MealService.loadMeals();

    expect(meals.isNotEmpty, true);

    expect(meals.first.foodName, isA<String>());

  });

}