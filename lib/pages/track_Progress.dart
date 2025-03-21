import 'package:flutter/material.dart';
import 'package:fluttr_app/services/firestore.dart';
import 'package:fluttr_app/services/noti_services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TrackProgress extends StatefulWidget {
  const TrackProgress({super.key});

  @override
  State<TrackProgress> createState() => _TrackProgressState();
}

class _TrackProgressState extends State<TrackProgress> {
  String? parentId, childId;
  void _showNotification() {
    NotiServices.instantNotification(
      "Habit Reminder",
      "It's time to complete your habit!",
    );
  }

  void getUserSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? childIdRef = prefs.getString('childId');
    String? parentIdRef = prefs.getString('parentId');
    setState(() {
      childId = childIdRef;
      parentId = parentIdRef;
    });
  }

  final FirestoreService firestoreService = FirestoreService();

  final TextEditingController textcontroller = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  String? selectedHabitId;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    getUserSession();
  }

  void openHabitBox({String? habitId}) {
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
                  childId!,
                  habitId,
                  textcontroller.text,
                  timeString,
                  descriptionController.text,
                );
              } else {
                firestoreService.addHabit(
                  parentId!,
                  childId!,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 2, 166, 255),
      appBar: AppBar(
        title: Text('Track Progress'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        child: Expanded(
          child: StreamBuilder(
            stream: firestoreService.getHabitsStream(childId!),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    final habit = snapshot.data.docs[index];
                    String habitId = snapshot.data.docs[index].id;
                    final timeString = habit['time'];
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedHabitId =
                              selectedHabitId == habitId ? null : habitId;
                        });
                      },
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFF02A6FF),
                                  Color(0xFF0066FF)
                                ], // Adjust colors
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(30),
                              ),
                            ),
                            child: ListTile(
                              title: Text(
                                snapshot.data.docs[index]['habit'],
                                style: TextStyle(fontSize: 18),
                              ),
                              subtitle: Text(
                                habit['description'],
                                style: TextStyle(fontSize: 15),
                              ),
                              trailing: Text(
                                timeString,
                                style: TextStyle(fontSize: 25),
                              ),
                            ),
                          ),
                          if (selectedHabitId == habitId)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    textcontroller.text = habit['habit'];
                                    descriptionController.text =
                                        habit['description'];
                                    var splited = timeString.split(':');
                                    var split = splited[1].split(' ');
                                    splited[1] = split[0];
                                    splited.add(split[1]);

                                    print(splited); // Debugging log'

                                    int hour = splited[2] == "PM"
                                        ? (int.parse(splited[0]) % 12 + 12)
                                        : int.parse(splited[0]);
                                    int minute = int.parse(splited[1]);
                                    selectedTime = TimeOfDay(
                                      hour: hour,
                                      minute: minute,
                                    );
                                    openHabitBox(habitId: habitId);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () {
                                    firestoreService.deleteHabit(
                                        childId!, habitId);
                                  },
                                ),
                              ],
                            ),
                          SizedBox(height: 20),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openHabitBox,
        child: const Icon(Icons.add),
      ),
    );
  }
}
