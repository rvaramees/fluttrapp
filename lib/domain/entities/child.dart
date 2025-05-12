import 'package:equatable/equatable.dart';

class Child extends Equatable {
  final String childId;
  final String name;
  final int age;
  final int level;
  final int exp;
  final Map<String, dynamic> preferences;
  final String parentId;
  final String password;

  const Child(
      {required this.childId,
      required this.name,
      required this.age,
      required this.level,
      required this.exp,
      required this.preferences,
      required this.parentId,
      required this.password});

  @override
  List<Object?> get props =>
      [childId, name, age, level, exp, preferences, parentId, password];
}
