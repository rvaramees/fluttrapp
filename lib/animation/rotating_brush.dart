import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class ToothbrushAnimation extends StatefulWidget {
  const ToothbrushAnimation({super.key});

  @override
  ToothbrushAnimationState createState() => ToothbrushAnimationState();
}

class ToothbrushAnimationState extends State<ToothbrushAnimation>
    with TickerProviderStateMixin {
  late AnimationController _frontTeethController; // Default animation

  @override
  void initState() {
    super.initState();

    _frontTeethController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3), // Speed control for front
    )..repeat();
  }

  @override
  void dispose() {
    _frontTeethController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _frontTeethController,
        builder: (context, child) {
          double angle = _frontTeethController.value * 2 * pi;
          double radius = 15;

          return Transform.translate(
            offset: Offset(
              cos(angle) * radius - 45,
              sin(angle) * radius + 5,
            ),
            child: Image.asset(
              'assets/brushh.png', // Replace with your image
              width: 100, // Adjust size of toothbrush
              height: 100,
            ),
          );
        },
      ),
    );
  }
}
