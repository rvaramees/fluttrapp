import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirestoreService {
  final CollectionReference users =
      FirebaseFirestore.instance.collection('users');

  // ✅ Add Parent using UID
  Future<void> addParent(String uid, String name, String email) {
    return users.doc(uid).set({
      'name': name,
      'email': email,
      'children': [], // Empty list initially
      'timestamp': Timestamp.now(),
    });
  }

  Future<void> createDailyBrushingRecord(
      String parentId, String childId) async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;

      // Get tomorrow's date in YYYY-MM-DD format
      String tomorrowDate = DateFormat('yyyy-MM-dd')
          .format(DateTime.now().add(Duration(days: 1)));

      // Reference to tomorrow's document
      DocumentReference docRef = _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .collection('brushingRecords')
          .doc(tomorrowDate);

      // Check if the document already exists
      DocumentSnapshot doc = await docRef.get();
      if (!doc.exists) {
        await docRef.set({
          "morning": false,
          "evening": false,
          "createdAt": FieldValue.serverTimestamp(),
        });
        print("Brushing record created for $tomorrowDate");
      } else {
        print("Brushing record already exists for $tomorrowDate");
      }
    } catch (e) {
      print("Error creating brushing record: $e");
    }
  }

  // ✅ Add Child under Parent's UID
  Future<String> addChild(String parentUid, String childName, int age,
      String picturePassword) async {
    DocumentReference childRef = await users
        .doc(parentUid)
        .collection('children') // Store children under parent UID
        .add({
      'name': childName,
      'age': age,
      'picturePassword': picturePassword, // Store hashed image data
      'brushingRecords': {}, // Empty initially
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

    DocumentSnapshot doc = await users
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('brushingRecords')
        .doc(today)
        .get();

    if (!doc.exists) {
      await users
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .collection('brushingRecords')
          .doc(today)
          .set({
        'morning': false,
        'evening': false,
      });
    }
  }

  // ✅ Update Brushing Record for Child
  Future<void> updateBrushingRecord(
      String parentUid, String childId, String timeOfDay) async {
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    await users
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('brushingRecords')
        .doc(today)
        .set({
      timeOfDay: true, // Update morning or evening
    }, SetOptions(merge: true));
  }

  // ✅ Get Parent's Children
  Stream<QuerySnapshot> getChildrenStream(String parentUid) {
    return users.doc(parentUid).collection('children').snapshots();
  }

// collection
  final CollectionReference habits =
      FirebaseFirestore.instance.collection('habittracker');
  //create
  Future<void> addHabit(String habit, String time, String description) {
    return habits.add({
      'habit': habit,
      'time': time,
      'description': description,
      'done': false,
      'timestamp': Timestamp.now(),
    });
  }

  //read
  Stream<QuerySnapshot> getHabitsStream() {
    final habitStream = habits.orderBy('time', descending: true).snapshots();
    return habitStream;
  }

  //update
  Future<void> updateHabit(
      String id, String habit, String time, String description) {
    return habits.doc(id).update({
      'habit': habit,
      'time': time,
      'description': description,
      'timestamp': Timestamp.now(),
    });
  }

  //delete
  Future<void> deleteHabit(String id) {
    return habits.doc(id).delete();
  }
}
