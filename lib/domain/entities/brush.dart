import 'package:equatable/equatable.dart';

class Brush extends Equatable {
  final String id;
  final bool morning;
  final bool night;

  const Brush({
    required this.id,
    required this.morning,
    required this.night,
  });
  
  @override
  List<Object?> get props => [id, morning, night];
}
