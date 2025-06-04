import 'package:flutter/material.dart';
import 'dart:math' as math;

class StartBg extends StatefulWidget {
  const StartBg({super.key});

  @override
  State<StartBg> createState() => _StartBgState();
}

class _StartBgState extends State<StartBg> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _swayAnimation1;
  late Animation<double> _swayAnimation2;

  // --- Overall Tree + Bush Position Offset ---
  final double unitVerticalOffset = -50.0; // Adjust to move units up/down

  // --- Bush Properties ---
  final String bushAsset = 'assets/bush.png';
  final double bushImageWidth = 200.0;
  final double bushImageHeight = 120.0;

  // Vertical bush offset
  final double bushVerticalOffset = 70.0;

  // --- Tree 1 (Right Side Tree) ---
  final String tree1Asset = 'assets/tree.png';
  final double tree1ImageWidth = 500.0;
  final double tree1ImageHeight = 550.0;
  final double treeVerticalAlignFactor = 0.2;
  final double tree1SwayMagnitude = 0.02;

  // --- Tree 2 (Left Side Tree) ---
  final String tree2Asset = 'assets/tree.png';
  final double tree2ImageWidth = 500.0;
  final double tree2ImageHeight = 550.0;
  final double tree2SwayMagnitude = -0.018;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _swayAnimation1 = Tween<double>(
      begin: -tree1SwayMagnitude,
      end: tree1SwayMagnitude,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutSine,
    ));

    _swayAnimation2 = Tween<double>(
      begin: -tree2SwayMagnitude,
      end: tree2SwayMagnitude,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Interval(0.1, 0.9, curve: Curves.easeInOutSine),
    ));

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildTreeAndBushUnit({
    required Animation<double> swayAnimation,
    required String treeAssetPath,
    required double currentTreeImageWidth,
    required double currentTreeImageHeight,
    required String currentBushAssetPath,
    required double currentBushImageWidth,
    required double currentBushImageHeight,
    required double unitVerticalOffset,
  }) {
    final double unitEffectiveWidth =
        math.max(currentTreeImageWidth, currentBushImageWidth);

    return SizedBox(
      width: unitEffectiveWidth,
      height: currentTreeImageHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          //1 - Sways tree image
          Positioned(
            top: unitVerticalOffset,
            left: (unitEffectiveWidth - currentTreeImageWidth) / 2,
            width: currentTreeImageWidth,
            height: currentTreeImageHeight,
            child: Transform.rotate(
              angle: swayAnimation.value,
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                treeAssetPath,
                fit: BoxFit.contain,
              ),
            ),
          ),

          //2 - Image positioned top from the last image
          Positioned(
            bottom: bushVerticalOffset, // Use the individual offset here
            left: (unitEffectiveWidth - currentBushImageWidth) / 2,
            width: currentBushImageWidth,
            height: currentBushImageHeight,
            child: Image.asset(
              currentBushAssetPath,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final double unit1EffectiveWidth =
        math.max(tree1ImageWidth, bushImageWidth);
    final double unit1EffectiveHeight = tree1ImageHeight;
    final double targetUnit1CenterY =
        (screenSize.height / 2) * (1 + treeVerticalAlignFactor);
    final double unit1TopPosition =
        targetUnit1CenterY - (unit1EffectiveHeight / 2) + unitVerticalOffset;

    final double unit2EffectiveWidth =
        math.max(tree2ImageWidth, bushImageWidth);
    final double unit2EffectiveHeight = tree2ImageHeight;
    final double targetUnit2CenterY =
        (screenSize.height / 2) * (1 + treeVerticalAlignFactor);
    final double unit2TopPosition =
        targetUnit2CenterY - (unit2EffectiveHeight / 2) + unitVerticalOffset;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/start_bg.png',
                fit: BoxFit.cover,
              ),
            ),
            Positioned(
              right: -unit1EffectiveWidth / 2,
              top: unit1TopPosition,
              width: unit1EffectiveWidth,
              height: unit1EffectiveHeight,
              child: _buildTreeAndBushUnit(
                swayAnimation: _swayAnimation1,
                treeAssetPath: tree1Asset,
                currentTreeImageWidth: tree1ImageWidth,
                currentTreeImageHeight: tree1ImageHeight,
                currentBushAssetPath: bushAsset,
                currentBushImageWidth: bushImageWidth,
                currentBushImageHeight: bushImageHeight,
                unitVerticalOffset: unitVerticalOffset,
              ),
            ),
            Positioned(
              left: -unit2EffectiveWidth / 2,
              top: unit2TopPosition,
              width: unit2EffectiveWidth,
              height: unit2EffectiveHeight,
              child: _buildTreeAndBushUnit(
                swayAnimation: _swayAnimation2,
                treeAssetPath: tree2Asset,
                currentTreeImageWidth: tree2ImageWidth,
                currentTreeImageHeight: tree2ImageHeight,
                currentBushAssetPath: bushAsset,
                currentBushImageWidth: bushImageWidth,
                currentBushImageHeight: bushImageHeight,
                unitVerticalOffset: unitVerticalOffset,
              ),
            ),
          ],
        );
      },
    );
  }
}
