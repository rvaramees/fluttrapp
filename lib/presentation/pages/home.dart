import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/domain/usecases/child/get_child_usecase.dart';
import 'package:fluttr_app/presentation/bloc/selected_child/selected_child_bloc.dart';
import 'package:fluttr_app/presentation/widgets/loading.dart';
import 'package:fluttr_app/services/firestore.dart';
import 'package:fluttr_app/presentation/widgets/scrolling_background.dart';
// import 'package:fluttr_app/main.dart';
import 'package:get/get.dart';
import 'package:fluttr_app/presentation/pages/start_brushing.dart';
import 'package:fluttr_app/presentation/pages/daily_challenges.dart';
import 'package:fluttr_app/presentation/pages/track_progress.dart';
import 'package:fluttr_app/presentation/pages/edu_videos.dart';
import 'package:fluttr_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fluttr_app/presentation/widgets/custom_card.dart';
import 'package:fluttr_app/presentation/pages/login.dart'; // Import the Login class

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? parentId;
  String? childId;
  bool isLoading = true;
  final AuthService _auth = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  int? level;
  int? exp;
  String? childName;

  // Future<String?> _loadChildSession() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   String? childId = prefs.getString('childId');

  //   return childId ?? null;
  // }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    _initializeLevel();
  }

  Future<void> _initializeLevel() async {
    BlocProvider.of<SelectedChildBloc>(context)
        .add(CheckPreviousSelectedChild());
    final Child? child =
        (context.read<SelectedChildBloc>().state is ChildSelected)
            ? (context.read<SelectedChildBloc>().state as ChildSelected).child
            : null;
    if (child == null) {
      print("No child selected");
      return;
    }
    print('${child.name}');
    await _firestoreService.updateLevel(child.childId);
    level = await _firestoreService.getLevel(child.childId);
    exp = await _firestoreService.getExp(child.childId);
    print("Level: $level");
    print("Exp: $exp");
    setState(() {
      isLoading = false; // Set loading to false only after data is fetched
    });
  }

  @override
  Widget build(BuildContext context) {
    return (isLoading == true)
        ? LoadingPage()
        : Scaffold(
            appBar: AppBar(
              title: const Text("Brighter Bites"),
              backgroundColor: Colors.blueGrey,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/start');
                },
              ),
            ),
            body: Stack(children: [
              ScrollingBackground(),
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
                          height: 20,
                        ),
                        SizedBox(
                          // height: 100,
                          // width: 215,
                          child: BlocBuilder<SelectedChildBloc,
                              SelectedChildState>(
                            builder: (context, state) {
                              if (state is ChildSelected) {
                                return CustomCard(
                                    level: state.child.level,
                                    exp: state.child.exp,
                                    name: state.child.name);
                              } else {
                                return Text('No child selected');
                              }
                            },
                          ),
                        ),
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
                                    // String? childId = await _loadChildSession();
                                    Navigator.pushReplacementNamed(
                                        context, '/brusher');
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
                                    Navigator.pushReplacementNamed(
                                        context, '/habits');
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
