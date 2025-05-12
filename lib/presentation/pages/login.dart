import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttr_app/main.dart';
import 'package:fluttr_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:fluttr_app/presentation/pages/signup.dart';
import 'package:fluttr_app/presentation/pages/start_page.dart';
import 'package:fluttr_app/services/auth_service.dart';
import 'package:fluttr_app/presentation/pages/home.dart';

class LoginPage extends StatefulWidget {
  @override
  const LoginPage({super.key});
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _checkSession();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // void _checkSession() async {
  //   Map<String, String>? session = await _auth.getUserSessionWithChild();
  //   if (session != null && session['childId'] != null) {
  //     String parentId = session['parentId']!;
  //     String childId = session['childId']!;
  //     _goToHome(parentId, childId); // ✅ If child already selected, go to Home
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
          if (state is AuthSuccess) {
            // Navigate to home screen
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => AuthGate()));
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        }, builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(children: [
            Positioned.fill(
              child: Image.asset(
                'assets/home_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      controller: _email,
                    ),
                    SizedBox(height: 16.0),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      controller: _password,
                      obscureText: true,
                    ),
                    SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        BlocProvider.of<AuthBloc>(context).add(
                          AuthLoginRequested(
                              email: _email.text, password: _password.text),
                        );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AuthGate()));
                      },
                      child: Text('Login'),
                    ),
                    ElevatedButton(
                      onPressed: _goToSignup,
                      child: Text('Signup'),
                    ),
                  ],
                ),
              ),
            )
          ]);
        }));
  }

  // void _signOut() {
  //   _auth.signout();
  //   ScaffoldMessenger.of(context).showSnackBar(
  //     SnackBar(content: Text('Signed out successfully')),
  //   );
  // }

  void _goToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  void _goToHome(String userId, String childId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Home()),
    );
  }

  _login() async {
    var user =
        await _auth.loginUserWithEmailAndPassword(_email.text, _password.text);
    if (user != null) {
      String userId = user.uid;

      // 🔹 Fetch children associated with the parent
      var childrenSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('children')
          .get();

      List<QueryDocumentSnapshot> childrenDocs = childrenSnapshot.docs;

      if (childrenDocs.isEmpty) {
        // ❌ No children registered, show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('No children found. Please register a child.')),
        );
        return;
      }

      // ✅ Show Child Selection Dialog
      _showChildSelectionDialog(userId, childrenDocs);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Check email and password.')),
      );
    }
  }

  void _showChildSelectionDialog(
      String userId, List<QueryDocumentSnapshot> children) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing without selection
      builder: (context) {
        return AlertDialog(
          title: Text('Select Child'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: children.map((child) {
              return ListTile(
                title: Text(child['name']),
                onTap: () {
                  _selectChild(userId, child.id);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _selectChild(String parentId, String childId) async {
    await _auth.setUserSession(parentId, childId); // ✅ Store in session

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Logged in as child.')),
    );

    _goToStart(); // ✅ Redirect to Home
  }

  void _goToStart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StartPage(),
      ),
    );
  }
}
