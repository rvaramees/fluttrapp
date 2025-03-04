import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fluttr_app/pages/start_brushing.dart';
import 'package:fluttr_app/pages/daily_challenges.dart';
import 'package:fluttr_app/pages/track_progress.dart';
import 'package:fluttr_app/pages/edu_videos.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  void openNoteBox() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Brighter Bites"),
        backgroundColor: Colors.blueGrey,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.cyanAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildMenuButton(
                icon: Icons.brush,
                label: "Start Brushing",
                color: Colors.orange,
                onTap: () {
                  Get.to(() => const StartBrushing());
                },
              ),
              _buildMenuButton(
                icon: Icons.flag,
                label: "Daily Challenges",
                color: Colors.green,
                onTap: () {
                  Get.to(() => DailyChallenges());
                  // Handle Daily Challenges tap
                },
              ),
              _buildMenuButton(
                icon: Icons.track_changes,
                label: "Track Progress",
                color: Colors.purple,
                onTap: () {
                  Get.to(() => const TrackProgress());
                  // Handle Track Progress tap
                },
              ),
              _buildMenuButton(
                icon: Icons.video_library,
                label: "Educational Videos",
                color: Colors.red,
                onTap: () {
                  Get.to(() => const EduVideos());
                  // Handle Educational Videos tap
                },
              ),
            ],
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
            SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
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
}
