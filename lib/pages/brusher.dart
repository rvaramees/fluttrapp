import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttr_app/services/firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:fluttr_app/animation/rotating_brush.dart';
// import 'package:fluttr_app/services/face_detection_service.dart';
// import 'package:fluttr_app/services/face_painter.dart';

import 'dart:async';

class Brusher extends StatefulWidget {
  final String sessionType; // Morning or Evening
  final String userId;
  final String childId;

  const Brusher({
    super.key,
    required this.sessionType,
    required this.userId,
    required this.childId,
  });

  @override
  State<Brusher> createState() => _BrusherState();
}

class _BrusherState extends State<Brusher> {
  FirestoreService _firestore = FirestoreService();
  // final FaceDetectionService _faceDetectionService = FaceDetectionService();
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  var frontCamera;
  int _timerSeconds = 30;
  Timer? _timer;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      _cameras = await availableCameras();
      final frontCameras = _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front);
      setState(() {
        frontCamera = frontCameras;
      });
      _controller = CameraController(
        frontCameras,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller.initialize();
      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera permission is required!")),
      );
    }
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _pauseTimer();
    } else {
      _startTimer();
    }
  }

  void _startTimer() {
    _isTimerRunning = true;
    setState(() {});

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() {
          _timerSeconds--;
        });
      } else {
        _pauseTimer();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    setState(() {});

    if (_timerSeconds == 0) {
      _firestore.updateBrushingRecord(
        widget.userId,
        widget.childId,
        widget.sessionType.toLowerCase(),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    // _faceDetectionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 6, 152, 224),
      appBar: AppBar(
        title: Text("Brighter Brushing! 🦷✨", style: TextStyle(fontSize: 22)),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 450,
              width: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _isCameraInitialized
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Transform(
                              alignment: Alignment.topCenter,
                              transform: Matrix4.rotationY(3.1415927),
                              child: Container(
                                height:
                                    450, // This defines the camera preview height
                                width: 300,
                                child: CameraPreview(_controller),
                              )),
                        ),
                      ],
                    )
                  : Center(child: CircularProgressIndicator()),
            ),
          ),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "Time Left: ${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SizedBox(height: 40),
          Expanded(
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _isTimerRunning
                  ? Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(
                                30), // Adjust the radius as needed
                            topRight: Radius.circular(30),
                          ),
                        ),
                        alignment: Alignment.topCenter,
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment
                                  .center, // Aligns both the image and animation
                              children: [
                                // Teeth Image
                                Image.asset(
                                  'assets/teeth.png', // Make sure the image is in your assets folder
                                  width: 300, // Adjust width as needed
                                  height: 150, // Adjust height as needed
                                  fit: BoxFit.contain,
                                ),
                                // Toothbrush Animation on top of teeth
                                ToothbrushAnimation(),
                              ],
                            ),
                            Text("Brush in the Rotated Method",
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _toggleTimer,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(15),
                      ),
                      child: Icon(Icons.play_arrow,
                          key: ValueKey(2), size: 40, color: Colors.green),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
