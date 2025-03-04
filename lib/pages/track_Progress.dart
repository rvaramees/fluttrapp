import 'package:flutter/material.dart';
import 'package:fluttr_app/services/firestore.dart';
import 'package:fluttr_app/services/noti_services.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class TrackProgress extends StatefulWidget {
  const TrackProgress({super.key});

  @override
  State<TrackProgress> createState() => _TrackProgressState();
}

class _TrackProgressState extends State<TrackProgress> {
  void _showNotification() {
    NotiServices.instantNotification(
      "Habit Reminder",
      "It's time to complete your habit!",
    );
  }

  void _showScheduledNotification(String habit, String timeString) {
    print("$timeString"); // Debugging log
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    final now = tz.TZDateTime.now(tz.local);
    print(now); // Debugging log
    timeString = timeString.replaceAll(RegExp(r'\s+'), ' ').trim();
    print("time:$timeString"); // Debugging log

    try {
      var splited = timeString.split(':');
      var split = splited[1].split(' ');
      splited[1] = split[0];
      splited.add(split[1]);

      print(splited); // Debugging log'

      int hour = splited[2] == "PM"
          ? (int.parse(splited[0]) % 12 + 12)
          : int.parse(splited[0]);
      int minute = int.parse(splited[1]); // Debugging log

      // Extract hours and minutes in 24-hour format
      // int hour = dateTime.hour;
      // int minute = dateTime.minute;
      print("Parsed Time -> Hour: $hour, Minute: $minute");
      print("$hour : $minute"); // Debugging log
      NotiServices.scheduledNotification(
        "Habit Reminder",
        "It's time to complete your habit!",
        _nextInstanceOfTime(hour, minute),
      );
    } catch (e) {
      print("Error parsing time: $e"); // Debugging log
    }
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print("🔹 Current Local Time: $now"); // Debugging log

    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    print(
        "🔹 Scheduled Time Before Adjustment: $scheduledDate"); // Debugging log

    // If the scheduled time is in the past, schedule it for the next day
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print("🔹 Final Scheduled Time: $scheduledDate"); // Debugging log
    return scheduledDate;
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
                  habitId,
                  textcontroller.text,
                  timeString,
                  descriptionController.text,
                );
              } else {
                firestoreService.addHabit(
                  textcontroller.text,
                  timeString,
                  descriptionController.text,
                );
                _showScheduledNotification(textcontroller.text, timeString);
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
      appBar: AppBar(
        title: Text('Track Progress'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: firestoreService.getHabitsStream(),
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
                            ListTile(
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
                                      firestoreService.deleteHabit(habitId);
                                    },
                                  ),
                                ],
                              ),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: _showNotification,
                  child: const Text('Show Notification'),
                ),
                ElevatedButton(
                  onPressed: () =>
                      _showScheduledNotification("habit", '11:00 PM'),
                  child: const Text('Show Scheduled Notification'),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: openHabitBox,
        child: const Icon(Icons.add),
      ),
    );
  }
}
