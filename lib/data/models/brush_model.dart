import 'package:brighter_bites/domain/entities/brush.dart';


class BrushModel {
  final String id;
  final bool morning;
  final bool night;

  const BrushModel({
    required this.id,
    required this.morning,
    required this.night,
  });

  Brush toEntity() {
    return Brush(
      id: id,
      morning: morning,
      night: night,
    );
  }

  factory BrushModel.fromJson(Map<String, dynamic> json, documentId) {
    return BrushModel(
      id: documentId,
      morning: json['morning'] != null ? json['morning'] as bool : false,
      night: json['night'] != null ? json['night'] as bool : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'morning': morning,
      'night': night,
    };
  }
}
