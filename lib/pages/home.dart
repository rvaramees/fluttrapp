import 'package:flutter/material.dart';
// import 'package:fluttr_app/main.dart';
import 'package:get/get.dart';
import 'package:fluttr_app/pages/start_brushing.dart';
import 'package:fluttr_app/pages/daily_challenges.dart';
import 'package:fluttr_app/pages/track_progress.dart';
import 'package:fluttr_app/pages/edu_videos.dart';
import 'package:fluttr_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.cyanAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FutureBuilder<String?>(
            future: _auth.getUserId(), // Fetch user ID asynchronously
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              String userId = snapshot.data!; // Get user ID safely

              return GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                children: [
                  _buildMenuButton(
                    icon: Icons.brush,
                    label: "Start Brushing",
                    color: Colors.orange,
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
                    label: "Daily Challenges",
                    color: Colors.green,
                    onTap: () {
                      Get.to(() => DailyChallenges());
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.track_changes,
                    label: "Track Progress",
                    color: Colors.purple,
                    onTap: () {
                      Get.to(() => const TrackProgress());
                    },
                  ),
                  _buildMenuButton(
                    icon: Icons.video_library,
                    label: "Educational Videos",
                    color: Colors.red,
                    onTap: () {
                      Get.to(() => const EduVideos());
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      goToLogin(context);
                      await _auth.signout();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Signed out successfully')),
                      );
                    },
                    child: const Text('Sign Out'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
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
            Icon(icon, size: 50, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
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
