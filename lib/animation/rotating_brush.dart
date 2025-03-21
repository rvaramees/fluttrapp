import 'dart:math';
import 'package:flutter/material.dart';

class ToothbrushAnimation extends StatefulWidget {
  @override
  _ToothbrushAnimationState createState() => _ToothbrushAnimationState();
}

class _ToothbrushAnimationState extends State<ToothbrushAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double angle = _controller.value * 2 * pi;
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

// class ToothbrushPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     Paint brush = Paint()
//       ..color = Colors.blue
//       ..strokeWidth = 6
//       ..strokeCap = StrokeCap.round;

//     // Handle
//     canvas.drawLine(Offset(size.width / 2 - 10, size.height / 2),
//         Offset(size.width / 2 + 30, size.height / 2), brush);

//     // Bristles
//     Paint bristles = Paint()
//       ..color = Colors.white
//       ..strokeWidth = 8
//       ..strokeCap = StrokeCap.square;

//     canvas.drawLine(Offset(size.width / 2 + 30, size.height / 2),
//         Offset(size.width / 2 + 30, size.height / 2 + 5), bristles);
//   }

//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
// }

void main() {
  runApp(MaterialApp(
    home: Scaffold(
      backgroundColor: Colors.blue.shade100,
      body: ToothbrushAnimation(),
    ),
  ));
}
