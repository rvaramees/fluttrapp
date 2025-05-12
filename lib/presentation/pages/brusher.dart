import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttr_app/animation/left_side_brush.dart';
import 'package:fluttr_app/core/di/injection_container.dart';
import 'package:fluttr_app/presentation/bloc/selected_child/selected_child_bloc.dart';
import 'package:fluttr_app/services/auth_service.dart';
import 'package:fluttr_app/presentation/widgets/horiscrolling.dart';
import 'package:fluttr_app/services/preferences_service.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fluttr_app/services/firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:fluttr_app/animation/rotating_brush.dart';
// import 'package:fluttr_app/services/face_detection_service.dart';
// import 'package:fluttr_app/services/face_painter.dart';

import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

class Brusher extends StatefulWidget {
  final String sessionType;

  const Brusher({super.key, required this.sessionType});

  @override
  State<Brusher> createState() => _BrusherState();
}

class _BrusherState extends State<Brusher> {
  final FirestoreService _firestore = FirestoreService();

  late CameraController _controller;
  late List<CameraDescription> _cameras;
  bool _isCameraInitialized = false;
  var frontCamera;
  int _timerSeconds = 30;
  Timer? _timer;
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isTimerRunning = false;
  String? _childId;
  bool isBrushingTime = true;
  List<String> musicList = [
    "sounds/The_Gardens_Remix.mp3",
    "sounds/linga_guli.mp3",
  ];
  String playingMusic =
      "sounds/The_Gardens_Remix.mp3"; // ✅ Ensure correct asset path

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer(); // ✅ Initialize AudioPlayer
    _initCamera();
  }

  Future<void> loadSessionData() async {
    final selectedChildBloc =
        sl<SelectedChildBloc>(); // Access the bloc using GetIt
    if (selectedChildBloc.state is ChildSelected) {
      final selectedChildId =
          await (selectedChildBloc.state as ChildSelected).child.childId;
      print('The childId is: $selectedChildId');
      setState(() {
        _childId = selectedChildId;
      });
      // Do something with the childId
    } else {
      print('No child selected');
      setState(() {
        _childId = null; // Set to null if no child is selected
      });
    }
  }

  // void loadSessionData() async {
  //   final childId = await BlocProvider.of<

  Future<void> _playMusic() async {
    try {
      if (!_isPlaying) {
        await _audioPlayer
            .play(AssetSource(playingMusic)); // ✅ Ensure correct asset path
        setState(() => _isPlaying = true);
        print("Playing music...");
      }
    } catch (e) {
      print("Error playing music: $e");
    }
  }

  Future<void> _stopMusic() async {
    try {
      await _audioPlayer.stop();
      setState(() => _isPlaying = false);
    } catch (e) {
      print("Error stopping music: $e");
    }
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
    _playMusic(); // ✅ Start music when timer starts
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

  Future<void> _pauseTimer() async {
    _timer?.cancel();
    _isTimerRunning = false;
    _stopMusic(); // ✅ Stop music when timer stops
    setState(() {});

    String timeOfDay =
        widget.sessionType.toLowerCase(); // "morning" or "evening"

    setState(() {});

    if (_timerSeconds == 0) {
      // if (await _firestore.isBrushingDone(_childId!)) {
      _firestore.updateBrushingRecord(_childId!, timeOfDay);
      print("Brushing record updated for child ID: $_childId");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Brushing record updated!")),
      );
      _firestore.updateExp(_childId!);
      print("Experience points updated for child ID: $_childId");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Experience points updated!")),
      );
    }
  }

  void _changeMusic(String track) {
    if (_isPlaying) {
      _stopMusic(); // Stop current music before changing
    }
    setState(() {
      playingMusic = track;
    }); // Play new music
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    _audioPlayer.dispose(); // ✅ Properly dispose of AudioPlayer
    super.dispose();
  }

  PreferencesService preferencesService = PreferencesService();
  String? morningTime;
  String? eveningTime;
  Future<void> getBrushTimings() async {
    if (_childId == null) {
      print('User ID or Child ID is null. Cannot fetch brushing timings.');
      return;
    }
    Map<String, dynamic>? preferences =
        await preferencesService.getBrushingPreferences(_childId!);

    setState(() {
      morningTime = preferences?["morningTime"];
      eveningTime = preferences?["eveningTime"];
    });
    _checkBrushingTime();
  }

  void _checkBrushingTime() async {
    await getBrushTimings();
    DateTime now = DateTime.now();
    String currentTime = DateFormat.Hm().format(now);

    if (morningTime != null && _isWithinTimeRange(morningTime!, currentTime)) {
      setState(() {
        isBrushingTime = true;
      });
    } else if (eveningTime != null &&
        _isWithinTimeRange(eveningTime!, currentTime)) {
      setState(() {
        isBrushingTime = true;
      });
    } else {
      setState(() {
        isBrushingTime = false;
      });
    }
    print(currentTime);
    print(isBrushingTime);
  }

  bool _isWithinTimeRange(String brushingTime, String currentTime) {
    try {
      // Parse brushing time and current time into DateTime with today's date
      DateTime now = DateTime.now();
      DateTime brushingDateTime = _parseTime(brushingTime, now);
      DateTime currentDateTime = _parseTime(currentTime, now);

      print("Brushing Time: $brushingDateTime");
      print("Current Time: $currentDateTime");

      return currentDateTime
              .isAfter(brushingDateTime.subtract(Duration(minutes: 1))) &&
          currentDateTime.isBefore(brushingDateTime.add(Duration(hours: 3)));
    } catch (e) {
      print("Error in _isWithinTimeRange: $e");
      return false;
    }
  }

  DateTime _parseTime(String timeString, DateTime today) {
    try {
      DateFormat format = DateFormat.jm();
      DateTime parsedTime = format.parse(timeString);

      return DateTime(today.year, today.month, today.day, parsedTime.hour,
          parsedTime.minute);
    } catch (e) {
      print("Error parsing time: $e");
      return today;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 6, 152, 224),
        appBar: AppBar(
          title: Text("Brighter Brushing! 🦷✨", style: TextStyle(fontSize: 22)),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
          actions: [
            // 🔥 Music Swap Button
            PopupMenuButton<String>(
              icon: Icon(Icons.music_note), // Music icon in AppBar
              onSelected: _changeMusic,
              itemBuilder: (context) => musicList
                  .map((track) => PopupMenuItem(
                        value: track,
                        child:
                            Text(track.split('/').last.replaceAll('.mp3', '')),
                      ))
                  .toList(),
            ),
          ],
        ),
        body: Stack(children: [
          Horiscrolling(),
          BlocBuilder<SelectedChildBloc, SelectedChildState>(
            builder: (context, state) {
              final childId = (state as ChildSelected).child.childId;
              print('The childId is: $childId');
              _childId = childId;
              return Column(
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
                                    child: SizedBox(
                                      height: 450, // Camera preview height
                                      width: 300,
                                      child: CameraPreview(_controller),
                                    ),
                                  ),
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
                      child: ElevatedButton(
                        onPressed: _pauseTimer,
                        child: Text(
                          "Time Left: ${(_timerSeconds ~/ 60).toString().padLeft(2, '0')}:${(_timerSeconds % 60).toString().padLeft(2, '0')}",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      )),
                  SizedBox(height: 40),

                  /// Use Flexible here to avoid Expanded error
                  Flexible(
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: (_isTimerRunning)
                          ? Column(
                              // Wrap in Column to allow Expanded usage
                              children: [
                                Expanded(
                                  // Now it's safe to use inside Column
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(30),
                                        topRight: Radius.circular(30),
                                      ),
                                    ),
                                    alignment: Alignment.topCenter,
                                    child: (_timerSeconds > 10)
                                        ? (_timerSeconds > 20)
                                            ? Column(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/teeth.png',
                                                        width: 300,
                                                        height: 150,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      ToothbrushAnimation(),
                                                    ],
                                                  ),
                                                  Text("Brush at the front",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              )
                                            : Column(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Image.asset(
                                                        'assets/teeth.png',
                                                        width: 300,
                                                        height: 150,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      SideTeethAnimation(
                                                        isLeft: true,
                                                      ),
                                                    ],
                                                  ),
                                                  Text("Brush at the left side",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.bold))
                                                ],
                                              )
                                        : Column(
                                            children: [
                                              Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Image.asset(
                                                    'assets/teeth.png',
                                                    width: 300,
                                                    height: 150,
                                                    fit: BoxFit.contain,
                                                  ),
                                                  SideTeethAnimation(
                                                      isLeft: false),
                                                ],
                                              ),
                                              Text("Brush at the right side",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold))
                                            ],
                                          ),
                                  ),
                                )
                              ],
                            )
                          : ElevatedButton(
                              onPressed: () {
                                // if (isBrushingTime)
                                _toggleTimer();
                              },
                              child: Image.asset(
                                'assets/play_button.png',
                                width: 75,
                                height: 120,
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ]));
  }
}
