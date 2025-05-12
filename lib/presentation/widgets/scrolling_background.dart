import 'package:flutter/material.dart';

class ScrollingBackground extends StatefulWidget {
  const ScrollingBackground({super.key});

  @override
  _ScrollingBackgroundState createState() => _ScrollingBackgroundState();
}

class _ScrollingBackgroundState extends State<ScrollingBackground>
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
        return Stack(
          children: [
            Positioned(
              top: _animation.value * screenHeight - screenHeight,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: screenHeight,
                child: Image.asset(
                  'assets/home_bg.png', // Your background image
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              top: _animation.value * screenHeight,
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: screenHeight,
                child: Image.asset(
                  'assets/home_bg.png', // Second copy of the image
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
