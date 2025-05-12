import 'dart:math';
import 'package:flutter/material.dart';

class SideTeethAnimation extends StatefulWidget {
  final bool isLeft;
  const SideTeethAnimation({Key? key, this.isLeft = false}) : super(key: key);
  @override
  State<SideTeethAnimation> createState() => _SideTeethAnimationState();
}

class _SideTeethAnimationState extends State<SideTeethAnimation>
    with SingleTickerProviderStateMixin {
  // or maybe the offset.
  late AnimationController _sideTeethControllerLeft;

  @override
  void initState() {
    super.initState();
    _sideTeethControllerLeft = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2), // Faster animation for side
    )..repeat();
  }

  @override
  void dispose() {
    _sideTeethControllerLeft.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int offset = widget.isLeft ? -80 : -15;
    return Center(
      child: AnimatedBuilder(
        animation: _sideTeethControllerLeft,
        builder: (context, child) {
          double angle = _sideTeethControllerLeft.value * 2 * pi;
          double radius = 8; // Smaller radius
          return Transform.translate(
            offset: Offset(
              cos(angle) * radius + offset + 25, // Adjust X position
              sin(angle) * radius, // Adjust Y position
            ),
            child: Image.asset(
              'assets/brushh.png', // Replace with your image
              width: 75, // Smaller size
              height: 50,
            ),
          );
        },
      ),
    );
  }
}
