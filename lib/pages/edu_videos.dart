import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class EduVideos extends StatefulWidget {
  @override
  _EduVideos createState() => _EduVideos();
}

class _EduVideos extends State<EduVideos> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    String videoUrl = 'https://youtu.be/vcNAhUqH9U0?si=SBn4zTs7iDunFwaH';
    String? videoId = YoutubePlayer.convertUrlToId(videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId!,
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Brushing Tutorial'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.cyanAccent],
          ),
        ),
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // YouTube Video Player
            ClipRRect(
              borderRadius: BorderRadius.circular(12), // Rounded corners
              child: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: Colors.blue,
              ),
            ),
            SizedBox(height: 20), // Spacing

            // Tutorial Text
            Expanded(
              child: ListView(
                children: [
                  Text(
                    "How to Brush Your Teeth - Steps",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),

                  tutorialStep("1. Apply Toothpaste",
                      "Place a pea-sized amount of toothpaste on your toothbrush."),
                  tutorialStep("2. Brush Outer Surfaces",
                      "Hold the toothbrush at a 45-degree angle and use short back-and-forth strokes."),
                  tutorialStep("3. Brush Inner Surfaces",
                      "Tilt the brush vertically behind the front teeth and use up-and-down strokes."),
                  tutorialStep("4. Brush Chewing Surfaces",
                      "Use a firm back-and-forth motion to clean the chewing surfaces."),
                  tutorialStep("5. Brush Your Tongue",
                      "Gently brush your tongue to remove bacteria and keep your breath fresh."),
                  tutorialStep("6. Duration",
                      "Brush for at least two minutes to ensure all areas are cleaned."),
                  tutorialStep("7. Rinse",
                      "Spit out the toothpaste and rinse your mouth with water."),

                  SizedBox(height: 20),

                  // Additional Tips
                  Text(
                    "Additional Tips",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  tutorialStep("• Frequency",
                      "Brush twice daily, in the morning and before bed."),
                  tutorialStep("• Toothbrush Care",
                      "Replace your toothbrush every 3-4 months."),
                  tutorialStep("• Flossing",
                      "Floss daily to remove plaque and food particles."),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget tutorialStep(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
