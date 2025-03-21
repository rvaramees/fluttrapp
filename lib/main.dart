import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttr_app/firebase_options.dart';
import 'package:fluttr_app/pages/home.dart';
import 'package:fluttr_app/pages/login.dart';
import 'package:fluttr_app/services/noti_services.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:fluttr_app/services/auth_service.dart';
// import 'package:fluttr_app/services/firestore.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
Future<void> storeLastOpenedDate() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String today = DateTime.now().toIso8601String().split('T')[0]; // Store only the date (YYYY-MM-DD)
  await prefs.setString('last_opened_date', today);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  // tz.setLocalLocation(tz.getLocation(localTimeZone)); // Set local timezone
  print(await FlutterTimezone.getLocalTimezone());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotiServices().initNotification();
  await storeLastOpenedDate(); // Store last opened date when app starts

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String? parentId;
  String? childId;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final _auth = AuthService();
    Map<String, String>? session = await _auth.getUserSessionWithChild();

    if (session != null && session['childId'] != null) {
      setState(() {
        parentId = session['parentId'];
        childId = session['childId'];
      });
    }
    setState(() {
      isLoading = false;
      print("Loading done");
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: isLoading
          ? LoginPage()
          : (parentId != null && childId != null)
              ? Home(parentId: parentId!, childId: childId!)
              : LoginPage(),
    );
  }
}
