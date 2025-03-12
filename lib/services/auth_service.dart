import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fluttr_app/main.dart';
// import 'package:fluttr_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;

  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } catch (e) {
      print("Something went wrong $e");
    }
    return null;
  }

  // 🔹 Retrieve Parent ID and Child ID from session
  Future<Map<String, String>?> getUserSessionWithChild() async {
    final prefs = await SharedPreferences.getInstance();
    String? parentId = prefs.getString('parentId');
    String? childId = prefs.getString('childId');

    if (parentId != null && childId != null) {
      return {'parentId': parentId, 'childId': childId};
    }
    return null;
  }

  // 🔹 Store Parent ID and Child ID in session
  Future<void> setUserSession(String parentId, String childId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('parentId', parentId);
    await prefs.setString('childId', childId);
  }

  Future<String?> getUserId() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  Future<User?> loginUserWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Save user session
      await _saveUserSession(userCredential.user!.uid);
      print("Successfully logged in: ${userCredential.user!.uid}");
      return userCredential.user;
    } catch (e) {
      print("Login failed: $e");
      return null;
    }
  }

  // ✅ Save session (User ID)
  Future<void> _saveUserSession(String userId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('parentId', userId);
  }

  // ✅ Get session (Check if user is logged in)
  Future<String?> getUserSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('parentId'); // Returns userId if logged in
  }

  // ✅ Logout function
  Future<void> signout() async {
    await _auth.signOut();

    // Clear session
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('parentId');
    print("Successfully logged out");

    // Get.to(() => main());
  }
}
