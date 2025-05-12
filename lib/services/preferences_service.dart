import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // For TimeOfDay parsing
import 'package:fluttr_app/services/noti_services.dart';
import 'package:timezone/timezone.dart' as tz;

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
      await _firestore.collection('children').doc(childId).update({
        'preferences': {
          'morningTime': morningTime,
          'eveningTime': eveningTime,
          'reminderEnabled': reminderEnabled,
        },
      });
      print("saved Brushing preferences.");
      _showScheduledNotification(1, 'Morning', 'Brush', morningTime);
      _showScheduledNotification(2, 'Evening', 'Brush', eveningTime);
    } catch (e) {
      print("Error saving preferences: $e");
    }
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

  Future<Map<String, dynamic>?> getBrushingPreferences(String? childId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('children').doc(childId).get();
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
