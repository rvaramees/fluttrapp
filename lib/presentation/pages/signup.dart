// import "package:fluttr_app/pages/home.dart";
import "package:brighter_bites/presentation/bloc/auth/auth_bloc.dart";
import "package:brighter_bites/services/auth_service.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/material.dart";

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _name = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _email.dispose();
    _password.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(listener: (context, state) {
      if (state is AuthSuccess) {
        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/');
      } else if (state is AuthFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.message)),
        );
      }
    }, builder: (context, state) {
      if (state is AuthLoading) {
        return const Center(child: CircularProgressIndicator());
      }
      return Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue, const Color.fromARGB(255, 7, 76, 227)])),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Form(
            key: formKey,
            child: Column(
              children: [
                const Spacer(),
                const Text("Signup.",
                    style: TextStyle(
                        color: Color.fromARGB(255, 249, 248, 248),
                        fontSize: 50,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: "Enter Name",
                    labelText: "Name",
                    hintStyle: TextStyle(color: Colors.white),
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                  obscureText: true,
                  controller: _name,
                  style: const TextStyle(color: Colors.white),
                ),
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
                  onPressed: () {
                    BlocProvider.of<AuthBloc>(context).add(
                      AuthSignupRequested(
                          email: _email.text,
                          password: _password.text,
                          name: _name.text),
                    );
                  },
                ),
                const SizedBox(height: 5),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text("Already have an account? "),
                  InkWell(
                    onTap: () => Navigator.pushReplacementNamed(
                      context,
                      '/login',
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                          color: Color.fromARGB(255, 249, 248, 248),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
                const Spacer()
              ],
            ),
          ),
        ),
      );
    }));
  }

  // goToLogin(BuildContext context) => Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => LoginPage()),
  //     );

  // goToHome(BuildContext context) => Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => const Home()),
  //     );

  // _signup(BuildContext context, String email, String password) async {
  //   try {
  //     final user = await _auth.createUserWithEmailAndPassword(email, password);

  //     if (user != null) {
  //       String uid = user.uid; // ✅ Get the user's UID

  //       // ✅ Navigate to Account Creation with uid
  //       Navigator.push(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => AddChildScreen()
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     print("Signup failed: $e");
  //   }
  // }
}
