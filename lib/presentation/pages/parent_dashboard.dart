import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttr_app/core/di/injection_container.dart' as di;
import 'package:fluttr_app/domain/entities/child.dart';
import 'package:fluttr_app/domain/usecases/child/get_child_usecase.dart';
import 'package:fluttr_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:fluttr_app/presentation/bloc/child/child_bloc.dart';
import 'package:fluttr_app/presentation/bloc/selected_child/selected_child_bloc.dart';
import 'package:fluttr_app/presentation/pages/add_child.dart';
import 'package:fluttr_app/services/firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  final TextEditingController textcontroller = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  TimeOfDay? selectedTime;
  final FirestoreService firestoreService = FirestoreService();
//   String? parentId;
//   String? childId;
//   String? parentName;
//   String? childName;
//   int? level;
//   int? exp;
//   String? today;
//   Map<String, dynamic>? dailyProgress;
//   final FirestoreService _firestoreService = FirestoreService();

//   @override
//   void initState() {
//     super.initState();
//     _loadDailyProgress();
//   }

//   Future<void> _loadDailyProgress() async {
//     final prefs = await SharedPreferences.getInstance();
//     String today = DateTime.now()
//         .toIso8601String()
//         .split('T')[0]; // Store only the date (YYYY-MM-DD)
//     print(today);
//     final FirestoreService firestoreService = FirestoreService();
//     String? parentId = prefs.getString('parentId');
//     String? childId = prefs.getString('childId');
//     if (parentId != null && childId != null) {
//       Map<String, dynamic>? dailyProgressRef =
//           await firestoreService.getDailyProgress(childId);
//       setState(() {
//         dailyProgress = dailyProgressRef;
//       });
//     }
//   }

