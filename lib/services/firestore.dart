import 'package:brighter_bites/services/noti_services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference habits =
      FirebaseFirestore.instance.collection('habits');
  final CollectionReference brushes =
      FirebaseFirestore.instance.collection('brushes');
  final CollectionReference children =
      FirebaseFirestore.instance.collection('children');

  final NotiServices notiServices = NotiServices();

  // ✅ Add Parent using UID
  Future<void> addParent(String uid, String name, String email) {
    return users.doc(uid).set({
      'name': name,
      'email': email,
      'children': [], // Empty list initially
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> checkAndCreateDailyBrushingRecord(String childId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastBrushingDate = prefs.getString('last_brushing_date');
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    print("📅 Checking brushing record for today...");
    print("   - Last brushing date: $lastBrushingDate");
    print("   - Today's date: $today");
    print("   - Child ID: $childId");

    if (lastBrushingDate != today) {
      DocumentReference childDocRef =
          FirebaseFirestore.instance.collection('brushes').doc(childId);

      try {
        await childDocRef.collection('records').doc(today).set({
          'morning': false,
          'evening': false,
        }, SetOptions(merge: true));

        await prefs.setString('last_brushing_date', today);
        print("✅ Successfully created brushing record for $today");
      } catch (e) {
        print("❌ Error creating brushing record: $e");
      }
    } else {
      print("⚠️ Brushing record already exists for today.");
    }
  }

  // ✅ Add Child under Parent's UID
  // Future<String> addChild(String parentUid, String childName, int age,
  //     String picturePassword) async {
  //   DocumentReference brushesRef = brushes.doc('childId');
  //   DocumentReference childRef = await users
  //       .doc(parentUid)
  //       .collection('children') // Store children under parent UID
  //       .add({
  //     'name': childName,
  //     'age': age,
  //     'picturePassword':
  //         picturePassword, // Store hashed image data // Empty initially
  //     'timestamp': Timestamp.now(),
  //   });

  //   // ✅ Initialize Brushing Records for the Child
  //   await initializeBrushingRecord(childRef.id);
  //   String childId = childRef.id;
  //   print("Added child:  $childId ");
  //   return childRef.id;
  // }

  // ✅ Initialize Brushing Records for a Child
  Future<void> initializeBrushingRecord(String childId) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    DocumentReference recordRef =
        brushes.doc(childId).collection('records').doc(today);

    DocumentSnapshot doc = await recordRef.get();

    if (!doc.exists) {
      await recordRef.set({
        'morning': false,
        'evening': false,
      }, SetOptions(merge: true));
    }
  }

  // ✅ Update Brushing Record for Child
  Future<void> updateBrushingRecord(String childId, String timeOfDay) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await brushes.doc(childId).collection('records').doc(today).set({
      timeOfDay: true, // Update morning or evening
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> getDailyProgress(String childId) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    DocumentSnapshot doc =
        await brushes.doc(childId).collection('records').doc(today).get();
    return doc.data() as Map<String, dynamic>?;
  }

  // ✅ Get Parent's Children
  Stream<QuerySnapshot> getChildrenStream(String parentUid) {
    return users.doc(parentUid).collection('children').snapshots();
  }

  Future<bool> isBrushingDone(String childId) {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return brushes.doc(childId).collection('records').doc(today).get().then(
          (doc) => doc.exists,
        );
  }

// collection
  Future<void> addHabit(String childId, String habit,
      String time, String description) async {
    // Get the child's reference and store it if it doesn't exist
    DocumentReference habitRef = habits
        .doc(childId); // Create a document for the child in habits collection

    // Ensure the child doc has a reference to this habit collection
    await children.doc(childId).set({
      'habitsRef': habitRef.path, // Save reference to the habits collection
    }, SetOptions(merge: true));
    // Add the habit to the child's independent habit subcollection
    DocumentReference habitId = await habitRef.collection('habitRecords').add({
      'habit': habit,
      'time': time,
      'description': description,
      'done': false,
      'timestamp': Timestamp.now(),
    });
    _showScheduledNotification(habitId.id.hashCode, habit, description, time);
  }

  void _showScheduledNotification(
      int id, String habit, String description, String timeString) {
    print(timeString); // Debugging log
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
        id,
        habit,
        description,
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

  // ✅ Get Habit Stream (Retrieve all habits for a child)
  Stream<QuerySnapshot> getHabitsStream(String childId) {
    return habits
        .doc(childId)
        .collection('habitRecords')
        .orderBy('time', descending: true)
        .snapshots();
  }

  // ✅ Update Habit
  Future<void> updateHabit(String childId, String habitId, String habit,
      String time, String description) {
    return habits.doc(childId).collection('habitRecords').doc(habitId).update({
      'habit': habit,
      'time': time,
      'description': description,
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> updateHabitDone(String childId, String habitId, bool done) {
    return habits.doc(childId).collection('habitRecords').doc(habitId).update({
      'done': done,
    });
  }

  // ✅ Delete Habit
  Future<void> deleteHabit(String childId, String habitId) {
    return habits.doc(childId).collection('habitRecords').doc(habitId).delete();
  }

  void updateExp(String childId) {
    // Update the level of the child in the Firestore database
    children.doc(childId).update({
      'exp': FieldValue.increment(100),
    });
    print("Updated exp for child: $childId");
  }

  Future<void> updateLevel(String childId) async {
    int exp = await children.doc(childId).get().then((value) => value['exp']);
    int level =
        await children.doc(childId).get().then((value) => value['level']);
    print("level: $level");
    print("exp: $exp");
    if (exp >= 1000) {
      level = level + 1;
      exp = exp - 1000;
      // Update the level of the child in the Firestore database
      children.doc(childId).update({
        'level': level,
        'exp': exp,
      });
      print("Updated level for child: $childId");
    }
  }

  Future<String> getChildName(String userId, String childId) async {
    String name =
        await children.doc(childId).get().then((value) => value['name']);
    print("child name: $name");
    return name;
  }

  Future<String> getParentName(String userId) async {
    String name = await users.doc(userId).get().then((value) => value['name']);
    print("parent name: $name");
    return name;
  }

  Future<int> getLevel(String childId) async {
    int level =
        await children.doc(childId).get().then((value) => value['level']);
    print("level: $level");
    return level;
  }

  getExp(String childId) {
    return children.doc(childId).get().then((value) => value['exp']);
  }
}
