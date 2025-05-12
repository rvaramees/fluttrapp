import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fluttr_app/presentation/pages/home.dart';

class AnimatedPlayButton extends StatefulWidget {
  final VoidCallback onTap;

  const AnimatedPlayButton({super.key, required this.onTap});

  @override
  _AnimatedPlayButtonState createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Speed of animation
    )..repeat(reverse: true); // Repeat back and forth

    _animation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value), // Move up & down
          child: child,
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
        ),
        child: ElevatedButton(
            onPressed: () {
              widget.onTap(); // Call the function passed from the parent
            },
            style: ElevatedButton.styleFrom(
              shape: CircleBorder(),
              padding: EdgeInsets.zero,
              backgroundColor: Colors.white,
            ),
            child: Image.asset('assets/play_button.png')),
      ),
    );
  }
}
