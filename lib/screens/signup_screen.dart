import 'package:flutter/material.dart';
import '../services/mongo_database.dart';
import 'login_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // -------- VALIDATORS --------

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }

    final nameReg = RegExp(r'^[a-zA-Z ]+$');

    if (!nameReg.hasMatch(value)) {
      return "Name can contain letters only";
    }

    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }

    final emailReg =
        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailReg.hasMatch(value)) {
      return "Enter a valid email address";
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }

    if (value.length < 8) {
      return "Password must be at least 8 characters";
    }

    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return "Password must include a number";
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return "Password must include a special character";
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Confirm your password";
    }

    if (value != _passwordController.text) {
      return "Passwords do not match";
    }

    return null;
  }

  // -------- SIGNUP --------

  void _signup() async {

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final result = await MongoDatabase.insertUser(name, email, password);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Signup failed')),
    );

    if (result['success'] == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  Image.asset('assets/images/logo.png', width: 180, height: 180),

                  const SizedBox(height: 20),

                  const Text(
                    'DiaPredict',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Predict • Prevent • Personalize.',
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 40),

                  CustomTextField(
                    label: 'Full Name',
                    controller: _nameController,
                    icon: Icons.person_outline,
                    validator: _validateName,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Email',
                    controller: _emailController,
                    icon: Icons.email_outlined,
                    validator: _validateEmail,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Password',
                    controller: _passwordController,
                    isPassword: true,
                    icon: Icons.lock_outline,
                    validator: _validatePassword,
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    label: 'Confirm Password',
                    controller: _confirmPasswordController,
                    isPassword: true,
                    icon: Icons.lock_outline,
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: 40),

                  CustomButton(
                    text: 'Sign Up',
                    onPressed: _signup,
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Already have an account? "),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()),
                        ),
                        child: const Text(
                          'Login',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}