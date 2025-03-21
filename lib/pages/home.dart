import 'package:flutter/material.dart';
// import 'package:fluttr_app/main.dart';
import 'package:get/get.dart';
import 'package:fluttr_app/pages/start_brushing.dart';
import 'package:fluttr_app/pages/daily_challenges.dart';
import 'package:fluttr_app/pages/track_progress.dart';
import 'package:fluttr_app/pages/edu_videos.dart';
import 'package:fluttr_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttr_app/widgets/custom_card.dart';
import 'package:fluttr_app/pages/login.dart'; // Import the Login class

class Home extends StatefulWidget {
  final String parentId;
  final String childId;

  const Home({super.key, required this.parentId, required this.childId});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final AuthService _auth = AuthService();
  final CustomCard card = CustomCard();

  Future<String?> _loadChildSession() async {
    final prefs = await SharedPreferences.getInstance();
    String? childId = prefs.getString('childId');

    return childId ?? null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Brighter Bites"),
        backgroundColor: Colors.blueGrey,
      ),
      floatingActionButton: SizedBox(
        width: 150, // Adjust width as needed
        height: 56, // Standard FloatingActionButton height
        child: FloatingActionButton.extended(
          onPressed: () async {
            goToLogin(context);
            await _auth.signout();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Signed out successfully')),
            );
          },
          label: Text('Sign Out'),
        ),
      ),
      body: Stack(children: [
        Positioned.fill(
          child: Image.asset(
            'assets/home_bg.png',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: FutureBuilder<String?>(
              future: _auth.getUserId(), // Fetch user ID asynchronously
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                String userId = snapshot.data!; // Get user ID safely

                return Column(children: [
                  SizedBox(
                      height: 120,
                      width: 500,
                      child: Image.asset(
                        'assets/Logo.png',
                        fit: BoxFit.cover,
                      )),
                  SizedBox(
                    height: 20,
                  ),
                  SizedBox(height: 100, width: 150, child: card),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                      padding: EdgeInsets.all(30),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        shrinkWrap: true,
                        mainAxisSpacing: 20,
                        children: [
                          _buildMenuButton(
                            icon: Icons.brush,
                            label: "Start Brushing",
                            color: Colors.white,
                            onTap: () async {
                              String? childId = await _loadChildSession();
                              if (childId != null) {
                                Get.to(() => StartBrushingPage(
                                      userId: userId,
                                      childId: childId,
                                    ));
                              }
                            },
                          ),
                          _buildMenuButton(
                            icon: Icons.flag,
                            label: " Challenges",
                            color: Colors.white,
                            onTap: () {
                              Get.to(() => DailyChallenges());
                            },
                          ),
                          _buildMenuButton(
                            icon: Icons.track_changes,
                            label: "Habit Tracker",
                            color: Colors.white,
                            onTap: () {
                              Get.to(() => TrackProgress());
                            },
                          ),
                          _buildMenuButton(
                            icon: Icons.video_library,
                            label: "Educational Videos",
                            color: Colors.white,
                            onTap: () {
                              Get.to(() => EduVideos());
                            },
                          ),
                        ],
                      ))
                ]);
              },
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.black),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // void goToMain(BuildContext context) {
  //   Navigator.pushReplacement(
  //     context,
  //     MaterialPageRoute(
  //         builder: (context) =>
  //             Home()), // Replace with the main widget of your app
  //   );
  // }

  void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
