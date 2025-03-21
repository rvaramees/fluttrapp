import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:fluttr_app/services/noti_services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference habits =
      FirebaseFirestore.instance.collection('habits');
  final CollectionReference brushes =
      FirebaseFirestore.instance.collection('brushes');

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

    if (lastBrushingDate != today) {
      // Ensure child document exists
      DocumentReference childDocRef = brushes.doc(childId);

      // Create a new brushing record for today
      await childDocRef.collection('records').doc(today).set({
        'morning': false,
        'evening': false,
      });

      // Update last stored date
      await prefs.setString('last_brushing_date', today);
    }
  }

  // ✅ Add Child under Parent's UID
  Future<String> addChild(String parentUid, String childName, int age,
      String picturePassword) async {
    DocumentReference brushesRef = brushes.doc('childId');
    DocumentReference childRef = await users
        .doc(parentUid)
        .collection('children') // Store children under parent UID
        .add({
      'name': childName,
      'age': age,
      'picturePassword':
          picturePassword, // Store hashed image data // Empty initially
      'timestamp': Timestamp.now(),
    });

    // ✅ Initialize Brushing Records for the Child
    await initializeBrushingRecord(parentUid, childRef.id);
    String childId = childRef.id;
    print("Added child:  $childId ");
    return childRef.id;
  }

  // ✅ Initialize Brushing Records for a Child
  Future<void> initializeBrushingRecord(
      String parentUid, String childId) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    DocumentReference recordRef =
        brushes.doc(childId).collection('records').doc(today);

    DocumentSnapshot doc = await recordRef.get();

    if (!doc.exists) {
      await recordRef.set({
        'morning': false,
        'evening': false,
      }, SetOptions(merge: true));
      await users
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .set({'brushes': brushes.doc(childId).path}, SetOptions(merge: true));
    }
  }

  // ✅ Update Brushing Record for Child
  Future<void> updateBrushingRecord(
      String parentUid, String childId, String timeOfDay) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await brushes.doc(childId).collection('records').doc(today).set({
      timeOfDay: true, // Update morning or evening
    }, SetOptions(merge: true));
  }

  // ✅ Get Parent's Children
  Stream<QuerySnapshot> getChildrenStream(String parentUid) {
    return users.doc(parentUid).collection('children').snapshots();
  }

// collection
  Future<void> addHabit(String parentUid, String childId, String habit,
      String time, String description) async {
    // Get the child's reference and store it if it doesn't exist
    DocumentReference habitRef = habits
        .doc(childId); // Create a document for the child in habits collection

    // Ensure the child doc has a reference to this habit collection
    await users.doc(parentUid).collection('children').doc(childId).set({
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

  // ✅ Delete Habit
  Future<void> deleteHabit(String childId, String habitId) {
    return habits.doc(childId).collection('habitRecords').doc(habitId).delete();
  }
}
