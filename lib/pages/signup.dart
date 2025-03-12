// import "package:fluttr_app/pages/home.dart";
import "package:fluttr_app/pages/login.dart";
import "package:fluttr_app/services/auth_service.dart";
import "package:flutter/material.dart";
import 'package:fluttr_app/pages/account_creation.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue, const Color.fromARGB(255, 7, 76, 227)])),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          children: [
            const Spacer(),
            const Text("Signup",
                style: TextStyle(
                    color: Color.fromARGB(255, 249, 248, 248),
                    fontSize: 40,
                    fontWeight: FontWeight.w500)),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter Email",
                labelText: "Email",
                hintStyle: TextStyle(color: Colors.white),
                labelStyle: TextStyle(color: Colors.white),
              ),
              controller: _email,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter Password",
                labelText: "Password",
                hintStyle: TextStyle(color: Colors.white),
                labelStyle: TextStyle(color: Colors.white),
              ),
              obscureText: true,
              controller: _password,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              child: const Text("Signup"),
              onPressed: () => {
                _signup(context, _email.text, _password.text),
                // _firestore.addUser(_email.text, _password.text),
              },
            ),
            const SizedBox(height: 5),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Already have an account? "),
              InkWell(
                onTap: () => goToLogin(context),
                child: const Text("Login", style: TextStyle(color: Colors.red)),
              )
            ]),
            const Spacer()
          ],
        ),
      ),
    ));
  }

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );

  // goToHome(BuildContext context) => Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const Home()),
  //     );

  _signup(BuildContext context, String email, String password) async {
    try {
      final user = await _auth.createUserWithEmailAndPassword(email, password);

      if (user != null) {
        String uid = user.uid; // ✅ Get the user's UID

        // ✅ Navigate to Account Creation with uid
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountCreation(uid: uid, email: email),
          ),
        );
      }
    } catch (e) {
      print("Signup failed: $e");
    }
  }
}
