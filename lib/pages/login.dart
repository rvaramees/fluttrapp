import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttr_app/pages/signup.dart';
import 'package:fluttr_app/services/auth_service.dart';
import 'package:fluttr_app/pages/home.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _checkSession() async {
    Map<String, String>? session = await _auth.getUserSessionWithChild();
    if (session != null && session['childId'] != null) {
      String parentId = session['parentId']!;
      String childId = session['childId']!;
      _goToHome(parentId, childId); // ✅ If child already selected, go to Home
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Login'),
        ),
        body: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                Colors.blue,
                const Color.fromARGB(255, 7, 76, 227)
              ])),
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
                  onPressed: _login,
                  child: Text('Login'),
                ),
                ElevatedButton(
                  onPressed: _goToSignup,
                  child: Text('Signup'),
                ),
                ElevatedButton(onPressed: _signOut, child: Text('Signout')),
              ],
            ),
          ),
        ));
  }

  void _signOut() {
    _auth.signout();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Signed out successfully')),
    );
  }

  void _goToSignup() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignupScreen()),
    );
  }

  void _goToHome(String userId, String childId) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Home(
                parentId: userId,
                childId: childId,
              )),
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

    _goToHome(parentId, childId); // ✅ Redirect to Home
  }
}
