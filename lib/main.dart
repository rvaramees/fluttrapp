import 'package:brighter_bites/core/di/injection_container.dart' as di;
import 'package:brighter_bites/firebase_options.dart';
import 'package:brighter_bites/presentation/bloc/auth/auth_bloc.dart';
import 'package:brighter_bites/presentation/bloc/child/child_bloc.dart';
import 'package:brighter_bites/presentation/bloc/selected_child/selected_child_bloc.dart';
import 'package:brighter_bites/presentation/pages/add_child.dart';
import 'package:brighter_bites/presentation/pages/brusher.dart';
import 'package:brighter_bites/presentation/pages/daily_challenges.dart';
import 'package:brighter_bites/presentation/pages/edu_videos.dart';
import 'package:brighter_bites/presentation/pages/home.dart';
import 'package:brighter_bites/presentation/pages/login.dart';
import 'package:brighter_bites/presentation/pages/parent_dashboard.dart';
import 'package:brighter_bites/presentation/pages/parent_home.dart';
import 'package:brighter_bites/presentation/pages/signup.dart';
import 'package:brighter_bites/presentation/pages/start_brushing.dart';
import 'package:brighter_bites/presentation/pages/start_page.dart';
import 'package:brighter_bites/presentation/pages/track_progress.dart';
import 'package:brighter_bites/presentation/widgets/loading.dart';
import 'package:brighter_bites/services/noti_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;

// import 'package:fluttr_app/services/firestore.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

Future<void> storeLastOpenedDate() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String today = DateTime.now()
      .toIso8601String()
      .split('T')[0]; // Store only the date (YYYY-MM-DD)
  await prefs.setString('last_opened_date', today);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  // tz.setLocalLocation(tz.getLocation(localTimeZone)); // Set local timezone
  print(await FlutterTimezone.getLocalTimezone());
  await NotiServices().initNotification();
  await storeLastOpenedDate(); // Store last opened date when app starts

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                di.sl<AuthBloc>()..add(const AuthGetCurrentUser()),
          ),
          BlocProvider<ChildBloc>(
            create: (context) => di.sl<ChildBloc>(), // Initialize ChildBloc
          ),
          BlocProvider<SelectedChildBloc>(
            create: (context) => di.sl<SelectedChildBloc>(),
          )
        ],
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Kids Dental Health',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: AuthGate(),
          routes: {
            '/login': (context) => const LoginPage(),
            '/start': (context) => const StartPage(),
            '/home': (context) => const Home(),
            '/signup': (context) => const SignupScreen(),
            '/brushing': (context) => const StartBrushingPage(),
            '/brusher': (context) => const Brusher(sessionType: 'morning'),
            '/add_child': (context) => const AddChildScreen(),
            '/habits': (context) => const TrackProgress(),
            '/Challenges': (context) => const DailyChallenges(),
            '/tutorial': (context) => const EduVideos(),
            '/parent_dashboard': (context) => const ParentDashboard(),
            '/parent_home': (context) => const ParentHome(),
          },
        ));
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          // Load children if the user is logged in
          BlocProvider.of<ChildBloc>(context)
              .add(LoadChildren(parentId: state.user.id));
          BlocProvider.of<SelectedChildBloc>(context).add(
              const CheckPreviousSelectedChild()); // Check for previously selected child
        }
      },
      builder: (context, state) {
        if (state is AuthSuccess) {
          return BlocBuilder<SelectedChildBloc, SelectedChildState>(
            builder: (context, selectedChildState) {
              if (selectedChildState is ChildSelected) {
                // Child is selected: Show child's start page
                return const StartPage();
              } else {
                // No child selected: Parent dashboard or prompt to add child
                return BlocBuilder<ChildBloc, ChildState>(
                  builder: (context, childState) {
                    if (childState is ChildLoaded) {
                      if (childState.children.isNotEmpty) {
                        return const StartPage();
                      } else {
                        return const AddChildScreen();
                      }
                    } else if (childState is ChildLoading) {
                      return const LoadingPage();
                    } else if (childState is ChildError) {
                      return Scaffold(
                          body: Center(
                              child: Text(
                                  'Error loading children: ${childState.message}')));
                    } else {
                      return const Scaffold(
                          body: Center(child: Text('Loading...')));
                    }
                  },
                );
              }
            },
          );
        } else if (state is AuthLoading) {
          return const LoadingPage();
        } else {
          return LoginPage();
        }
      },
    );
  }
}
