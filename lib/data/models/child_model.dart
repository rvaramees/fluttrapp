import 'package:fluttr_app/domain/entities/child.dart';

class ChildModel {
  final String childId;
  final String name;
  final int age;
  final int level;
  final int exp;
  final Map<String, dynamic> preferences;
  final String parentId;
  final String password;

  ChildModel(
      {required this.childId,
      required this.name,
      required this.age,
      required this.level,
      required this.exp,
      required this.preferences,
      required this.parentId,
      required this.password});

  Child toEntity() {
    return Child(
        childId: childId,
        name: name,
        age: age,
        level: level,
        exp: exp,
        preferences: preferences,
        parentId: parentId,
        password: password);
  }

  factory ChildModel.fromJson(Map<String, dynamic> json, documentId) {
    return ChildModel(
      childId: documentId,
      name: json['name'] != null ? json['name'] as String : '',
      age: json['age'] != null
          ? (json['age'] as num).toInt()
          : 0, // Handle null age
      level: json['level'] != null
          ? (json['level'] as num).toInt()
          : 0, // Handle null level
      exp: json['exp'] != null
          ? (json['exp'] as num).toInt()
          : 0, // Handle null exp
      preferences: json['preferences'] != null
          ? Map<String, dynamic>.from(json['preferences'] as Map)
          : {}, // Ensure map conversion
      parentId: json['parentId'] != null
          ? json['parentId'] as String
          : '', //Handle null parentID
      password: json['password'] != null ? json['password'] as String : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'level': level,
      'exp': exp,
      'preferences': preferences,
      'parentId': parentId,
    };
  }
}
