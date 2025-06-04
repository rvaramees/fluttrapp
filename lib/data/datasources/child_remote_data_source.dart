import 'package:brighter_bites/data/models/child_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class ChildRemoteDataSource {
  Future<ChildModel> addChild(ChildModel child);
  Future<List<ChildModel>> getChildrenForUser(String userId);
  Future<void> updateChild(ChildModel child);
  Future<void> deleteChild(String childId);
  Future<ChildModel> getChild(String childId);
}

class ChildRemoteDataSourceImpl implements ChildRemoteDataSource {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  @override
  Future<ChildModel> addChild(ChildModel child) async {
    try {
      // If using Firestore:
      await firestore
          .collection('children')
          .doc(child.childId)
          .set(child.toJson());
      return child;
    } catch (e) {
      throw Exception('Error adding child: $e');
    }
  }

  @override
  Future<List<ChildModel>> getChildrenForUser(String userId) async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('children')
          .where('parentId', isEqualTo: userId)
          .get();

      List<ChildModel> children = [];
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>?; // Safely get the data
        if (data != null) {
          try {
            children.add(ChildModel.fromJson(data, doc.id));
          } catch (e) {
            print('Error creating ChildModel from document ${doc.id}: $e');
            // Optionally, re-throw the exception or continue to the next document
          }
        } else {
          print('Document ${doc.id} has no data.');
        }
      }
      return children;
    } catch (e) {
      throw Exception('Firestore Get Children Error: $e');
    }
  }

  @override
  Future<void> updateChild(ChildModel child) async {
    try {
      await firestore
          .collection('children')
          .doc(child.childId)
          .update(child.toJson());
    } catch (e) {
      throw Exception('Error updating child: $e');
    }
  }

  @override
  Future<void> deleteChild(String childId) async {
    try {
      await firestore.collection('children').doc(childId).delete();
    } catch (e) {
      throw Exception('Error removing child: $e');
    }
  }

  @override
  Future<ChildModel> getChild(String childId) async {
    try {
      final DocumentSnapshot snapshot =
          await firestore.collection('children').doc(childId).get();
      if (snapshot.exists) {
        return ChildModel.fromJson(
            snapshot.data() as Map<String, dynamic>, snapshot.id);
      } else {
        throw Exception("Child not found");
      }
    } catch (e) {
      throw Exception('Error fetching child: $e');
    }
  }
}
