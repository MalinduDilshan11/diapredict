import 'package:flutter/material.dart';
// Ensure this import matches your file structure
// import 'package:your_project_name/home_screen.dart'; 

class AssessRiskScreen extends StatefulWidget {
  const AssessRiskScreen({super.key});

  @override
  State<AssessRiskScreen> createState() => _AssessRiskScreenState();
}

class _AssessRiskScreenState extends State<AssessRiskScreen> {
  int currentStep = 0;
  final int totalSteps = 10;

  // Answers storage (Original logic preserved)
  String? ageGroup;
  String? gender;
  double height = 170.0;
  double weight = 70.0;
  double bmi = 24.2;
  bool? highBP;
  bool? highChol;
  String? generalHealth;
  bool? physActivity;
  bool? fruits;
  bool? veggies;
  bool? diffWalk;

  final List<String> ageGroups = [
    '18-24', '25-29', '30-34', '35-39', '40-44',
    '45-49', '50-54', '55-59', '60-64', '65-69',
    '70-74', '75-79', '80+'
  ];

  final List<String> healthOptions = ['Excellent', 'Very good', 'Good', 'Fair', 'Poor'];

  @override
  void initState() {
    super.initState();
    _calculateBMI();
  }

  // --- ORIGINAL FUNCTIONS ---
  void _calculateBMI() {
    if (height > 0 && weight > 0) {
      setState(() {
        bmi = weight / ((height / 100) * (height / 100));
      });
    }
  }

  Color _getBmiColor() {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  String _getBmiStatus() {
    if (bmi < 18.5) return "Underweight";
    if (bmi < 25) return "Normal";
    if (bmi < 30) return "Overweight";
    return "Obese";
  }

  void nextStep() {
    if (currentStep < totalSteps - 1) {
      setState(() => currentStep++);
    } else {
      _calculateRisk();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() => currentStep--);
    }
  }

