import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:logging/logging.dart';
import 'package:timezone/timezone.dart' as tz;

class NotiServices {
  // Initialize FlutterLocalNotificationsPlugin
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  // Notification Response
  static Future<void> onDidReceiveNotification(
      NotificationResponse notificationResponse) async {}
  // Logger
  // final Logger _logger = Logger('NotiServices');

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  // Initialize the notification plugin
  Future<void> initNotification() async {
    if (_isInitialized) return; // Prevent re-initialization

    // android initialization
    const AndroidInitializationSettings initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // ios initialization
    const DarwinInitializationSettings initSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // initialization settings
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    // initialize plugin
    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: onDidReceiveNotification,
        onDidReceiveBackgroundNotificationResponse: onDidReceiveNotification);

    // Request permission
    flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    _isInitialized = true;

    //   // Handle foreground messages
    //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //     RemoteNotification? notification = message.notification;
    //     AndroidNotification? android = message.notification?.android;

    //     if (notification != null && android != null) {
    //       flutterLocalNotificationsPlugin.show(
    //         notification.hashCode,
    //         notification.title,
    //         notification.body,
    //         NotificationDetails(
    //           android: AndroidNotificationDetails(
    //             'channel_id',
    //             'channel_name',
    //             channelDescription: 'channel_description',
    //             importance: Importance.max,
    //             priority: Priority.high,
    //           ),
    //         ),
    //       );
    //     }
    //   });
    // }

    // // Notification detail setup
    // NotificationDetails notificationDetails() {
    //   return const NotificationDetails(
    //     android: AndroidNotificationDetails(
    //       'daily_channel_id',
    //       'Daily Notification',
    //       channelDescription: 'Daily Notification',
    //       importance: Importance.max,
    //       priority: Priority.high,
    //     ),
    //     iOS: DarwinNotificationDetails(),
    //   );
    // }

    // // Show Notification
    // Future<void> showNotification({
    //   int id = 0,
    //   String? title,
    //   String? body,
    // }) async {
    //   return flutterLocalNotificationsPlugin.show(
    //     id,
    //     title,
    //     body,
    //     notificationDetails(),
    //   );
    // }

    // // Show Scheduled Notification
    // Future<void> showScheduledNotification({
    //   required int id,
    //   required String title,
    //   required String body,
    //   required tz.TZDateTime scheduledTime,
    // }) async {
    //   return flutterLocalNotificationsPlugin.zonedSchedule(
    //     id,
    //     title,
    //     body,
    //     scheduledTime,
    //     notificationDetails(),
    //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    //     matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    //     uiLocalNotificationDateInterpretation:
    //         UILocalNotificationDateInterpretation.absoluteTime,
    //   );
  }

  // Show Instant Notification
  static Future<void> instantNotification(String title, String body) async {
    // Define notification details
    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        "channel_Id",
        "channel_Name",
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics);
  }

  // Show Scheduled Notification
  static Future<void> scheduledNotification(
      String title, String body, tz.TZDateTime scheduledDate) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your_channel_id',
          'your_channel_name',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Future<void> showScheduledNotification({
  //   required int id,
  //   required String title,
  //   required String body,
  //   required tz.TZDateTime scheduledTime,
  //   required DateTimeComponents matchDateTimeComponents,
  // }) async {
  //   const NotificationDetails platformChannelSpecifics = NotificationDetails(
  //     android: AndroidNotificationDetails(
  //       "channel_Id",
  //       "channel_Name",
  //       importance: Importance.high,
  //       priority: Priority.high,
  //     ),
  //     iOS: DarwinNotificationDetails(),
  //   );

  //   return flutterLocalNotificationsPlugin.zonedSchedule(
  //     id,
  //     title,
  //     body,
  //     scheduledTime,
  //     platformChannelSpecifics,
  //     androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  //     matchDateTimeComponents: matchDateTimeComponents, // Repeat daily
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //   );
  // }
}
