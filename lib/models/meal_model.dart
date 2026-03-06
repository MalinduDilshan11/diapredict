class MealModel {
  final String foodName;
  final String foodType;
  final String risk;
  final String mealType;

  MealModel({
    required this.foodName,
    required this.foodType,
    required this.risk,
    required this.mealType,
  });

  factory MealModel.fromCsv(List<String> row) {
    return MealModel(
      foodName: row[0].trim(),
      foodType: row[1].trim(),
      risk: row[2].trim(),
      mealType: row[3].trim(),
    );
  }
}