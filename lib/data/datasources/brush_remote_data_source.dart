import 'package:brighter_bites/data/models/brush_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:fluttr_app/domain/entities/brush.dart';

abstract class BrushRemoteDataSource {
  Future<void> addBrush(String childId, BrushModel brush);
  Future<void> removeBrush(String childId, String brushId, bool time);
  Future<void> updateBrush(String childId, String brushId, bool time);
  Future<List<BrushModel>> getBrushesForChild(String childId);
}

class BrushRemoteDataSourceImpl implements BrushRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference brushesCollection =
      FirebaseFirestore.instance.collection('brushes');

  @override
  Future<void> addBrush(String childId, BrushModel brush) async {
    final CollectionReference childBrushesCollection =
        brushesCollection.doc(childId).collection('records');
    try {
      await childBrushesCollection.doc(brush.id).set(brush.toJson());
    } catch (e) {
      throw Exception('Error adding brush: $e');
    }
  }

  @override
  Future<void> removeBrush(String childId, String brushId, bool time) async {
    final CollectionReference childBrushesCollection =
        brushesCollection.doc(childId).collection('records');
    try {
      if (time) {
        await childBrushesCollection.doc(brushId).set({
          'morning': false,
        }, SetOptions(merge: true));
      } else {
        await childBrushesCollection.doc(brushId).set({
          'night': false,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Error removing brush: $e');
    }
  }

  @override
  Future<void> updateBrush(String childId, String brushId, bool time) async {
    final CollectionReference childBrushesCollection =
        brushesCollection.doc(childId).collection('records');
    try {
      if (time) {
        await childBrushesCollection.doc(brushId).set({
          'morning': true,
        }, SetOptions(merge: true));
      } else {
        await childBrushesCollection.doc(brushId).set({
          'night': true,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Error updating brush: $e');
    }
  }

  @override
  Future<List<BrushModel>> getBrushesForChild(String childId) async {
    final CollectionReference childBrushesCollection =
        brushesCollection.doc(childId).collection('records');
    try {
      final QuerySnapshot snapshot = await childBrushesCollection.get();
      return snapshot.docs
          .map((doc) =>
              BrushModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error getting brushes: $e');
    }
  }
}
