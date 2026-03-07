import 'package:flutter/material.dart';
import 'assess_risk_screen.dart';
import 'meal_plan_view_screen.dart';
import 'welcome_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userName;
  final String email;
  final String riskLevel;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.email,
    required this.riskLevel,
  });

  Color riskColor() {
    if (riskLevel.toUpperCase() == "LOW") return Colors.green;
    if (riskLevel.toUpperCase() == "MEDIUM") return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final color = riskColor();

    return Scaffold(
      backgroundColor: const Color(0xfff4f7fb),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Animated Header
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xff4facfe),
                    Color(0xff00f2fe),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
              child: Column(
                children: [
                  /// Avatar Glow Ring + Random Avatar
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(0.7),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 55,
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(
                        "https://api.dicebear.com/7.x/personas/png?seed=$userName",
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    email,
                    style: const TextStyle(
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 14),

                  /// Risk Badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.health_and_safety,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Risk Level: $riskLevel",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Stat Cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: statCard(
                      "Risk Level",
                      riskLevel,
                      Icons.favorite,
                      color,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: statCard(
                      "Meal Plan",
                      "3 Days",
                      Icons.restaurant_menu,
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Actions Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Health Actions",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 15),

                    /// Update Assessment
                    actionTile(
                      icon: Icons.edit,
                      title: "Update Health Assessment",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AssessRiskScreen(
                              userName: userName,
                              email: email,
                            ),
                          ),
                        );
                      },
                    ),

                    /// View Meal Plan
                    actionTile(
                      icon: Icons.restaurant_menu,
                      title: "View Meal Plan",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealPlanViewScreen(
                              email: email,
                              userName: userName,
                              riskLevel: riskLevel,
                            ),
                          ),
                        );
                      },
                    ),

                    /// Logout
                    actionTile(
                      icon: Icons.logout,
                      title: "Logout",
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WelcomeScreen(),
                          ),
                          (route) => false,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Stat Card
  Widget statCard(
      String title, String value, IconData icon, Color color) {
    return Container(
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
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
        ],
      ),
    );
  }

  /// Action Tile
  Widget actionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.1),
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}