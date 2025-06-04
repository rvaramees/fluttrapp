import 'package:brighter_bites/domain/entities/child.dart';
import 'package:brighter_bites/presentation/bloc/child/child_bloc.dart';
import 'package:brighter_bites/presentation/bloc/selected_child/selected_child_bloc.dart';
import 'package:brighter_bites/presentation/pages/home.dart';
import 'package:brighter_bites/presentation/pages/login.dart';
import 'package:brighter_bites/presentation/pages/parent_dashboard.dart';
import 'package:brighter_bites/presentation/widgets/play_button.dart';
import 'package:brighter_bites/presentation/widgets/start_bg.dart';
import 'package:brighter_bites/services/auth_service.dart';
import 'package:brighter_bites/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import the Login class

class StartPage extends StatefulWidget {
  const StartPage({super.key});
  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  String? parentId;
  String? childId;
  String? childName;
  bool isLoading = true;
  final TextEditingController _password = TextEditingController();
  final AuthService _auth = AuthService();
  final FirestoreService _firestore = FirestoreService();

  Future<void> _loadChildSession() async {
    // childName =
    // Get the childId from SharedPreferences
    // final prefs = await SharedPreferences.getInstance();
    // final prefs = await SharedPreferences.getInstance();
    // String? parentId = prefs.getString('parentId');
    // String? childId = prefs.getString('childId');

    // print("🔍 Retrieved parentId: $parentId");
    // print("🔍 Retrieved childId: $childId");

    // setState(() {
    //   this.parentId = parentId;
    //   this.childId = childId;
    // });

    // if (parentId != null && childId != null) {
    //   await _firestore.checkAndCreateDailyBrushingRecord(childId);
    // } else {
    //   print("❌ Error: parentId or childId is null");
    // }
    // // Return childId
  }

  Future<bool> _checkPassword() async {
    final prefs = await SharedPreferences.getInstance();
    String? password = prefs.getString('password');
    if (password == _password.text) {
      return true;
    }
    return false;
  }
  // void _initialize() async {
  //   // Get childId
  //   if (loadedChildId != null) {
  //     print("✅ Loaded Child ID: $loadedChildId");
  //     await _firestore.checkAndCreateDailyBrushingRecord(childId);
  //   } else {
  //     print("❌ Error: childId is null");
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadChildSession();
    isLoading = false;
  }

  void openLoginBox({String? habitId}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter your password'),
              SizedBox(height: 10),
              TextField(
                controller: _password,
                decoration: InputDecoration(
                  hintText: 'Password',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _checkPassword().then((value) {
                    if (value) {
                      Navigator.pushReplacementNamed(context, '/parent_home');
                      print('Password is correct');
                    } else {
                      Get.snackbar('Error', 'Invalid password');
                    }
                  });
                },
                child: Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Brighter Bites"),
      //   backgroundColor: Colors.blueGrey,
      //   actions: [],
      // ),
      body: BlocBuilder<ChildBloc, ChildState>(
        builder: (context, childState) {
          if (childState is ChildLoaded) {
            final children = childState.children;

            if (children.isEmpty) {
              return const Center(
                child: Text(
                    'No children available. Please add children from the parent dashboard.'),
              );
            }

            return Stack(
              children: [
                StartBg(),
                Container(
                  child: Column(children: [
                    SizedBox(
                      height: 100,
                    ),
                    SizedBox(
                      height: 350,
                      width: 350,
                      child: Image.asset(
                        'assets/logo2.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedPlayButton(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Home(),
                                    ),
                                  );
                                },
                              )
                            ],
                          ),
                        )),
                    SizedBox(height: 20),
                    BlocBuilder<SelectedChildBloc, SelectedChildState>(
                      builder: (context, selectedChildState) {
                        String buttonText = 'Select Child'; // Default Text

                        if (selectedChildState is ChildSelected) {
                          buttonText =
                              selectedChildState.child.name; // Display name
                        }

                        return ElevatedButton(
                          onPressed: () {
                            _showChildSelectionDialog(context, children);
                          },
                          child: Text(buttonText),
                        );
                      },
                    ),
                  ]),
                ),
                ElevatedButton(
                  onPressed: () {
                    openLoginBox();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shadowColor: Colors.black,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Parent Dashboard',
                  ),
                ),
              ],
            );
          } else if (childState is ChildLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (childState is ChildError) {
            return Center(
                child: Text('Error loading children: ${childState.message}'));
          } else {
            return const Center(child: Text('Loading...'));
          }
        },
      ),
    );
  }

  void goToLogin(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  void goToParentDashboard(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ParentDashboard()),
    );
  }

  void _showChildSelectionDialog(BuildContext context, List<Child> children) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Child'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: children.map((child) {
                return ListTile(
                  title: Text(child.name),
                  onTap: () {
                    // Dispatch SelectChild event
                    BlocProvider.of<SelectedChildBloc>(context)
                        .add(SelectChild(child: child));
                    Navigator.of(context).pop(); // Close the dialog
                    print('child: ${child.name}');
                    setState(() {
                      childName = child.name;
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
