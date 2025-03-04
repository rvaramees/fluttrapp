import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
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
