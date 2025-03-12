import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttr_app/services/firestore.dart';

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
  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  int _timerSeconds = 30; // 30 seconds timer
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
      _controller = CameraController(
        _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front),
        ResolutionPreset.medium,
      );

      await _controller.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
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
        _pauseTimer(); // Pause when time is up
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    _isTimerRunning = false;
    setState(() {});

    // ✅ Call Firestore update function when timer completes
    if (_timerSeconds == 0) {
      _firestore.updateBrushingRecord(
        widget.userId,
        widget.childId,
        widget.sessionType.toLowerCase(), // "morning" or "evening"
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "${widget.sessionType} Brushing! 😁🪥",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          Center(
            child: Container(
              height: 450,
              width: 350,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: _isCameraInitialized
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Transform(
                        alignment: Alignment.center,
                        transform:
                            Matrix4.rotationY(3.1415927), // Flip horizontally
                        child: CameraPreview(_controller),
                      ),
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
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _toggleTimer,
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.all(15),
              backgroundColor: _isTimerRunning
                  ? const Color.fromARGB(255, 7, 215, 234)
                  : const Color.fromARGB(255, 7, 215, 234),
            ),
            child: Icon(
              _isTimerRunning ? Icons.pause : Icons.play_arrow,
              size: 40,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