//   Future<void> _loadChildSession() async {
//     final prefs = await SharedPreferences.getInstance();
//     String? parentId = prefs.getString('parentId');
//     String? childId = prefs.getString('childId');
//     String? parentName = await _firestoreService.getParentName(parentId!);
//     String? childName =
//         await _firestoreService.getChildName(parentId, childId!);
//     int childLevel = await _firestoreService.getLevel(parentId, childId);
//     int childExp = await _firestoreService.getExp(parentId, childId);
//     String today = DateTime.now().toIso8601String().split('T')[0];
//     setState(() {
//       this.parentId = parentId;
//       this.childId = childId;
//       this.parentName = parentName;
//       this.childName = childName;
//       level = childLevel;
//       exp = childExp;
//       this.today = today;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: const Text("Brighter Bites"),
//           backgroundColor: Colors.blueGrey,
//         ),
//         body: BlocBuilder<ChildBloc, ChildState>(builder: (context, state) {
//           if (state is ChildLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is ChildLoaded) {
//             Stack(
//               children: [
//                 Positioned.fill(
//                   child: Image.asset('assets/home_bg.png', fit: BoxFit.cover),
//                 ),
//                 Container(
//                     child: Padding(
//                         padding: const EdgeInsets.all(40.0),
//                         child: Center(
//                           child: Container(
//                             height: 600,
//                             padding: EdgeInsets.all(40),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               gradient: LinearGradient(
//                                 colors: [
//                                   const Color.fromARGB(255, 4, 137, 246),
//                                   Colors.lightBlueAccent,
//                                 ],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               border: Border.all(color: Colors.white, width: 5),
//                             ),
//                             child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 children: [
//                                   SizedBox(
//                                     child: Text('Welcome, Ramees',
//                                         style: TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                         )),
//                                   ),
//                                   SizedBox(
//                                     height: 20,
//                                   ),
//                                   ListView.builder(
//                                     itemCount: state.children.length,
//                                     itemBuilder: (context, index) {
//                                       return ListTile(
//                                         title: Text(
//                                           state.children[index].name,
//                                           style: TextStyle(
//                                             fontSize: 20,
//                                             fontWeight: FontWeight.bold,
//                                             color: Colors.white,
//                                           ),
//                                         ),
//                                         onTap: () {},
//                                       );
//                                     },
//                                   ),
//                                   //     Row(
//                                   //         mainAxisAlignment: MainAxisAlignment.center,
//                                   //         children: [
//                                   //           SizedBox(
//                                   //             child: Text('Level : 2',
//                                   //                 style: TextStyle(
//                                   //                   fontSize: 20,
//                                   //                   fontWeight: FontWeight.bold,
//                                   //                   color: Colors.white,
//                                   //                 )),
//                                   //           ),
//                                   //           SizedBox(
//                                   //             width: 10,
//                                   //           ),
//                                   //           SizedBox(
//                                   //             child: Text('Exp : 300',
//                                   //                 style: TextStyle(
//                                   //                   fontSize: 20,
//                                   //                   fontWeight: FontWeight.bold,
//                                   //                   color: Colors.white,
//                                   //                 )),
//                                   //           ),
//                                   //         ]),
//                                   //     SizedBox(
//                                   //       height: 20,
//                                   //     ),
//                                   //     Container(
//                                   //       child: Column(
//                                   //         children: [
//                                   //           SizedBox(
//                                   //             child: Text('Daily Progress',
//                                   //                 style: TextStyle(
//                                   //                   fontSize: 20,
//                                   //                   fontWeight: FontWeight.bold,
//                                   //                   color: Colors.white,
//                                   //                 )),
//                                   //           ),
//                                   //           Text('$today',
//                                   //               style: TextStyle(
//                                   //                 fontSize: 15,
//                                   //                 fontWeight: FontWeight.bold,
//                                   //                 color: Colors.white,
//                                   //               )),
//                                   //           SizedBox(
//                                   //             height: 20,
//                                   //           ),
//                                   //           Row(
//                                   //             mainAxisAlignment: MainAxisAlignment.center,
//                                   //             children: [
//                                   //               Text(
//                                   //                 'Brushes :',
//                                   //                 style: TextStyle(
//                                   //                   fontSize: 20,
//                                   //                   fontWeight: FontWeight.bold,
//                                   //                   color: Colors.white,
//                                   //                 ),
//                                   //               ),
//                                   //               SizedBox(
//                                   //                 width: 30,
//                                   //               ),
//                                   //               Icon(Icons.wb_sunny,
//                                   //                   size: 40,
//                                   //                   color: dailyProgress?['morning'] == true
//                                   //                       ? Colors.orange
//                                   //                       : Colors.grey),
//                                   //               SizedBox(width: 20),
//                                   //               Icon(Icons.nightlight_round,
//                                   //                   size: 40,
//                                   //                   color: dailyProgress?['evening'] == true
//                                   //                       ? Colors.white
//                                   //                       : Colors.grey),
//                                   //             ],
//                                   //           ),
//                                   //           SizedBox(
//                                   //             height: 20,
//                                   //           ),
//                                   //           ElevatedButton(
//                                   //             onPressed: () {
//                                   //               Navigator.pushNamed(context, '/add_child');
//                                   //             },
//                                   //             child: Text('Add Child'),
//                                   //           ),
//                                   //           SizedBox(
//                                   //             height: 20,
//                                   //           ),
//                                   //           ElevatedButton(
//                                   //             onPressed: () {
//                                   //               BlocProvider.of<SelectedChildBloc>(context)
//                                   //                   .add(const ClearSelectedChild());
//                                   //               BlocProvider.of<AuthBloc>(context)
//                                   //                   .add(const AuthLogoutRequested());
//                                   //               Navigator.pushReplacementNamed(
//                                   //                 context,
//                                   //                 '/login',
//                                   //               );
//                                   //             },
//                                   //             child: Text('logout'),
//                                   //           ),
//                                   //           // Text(
//                                   //           //   'Habits :',
//                                   //           //   style: TextStyle(
//                                   //           //     fontSize: 20,
//                                   //           //     fontWeight: FontWeight.bold,
//                                   //           //     color: Colors.white,
//                                   //           //   ),
//                                   //           // ),
//                                   //           // SizedBox(
//                                   //           //   // height: 20,
//                                   //           // ),
//                                   //         ],
//                                   //       ),
//                                   //     )
//                                   //   ],
//                                   // ),
//                                 ]),
//                           ),
//                         )))
//               ],
//             );
//           } else {
//             return const Center(child: Text('No children found'));
//           }
//         }));
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parent Dashboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/parent_home');
          },
        ),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () {
          //     BlocProvider.of<SelectedChildBloc>(context)
          //         .add(const ClearSelectedChild());
          //     BlocProvider.of<AuthBloc>(context)
          //         .add(const AuthLogoutRequested());
          //     Navigator.pushReplacementNamed(context, '/login');
          //   },
          // ),
        ],
      ),
      body: BlocBuilder<ChildBloc, ChildState>(
        builder: (context, state) {
          if (state is ChildLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ChildLoaded) {
            return ListView.builder(
              itemCount: state.children.length,
              itemBuilder: (context, index) {
                final child = state.children[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Age: ${child.age}'),
                        Text('Level: ${child.level}'),
                        Text('Exp: ${child.exp}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            _openChildDetails(child.childId);
                            // Navigate to child's page (not shown here)
                          },
                          child: const Text('View Details'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else if (state is ChildError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('No children found.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddChildScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openChildDetails(String childId) async {
    final GetChildUseCase getChildUseCase =
        di.sl<GetChildUseCase>(); // Get the use case

    final result = await getChildUseCase(GetChildParams(childId: childId));

    result.fold(
      (failure) {
        // Handle error (e.g., show a snackbar)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Error fetching child details: ${failure.message}')),
        );
      },
      (child) {
        // Successfully fetched the child: Show the dialog
        _showChildDetailsDialog(child);
      },
    );
  }

  void _showChildDetailsDialog(Child child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Child Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align text to the left
          children: [
            Text('Name: ${child.name}'),
            Text('Age: ${child.age}'),
            Text(
                'Level: ${child.level ?? "N/A"}'), // Handle null dentalProfileId
            Text('Exp: ${child.exp ?? "N/A"}'),
            Text(
                'Brushing Time: ${child.preferences['morning']}   ${child.preferences['evening']}'),
            // Add more child details here as needed
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Handle any action when the button is pressed
              _openHabitBox(child.childId, null);
            },
            child: const Text('Add New Habit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _openHabitBox(String childId, String? habitId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Add a new habit'),
              SizedBox(height: 10),
              TextField(
                controller: textcontroller,
                decoration: InputDecoration(
                  hintText: 'Enter habit',
                ),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  hintText: 'Enter description',
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
                child: Text(
                  selectedTime == null
                      ? 'Select Time'
                      : 'Selected Time: ${selectedTime!.format(context)}',
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              if (selectedTime == null) {
                // Show an error message if time is not selected
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please select a time')),
                );
                return;
              }
              final timeString = selectedTime!.format(context);
              if (habitId != null) {
                firestoreService.updateHabit(
                  childId,
                  habitId,
                  textcontroller.text,
                  timeString,
                  descriptionController.text,
                );
              } else {
                firestoreService.addHabit(
                  childId,
                  textcontroller.text,
                  timeString,
                  descriptionController.text,
                );
              }
              textcontroller.clear();
              descriptionController.clear();
              Navigator.pop(context);
            },
            child: habitId != null ? Text('Update Habit') : Text('Add Habit'),
          ),
        ],
      ),
    );
  }
}