  void _calculateRisk() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text('All Set!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('Your risk assessment is complete.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Replaced Navigator.pop with a direct push to Home
                  // Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: StadiumBorder()),
                child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- DESIGN HELPERS ---
  Map<String, dynamic> _getStepDesign() {
    switch (currentStep) {
      case 0: return {'icon': Icons.cake_rounded, 'color': Colors.indigo, 'label': 'Age'};
      case 1: return {'icon': Icons.wc_rounded, 'color': Colors.blue, 'label': 'Gender'};
      case 2: return {'icon': Icons.monitor_weight_rounded, 'color': Colors.teal, 'label': 'Body Info'};
      case 3: return {'icon': Icons.favorite_rounded, 'color': Colors.redAccent, 'label': 'Blood Pressure'};
      case 4: return {'icon': Icons.bloodtype_rounded, 'color': Colors.orange, 'label': 'Cholesterol'};
      case 5: return {'icon': Icons.health_and_safety_rounded, 'color': Colors.blueGrey, 'label': 'Overall Health'};
      case 6: return {'icon': Icons.fitness_center_rounded, 'color': Colors.green, 'label': 'Activity'};
      case 7: return {'icon': Icons.restaurant_rounded, 'color': Colors.orangeAccent, 'label': 'Fruit Intake'};
      case 8: return {'icon': Icons.eco_rounded, 'color': Colors.lightGreen, 'label': 'Vegetables'};
      case 9: return {'icon': Icons.blind_rounded, 'color': Colors.brown, 'label': 'Mobility'};
      default: return {'icon': Icons.help_outline, 'color': Colors.blue, 'label': 'Question'};
    }
  }

  String _getFullQuestion() {
    switch (currentStep) {
      case 0: return 'Which age group do you belong to?';
      case 1: return 'What is your gender?';
      case 2: return 'Please enter your current height and weight:';
      case 3: return 'Has a doctor ever told you that you have high blood pressure?';
      case 4: return 'Has a doctor ever told you that you have high cholesterol?';
      case 5: return 'In general, how would you rate your health?';
      case 6: return 'In the past 30 days, did you do any physical activity or exercise?';
      case 7: return 'Do you eat fruit at least once or more times per day?';
      case 8: return 'Do you eat vegetables at least once or more times per day?';
      case 9: return 'Do you have serious difficulty walking or climbing stairs?';
      default: return '';
    }
  }

  Widget _buildOptionTile({required String title, required bool isSelected, required VoidCallback onTap}) {
    Color themeColor = _getStepDesign()['color'];
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? themeColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? themeColor : Colors.grey.shade200, width: 2),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined, color: isSelected ? themeColor : Colors.grey),
            const SizedBox(width: 15),
            Text(title, style: TextStyle(fontSize: 17, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stepDesign = _getStepDesign();
    final Color themeColor = stepDesign['color'];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(stepDesign['label'], style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
            child: LinearProgressIndicator(
              value: (currentStep + 1) / totalSteps,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(themeColor),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: themeColor.withOpacity(0.1), blurRadius: 20)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 30),
                      color: themeColor.withOpacity(0.1),
                      child: Icon(stepDesign['icon'], color: themeColor, size: 60),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Text(
                              _getFullQuestion(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            const SizedBox(height: 25),
                            _buildStepFormContent(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(25, 0, 25, 30),
            child: Row(
              children: [
                if (currentStep > 0)
                  IconButton(
                    onPressed: previousStep,
                    icon: const Icon(Icons.arrow_back_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: const Size(60, 60),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                if (currentStep > 0) const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: Text(
                      currentStep == totalSteps - 1 ? 'Finish' : 'Continue',
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepFormContent() {
    switch (currentStep) {
      case 0:
        return DropdownButtonFormField<String>(
          value: ageGroup,
          items: ageGroups.map((age) => DropdownMenuItem(value: age, child: Text(age))).toList(),
          onChanged: (value) => setState(() => ageGroup = value),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        );
      case 1:
        return Column(
          children: [
            _buildOptionTile(title: 'Male', isSelected: gender == 'Male', onTap: () => setState(() => gender = 'Male')),
            _buildOptionTile(title: 'Female', isSelected: gender == 'Female', onTap: () => setState(() => gender = 'Female')),
          ],
        );
      case 2:
        return Column(
          children: [
            _buildInputField('Height (cm)', (v) { height = double.tryParse(v) ?? 170.0; _calculateBMI(); }),
            const SizedBox(height: 15),
            _buildInputField('Weight (kg)', (v) { weight = double.tryParse(v) ?? 70.0; _calculateBMI(); }),
            const SizedBox(height: 25),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _getBmiColor().withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text('BMI: ${bmi.toStringAsFixed(1)}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getBmiColor())),
                  Text(_getBmiStatus(), style: TextStyle(fontWeight: FontWeight.bold, color: _getBmiColor())),
                ],
              ),
            )
          ],
        );
      default:
        bool isHealth = currentStep == 5;
        dynamic currentVal = isHealth ? generalHealth : (currentStep == 3 ? highBP : currentStep == 4 ? highChol : currentStep == 6 ? physActivity : currentStep == 7 ? fruits : currentStep == 8 ? veggies : diffWalk);
        
        return Column(
          children: isHealth 
            ? healthOptions.map((opt) => _buildOptionTile(title: opt, isSelected: generalHealth == opt, onTap: () => setState(() => generalHealth = opt))).toList()
            : [
                _buildOptionTile(title: 'Yes', isSelected: currentVal == true, onTap: () => _updateAnswer(true)),
                _buildOptionTile(title: 'No', isSelected: currentVal == false, onTap: () => _updateAnswer(false)),
              ],
        );
    }
  }

  Widget _buildInputField(String label, Function(String) onChange) {
    return TextFormField(
      keyboardType: TextInputType.number,
      onChanged: onChange,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  void _updateAnswer(bool val) {
    setState(() {
      if (currentStep == 3) highBP = val;
      if (currentStep == 4) highChol = val;
      if (currentStep == 6) physActivity = val;
      if (currentStep == 7) fruits = val;
      if (currentStep == 8) veggies = val;
      if (currentStep == 9) diffWalk = val;
    });
  }
}