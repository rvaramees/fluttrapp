import 'package:brighter_bites/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword(
      {required String name, required String email, required String password});
  Future<UserModel> loginWithEmailPassword(
      {required String email, required String password});
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  AuthRemoteDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> loginWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user != null) {
        return UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName,
        );
      } else {
        throw Exception('Login Failed');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception('Firebase Login Error: ${e.code} - ${e.message}');
    } catch (e) {
      throw Exception('Firebase Login Error: $e');
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final UserCredential userCredential =
          await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;

      if (user != null) {
        await user.updateDisplayName(name); // Set the display name

        return UserModel(
          id: user.uid,
          email: user.email!,
          name: name,
        );
      } else {
        throw Exception('Signup failed');
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(
          'Firebase Signup Error: ${e.code} - ${e.message}'); // More specific errors
    } catch (e) {
      throw Exception('Firebase Signup Error: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw Exception('Firebase Logout Error: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final User? user = firebaseAuth.currentUser;

      if (user != null) {
        return UserModel(
          id: user.uid,
          email: user.email!,
          name: user.displayName!,
        );
      }

      return null;
    } catch (e) {
      throw Exception('Firebase Get Current User Error: $e');
    }
  }
}
