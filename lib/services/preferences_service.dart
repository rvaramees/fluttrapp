import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For TimeOfDay parsing

class PreferencesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveBrushingPreferences({
    required String parentId,
    required String childId,
    required String morningTime,
    required String eveningTime,
    required bool reminderEnabled,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .update({
        'preferences': {
          'morningTime': morningTime,
          'eveningTime': eveningTime,
          'reminderEnabled': reminderEnabled,
        },
      });
      print("saved Brushing preferences.");
    } catch (e) {
      print("Error saving preferences: $e");
    }
  }

  Future<Map<String, dynamic>?> getBrushingPreferences(
      String? parentId, String? childId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .get();
      print(parentId);
      print(childId);

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('preferences')) {
          Map<String, dynamic> preferences = data['preferences'];

          print("Raw preferences: $preferences"); // Debugging

          return {
            "morningTime": preferences['morningTime'],
            "eveningTime": preferences['eveningTime'],
            "reminderEnabled": preferences['reminderEnabled'] ?? false,
          };
        } else {
          print("No preferences found.");
        }
      } else {
        print("Document not found.");
      }
    } catch (e) {
      print("Error fetching preferences: $e");
    }
    return null;
  }

  /// Function to parse "9:00 PM" into TimeOfDay
  TimeOfDay? parseTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) return null;

    try {
      final RegExp timeRegex = RegExp(r'(\d+):(\d+) (\w{2})');
      final match = timeRegex.firstMatch(timeString);

      if (match != null) {
        int hour = int.parse(match.group(1)!);
        int minute = int.parse(match.group(2)!);
        String period = match.group(3)!;

        if (period.toLowerCase() == "pm" && hour != 12) {
          hour += 12;
        } else if (period.toLowerCase() == "am" && hour == 12) {
          hour = 0;
        }

        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      print("Error parsing time: $e");
    }
    return null;
  }

  // Future<Map<String, dynamic>?> getBrushingPreferences(
  //     String? parentId, String? childId) async {
  //   try {
  //     DocumentSnapshot doc = await _firestore
  //         .collection('users')
  //         .doc(parentId)
  //         .collection('children')
  //         .doc(childId)
  //         .get();
  //     if (doc.exists && doc.data() != null) {
  //       Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //       return data['preferences'] ?? {};
  //     }
  //   } catch (e) {
  //     print("Error fetching preferences: $e");
  //   }
  //   return null;
  // }
}
