import 'package:flutter/material.dart';

class SpriteSheetAnimation extends StatefulWidget {
  final String imagePath;
  final int frameCount;
  final int framesPerRow;
  final Duration frameDuration;
  final double width;
  final double height;

  const SpriteSheetAnimation({
    Key? key,
    required this.imagePath,
    required this.frameCount,
    required this.framesPerRow,
    required this.frameDuration,
    this.width = 50,
    this.height = 50,
  }) : super(key: key);

  @override
  _SpriteSheetAnimationState createState() => _SpriteSheetAnimationState();
}

class _SpriteSheetAnimationState extends State<SpriteSheetAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.frameDuration,
    )..repeat(); // Repeat indefinitely

    _animation =
        IntTween(begin: 0, end: widget.frameCount - 1).animate(_controller);
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
        final frameIndex = _animation.value;
        final row = frameIndex ~/ widget.framesPerRow;
        final col = frameIndex % widget.framesPerRow;

        final int rowCount = (widget.frameCount + widget.framesPerRow - 1) ~/
            widget.framesPerRow; // Calculate number of rows
        return SizedBox(
          width: widget.width,
          height: widget.height,
          child: FittedBox(
            // Important for scaling the sprite
            fit: BoxFit.fill, // Fill the available space
            child: ClipRect(
              child: Align(
                alignment: Alignment(
                    widget.framesPerRow > 1
                        ? -1.0 + (2.0 * col / (widget.framesPerRow - 1))
                        : 0.0, // horizontal
                    rowCount > 1
                        ? -1.0 + (2.0 * row / (rowCount - 1))
                        : 0.0 // vertical
                    ),
                widthFactor: 1 / widget.framesPerRow,
                heightFactor: 1 / rowCount,
                child: Image.asset(widget.imagePath),
              ),
            ),
          ),
        );
      },
    );
  }
}
