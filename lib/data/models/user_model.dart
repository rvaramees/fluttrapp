import 'package:brighter_bites/domain/entities/user.dart';

class UserModel {
  final String id;
  final String email;
  final String? name;

  UserModel({required this.id, required this.email, required this.name});

  User toEntity() {
    return User(id: id, email: email, name: name);
  }
}
