import 'package:flutter/material.dart';

class Horiscrolling extends StatefulWidget {
  const Horiscrolling({super.key});

  @override
  State<Horiscrolling> createState() => _HoriscrollingState();
}

class _HoriscrollingState extends State<Horiscrolling>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Speed of scrolling
    )..repeat(); // Infinite loop

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        double screenWidth = MediaQuery.of(context).size.width;

        return Stack(
          children: [
            Positioned(
              left: _animation.value * screenWidth -
                  screenWidth, // Moves left to right
              child: SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: Image.asset(
                  'assets/Cloud_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              left: _animation.value * screenWidth, // Second image follows
              child: SizedBox(
                width: screenWidth,
                height: screenHeight,
                child: Image.asset(
                  'assets/Cloud_bg.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
